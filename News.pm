package WWW::Google::News;

use strict;
use warnings;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_news get_news_greg_style get_news_for_topic);
our $VERSION   = '0.06';

use Carp;
use LWP;
use URI::Escape;

sub get_news {
  my $url = 'http://news.google.com/news/gnmainlite.html';
  my $ua = LWP::UserAgent->new;
  my $response = $ua->get($url);
  my $results = {};

  return unless $response->is_success;

  #print STDERR "\n",length($response->content)," bytes \n";

  my $re1 =  '<TD nowrap bgcolor=#efefef>\s*<B>&nbsp;(.*?)</B>\s*</TD>';
  my $re2 =  '<BR>\s*<a class=y href="(.*?)">(.*?)</a><BR>';

  my @sections = split /($re1)/m,$response->content;
  my $current_section = '';
  foreach my $section (@sections) {
    if ($section =~ m/$re1/m) {
      $current_section = $1;
      #print STDERR $1,"\n";
    } else {
      my @stories = split /($re2)/mi,$section;
      foreach my $story (@stories) {
        if ($story =~ m/$re2/mi) {
          if (!(exists($results->{$current_section}))) {
            $results->{$current_section} = [];
          }
          my $story_h = {};
          $story_h->{url} = $1;
          $story_h->{headline} = $2;
          push(@{$results->{$current_section}},$story_h);
        }
      }
    }
  }
  #print STDERR Dumper($results);
  return $results;
}


sub get_news_greg_style {
  my $results = get_news();
  my $greg_results = {};
  foreach my $section (keys(%$results)) {
    $greg_results->{$section} = {};
    my $cnt = 0;
    foreach my $story_h (@{$results->{$section}}) {
      $cnt++;
      $greg_results->{$section}->{$cnt} = $story_h;
    }
  }
  return $greg_results;
}

sub get_news_for_topic {

	my $topic = uri_escape( $_[0] );

	my @results = ();
	my $url = "http://news.google.com/news?hl=en&edition=us&q=$topic";
	my $ua = LWP::UserAgent->new();
	$ua->agent('Mozilla/5.0');

	my $response = $ua->get($url);
	return unless $response->is_success;

	my $re1 = '<br><div>(.+)<.*br></div>';
	my $re2 =  '<a href=(.*?)>(.*?)</a><br><font size=[^>]+><font color=[^>]+>([^<]*?)</font>([^<]*?)</font><br><font size=[^>]+>\s*<b>...</b>\s*(.*?)</font>';

	my( $section ) = ( $response->content =~ m/$re1/s );
	$section =~ s/\n//g;
	my @stories = split /($re2)/mi,$section;

	foreach my $story (@stories) {
		if ($story =~ m/$re2/i) {
			my $story_h = {};
                
			my( $url, $headline, $source, $date, $summary ) = ( $1, $2, $3, $4, $5 );
			$source =~ s/&nbsp;/ /g;
			$source =~ s/\s+/ /g;
			$date =~ s/&nbsp;/ /g;
			$date =~ s/\s+/ /g;
			$date =~ s/-//g;
			#$summary = $hs->parse($summary); $hs->eof;
			$summary =~ s#<br># #gi;
			$summary =~ s#<.+?>##gi;
        
			$story_h->{url} = $url;
			$story_h->{headline} = $headline;
			$story_h->{source} = $source;
			$story_h->{date} = $date;
			$story_h->{description} = "$source: $summary";

			push(@results,$story_h);

		}
	}

	return \@results;

}

1;

__END__

=head1 NAME

WWW::Google::News - Access to Google's News Service (Not Usenet)

=head1 SYNOPSIS

  use WWW:Google::News qw(get_news);
  my $results = get_news();
  
  my $results = get_news_for_topic('impending asteriod impact');

=head1 DESCRIPTION

This module provides a couple of methods to scrape results from Google News, returning 
a data structure similar to the following (which happens to be suitable to feeding into XML::RSS).

  {
    'Top Stories' =>
              [
               {
                 'url' => 'http://www.washingtonpost.com/wp-dyn/articles/A9707-2002Nov19.html',
                 'headline' => 'Amendment to Homeland Security Bill Defeated'
               },
               {
                 'url' => 'http://www.ananova.com/news/story/sm_712444.html',
                 'headline' => 'US and UN at odds as Iraq promises to meet deadline'
               }
              ],
    'Entertainment' =>
             [
              {
                'url' => 'http://abcnews.go.com/sections/entertainment/DailyNews/Coburn021119.html',
                'headline' => 'James Coburn Dies'
              },
              {
                'url' => 'http://www.cbsnews.com/stories/2002/11/15/entertainment/main529532.shtml',
                'headline' => '007s On Parade At \'Die\' Premiere'
              }
             ]
   }

=head1 METHODS

=over 4

=item get_news()

Scrapes L<http://news.google.com/news/gnmainlite.html> and returns a reference 
to a hash keyed on News Section, which points to an array of hashes keyed on URL and Headline.

=item get_news_for_topic( $topic )

Queries L<http://news.google.com/news> for results on a particular topic, 
and returns a pointer to an array of hashes containing result data. 

An RSS feed can be constructed from this very easily:

	use WWW::Google::News;
	use XML::RSS;

	$results = get_news_for_topic( $topic )
	my $rss = XML::RSS->new;
	$rss->channel(title => "Google News -- $topic");
	for (@{$news}) {
                $rss->add_item(
                        title => $_->{headline},
                        link  => $_->{url},
                        description  => $_->{description},
                );
        }
        print $rss->as_string;

=item get_news_greg_style()

It also provides a method called get_news_greg_style() which returns the same data, only
using a hash keyed on story number instead of the array described in the above.

=head1 TODO

* Implement an example RSS feed. -- Done, see above

* Seek out a good psychologist so we can work through Greg's obsession with hashes.

=head1 AUTHORS

Greg McCarroll <greg@mccarroll.demon.co.uk>, Bowen Dwelle <bowen@dwelle.org>

=head1 KUDOS

Darren Chamberlain for rss_alternate.pl

Leon Brocard for pulling me up on my obsessive compulsion to use
hashes.

=head1 SEE ALSO

L<http://news.google.com/>
L<http://news.google.com/news/gnmainlite.html>

=cut

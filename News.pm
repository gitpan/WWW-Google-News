package WWW::Google::News;

use strict;
use warnings;

#use Data::Dumper;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_news get_news_greg_style);
our $VERSION   = '0.04';

use LWP;
use Carp;

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

1;

__END__

=head1 NAME

WWW::Google::News - Access to Google's News Service (Not Usenet)

=head1 SYNOPSIS

  use WWW:Google::News qw(get_news);
  my $result = get_news();

=head1 DESCRIPTION

This module provides one method get_news() which scren scrapes Google News and returns
a data structure similar to ...

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

Which is a reference to a hash keyed on News Section, which points to
an array of hashes keyed on URL and Headline.

It also provides a method called get_news_greg_style() which returns the same data, only
using a hash keyed on story number instead of the array described in the above.

=head1 TODO

* Implement an example RSS feed.

* Seek out a good psychologist so we can work through my obsession
  with hashes.

=head1 AUTHOR

Greg McCarroll <greg@mccarroll.demon.co.uk>

=head1 KUDOS

Darren Chamberlain for rss_alternate.pl

Leon Brocard for pulling me up on my obsessive compulsion to use
hashes.

=head1 SEE ALSO

L<http://http://news.google.com/news/gnmainlite.html>

=cut

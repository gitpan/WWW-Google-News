package WWW::Google::News;

use 5.006;
use strict;
use warnings;

#use Data::Dumper;

require Exporter;

our @ISA       = qw(Exporter);
our @EXPORT_OK = qw(get_news);
our $VERSION   = '0.01';

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
      my $cnt = 0;
      foreach my $story (@stories) {

        if ($story =~ m/$re2/mi) {
          $cnt++;
          if (!(exists($results->{$current_section}))) {
            $results->{$current_section} = {};
          }
          $results->{$current_section}->{$cnt}->{url} = $1;
          $results->{$current_section}->{$cnt}->{headline} = $2;
        }
      }
    }
  }
  #print STDERR Dumper($results);
  return $results;
}

1;

__END__

=head1 NAME

WWW::Google::News

=head1 SYNOPSIS

  use WWW:Google::News qw(get_news);

  my $result = get_news();

=head1 DESCRIPTION

This module provides one method get_news() which scren scrapes Google News and returns
a data structure similar to ...

  {
    'Top Stories' => {
              '1' => {
                 'url' => 'http://www.washingtonpost.com/wp-dyn/articles/A9707-2002Nov19.html',
                 'headline' => 'Amendment to Homeland Security Bill Defeated'
              }
              '2' => {
                 'url' => 'http://www.ananova.com/news/story/sm_712444.html',
                 'headline' => 'US and UN at odds as Iraq promises to meet deadline'
               }
            },
    'Entertainment' => {
             '1' => {
                'url' => 'http://abcnews.go.com/sections/entertainment/DailyNews/Coburn021119.html',
                'headline' => 'James Coburn Dies'
              },
             '2' => {
                'url' => 'http://www.cbsnews.com/stories/2002/11/15/entertainment/main529532.shtml',
                'headline' => '007s On Parade At \'Die\' Premiere'
              }
           },
   }

Which is a reference to a hash keyed on News Section, which points to hashes keyed on Story Number,
which points finally to a hash keyed on URL and Headline.

=head1 AUTHOR

Greg McCarroll <greg@mccarroll.demon.co.uk>

=head1 SEE ALSO

L<http://http://news.google.com/news/gnmainlite.html>

=cut

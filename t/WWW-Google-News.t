#!perl
use strict;
use Test::More tests => 13;

BEGIN { use_ok('WWW::Google::News',qw(get_news get_news_greg_style)); }

my $results;

$results = get_news_greg_style();

#use Data::Dumper;
#print STDERR "\n",Dumper($results);
#exit;


ok(defined($results),'GNGS: At least we got something');

ok(exists($results->{'Top Stories'}),'GNGS: Top Stories Exists');
ok(keys(%{$results->{'Top Stories'}}),'GNGS: Top Stories Is Not Empty');
ok(exists($results->{'Top Stories'}->{1}),'GNGS: Top Stories Story 1 Exists');
ok(exists($results->{'Top Stories'}->{1}->{url}),'GNGS: Top Stories Story 1 URL Exists');
ok(exists($results->{'Top Stories'}->{1}->{headline}),'GNGS: Top Stories Story 1 Headline Exists');


$results = get_news();

#use Data::Dumper;
#print STDERR "\n",Dumper($results);


ok(defined($results),'GN: At least we got something');

ok(exists($results->{'Top Stories'}),'GN: Top Stories Exists');
ok(keys(%{$results->{'Top Stories'}}),'GN: Top Stories Is Not Empty');
ok(exists(${$results->{'Top Stories'}}[0]),'GN: Top Stories Story 1 Exists');
ok(exists(${$results->{'Top Stories'}}[0]->{url}),'GN: Top Stories Story 1 URL Exists');
ok(exists(${$results->{'Top Stories'}}[0]->{headline}),'GN: Top Stories Story 1 Headline Exists');

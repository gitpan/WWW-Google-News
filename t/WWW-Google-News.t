#!perl
use strict;
use Test::More tests => 7;

BEGIN { use_ok('WWW::Google::News',qw(get_news)); }

my $results = get_news();

ok(defined($results),'At least we got something');

ok(exists($results->{'Top Stories'}),'Top Stories Exists');
ok(keys(%{$results->{'Top Stories'}}),'Top Stories Is Not Empty');
ok(exists($results->{'Top Stories'}->{1}),'Top Stories Story 1 Exists');
ok(exists($results->{'Top Stories'}->{1}->{url}),'Top Stories Story 1 URL Exists');
ok(exists($results->{'Top Stories'}->{1}->{headline}),'Top Stories Story 1 Headline Exists');

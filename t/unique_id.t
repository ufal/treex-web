#!/usr/bin/env perl
use strict;
use warnings;
use Test::More tests => 2;

# test if we have Data::Uniqid available and if it works
BEGIN { use_ok('Data::Uniqid') }

my $word1 = Data::Uniqid::luniqid;
my $word2 = Data::Uniqid::luniqid;

isnt($word1, $word2, "word1 '$word1' ne word2 '$word2'");

done_testing();

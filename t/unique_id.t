#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

# test if we have Data::TUID available and if it works
BEGIN { use_ok('Data::TUID') }

my $word1 = lc(Data::TUID::tuid length => -1);
my $word2 = lc(Data::TUID::tuid length => -1);

isnt($word1, $word2, "word1 '$word1' ne word2 '$word2'");

done_testing();

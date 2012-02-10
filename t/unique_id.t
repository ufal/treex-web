#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

# test if we have Data::GUID available and if it works
BEGIN { use_ok('Data::GUID') }

my $word1 = Data::GUID->new()->as_base64();
my $word2 = Data::GUID->new()->as_base64();

isnt($word1, $word2, "word1 '$word1' ne word2 '$word2'");

done_testing();

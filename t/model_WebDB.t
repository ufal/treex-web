#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

use Catalyst::Test 'Treex::Web';

BEGIN {use_ok 'Treex::Web';}

my $result_rs = Treex::Web->model('TreexDB::Result');

my $new_r1 = $result_rs->new;
my $new_r2 = $result_rs->new;

ok( $new_r1->hash and $new_r1->hash ne '', 'Result hash 1 ok' );
ok( $new_r2->hash and $new_r2->hash ne '', 'Result hash 2 ok' );
isnt( $new_r1->hash, $new_r2->hash, 'Hashes are different' );

done_testing();

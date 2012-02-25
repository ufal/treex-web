#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use DBICx::TestDatabase;

BEGIN { use_ok('Treex::Web::DB'); }

my $schema = DBICx::TestDatabase->new('Treex::Web::DB');

ok($schema, 'DB test schema is ok');

my $result_rs = $schema->resultset('Result');

ok($result_rs, 'Result set is ok');

my $new_r1 = $result_rs->create({ name => 'r1', scenario => '' });
my $new_r2 = $result_rs->create({ name => 'r2', scenario => '' });

isnt( $new_r1->hash, $new_r2->hash, 'Hashes are different' );

done_testing();

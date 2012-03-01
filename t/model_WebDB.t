#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;
use DBICx::TestDatabase;

BEGIN { use_ok('Treex::Web::DB'); }

my $schema = DBICx::TestDatabase->new('Treex::Web::DB');

ok($schema, 'DB test schema is ok');

### Test Result here
my $result_rs = $schema->resultset('Result');

ok($result_rs, 'Result rs is ok');

my $new_r1 = $result_rs->create({ name => 'r1', scenario => '' });
my $new_r2 = $result_rs->create({ name => 'r2', scenario => '' });

isnt( $new_r1->hash, $new_r2->hash, 'Hashes are different' );

$new_r1->delete;
$new_r2->delete;

### Test Scenario here
my $scenario_rs = $schema->resultset('Scenario');
ok($scenario_rs, 'Scenario rs is ok');

my $scenario_data = { name => 'scenario1', scenario => 'This is test' };

my $new_scenario = $scenario_rs->create($scenario_data);

ok( $new_scenario->in_storage, 'New scenario created' );

my $fail_scenario = 0;
eval {
    $fail_scenario = $scenario_rs->create($scenario_data);
};

ok( !$fail_scenario || !$fail_scenario->in_storage, 'Creating scenarion with the same name should fail');

done_testing();

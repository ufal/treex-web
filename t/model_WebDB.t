#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;

BEGIN {
    $ENV{ TREEX_WEB_CONFIG_LOCAL_SUFFIX } = 'test';
}

use Treex::Web;

### Test Result here
# my $result_rs = Treex::Web->model('WebDB::Result');

# ok($result_rs, 'Result rs is ok');

# my $new_r1 = $result_rs->create({ name => 'r1'});
# my $new_r2 = $result_rs->create({ name => 'r2'});

# isnt( $new_r1->unique_token, $new_r2->unique_token, 'Tokens are different' );

# $new_r1->delete;
# $new_r2->delete;

### Test Scenario here
my $scenario_rs = Treex::Web->model('WebDB::Scenario');
ok($scenario_rs, 'Scenario rs is ok');

my $scenario_data = {
    name => 'scenario1',
    scenario => 'This is test',
    public => 1
};

my $new_scenario = $scenario_rs->create($scenario_data);

ok( $new_scenario->in_storage, 'New scenario created' );

# my $fail_scenario = 0;
# eval {
#     $fail_scenario = $scenario_rs->create($scenario_data);
# };

# ok( !$fail_scenario || !$fail_scenario->in_storage, 'Creating scenarion with the same name should fail');

done_testing();

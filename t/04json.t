#!/usr/bin/perl -Iblib/lib -Iblib/arch -I../blib/lib -I../blib/arch
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 04json.t'

# Test file created outside of h2xs framework.
# Run this like so: `perl 04json.t'
#   Michal Sedlak <sedlakmichal@gmail.com>     2013/04/22 10:47:42

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use Test::More qw( no_plan );

use boolean;
use Data::Rmap qw(:all);
use Data::Clone qw/clone/;
use JSON;

my $json = <<JS;
{"false_value":false,"some_array":[],"true_val":true,"int_val":1}
JS

my $expected_json = {
    false_value => 'false',
    some_array => [],
    true_val => 'true',
    int_val => 1
};

my $data_decoded = from_json($json);
is_deeply($data_decoded, $expected_json, "JSON decoded OK");

my $data_cloned;
eval {
    $data_cloned = clone($data_decoded);
};
ok($@, 'Got cloning error');

rmap_all { $_ = $_ ? true : false if JSON::is_bool($_) } $data_decoded;
$data_cloned = clone($data_decoded);

my $expected_clone = {
    false_value => 0,
    some_array => [],
    true_val => 1,
    int_val => 1
};

is_deeply($data_cloned, $expected_clone, "Clone as expected");
my $jsoned = to_json($data_cloned, { convert_blessed => 1 });
is_deeply(from_json($jsoned), from_json($json), "Cloned json match");

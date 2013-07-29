#!/usr/bin/perl -Iblib/lib -Iblib/arch -I../blib/lib -I../blib/arch
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl scenario_sanitize.t'

# Test file created outside of h2xs framework.
# Run this like so: `perl scenario_sanitize.t'
#   Michal Sedlak <sedlakmichal@gmail.com>     2013/07/29 01:09:39

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;
use Test::More;

BEGIN {
    $ENV{ TREEX_WEB_CONFIG_LOCAL_SUFFIX } = 'test';
}

use Treex::Web;

my $result_rs = Treex::Web->model('WebDB::Result');
ok($result_rs, 'Model is ok');
is($result_rs->count, 0, 'DB is empty');

my $result = $result_rs->new_result({
    input_type => 'treex'
});

my $scenario = <<'SCEN';
Util::SetGlobal language=und
Read::Treex
Arbitrary::Block
Arbitrary::Block1
Write::Treex
Arbitrary::Block2
SCEN

is( $scenario, $result->_sanitize_scenario($scenario), 'Sanitize has no effect' );

my $scenario2 = <<'SCEN';
Util::SetGlobal language=und
Read::Treex from='asdf' param=asdfsadf
Arbitrary::Block
Arbitrary::Block1
Write::Treex to=blab blab='sadf1222'
Arbitrary::Block2
SCEN

my $scenario3 = <<'SCEN';
Util::SetGlobal language=und
Read::Treex from=input.treex
Arbitrary::Block
Arbitrary::Block1
Write::Treex to=result.treex
Arbitrary::Block2
SCEN

is( $scenario, $result->_sanitize_scenario($scenario2), 'Remove all params' );
is( $scenario3, $result->_inject_scenario($scenario2), 'Inject scenario with params');

my ($type) = 'input.treex.gz' =~ /\.(\w+?(?:\.gz)?)$/;
#diag("Type is: $type");
is( 'treex.gz', $type, 'Extraction pattern works');


done_testing();

use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Treex::Web';
use Treex::Web::Controller::Query;

ok( request('/query')->is_success, 'Request should succeed' );
done_testing();

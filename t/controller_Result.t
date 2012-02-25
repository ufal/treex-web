use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Treex::Web';
use Treex::Web::Controller::Result;

ok( request('/result')->is_success, 'Request should succeed' );
done_testing();

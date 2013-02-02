use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Treex::Web';
use Treex::Web::Controller::Result::Download;

ok( request('/result/download')->is_success, 'Request should succeed' );
done_testing();

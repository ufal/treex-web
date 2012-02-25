#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Treex::Web';
use Treex::Web::Controller::Auth;

ok( request('/auth')->is_success, 'Request should succeed' );
done_testing();

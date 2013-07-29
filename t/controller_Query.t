#!/usr/bin/env perl
use strict;
use warnings;
use Test::More;


use Catalyst::Test 'Treex::Web';
use Treex::Web::Controller::Query;

my ($res, $c) = ctx_request('/query');

ok( $res->is_success, 'Request should succeed' );
done_testing();

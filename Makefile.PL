#!/usr/bin/env perl
# IMPORTANT: if you delete this file your app will not work as
# expected.  You have been warned.
use inc::Module::Install 1.02;
use Module::Install::Catalyst; # Complain loudly if you don't have
# Catalyst::Devel installed or haven't said
                               # 'make dist' to create a standalone tarball.

name 'Treex-Web';
all_from 'lib/Treex/Web.pm';

requires 'Catalyst::Runtime' => '5.90007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Action::RenderView';
requires 'Moose';
requires 'namespace::autoclean';
requires 'Config::General'; # This should reflect the config file format you've chosen
                 # See Catalyst::Plugin::ConfigLoader for supported forma
requires 'Catalyst::View::TT';
requires 'Catalyst::Plugin::I18N';
requires 'Catalyst::Plugin::Unicode';

# DB stuff
requires 'Catalyst::Model::DBIC::Schema';
requires 'DBIx::Class::TimeStamp';
requires 'DBIx::Class::UUIDColumns';
requires 'SQL::Translator';
requires 'Email::Valid'; # used to check user mails
requires 'Data::Uniqid'; # used to generate UUID Columns

# Auth stuff
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Plugin::Authorization::Roles';
#requires 'Catalyst::Plugin::Session::State::Cookie';
#requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'Catalyst::Plugin::CookiedSession';

# HTML::FormHandler
requires 'HTML::FormHandler';

# misc
requires 'Catalyst::Plugin::Assets';
requires 'IPC::Run'; # used to run treex command

test_requires 'Test::More' => '0.88';
test_requires 'DBICx::TestDatabase';
catalyst;

install_script glob('script/*.pl');
auto_install;
WriteAll;

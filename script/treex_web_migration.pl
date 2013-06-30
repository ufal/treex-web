#!/usr/bin/perl
# treex_web_migration.pl --- Tool to create and manage your migrations for Treex::Web
# Author: Michal Sedlak <sedlakmichal@gmail.com>
# Created: 02 Mar 2012
# Version: 0.01

use warnings;
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use Treex::Web;
use DBIx::Class::Migration::Script;

DBIx::Class::Migration::Script
    ->run_with_options(
        schema => Treex::Web->model('WebDB')->schema,
        databases => ['MySQL', 'SQLite', 'PostgreSQL'],
    );

__END__

=head1 NAME

treex_web_migration.pl - Describe the usage of script briefly

=head1 SYNOPSIS

treex_web_migration.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for treex_web_migration.pl,

=head1 AUTHOR

Michal Sedlak, E<lt>sedlakmichal@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

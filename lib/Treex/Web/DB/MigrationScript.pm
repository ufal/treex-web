package Treex::Web::DB::MigrationScript;

use strict;
use warnings;
use Moose;
use Treex::Web;

extends 'DBIx::Class::Migration::Script';

=head1 NAME

Treex::Web::DB::MigrationScript

=head1 DESCRIPTION

Sets defaults for the L<DBIx::Class::Migration::Script>

=head1 METHODS

=cut

=head2 defaults

Defaults override. Sets schema with Treex::Web configuration

=cut

sub defaults {
    schema => Treex::Web->model('WebDB')->schema;
}

__PACKAGE__->meta->make_immutable;
__PACKAGE__->run_if_script;

1;
__END__

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

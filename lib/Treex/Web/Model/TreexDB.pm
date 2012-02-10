package Treex::Web::Model::TreexDB;

use strict;
use base 'Catalyst::Model::DBIC::Schema';

__PACKAGE__->config(
    schema_class => 'Treex::Web::DB',
                    
    connect_info => {
        dsn => 'dbi:SQLite:db/treex.db',
        user => '',
        password => '',
    }
);

=head1 NAME

Treex::Web::Model::TreexDB - Catalyst DBIC Schema Model

=head1 SYNOPSIS

See L<Treex::Web>

=head1 DESCRIPTION

L<Catalyst::Model::DBIC::Schema> Model using schema L<Treex::Web::DB>

=head1 AUTHOR

Michal Sedlák

=head1 LICENSE

This library is free software, you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

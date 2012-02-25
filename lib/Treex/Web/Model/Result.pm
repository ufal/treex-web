package Treex::Web::Model::Result;
use Moose;
use Data::TUID;
use namespace::autoclean -except => 'meta';
extends 'Catalyst::Model';

=head1 NAME

Treex::Web::Model::Result - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=cut

=head2 create_hash

=cut

sub create_hash {
    Data::TUID::tuid length => -1;
}

=head1 AUTHOR

Michal Sedlák

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

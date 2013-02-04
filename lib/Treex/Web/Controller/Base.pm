package Treex::Web::Controller::Base;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Treex::Web::Controller::Base - Catalyst Controller

=head1 DESCRIPTION

Base Treex::Web Controller.

=head1 FIELDS

=cut

=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

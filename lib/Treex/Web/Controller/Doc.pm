package Treex::Web::Controller::Doc;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Treex::Web::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::Doc

=head1 DESCRIPTION

Catalyst Controller for serving Swagger documentation.

=head1 METHODS

=cut

__PACKAGE__->api->resource_path('/doc');

=head2 base

Sets base path according to current request

=cut

sub base :Chained('/') :PathPart('') :CaptureArgs(0)  {
    my ( $self, $c ) = @_;

    __PACKAGE__->api->base_path($c->uri_for('/')->as_string);
}

=head2 index

Returns list of resources

=over

=item index_GET

=back

=cut

sub index :Chained('base') :PathPart(doc) :Args(0) :ActionClass('REST') { }

sub index_GET {
    my ( $self, $c ) = @_;

    $self->status_ok($c, entity => __PACKAGE__->api->resource_listing );
}

=head2 listing

Returns listing of each api

=over

=item listing_GET

=back

=cut

sub listing :Chained('base') :PathPart(doc) Args(1) :ActionClass('REST') { }

sub listing_GET {
    my ( $self, $c, $path ) = @_;

    $self->status_ok($c, entity => __PACKAGE__->api->api_listing($path));
}


=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

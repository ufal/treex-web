package Treex::Web::Controller::Root;
use Moose;
use Treex::Web::Forms::QueryForm;
use namespace::autoclean;

BEGIN { extends 'Treex::Web::Controller::Base' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Treex::Web::Controller::Root - Root Controller for Treex::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Forms::QueryForm->new(
        action => $c->uri_for($c->controller('Query')->action_for('index')),
    );

    $c->stash(
        query_form => $form
    );
}

=head2 auto

=cut

sub auto :Path {
    my ( $self, $c ) = @_;

    my $results_rs = $c->model('WebDB::Result')
        ->search_rs(
            {($c->user_exists ? (user => $c->user->id) : (user => undef))},
            { order_by => { -desc => 'last_modified' } });
    $c->stash(results_rs => $results_rs);
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
    my ( $self, $c ) = @_;
    $c->response->body( 'Page not found' );
    $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

THC,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

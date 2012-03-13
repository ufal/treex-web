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

    $form->defaults({
        input => 'This is a test text.',
        scenario => 's'
    });
    
    $c->stash(
        queryForm => $form
    );
}

=head2 auto

=cut

sub auto :Path {
    my ( $self, $c ) = @_;
    
    $c->stash(
        treex_version => $Treex::Web::VERSION,
        menu => [
            { name => 'Dashboard', url => $c->uri_for($c->controller('Root')->action_for('index')) },
            { name => 'My Results', url => $c->uri_for($c->controller('Result')->action_for('index')) },
            { name => 'Scenarios', url => $c->uri_for($c->controller('Scenario')->action_for('index')) }
        ]
           );
    
    #
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

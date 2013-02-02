package Treex::Web::Controller::Login;
use Moose;
use Treex::Web::Forms::LoginForm;
use Treex::Web::Forms::SignupForm;
use namespace::autoclean;

BEGIN {extends 'CatalystX::SimpleLogin::Controller::Login';}

=head1 NAME

Treex::Web::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 ATTRIBUTES

=cut

has '+login_form_class' => (
    default => 'Treex::Web::Forms::LoginForm',
);

=head1 METHODS

=cut

=head2 login

=cut

after 'login' => sub {
    my ( $self, $c ) = @_;

    $c->stash( template => 'auth/login.tt2' );
};


sub signup :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Forms::SignupForm->new(
        action => $c->uri_for($self->action_for('signup')),
        schema => $c->model('WebDB')->schema,
    );

    if ( $c->req->method eq 'POST' && $form->process(params => $c->req->parameters)) {
        my $user = $form->item;
        $c->flash->{status_msg} = "Your account has been successully created. Check your mailbox for the activation email.";
        $c->stash( user => $user );
    }

    $c->stash( signupForm => $form, template => 'auth/signup.tt2' );
}

sub logout :Local :Args(0) {
    my ( $self, $c ) = @_;

    $c->flash->{status_msg} = "You have been successfully logged out."
        if $c->user_exists && $c->logout;
    $c->response->redirect($c->uri_for($c->controller('Root')->action_for('index')));
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

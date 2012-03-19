package Treex::Web::Controller::Auth;
use Moose;
use Treex::Web::Forms::LoginForm;
use Treex::Web::Forms::SignupForm;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::Base'; }

=head1 NAME

Treex::Web::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 login

=cut

sub login :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Forms::LoginForm->new(
        action => $c->uri_for($self->action_for('login')),
    );
    
    if ( $c->req->method eq 'POST' && $form->process(params => $c->req->parameters) ) {
        my $params = $form->value;
        if ($c->authenticate({
            password => $params->{password},
            email => $params->{email},
        })) {
            $c->flash->{status_msg} = "You have beed successfully logged in.";
            $c->response->redirect($c->uri_for($c->controller('Root')->action_for('index')));
        } else {
            $c->flash->{error_msg} = "Login has failed! Check your username and password";
        }
    }
    
    $c->stash( loginForm => $form, template => 'auth/login.tt' );
}

sub signup :Local :Args(0) {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Forms::SignupForm->new(
        action => $c->uri_for($self->action_for('signup'))
    );

    if ( $c->req->method eq 'POST' && $form->process(params => $c->req->parameters)) {
        
    }
    
    $c->stash( signupForm => $form, template => 'auth/signup.tt' )
}

sub logout :Local :Args(0) {
    my ( $self, $c ) = @_;
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

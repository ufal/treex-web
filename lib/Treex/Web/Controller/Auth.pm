package Treex::Web::Controller::Auth;

use Moose;
use Treex::Web::Form::Login;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::Auth - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

has login_form => (
    isa => 'Object',
    is => 'ro',
    lazy_build => 1,
);

sub _build_login_form {
    my $self = shift;
    return Treex::Web::Form::Login->new();
}


sub index :Path :Args(0) :ActionClass('REST') { }

sub index_GET {
    my ( $self, $c ) = @_;
    if ($c->user_exists) {
        $self->status_ok($c, entity => { session => 1 });
    } else {
        $self->status_not_found($c, message => 'User in not logged in');
    }
}

sub index_POST {
    my ( $self, $c ) = @_;
    my $form = $self->login_form;
    my $p = $c->req->parameters;

    if( $form->process(ctx => $c, params => $p) ) {
        # TODO: This is security threat, session should be replaced
        # after login to make session stealing impossible
        $c->extend_session_expires(999999999999)
            if $form->field( 'remember' )->value;
        $self->status_ok( $c, entity => $c->user->REST );
    } else {
        $self->status_bad_request( $c, message => join "\n", $form->errors )
    }
}

sub index_DELETE {
    my ( $self, $c ) = @_;

    $c->logout;
    $c->delete_session;
    $self->status_no_content( $c );
}

=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

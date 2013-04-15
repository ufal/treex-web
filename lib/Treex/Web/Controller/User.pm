package Treex::Web::Controller::User;
use Moose;
use Email::Valid;
use Treex::Web::Form::Signup;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

has signup_form => (
    isa => 'Object',
    is => 'ro',
    lazy_build => 1,
);

sub _build_signup_form {
    my $self = shift;
    return Treex::Web::Form::Signup->new();
}

=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Treex::Web::Controller::User in User.');
}

sub email_available :Path('email-available') :Args(0) :ActionClass('REST') { }

sub email_available_GET {
    my ( $self, $c ) = @_;

    my $email = $c->req->parameters->{email};
    unless (Email::Valid->address($email)) {
        $self->status_bad_request($c, message => 'Email is invalid');
        return;
    }

    $self->status_ok($c, entity => {
        available => $c->model('WebDB::User')->is_email_available($email) ? 1 : 0
    });
}

sub signup :Local :Args(0) :ActionClass('REST') { }

sub signup_POST {
    my ( $self, $c ) = @_;

    my $form = $self->signup_form;
    #my $new_user = $c->model('WebDB::User')->new_result({});
    if( $form->process(
        ctx => $c,
        schema => $c->model('WebDB')->schema,
        params => $c->req->parameters) ) {
        $self->status_ok( $c, entity => $form->item->REST );
    } else {
        $self->status_bad_request( $c, message => join "\n", $form->errors )
    }

}


=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

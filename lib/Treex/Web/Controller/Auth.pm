package Treex::Web::Controller::Auth;

use Moose;
use Treex::Web::Form::Login;
use List::Util qw(first);
use boolean;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::REST'; }

my $auth_resource = __PACKAGE__->api_resource(
    path => 'auth'
);

__PACKAGE__->api_model(
    'LoginPayload',
    email => {
        type => 'string',
        required => 1,
        description => 'User email'
    },
    password => {
        type => 'string',
        required => 1,
        description => 'User password'
    },
    remember => {
        type => 'boolean',
        description => 'Flag whether to remmember the session or not'
    }
);

=head1 NAME

Treex::Web::Controller::Auth - Authentication

=head1 DESCRIPTION

Catalyst Restful Controller.

=head1 METHODS

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

=head2 index

REST base for all CRUD methods

=over 2

=item index_GET

=item index_POST

=item index_DELETE

=back

=cut

my $index_api = $auth_resource->api(
    controller => __PACKAGE__,
    action => 'index',
    path => '/auth',
    description => 'User authentication',
);

sub index :Path :Args(0) :ActionClass('REST') { }

$index_api->get(
    summary  => 'Check for whether the session exists',
    notes    => "If the session cookie is missing or the session doesn't exists \
 request ends up with the 404 error. NOTE: The documentation on this item is broken.",
    response => 'User',
    nickname => 'sessionCheck',
    params   => [
        __PACKAGE__->api_param(
            param => 'header',
            name => 'Cookie',
            description => 'Session cookie',
            type => 'string',
            required => 1
        )
    ],
    errors   => [ __PACKAGE__->api_error('not_found', 404, 'User is not logged in') ]
);

sub index_GET {
    my ( $self, $c ) = @_;
    if ($c->user_exists && $c->user) {
        $self->status_ok($c, entity => $c->user->REST);
    } else {
        $self->status_error($c, $index_api->error('not_found'));
    }
}

$index_api->post(
    summary  => 'Provides user login',
    notes    => 'Simple user login action',
    response => 'User',
    nickname => 'login',
    params   => [
        __PACKAGE__->api_param_body('LoginPayload', 'Login object for authentication', 'Login data'),
    ],
    errors   => [ __PACKAGE__->api_error('login_failed', 400, 'Invalid email or password') ]
);

sub index_POST {
    my ( $self, $c ) = @_;
    my $form = $self->login_form;

    my $p = $self->validate_params($c, 'LoginPayload');

    if( $form->process(ctx => $c, params => $p) ) {
        # TODO: This is security threat, session should be replaced
        # after login to make session stealing impossible
        $c->extend_session_expires(999999999999)
            if $form->field( 'remember' )->value;
        $self->status_ok( $c, entity => $c->user->REST );
    } else {
        $self->status_error($c, $index_api->error('login_failed'));
    }
}

$index_api->delete(
    summary  => 'Provides user logout',
    notes    => 'Deletes user session',
    nickname => 'logout',
);

sub index_DELETE {
    my ( $self, $c ) = @_;

    $c->logout;
    $c->delete_session;
    $self->status_no_content( $c );
}

my $shibboleth_api = $auth_resource->api(
  controller => __PACKAGE__,
  action => 'shibboleth',
  path => '/auth/shibboleth',
  description => 'Shibboleth authentication',
);

sub shibboleth :Local :Args(0) {
  my ( $self, $c ) = @_;

  my $redirect = $c->req->param('loc');
  my $req = $c->req;

  if ($req->header('shib-session-id')) {
    my $organization = $req->header('shib-identity-provider');

    my $persistent_token = first {defined} map { $req->header($_) }
      qw(eppn persistent-id mail);

    my $email = $req->header('mail');
    my $first_name = $req->header('givenName') || $req->header('cn');
    my $last_name = $req->header('sn');

    return $redirect ? $c->res->redirect($redirect."#no-metadata") : $self->status_ok( $c, entity => $req->headers )
      unless $persistent_token;

    my $user = $c->model('WebDB::User')->find_or_new({
      persistent_token => $persistent_token,
      organization => $organization
    });

    $user->email($email);
    $user->first_name($first_name);
    $user->last_name($last_name);

    $user->update_or_insert;

    if ($c->authenticate({ dbix_class => { result => $user } })) {
      return $redirect ? $c->res->redirect($redirect."#success") : $self->status_ok( $c, entity => $req->headers );
    }
  }

  return $redirect ? $c->res->redirect($redirect."#failed") : $self->status_ok( $c, entity => $req->headers );
}

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

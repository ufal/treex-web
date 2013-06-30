package Treex::Web::Controller::User;
use Moose;
use Email::Valid;
use boolean;
use Treex::Web::Form::Signup;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::REST'; }

my $user_resouce = __PACKAGE__->api_resource(
    path => 'users'
);

__PACKAGE__->api_model(
    'SignupPayload',
    email => {
        type => 'string',
        format => 'email',
        required => 1
    },
    password => {
        type => 'string',
        required => 1
    },
    passwordConfirm => {
        type => 'string',
        required => 1,
        description => 'Must be same as password'
    }
);

__PACKAGE__->api_model(
    'UserUpdatePayload',
    email => {
        type => 'string',
        format => 'email',
        required => 0
    },
    name => {
        type => 'string',
        required => 0
    },
    password => {
        type => 'string',
        required => 0
    },
    passwordConfirm => {
        type => 'string',
        required => 0,
        description => 'Must be same as password'
    }
);

__PACKAGE__->api_model(
    'EmailAvailability',
    available => {
        type => 'boolean',
        required => 1
    }
);

=head1 NAME

Treex::Web::Controller::User - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

my $users_api = $user_resouce->api(
    controller => __PACKAGE__,
    action => 'users',
    path => '/users',
    description => 'Operations on all users'
);

sub users :Path('/users') :Args(0) :ActionClass('REST') {
    my ( $self, $c ) = @_;
}

$users_api->get(
    summary => 'Get list of all users',
    notes => "Administrators can access all user's attributes.",
    response => 'List[User]',
    nickname => 'usersList',
);

sub users_GET :Does('~NeedsLogin') {
    my ( $self, $c ) = @_;

    my @users = $c->model('WebDB::User')->all;
    my $admin = $c->user->is_admin;
    $self->status_ok($c, entity => [ map { $_->REST($admin) } @users ]);
}

$users_api->post(
    summary => 'Create new user account',
    notes => 'Another place of potential security threat',
    response => 'User',
    nickname => 'userSignup',
    params => [
        __PACKAGE__->api_param_body('SignupPayload', 'User signup info', 'User info')
    ],
    errors => [
        __PACKAGE__->api_error('email_error', 400, 'Email address is invalid'),
        __PACKAGE__->api_error('passwords_not_same', 400, 'Passwords are not the same'),
        __PACKAGE__->api_error('email_taken', 409, 'Email address is already taken'),
    ]
);

sub users_POST {
    my ( $self, $c ) = @_;

    my $p = $self->validate_params($c, 'SignupPayload');

    my $form = Treex::Web::Form::Signup->new(
        schema => $c->model('WebDB')->schema
    );

    my $new_user = $c->model('WebDB::user')->new_result({});
    if ( $form->process(item => $new_user, params => $p) ) {

        if ($c->model('WebDB::User')->count == 1) {
            $new_user->active(1);
            $new_user->activate_token(undef);
            $new_user->is_admin(1);
            $new_user->update;
        }

        $self->status_ok( $c, entity => $new_user->REST );
    } else {
        $self->status_error( $c, $users_api->errors($form->errors))
    }
}

my $user_api = $user_resouce->api(
    controller => __PACKAGE__,
    action => 'user',
    path => '/users/{userId}',
    description => 'Operations on a single user'
);

my @user_errors = (
    __PACKAGE__->api_error('not_found', 404, 'User not found'),
    __PACKAGE__->api_error('forbidden', 403, 'Access denied')
);

my @user_params = (
    __PACKAGE__->api_param_path('int', 'User id', 'userId')
);

sub user :Path('/users') :Args(1) :ActionClass('REST') :Does('~NeedsLogin') {
    my ( $self, $c, $user_id ) = @_;

    my $user = $c->model('WebDB::User')->find($user_id||0);
    unless ($user) {
        $self->status_error($c, $user_api->error('not_found'));
        $c->detach;
    }

    unless ($c->user->id == $user->id or $user->is_admin) {
        $self->status_error($c, $user_api->error('forbidden'));
        $c->detach;
    }

    $c->stash( user => $user );
}

$user_api->get(
    summary => 'Get user by Id',
    notes => "User must be logged in to see this \
resource. Only administrator can access all user's attributes.",
    response => 'User',
    nickname => 'getUser',
    params => [
        @user_params
    ],
    errors => [
        @user_errors
    ]
);

sub user_GET {
    my ( $self, $c ) = @_;

    my $user = $c->stash->{user};
    my $all = $user->id == $c->user->id || $user->is_admin;

    $self->status_ok($c, entity => $user->REST($all));
}

$user_api->put(
    summary => 'Update user info',
    notes => "User can only update his own info or have administrator privileges",
    response => 'User',
    nickname => 'updateUser',
    params => [
        @user_params,
        __PACKAGE__->api_param_body('UserUpdatePayload', 'User data', 'User')
    ],
    errors => [
        @user_errors
    ]
);

sub user_PUT {
    my ( $self, $c ) = @_;

    $c->response->status(500);
    $c->response->body('TODO');
}

$user_api->delete(
    summary => 'Deletes user and all his related records',
    notes => "Users can only delete themselves. Administators can delete any user. Last administator cannot delete himself.",
    nickname => 'deleteUser',
    params => [
        @user_params,
    ],
    errors => [
        @user_errors,
        __PACKAGE__->api_error('last_admin', 403, 'Last administator cannot be deleted')
    ]
);

sub user_DELETE {
    my ( $self, $c ) = @_;

    my $user = $c->stash->{user};
    unless ($user->id == $c->user->id || $user->is_admin) {
        $c->status_error($c, $user_api->error('forbidden'));
        return
    }

    if ($user->id == $c->user->id && $user->is_admin) {
        my $last = $c->model('WebDB::User')->search( is_admin => 1 )->count <= 1;
        if ($last) {
            $self->status_error($c, $user_api->error('last_admin'));
            return
        }
    }

    $c->logout;
    $c->delete_session;
    $user->delete;

    $self->status_ok($c, entity => $user->REST(1));
}

my $email_available_api = $user_resouce->api(
    controller => __PACKAGE__,
    action => 'email_available',
    path => '/users/email-available',
    description => 'Email availability check'
);

sub email_available :Path('/users/email-available') :Args(0) :ActionClass('REST') { }

$email_available_api->get(
    summary => 'Checks whether the given email is available for registration',
    response => 'EmailAvailability',
    nickname => 'checkEmail',
    params => [
        __PACKAGE__->api_param_query('string', 'The email', 'email')
    ],
    errors => [
        __PACKAGE__->api_error('email_invalid', 400, 'Email is invalid')
    ]
);

sub email_available_GET {
    my ( $self, $c ) = @_;

    my $email = $c->req->parameters->{email}||'';
    unless (Email::Valid->address($email)) {
        $self->status_error($c, $email_available_api->error('email_invalid'));
        return;
    }

    $self->status_ok($c, entity => {
        available => $c->model('WebDB::User')->is_email_available($email) ? true : false
    });
}

my $activate_api = $user_resouce->api(
    controller => __PACKAGE__,
    action => 'activate',
    path => '/users/activate',
    description => 'Activate user by token'
);

sub activate :Path('/users/activate') :Args(0) :ActionClass('REST') { }

$activate_api->get(
    summary => 'Activates user by activation token',
    notes => 'Returns 204 on success or 40* on failure',
    nickname => 'activateUser',
    params => [
        __PACKAGE__->api_param_query('string', 'Activation token', 'token')
    ],
    errors => [
        __PACKAGE__->api_error('no_token', 400, 'Token missing'),
        __PACKAGE__->api_error('not_found', 404, 'User not found')
    ]
);

sub activate_GET {
    my ( $self, $c) = @_;

    my $token = $c->req->params->{token}||'';

    unless ($token) {
        $self->status_error($c, $activate_api->error('no_token'));
        return;
    }

    my $user = $c->model('WebDB::User')->single({token => $token});
    if ($user) {
        $user->activate_token(undef);
        $user->active(1);
        $user->update;
        $self->status_no_content($c);
    } else {
        $self->status_error($c, $activate_api->error('not_found'));
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

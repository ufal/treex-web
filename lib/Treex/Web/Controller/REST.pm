package Treex::Web::Controller::REST;
use Moose;
use MooseX::ClassAttribute;
use JSON::Schema;
use Treex::Web;
use Swagger;
use Params::Validate qw(:all);
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Default Treex::Web Restfull Controller.

=head1 METHODS

=cut

class_has api => (
    isa => 'Swagger',
    is  => 'ro',
    default => sub { Swagger->new(api_version => $Treex::Web::API_VERSION) },
);

sub api_resource {
    shift->api->resource(@_);
}

sub api_param {
    shift->api->param(@_);
}

sub api_param_body {
    shift->api->param_body(@_);
}

sub api_error {
    shift->api->error(@_);
}

sub status_error {
    my ($self, $c, $error) = @_;

    $c->response->status($error->{code});
    $c->stash->{ $self->{'stash_key'} } = { error => $error->{reason} };
    return 1;
}

my $_schema_cache = {};

sub validate_params {
    my ($self, $c, $model_name) = @_;

    $_schema_cache->{$model_name} =
        JSON::Schema->new(__PACKAGE__->api->model($model_name))
                unless $_schema_cache->{$model_name};

    my $schema = $_schema_cache->{$model_name};
    my $params = $c->req->data||{};

    my $result = $schema->validate();

    unless ($result) {
        $self->status_bad_request( $c, join("\n", $result->errors) );
        $c->detach;
    }

    return $params;
}

=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

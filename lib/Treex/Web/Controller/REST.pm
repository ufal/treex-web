package Treex::Web::Controller::REST;
use Moose;
use Treex::Web::DB;
use Treex::Web::Api;
use Params::Validate qw(:all);
use List::Util qw(min);
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::REST - Catalyst Controller

=head1 DESCRIPTION

Default Treex::Web Restfull Controller.

=head1 METHODS

=cut

for my $source (Treex::Web::DB->sources) {
    my $class = Treex::Web::DB->source_registrations->{$source}->result_class;
    if ($class->can('rest_schema')) {
        __PACKAGE__->api_model($source, $class->rest_schema);
    }
}

sub api { Treex::Web::Api->api }

sub api_resource {
    shift->api->resource(@_);
}

sub api_model {
    shift->api->model(@_);
}

sub api_param {
    shift->api->param(@_);
}

sub api_param_body {
    shift->api->param_body(@_);
}

sub api_param_path {
    shift->api->param_path(@_);
}

sub api_param_query {
    shift->api->param_query(@_);
}

sub api_error {
    shift->api->error(@_);
}

sub status_error {
    my ($self, $c, @errors) = @_;

    if (@errors == 1) {
        my $error = shift @errors;
        $c->response->status($error->{code});
        $c->stash->{ $self->{'stash_key'} } = { error => $error->{reason} };
    } else {
        # find lowest code and display only those errors
        my $code = min map { $_->{code} } @errors;

        @errors = grep { $_->{code} == $code } @errors;
        return $self->status_error($c, @errors) if @errors == 1;

        $c->response->status($code);
        $c->stash->{ $self->{'stash_key'} } = {
            message => 'The request cannot be fulfilled because of multiple errors',
            errors => [ map { $_->{reason} } @errors ]
        };
    }

    return 1;
}

sub status_unauthorized {}

sub validate_params {
    my ($self, $c, $model_name) = @_;

    my $model = __PACKAGE__->api->model($model_name);

    die "Unknown model '$model_name'\n"
        unless $model;

    my $params = $c->req->data||{};
    my $result = $model->validator->validate($params);

    unless ($result->valid) {
        $c->response->status(400);
        my $error_message = 'The request cannot be fulfilled due to bad parameters. Please check api documentation at ' . $c->uri_for('/');
        $c->stash->{ $self->{'stash_key'} } = {
            message => $error_message,
            errors => [ map { $_->to_string } $result->errors ]
        };
        $c->detach;
        return;
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

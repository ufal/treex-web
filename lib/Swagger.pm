package Swagger;

use Moose;
use Params::Validate qw(HASHREF SCALAR validate validate_pos);
use Swagger::Resource;
use Swagger::Model;
use boolean;
use namespace::autoclean;

=head1 NAME

Swagger - Perl implementation of Swagger

=head1 SYNOPSIS

   use Swagger;
   my $doc = Swagger->new(api_version => $API_VERSION);

   # define doc

   $doc->resource_listing;       # to list all resources
   # or
   $doc->api_listing($resource); # list api of specific resource

=head1 DESCRIPTION

Swagger is a specification and complete framework implementation for
describing, producing, consuming, and visualizing RESTful web
services.

=head1 METHODS

=cut

has swagger_version => (
    is => 'rw',
    default => '1.1'
);

has api_version => (
    is => 'rw',
    default => '1'
);

has format => (
    is => 'rw',
    default => ''
);

has resource_path => (
    is => 'rw',
    default => '/api-docs'
);

has base_path => (
    is => 'rw',
    default => '/'
);

has models => (
    is => 'ro',
    isa => 'HashRef',
    init_arg => undef,
    default => sub { {} },
);

has resources => (
    is => 'ro',
    isa => 'HashRef',
    init_arg => undef,
    default => sub { {} },
);

=head2 resource

Define new resouce

   resource(
     path => 'resource',
     description => 'Desc or my resource',
   )

=cut

sub resource {
    my $self = shift;

    return $self->resources->{$_[0]}
        if @_ == 1 && !ref($_[0]);

    my %p = validate(@_,
                     {
                         path => 1,
                         description => 0
                     });

    my $res = Swagger::Resource->new(%p);
    $self->resources->{$p{path}} = $res;
    return $res;
}

=head2 model

Define new model

   model(
     id => 'model',
     properties => { ... model props ... }
   )

=cut

sub model {
    my $self = shift;
    my $name = shift;

    return $self->models->{$name} if @_ == 0;

    my $model = Swagger::Model->new(
        id => $name,
        properties => {@_},
    );

    $self->models->{$name} = $model;
    return $model;
}

=head2 param

Define new parameter

   param(
     param => 'param_type: body, query, header, path',
     name => 'param_name',
     description => 'Optional expression',
     type => 'type_name',
     required => 0/1,
     allowable_values => { ... },
     multiple => 0/1
   )

=cut

sub param {
    my $self = shift;

    my %p = validate(@_,
                     {
                         param => 1,
                         name => 1,
                         description => 0,
                         type => 1,
                         required => 0,
                         allowable_values => {
                             type => HASHREF,
                             optional => 1,
                         },
                         multiple => 0
                     });
    return {%p};
}

=head2 param_body

Shortcut to L<param> using param_type body

=cut

sub param_body {
    my $self = shift;
    my ($type, $desc, $name) = validate_pos(@_, 1, 1, 0);

    return $self->param(
        param => 'body',
        name => $name,
        description => $desc,
        type => $type,
        required => 1,
    )
}

=head2 param_path

Shortcut to L<param> using param_type path

=cut

sub param_path {
    my $self = shift;
    my ($type, $desc, $name) = validate_pos(@_, 1, 1, 1);

    return $self->param(
        param => 'path',
        name => $name,
        description => $desc,
        type => $type,
        required => 1,
    )
}

=head2 param_query

Shortcut to L<param> using param_type query

=cut

sub param_query {
    my $self = shift;
    my ($type, $desc, $name, $multiple) = validate_pos(@_, 1, 1, 1, 0);

    return $self->param(
        param => 'query',
        name => $name,
        description => $desc,
        type => $type,
        required => 1,
        ($multiple ? (multiple => 1) : ())
    )
}

=head2 error

Define new error

   error(
     name => 'error_name',
     code => 404,
     reason => 'Item not found'
   )

=cut

sub error {
    my $self = shift;
    my ($name, $code, $reason) = validate_pos(@_, { type => SCALAR }, { regex => qr/^\d+$/ }, 1);

    return {
        name => $name,
        code => $code,
        reason => $reason
    };
}

=head2 listing_header

Returns default Swagger listing header. Used for both resource listing
and api listing.

=cut

sub listing_header {
    my $self = shift;
    return {
        apiVersion => $self->api_version,
        swaggerVersion => $self->swagger_version,
        basePath => $self->base_path,
        apis => [],
    }
}

=head2 api_listing

Get listing of api of specific resource. Resource path serves as a parameter.

=cut

sub api_listing {
    my ($self, $path) = @_;

    die 'No path to list' unless $path;

    my $listing = $self->listing_header;
    my $resource = $self->resources->{$path};

    return $listing unless $resource;

    $listing->{apis} = [
        map { {
            path => $_->path,
            description => ($_->description||''),
            operations => [ map { {
                httpMethod => $_->{method},
                nickname => $_->{nickname},
                responseClass => ($_->{response}||'void'),
                ($_->{params} ? (
                    parameters => [ map { {
                        paramType => $_->{param},
                        name => $_->{name},
                        dataType => $_->{type},
                        ($_->{description} ? (description => $_->{description}) : ()),
                        required => ($_->{required} ? true : false),
                        ($_->{allowable_values} ? (allowableValues => $_->{allowable_values}) : ()),
                        ($_->{multiple} ? (multiple => $_->{multiple}) : ())
                    } } @{ $_->{params} }]
                ) : ()),
                summary => $_->{summary},
                ($_->{notes} ? (notes => $_->{notes}) : ()),
                ($_->{errors} ? (
                    errorResponses => [ map { {
                        code => int($_->{code}),
                        reason => $_->{reason}
                    } } @{ $_->{errors} }]
                ) : ())
            } } @{$_->operations} ]
        } } @{ $resource->apis }];

    my %models = map { $_ =>  $self->models->{$_}->listing }
        grep { exists $self->models->{$_} }
            map { $_, (exists $self->models->{$_} ? $self->models->{$_}->submodels : ()) }
                $resource->all_models;

    $listing->{models} = \%models if %models;

    return $listing;
}

=head2 resource_listing

List all available resources

=cut

sub resource_listing {
    my $self = shift;

    my $listing = $self->listing_header;

    $listing->{apis} = [
        map { {
            path => $self->resource_path . '/' . $_ . $self->format,
        } } keys %{ $self->resources }];

    return $listing;
}

__PACKAGE__->meta->make_immutable;

1;
__END__


=head1 SEE ALSO

This module is part of L<Treex::Web>

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

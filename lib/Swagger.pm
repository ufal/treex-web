package Swagger;

use Moose;
use Params::Validate qw(HASHREF SCALAR validate validate_pos);
use Swagger::Resource;
use Swagger::Model;
use boolean;
use namespace::autoclean;

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

sub error {
    my $self = shift;
    my ($name, $code, $reason) = validate_pos(@_, { type => SCALAR }, { regex => qr/^\d+$/ }, 1);

    return {
        name => $name,
        code => $code,
        reason => $reason
    };
}

sub listing_header {
    my $self = shift;
    return {
        apiVersion => $self->api_version,
        swaggerVersion => $self->swagger_version,
        basePath => $self->base_path,
        apis => [],
    }
}

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

=head1 NAME

Swagger - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Swagger;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Swagger,

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Michal Sedlak, E<lt>sedlakmichal@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

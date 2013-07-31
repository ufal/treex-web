package Swagger::Model;

use Moose;
use JSON::Schema;
use namespace::autoclean;


=head1 NAME

Swagger::Model - Representing Swagger Model data holder

=head1 SYNOPSIS

   use Swagger::Model;
   blah blah blah

=head1 DESCRIPTION

Model can generate output in Swagger but also in JSON Schema format
which can be used for validation

=head1 METHODS

=cut

has 'id' => ( is => 'ro' );

has 'validator' => (
    is         => 'rw',
    isa        => 'JSON::Schema',
    lazy_build => 1,
    predicate  => 'has_validator',
    clearer    => 'clear_validator'
);

has validator_formats => (
    isa => 'HashRef',
    is  => 'rw',
    default => sub { \%JSON::Schema::FORMATS },
);

sub _build_validator {
    my $self = shift;
    return JSON::Schema->new($self->schema, $self->validator_formats);
}

has 'properties' => (
    is => 'ro',
    isa => 'HashRef',
    default => sub { {} },
);

=head2 schema

Returns JSON Schema representation of the model

=cut

sub schema {
    my $self = shift;

    return {
        type => 'object',
        properties => { %{$self->properties} },
        additionalProperties => 0,
    };
}

=head2 listing

Returns Swagger representation of the model

=cut

sub listing {
    my $self = shift;

    return {
        id => $self->id,
        properties => { %{$self->properties} }
    }
}

=head2 submodels

Returns all submodel of this model

=cut

sub submodels {
    my $self = shift;

    my @submodels = map {
        my $prop = $self->properties->{$_};
        ref $prop->{items} ? $prop->{items}->{type} : $prop->{type};
    } keys %{$self->properties};

    my %uniq = map { $_, 1} @submodels;
    @submodels = keys %uniq;

    return wantarray ? @submodels : \@submodels;
}

__PACKAGE__->meta->make_immutable;
1;
__END__

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

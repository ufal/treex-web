package Swagger::Api;

use Moose;
use Params::Validate qw(ARRAYREF validate validate_pos);
use List::Util qw(first);
use namespace::autoclean;

=head1 NAME

Swagger::Api - Representing Swagger Api data holder

=head1 SYNOPSIS

   use Swagger::Api;

=head1 DESCRIPTION

Simple API object

This has no constructor of it's own.

=head1 NOTE

The API of this class will be subject of change.

=head1 METHODS

=cut

has 'controller'   => ( is => 'ro' );
has 'action'       => ( is => 'ro' );
has 'path'         => ( is => 'ro' );

has 'description' => (is => 'rw');

has 'operations' => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

=head2 operation

Defines a new operation on the Api

=cut

sub operation {
    my $self = shift;
    my $method = uc shift;

    my %p = validate(@_,
                     {
                         summary => 1,
                         nickname => 1,
                         method => 0,
                         notes => 0,
                         response => 0,
                         params => {
                             type => ARRAYREF,
                             optional => 1,
                         },
                         errors => {
                             type => ARRAYREF,
                             optional => 1
                         }
                     });

    push @{$self->operations}, {%p, method => $method};
    return $self;
}

=head2 models

List of all models used in this Api

=cut

sub models {
    my $self = shift;

    my @models;

    for my $op (@{$self->operations}) {
        my $response = $op->{response};
        $response =~ s/^\w+\[(\w+)\]$/$1/;
        push @models, $response if $response;

        if ($op->{params}) {
            push @models, map { $_->{type} }
                grep { $_->{param} eq 'body' } @{ $op->{params} };
        }
    }
    my %uniq = map { $_, 1 } @models;
    @models = keys %uniq;

    return wantarray ? @models : \@models;
}


my %unknown_error = (
    name => 'unknown_error',
    code => 400,
);

=head2 error

Returns an error by given C<name>

=cut

sub error {
    my ($self, $name) = @_;

    my $error;

    for my $op (@{$self->operations}) {
        $error = first { $_->{name} eq $name } @{$op->{errors}};
        last if $error;
    }

    return $error||{ %unknown_error, reason => ucfirst($name||'Unknown') };
}

=head2 errors

List of errors by name C<errors('error1', 'error2', ...)>

=cut

sub errors {
    my $self = shift;

    return map {
        $self->error($_)
    } @_;
}

=head2 get

=head2 post

=head2 delete

=head2 put

=head2 patch

Shortcuts to C<operation('METHOD', @_)>

=cut


sub get { shift->operation('GET', @_); }

sub post { shift->operation('POST', @_); }

sub delete { shift->operation('DELETE', @_); }

sub put { shift->operation('PUT', @_); }

sub patch { shift->operation('PATCH', @_); }

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

package Swagger::Api;

use Moose;
use Params::Validate qw(ARRAYREF validate validate_pos);
use List::Util qw(first);
use namespace::autoclean;

has 'controller'   => ( is => 'ro' );
has 'action'       => ( is => 'ro' );
has 'path'         => ( is => 'ro' );

has 'description' => (is => 'rw');

has 'operations' => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

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

    return wantarray ? @models : \@models;
}


my $unknow_error = {
    code => 500,
    reason => 'Unknown error'
};

sub error {
    my ($self, $name) = @_;

    my $error;

    for my $op (@{$self->operations}) {
        $error = first { $_->{name} eq $name } @{$op->{errors}};
        last if $error;
    }

    return $error||$unknow_error;
}

sub get { shift->operation('GET', @_); }

sub post { shift->operation('POST', @_); }

sub delete { shift->operation('DELETE', @_); }

sub put { shift->operation('PUT', @_); }

sub patch { shift->operation('PATCH', @_); }

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Swagger::Api - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Swagger::Api;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Swagger::Api,

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

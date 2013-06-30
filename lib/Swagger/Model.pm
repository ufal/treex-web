package Swagger::Model;

use Moose;
use JSON::Schema;
use namespace::autoclean;

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

sub schema {
    my $self = shift;

    return {
        type => 'object',
        properties => { %{$self->properties} },
        additionalProperties => 0,
    };
}

sub listing {
    my $self = shift;

    return {
        id => $self->id,
        properties => { %{$self->properties} }
    }
}

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

Swagger::Model - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Swagger::Model;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Swagger::Model,

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

package Swagger::Resource;

use Moose;
use Params::Validate qw(validate);
use Swagger::Api;
use namespace::autoclean;

has 'path'   => ( is => 'ro' );
has 'description' => (is => 'rw');

has 'apis' => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

sub api {
    my $self = shift;
    my %p = validate(@_,
                     {
                         controller => 1,
                         action => 1,
                         path => 1,
                         description => 0
                     });

    my $api = Swagger::Api->new(%p);
    push @{$self->apis}, $api;

    return $api;
}

sub all_models {
    my $self = shift;

    my @models;

    for my $api (@{$self->apis}) {
        push @models, $api->models;
    }

    my %uniq = map { $_, 1 } @models;
    @models = keys %uniq;

    return wantarray ? @models : \@models;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Swagger::Resource - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Swagger::Resource;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Swagger::Resource,

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

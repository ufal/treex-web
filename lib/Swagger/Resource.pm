package Swagger::Resource;

use Moose;
use Params::Validate qw(validate);
use Swagger::Api;
use namespace::autoclean;

=head1 NAME

Swagger::Resource - Representing Swagger Resource data holder

=head1 SYNOPSIS

   use Swagger::Resource;
   my $resource = Swagger::Resource->new( path => 'my_resource');

   $resource->api( ... ); # define new api

=head1 METHODS

=cut

has 'path'   => ( is => 'ro' );
has 'description' => (is => 'rw');

has 'apis' => (
    is => 'ro',
    isa => 'ArrayRef',
    default => sub { [] },
);

=head2 api

Defines a new api for this resource

TODO: list parameters

=cut

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

=head2 all_models

All models in all apis

=cut

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

package Treex::Web::Model::Resque;
use Moose;
use namespace::autoclean;

extends 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'Resque', args => { plugins => ['Status'] } );

sub prepare_arguments {
    my ($self, $c) = @_; # app
    return $self->{args} || {}
}

sub mangle_arguments {
    my ($self, $args) = @_;
    return %$args; # now the args are a plain list
}


=head1 NAME

Treex::Web::Model::Resque - Simple adapter for Resque

=head1 DESCRIPTION

A Catalyst model adapter for resque

=head1 METHODS

=over 2

=item prepare_arguments

=item mangle_arguments

=back

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

__PACKAGE__->meta->make_immutable;

1;

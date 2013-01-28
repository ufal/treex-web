package Treex::Web::Model::TheSchwartz;
#use Moose;
#use namespace::autoclean;

use base 'Catalyst::Model::Adaptor';

__PACKAGE__->config( class => 'TheSchwartz' );

sub prepare_arguments {
    my ($self, $c) = @_; # $app sometimes written as $c
    return $self->{args} || {}
}

sub mangle_arguments {
    my ($self, $args) = @_;
    return %$args; # now the args are a plain list
}

=head1 NAME

Treex::Web::Model::TheSchwartz - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

#__PACKAGE__->meta->make_immutable;

1;

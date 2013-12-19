package Treex::Web::Form::Login;

use HTML::FormHandler::Moose;
use MooseX::Types::Common::String qw/ NonEmptySimpleStr /;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Form::Base';}

=head1 NAME

Treex::Web::Forms::Login - Login from validator

=head1 FIELDS

=cut

has authenticate_realm => (
    is        => 'ro',
    isa       => NonEmptySimpleStr,
    predicate => 'has_authenticate_realm',
);

=over

=item email

=item password

=item remember

=back

=cut

has_field 'email' => ( type => 'Email' );
has_field 'password' => ( type => 'Password' );
has_field 'remember' => ( type => 'Boolean' );

=head1 METHODS

=head2 validate

Validates the form and triggers the authentification. In other words
the form is invalid unless the authentification is successful

=cut

sub validate {
    my $self = shift;

    my %values = %{$self->values}; # copy the values
    unless (
        $self->ctx->authenticate(
            {
                persistent_token => $values{email},
                organization => 'local',
                password => $values{password}
            },
            ($self->has_authenticate_realm ? $self->authenticate_realm : ()),
        )
    ) {
        $self->add_auth_errors;
        return;
    }
    return 1;
}

=head2 add_auth_errors

Triggers in case of missing email or password

=cut

sub add_auth_errors {
    my $self = shift;
    $self->field( 'password' )->add_error( 'Wrong username or password' )
        if $self->field( 'email' )->has_value && $self->field( 'password' )->has_value;
}

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

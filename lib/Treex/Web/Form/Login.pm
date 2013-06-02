package Treex::Web::Form::Login;

use HTML::FormHandler::Moose;
use MooseX::Types::Common::String qw/ NonEmptySimpleStr /;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Form::Base';}

has authenticate_realm => (
    is        => 'ro',
    isa       => NonEmptySimpleStr,
    predicate => 'has_authenticate_realm',
);

has_field 'email' => ( type => 'Email' );
has_field 'password' => ( type => 'Password' );
has_field 'remember' => ( type => 'Boolean' );
has_field 'submit'   => ( type => 'Submit', value => 'Login' );

sub validate {
    my $self = shift;

    my %values = %{$self->values}; # copy the values
    unless (
        $self->ctx->authenticate(
            {
                email => $values{email},
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

sub add_auth_errors {
    my $self = shift;
    $self->field( 'password' )->add_error( 'Wrong username or password' )
        if $self->field( 'email' )->has_value && $self->field( 'password' )->has_value;
}


__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

Treex::Web::Forms::Login - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Forms::Login;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Forms::Login;

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

Copyright (C) 2012 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

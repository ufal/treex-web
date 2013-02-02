package Treex::Web::Forms::LoginForm;

use HTML::FormHandler::Moose;
BEGIN {extends 'CatalystX::SimpleLogin::Form::Login';}
with 'Treex::Web::Forms::Role::Base';

has '+name' => (default => 'login-form');

sub after_build {
    my $self = shift;

    my $remember_field = $self->field('remember');
    $remember_field->label('Keep me logged in');
    $remember_field->do_label(0);

    my $password_field = $self->field('password');
    $password_field->required(1);

    my $username_field = $self->field('username');
    $username_field->type('Email');
    $username_field->accessor('email');
    $username_field->label('Email');
    $username_field->required(1);

    my $submit_field = $self->field('submit');
    $submit_field->element_attr({class => 'btn btn-primary'});
}

no HTML::FormHandler::Moose;
1;
__END__

=head1 NAME

Treex::Web::Forms::LoginForm - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Forms::LoginForm;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Forms::LoginForm;

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

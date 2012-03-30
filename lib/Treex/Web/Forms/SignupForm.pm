package Treex::Web::Forms::SignupForm;

use strict; 
use warnings;

use Moose;
use HTML::FormHandler::Moose;
extends 'Treex::Web::Forms::Base';
with 'HTML::FormHandler::TraitFor::Model::DBIC';

has '+item_class' => ( default => 'Treex::Web::DB::Result::User' );
has '+name' => (default => 'signup_form');

has_field 'email' => (type => 'Email', value => '', required => 1);
has_field 'password' => (type => 'Password', required => 1);
has_field 'password_confirm' => (type => 'Password', label => 'Confirm password', required => 1);
has_field 'submit' => (type => 'Submit', value => 'Submit');

after 'validate' => sub {
    my $self = shift;
    $self->field('password_confirm')->add_error('Passwords are not the same.')
        if $self->field('password')->value ne $self->field('password_confirm')->value;
};

no HTML::FormHandler::Moose;
1;
__END__

=head1 NAME

Treex::Web::Forms::SignupForm - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Forms::SignupForm;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Forms::SignupForm;

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

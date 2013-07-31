package Treex::Web::Form::Signup;

use Moose;
use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'Treex::Web::Form::Base';
with 'HTML::FormHandler::TraitFor::Model::DBIC';

=head1 NAME

Treex::Web::Forms::Signup - registration form

=head1 DESCRIPTION

NOT USED

=head1 METHODS

=cut

has '+item_class' => ( default => 'Treex::Web::DB::Result::User' );
has '+name' => (default => 'signup-form');

has '+unique_messages' => (
    default => sub {
        {
            email_unique => 'email_taken'
        }
    }
);

has_field 'email' => (type => 'Email', required => 1, unique_message => 'email_taken');
has_field 'password' => (type => 'Password', required => 1);
has_field 'password_confirm' => (type => 'Password', name => 'passwordConfirm', required => 1);

=head2 validate

=cut

sub validate {
    my $self = shift;

    $self->field('passwordConfirm')->add_error('passwords_not_same')
        if $self->field('password')->value ne $self->field('passwordConfirm')->value;
};

no HTML::FormHandler::Moose;
1;
__END__

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

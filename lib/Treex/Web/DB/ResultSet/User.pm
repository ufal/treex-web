package Treex::Web::DB::ResultSet::User;

use Moose;
use namespace::autoclean;
BEGIN {extends 'DBIx::Class::ResultSet';}

=head1 NAME

Treex::Web::DB::ResultSet::User

=head1 DESCRIPTION

Adds only a email check method to the User ResutlSet

=head1 METHODS

=head2 is_email_available

Checks whether is the email taken or not

=cut

sub is_email_available {
    my ($self, $email) = @_;

    return not $self->find({ email => $email });
}

1;
__END__

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

package Treex::Web::Form::Role::Base;

use HTML::FormHandler::Moose::Role;

=head1 NAME

Treex::Web::Forms::Role::Base - Role to set form defaults

=head1 METHODS

=cut

has 'is_html5'  => ( isa => 'Bool', is => 'ro', default => 1 );

=head2 build_do_form_wrapper

Returns 1

=cut

sub build_do_form_wrapper { 1 }

no HTML::FormHandler::Moose::Role;
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

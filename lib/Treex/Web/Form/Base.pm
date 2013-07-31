package Treex::Web::Form::Base;

use Moose;
use boolean;
use Data::Rmap qw(:all);
use JSON;
use HTML::FormHandler::Moose;
use namespace::autoclean;

extends 'HTML::FormHandler';

=head1 NAME

Treex::Web::Forms::Base

=head1 DESCRIPTION

Sets some defaults for all forms;

=cut

has '+is_html5' => (default => 1);

=head2 build_do_form_wrapper

Sets to 1

=cut

sub build_do_form_wrapper { 1 }

=head2 params

This is fixing nasty bug when serialized json booleans can't be overwritten

=cut

after 'params' => sub {
    my $self = shift;
    rmap_all { $_ = $_ ? true : false if JSON::is_bool($_) } $self->{params} if @_;
};

__PACKAGE__->meta->make_immutable;

1;
__END__

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

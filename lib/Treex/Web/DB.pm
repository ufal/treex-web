package Treex::Web::DB;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';
our $VERSION = 1;

__PACKAGE__->load_namespaces;

#__PACKAGE__->load_components("InflateColumn::Boolean");
#__PACKAGE__->true_is('1');
#__PACKAGE__->false_is('0');

__PACKAGE__->meta->make_immutable(inline_constructor => 0);

1;
__END__

=head1 NAME

Treex::Web::DB -- Database schema for L<Treex::Web>

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

use utf8;
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

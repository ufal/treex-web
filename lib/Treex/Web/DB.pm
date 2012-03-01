use utf8;
package Treex::Web::DB;

use Moose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Schema';
our $VERSION = '0.00002';

__PACKAGE__->load_namespaces;

__PACKAGE__->load_components(qw/Schema::Versioned/);

__PACKAGE__->upgrade_directory('sql/');

__PACKAGE__->meta->make_immutable(inline_constructor => 0);


1;

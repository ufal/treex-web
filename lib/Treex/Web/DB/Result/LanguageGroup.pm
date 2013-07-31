package Treex::Web::DB::Result::LanguageGroup;

=head1 NAME

Treex::Web::DB::Result::LanguageGroup

=cut

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::Ordered>

=back

=cut

__PACKAGE__->load_components("Ordered");


=head1 TABLE: C<language_groups>

=cut

__PACKAGE__->table("language_groups");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0


=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 120

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "name",
    { data_type => "varchar", is_nullable => 0, size => 200 },
    "position",
    { data_type => "integer", is_nullable => 1 }
);

=head1 POSITIONING

=head2 position

  data_type: 'integer'
  is_nullable: 1

=cut

__PACKAGE__->position_column('position');
__PACKAGE__->null_position_value(undef);


=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 languages

Type: has_many

Related object: L<Treex::Web::DB::Result::Language>

=cut

__PACKAGE__->has_many(
    "languages" => "Treex::Web::DB::Result::Language",
    "language_group",
);

__PACKAGE__->meta->make_immutable;
1;

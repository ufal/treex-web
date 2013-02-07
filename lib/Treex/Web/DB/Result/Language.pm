package Treex::Web::DB::Result::Language;

=head1 NAME

Treex::Web::DB::Result::Language

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

=head1 TABLE: C<languages>

=cut

__PACKAGE__->table("languages");

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
    "language_group",
    { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
    "code",
    { data_type => "varchar", is_nullable => 0, size => 10 },
    "name",
    { data_type => "varchar", is_nullable => 0, size => 120 },
    "position",
    { data_type => "integer", is_nullable => 1 }
);

=head1 POSITIONING

=cut

__PACKAGE__->position_column('position');
__PACKAGE__->grouping_column('language_group');
__PACKAGE__->null_position_value(undef);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Treex::Web::DB::Result::LanguageGroup>

=cut

__PACKAGE__->belongs_to(
    "language_group",
    "Treex::Web::DB::Result::LanguageGroup",
    { id => "language_group" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
    },
);

=head2 scenario_languages

Type: has_many

Related object: L<Treex::Web::DB::Result::ScenarioLanguage>

=cut

__PACKAGE__->has_many(
    "scenario_languages" => "Treex::Web::DB::Result::ScenarioLanguage",
    "language"
);

=head2 scenarios

Type: many_to_many

Related object: L<Treex::Web::DB::Result::Scenario>

=cut

__PACKAGE__->many_to_many( "scenarios" => "scenario_languages", "language" );

=head2 results

Type: has_many

Related object: L<Treex::Web::DB::Result::Result>

=cut

__PACKAGE__->has_many( "results" => "Treex::Web::DB::Result::Result", "language" );

__PACKAGE__->meta->make_immutable;
1;

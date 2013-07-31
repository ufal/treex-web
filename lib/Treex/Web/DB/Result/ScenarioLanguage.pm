package Treex::Web::DB::Result::ScenarioLanguage;

=head1 NAME

Treex::Web::DB::Result::ScenarioLanguages

=cut

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 TABLE: C<scenario_languages>

=cut

__PACKAGE__->table("scenario_languages");

=head1 ACCESSORS

=head2 scenario

  data_type: 'integer'
  is_nullable: 0


=head2 language

  data_type: 'varchar'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "scenario",
    { data_type => "integer", is_nullable => 0 },
    "language",
    { data_type => "varchar", is_nullable => 0 },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("scenario", "language");

=head1 RELATIONS

=head2 scenario

Type: belongs_to

Related object: L<Treex::Web::DB::Result::Scenario>

=cut

__PACKAGE__->belongs_to("scenario" => "Treex::Web::DB::Result::Scenario");

=head2 language

Type: belongs_to

Related object: L<Treex::Web::DB::Result::Language>

=cut

__PACKAGE__->belongs_to("language" => "Treex::Web::DB::Result::Language");

__PACKAGE__->meta->make_immutable;
1;

use utf8;
package Treex::Web::DB::Result::Scenario;

=head1 NAME

Treex::Web::DB::Result::Scenario

=cut

use strict;
use warnings;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=back

=cut

__PACKAGE__->load_components("InflateColumn::DateTime", "TimeStamp");

=head1 TABLE: C<scenarios>

=cut

__PACKAGE__->table("scenarios");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 scenario

  data_type: 'text'
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 120

=head2 comment

  data_type: 'text'
  is_nullable: 1

=head2 user

  data_type: 'integer'
  is_nullable: 0

=head2 last_modified

  data_type: 'datetime'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "scenario",
    { data_type => "text", is_nullable => 0 },
    "name",
    { data_type => "varchar", is_nullable => 0, size => 120 },
    "description",
    { data_type => "text", is_nullable => 1 },
    "public",
    {
        data_type => 'boolean',
        is_nullable => 0,
        is_boolean => 1,
        default => 0
    },
    "user",
    {
        data_type      => "integer",
        default_value  => 0,
        is_foreign_key => 1,
        is_nullable    => 0,
    },
    "created_at",
    {
        data_type => "datetime",
        is_nullable => 0,
        set_on_create => 1,
        set_on_update => 0
    },
    "last_modified",
    {
        data_type => "datetime",
        is_nullable => 0,
        set_on_create => 1,
        set_on_update => 1
    },
);

=head1 PRIMARY KEY

=over 4

=item * L</id>

=back

=cut

__PACKAGE__->set_primary_key("id");

=head1 UNIQUE CONSTRAINTS

=head2 C<name_user_unique>

Unique name per user

=over 4

=item * L</name>

=item * L</user>

=back

=cut

__PACKAGE__->add_unique_constraint("name_user_unique", ["name", "user"]);

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Treex::Web::DB::Result::User>

=cut

__PACKAGE__->belongs_to(
    "user",
    "Treex::Web::DB::Result::User",
    { id => "user" },
);

=head2 scenario_languages

Type: has_many

Related object: L<Treex::Web::DB::Result::ScenarioLanguage>

=cut

__PACKAGE__->has_many(
    "scenario_languages" => "Treex::Web::DB::Result::ScenarioLanguage",
    "scenario"
);

=head2 languages

Type: has_many

Related object: L<Treex::Web::DB::Result::Language>

=cut

__PACKAGE__->many_to_many( "languages" => "scenario_languages", "language" );

sub languages_names {
    map { $_->name } shift->languages;
}

sub REST {
    my ($self, $nested) = @_;
    return {
        id => $self->id,
        name => $self->name,
        description => $self->description,
        languages => [(map { $nested ? $_->REST($nested) : $_->id } $self->languages)],
        scenario => $self->scenario,
        ($self->user ? (user => ($nested ? $self->user->REST($nested) : $self->user->id)) : ()),
        public => $self->public
    };
}

__PACKAGE__->meta->make_immutable;
1;

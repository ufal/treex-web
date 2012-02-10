use utf8;
package Treex::Web::DB::Result::User;

=head1 NAME

Treex::Web::DB::Result::User

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

=head1 TABLE: C<user>

=cut

__PACKAGE__->table("user");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 email

  data_type: 'text'
  is_nullable: 1

=head2 password

  data_type: 'text'
  is_nullable: 1

=head2 last_modified

  data_type: 'datetime'
  is_nullable: 0

=cut

__PACKAGE__->add_columns
(
 "id",
 { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
 "email",
 { data_type => "text", is_nullable => 0 },
 "password",
 { data_type => "text", is_nullable => 0 },
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

=head2 C<email_unique>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint("email_unique", ["email"]);

=head1 RELATIONS

=head2 results

Type: has_many

Related object: L<Treex::Web::DB::Result::Result>

=cut

__PACKAGE__->has_many(
  "results",
  "Treex::Web::DB::Result::Result",
  { "foreign.user" => "self.id" },
  { cascade_copy => 0, cascade_delete => 1 },
);

__PACKAGE__->meta->make_immutable;
1;

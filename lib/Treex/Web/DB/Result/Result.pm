use utf8;
package Treex::Web::DB::Result::Result;

=head1 NAME

Treex::Web::DB::Result::Result

=cut

use strict;
use warnings;
use DBIx::Class::UUIDColumns;
use File::Spec ();
use Treex::Web;

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::PK::Auto>

=item * L<DBIx::Class::UUIDColumns>

=back

=cut

__PACKAGE__->load_components('InflateColumn::DateTime', 'TimeStamp', 'PK::Auto', 'UUIDColumns', 'InflateColumn::FS');

=head1 TABLE: C<result>

=cut

__PACKAGE__->table("result");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 job_uid

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=head2 session

  data_type: 'varchar'
  is_nullable: 0
  size: 100

=head2 user

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 0
  size: 120

=head2 last_modified

  data_type: 'datetime'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    "id",
    { data_type => "integer", is_auto_increment => 1, is_nullable => 0 },
    "job_uid",
    { data_type => "varchar", is_nullable => 0, size => 60 },
    "session",
    { data_type => "varchar", is_nullable => 0, size => 100},
    "user",
    {
        data_type      => "integer",
        default_value  => \"null",
        is_foreign_key => 1,
        is_nullable    => 1,
    },
    "name",
    { data_type => "varchar", is_nullable => 1, size => 120 },
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

=head2 C<hash_unique>

=over 4

=item * L</hash>

=back

=cut

__PACKAGE__->add_unique_constraint("hash_unique", ["job_uid"]);
__PACKAGE__->uuid_columns( 'job_uid' );
__PACKAGE__->uuid_class('::Data::Uniqid');

=head1 RELATIONS

=head2 user

Type: belongs_to

Related object: L<Treex::Web::DB::Result::User>

=cut

__PACKAGE__->belongs_to(
    "user",
    "Treex::Web::DB::Result::User",
    { id => "user" },
    {
        is_deferrable => 1,
        join_type     => "LEFT",
    },
);

=head1 METHODS

=cut

sub new {
    my ( $self, $attrs ) = @_;

    for my $column (@{$self->uuid_columns}) {
        $attrs->{$column} = $self->get_uuid
            unless defined $attrs->{$column};
    }

    return $self->next::method( $attrs );
}

sub fs_file_name {
    my ($self, $column, $column_info) = @_;
    return $column;
}

sub _fs_column_dirs {
    my $self = shift;

    my $hash = $self->job_uid;
    return File::Spec->catfile( substr($hash, 0, 2), $hash );
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;

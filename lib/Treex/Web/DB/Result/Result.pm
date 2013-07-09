use utf8;
package Treex::Web::DB::Result::Result;

=head1 NAME

Treex::Web::DB::Result::Result

=cut

use strict;
use warnings;
use DBIx::Class::UUIDColumns;
use File::Path ();
use File::Spec ();
use Treex::Web; # TODO: THIS MUST BE REMOVED

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
    "job_handle",
    { data_type => "varchar", is_nullable => 1, size => 255 },
    "unique_token",
    { data_type => "varchar", is_nullable => 0, size => 60 },
    "user",
    {
        data_type      => "integer",
        default_value  => \"null",
        is_foreign_key => 1,
        is_nullable    => 1,
    },
    "name",
    { data_type => "varchar", is_nullable => 1, size => 120 },
    "language",
    { data_type => "integer", is_nullable => 1 },
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

__PACKAGE__->add_unique_constraint("unique_token", ["unique_token"]);
__PACKAGE__->uuid_columns( 'unique_token' );
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

__PACKAGE__->belongs_to(
    "language" => "Treex::Web::DB::Result::Language",
);

=head1 METHODS

=cut

sub REST {
    my $self = shift;

    return {
        ($self->language ? (language => $self->language->code) : ()),
        name => utf8::decode($self->name),
        token => $self->unique_token,
        last_modified => $self->last_modified->strftime('%Y-%m-%dT%H:%M:%S%z'),
    };
}

sub rest_schema {
    return (
        language => { type => 'string' },
        name => { type => 'string' },
        token => { type => 'string' },
        last_modified => { type => 'string' }
    )
}

sub new {
    my ( $self, $attrs ) = @_;

    for my $column (@{$self->uuid_columns}) {
        $attrs->{$column} = $self->get_uuid
            unless defined $attrs->{$column};
    }

    return $self->next::method( $attrs );
}

sub insert {
    my ( $self, $scenario, $input ) = @_;

    my $path = $self->files_path;
    File::Path::make_path("$path/") or die "Path: $path, Error: $!";

    # write down scenario file
    $self->scenario($scenario);

    # write input file
    $self->input($input);

    return $self->next::method();
}

sub delete {
    my $self = shift;

    # remove all files too
    my $path = $self->files_path;
    File::Path::remove_tree("$path/");

    return $self->next::method(@_);
}

sub input {
    my ( $self, $input ) = @_;

    # write down input file
    return $self->_file_rw('input.txt', $input);
}

sub scenario {
    my ( $self, $scenario ) = @_;

    # write down scenario file
    return $self->_file_rw('scenario.scen', $scenario);
}

sub result_filename {
    my $self = shift;
    return File::Spec->catfile($self->files_path, 'result.treex');
}

sub error_log {
    shift->_file_rw('error.log');
}

sub _file_rw {
    my ( $self, $filename, $content ) = @_;

    my $path = $self->files_path;
    my $file = File::Spec->catfile($path, $filename);

    if (defined $content and $content ne '') {
        open my $fh, '>', $file or die $!;
        print $fh $content;
        close $fh;
        return $content;
    } else {
        open my $fh, '<', $file or return "";
        my $file_contents = do { local $/; <$fh> };
        close $fh;
        utf8::decode($file_contents);
        return $file_contents;
    }
}

sub files_path {
    my $self = shift;

    my $hash = $self->unique_token;
    return Treex::Web->path_to('data', 'results', substr($hash, 0, 2), $hash);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;

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
use File::Copy ();
use Encode;
use boolean;
use Treex::Web; # TODO: THIS MUST BE REMOVED

use Moose;
use MooseX::NonMoose;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::UUIDColumns>

=back

=cut

__PACKAGE__->load_components('TimeStamp', 'UUIDColumns');

=head1 TABLE: C<result>

=cut

__PACKAGE__->table("result");

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 job_handle

  data_type: 'varchar'
  is_nullable: 1
  size: 255

=head2 unique_token

  data_type: 'varchar'
  is_nullable: 0
  size: 60

=head2 session

  data_type: 'varchar'
  is_nullable: 1
  size: 100

=head2 user

  data_type: 'integer'
  default_value: 0
  is_foreign_key: 1
  is_nullable: 0

=head2 name

  data_type: 'varchar'
  is_nullable: 1
  size: 120

=head2 input_type

  data_type: 'varchar'
  default_value: 'txt'
  is_nullable: 0
  size: 20

=head2 output_type

  data_type: 'varchar'
  default_value: 'treex'
  is_nullable: 0
  size: 20

=head2 language

  data_type: 'integer'
  is_nullable: 1

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
    "session",
    { data_type => "varchar", is_nullable => 1, size => 100 },
    "user",
    {
        data_type      => "integer",
        default_value  => \"null",
        is_foreign_key => 1,
        is_nullable    => 1,
    },
    "name",
    { data_type => "varchar", is_nullable => 1, size => 120 },
    "input_type",
    { data_type => "varchar", is_nullable => 0, default_value => 'txt', size => 20 },
    "output_type",
    { data_type => "varchar", is_nullable => 0, default_value => 'treex', size => 20 },
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

=head2 C<unique_token>

=over 4

=item * L</unique_token>

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

=head2 REST

REST representation

=cut

sub REST {
    my $self = shift;

    return {
        id => $self->id,
        ($self->language ? (language => $self->language->code) : ()),
        name => decode_utf8($self->name),
        printable => ($self->output_type eq 'treex' ? true : false),
        output_type => $self->output_type,
        has_output_log => ($self->has_output_log ? true : false),
        input_type => $self->input_type,
        token => $self->unique_token,
        last_modified => $self->last_modified->strftime('%Y-%m-%dT%H:%M:%S%z'),
    };
}

=head2 rest_schema

JSON Schema

=cut

sub rest_schema {
    return (
        id => { type => 'number' },
        language => { type => 'string' },
        name => { type => 'string' },
        printable => { type => 'boolean' },
        output_type => { type => 'string' },
        has_output_log => { type => 'boolean' },
        input_type => { type => 'string' },
        token => { type => 'string' },
        last_modified => { type => 'string' }
    )
}

=head2 new

Creates a new instace with a L</unique_token>

=cut

sub new {
    my ( $self, $attrs ) = @_;

    for my $column (@{$self->uuid_columns}) {
        $attrs->{$column} = $self->get_uuid
            unless defined $attrs->{$column};
    }

    return $self->next::method( $attrs );
}

=head2 insert

Inserts new record to the database together with scenario and input

TODO: We need a transaction here

=cut

sub insert {
    my ( $self, $scenario, $input ) = @_;

    my $path = $self->files_path;
    if (!-d $path) {
        File::Path::make_path("$path/") or die "Path: $path, Error: $!";
    }

    # write down scenario file
    $self->scenario($scenario);

    # write input file
    $self->input($input) if $input;

    return $self->next::method();
}

=head2 delete

Deletes record from the database and all related files

=cut

sub delete {
    my $self = shift;

    # remove all files too
    my $path = $self->files_path;
    File::Path::remove_tree("$path/");

    return $self->next::method(@_);
}

=head2 input

get/set input

=cut

sub input {
    my ( $self, $input ) = @_;

    # write down input file
    return $self->_file_rw('input.'.$self->input_type, $input)
        if $self->input_type eq 'txt';
}

=head2 input_file

Set input file

=cut

sub input_file {
    my ( $self, $input_file, $type ) = @_;

    $self->input_type($type);
    my $path = $self->files_path;
    if (!-d $path) {
        File::Path::make_path("$path/") or die "Path: $path, Error: $!";
    }
    my $file = File::Spec->catfile($path, 'input.'.$self->input_type);

    print STDERR "Move $input_file -> $file\n";

    File::Copy::move($input_file, $file) or die "File move failed: $!";
}

=head2 scenario

get/set scenario

=cut

sub scenario {
    my ( $self, $scenario ) = @_;

    if ($scenario) {
        $scenario = $self->_inject_scenario($scenario);
    }

    # write down scenario file
    my $res = $self->_file_rw('scenario.scen', $scenario);

    return $scenario ? $res : $self->_sanitize_scenario($res);
}

=head2 result_filename

Constructs result filename

=cut

sub result_filename {
    my $self = shift;
    return File::Spec->catfile($self->files_path, 'result.'.$self->output_type);
}

=head2 error_log

Gets error log

=cut

sub error_log {
    shift->_file_rw('error.log');
}

=head2 has_output_log

Gets output log

=cut

sub has_output_log {
    my $self = shift;
    my $path = $self->files_path->stringify;
    my $file = File::Spec->catfile($path, 'out.log');
    return -s $file;
}

=head2 output_log

Gets output log

=cut

sub output_log {
    shift->_file_rw('out.log');
}

sub _file_rw {
    my ( $self, $filename, $content ) = @_;

    my $path = $self->files_path->stringify;
    my $file = File::Spec->catfile($path, $filename);

    if (defined $content and $content ne '') {
        open my $fh, '>', $file or die $!;
        utf8::encode($content);
        print $fh $content;
        close $fh;
        return $content;
    } else {
        # ignore too large files
        my $filesize = -s $file;
        if ($filesize > 1024*500) {
            return '';
        }
        open my $fh, '<', $file or return "";
        my $file_contents = do { local $/; <$fh> };
        close $fh;
        utf8::decode($file_contents);
        return $file_contents;
    }
}

sub _sanitize_scenario {
    my ( $self, $scenario ) = @_;

    $scenario =~ s/^\s*((?:Read|Write)::\w+)(?:\s\w+=\S+)*/$1/gim;
    return $scenario;
}

sub _inject_scenario {
    my ( $self, $scenario ) = @_;

    $scenario = $self->_sanitize_scenario($scenario);
    my ($input, $output ) = ('input.'.$self->input_type, 'result.treex');

    # inject write block
    my ($block) = $scenario =~ /Write::(\w+)/;
    if ($block eq 'Text') {
        $output = 'result.txt';
        $self->output_type('txt');
    } elsif ($block eq 'CoNLLX') {
        $output = 'result.conll';
        $self->output_type('conll');
    }
    $scenario =~ s/(Write::\w+)/$1 to=$output/g; # inject output param
    $scenario =~ s/(Read::\w+)/$1 from=$input/g; # inject input param
    return $scenario;
}

=head2 files_path

Constructs a path for current result

=cut

sub files_path {
    my $self = shift;

    my $hash = $self->unique_token;
    return Treex::Web->path_to('data', 'results', substr($hash, 0, 2), $hash);
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;

use utf8;
package Treex::Web::DB::Result::User;

=head1 NAME

Treex::Web::DB::Result::User

=cut

use Moose;
use Catalyst::Authentication::User;
use MooseX::NonMoose;
use boolean;
use MooseX::MarkAsMethods autoclean => 1;
extends 'DBIx::Class::Core';

=head1 COMPONENTS LOADED

=over 4

=item * L<DBIx::Class::InflateColumn::DateTime>

=item * L<DBIx::Class::TimeStamp>

=item * L<DBIx::Class::UUIDColumns>

=back

=cut

__PACKAGE__->load_components('EncodedColumn', 'InflateColumn::DateTime', 'TimeStamp', 'UUIDColumns');
__PACKAGE__->uuid_class('::Data::Uniqid');

=head1 TABLE: C<user>

=cut

__PACKAGE__->table('user');

=head1 ACCESSORS

=head2 id

  data_type: 'integer'
  is_auto_increment: 1
  is_nullable: 0

=head2 email

  data_type: 'varchar'
  size: 120
  is_nullable: 0

=head2 password

  data_type: 'char'
  size: 40
  is_nullable: 0

=head2 active

  data_type: 'boolean'
  default: 0

=head2 is_admin

  data_type: 'boolean'
  default: 0

=head2 activate_token

  data_type: 'char'
  size: 20
  is_nullable: 1
  default: null

=head2 last_modified

  data_type: 'datetime'
  is_nullable: 0

=cut

__PACKAGE__->add_columns(
    'id',
    { data_type => 'integer', is_auto_increment => 1, is_nullable => 0 },
    'email',
    { data_type => 'varchar', size => 120, is_nullable => 0 },
    'name',
    { data_type => 'varchar', size => 120, is_nullable => 1 },
    'password',
    {
        data_type => 'char',
        size => 59,
        is_nullable => 0,
        encode_column => 1,
        encode_class  => 'Crypt::Eksblowfish::Bcrypt',
        encode_args   => { key_nul => 0, cost => 8 },
        encode_check_method => 'check_password',
    },
    'is_admin',
    { data_type => 'boolean', default => 0, is_boolean => 1 },
    'active',
    { data_type => 'boolean', default => 0, is_boolean => 1 },
    'activate_token',
    { data_type => 'char', size => 20, is_nullable => 1 },
    'last_modified',
    {
        data_type => 'datetime',
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

__PACKAGE__->set_primary_key('id');

=head1 UNIQUE CONSTRAINTS

=head2 C<email_unique>

=over 4

=item * L</email>

=back

=cut

__PACKAGE__->add_unique_constraint('email_unique', ['email']);

=head1 RELATIONS

=head2 results

Type: has_many

Related object: L<Treex::Web::DB::Result::Result>

=cut

__PACKAGE__->has_many(
  'results',
  'Treex::Web::DB::Result::Result',
  { 'foreign.user' => 'self.id' },
  { cascade_copy => 0, cascade_delete => 1 },
);

=head2 scenarios

Type: has_many

Related object: L<Treex::Web::DB::Result::Scenario>

=cut

__PACKAGE__->has_many(
    'scenarios',
    'Treex::Web::DB::Result::Scenario',
    { 'foreign.user' => 'self.id' },
    { cascade_copy => 0, cascade_delete => 1},
);

=head1 METHODS

=cut

=head2 new

Creates a new instace with a L</activate_token>

=cut

sub new {
    my ( $self, $attrs ) = @_;

    $attrs->{active} = 0 unless defined $attrs->{active} && $attrs->{active};
    $attrs->{activate_token} = $self->get_uuid
        if $attrs->{active} == 0;
    $attrs->{is_admin} = 0;

    my $new = $self->next::method($attrs);

    return $new;
}

=head2 name_or_email

Returns name or first part of the email

=cut

sub name_or_email {
    my $self = shift;
    my @parts = split /@/, $self->email;
    shift @parts;
}

=head2 REST

REST representation

=cut

sub REST {
    my $self = shift;
    my $all = shift;

    return {
        id => $self->id,
        name => $self->name_or_email,
        ($all ? (
            email => $self->email,
            active => $self->active ? true : false,
            activate_token => $self->activate_token,
            is_admin => $self->is_admin ? true : false,
            last_modified => $self->last_modified->strftime('%Y-%m-%dT%H:%M:%S%z'),
        ) : ())
    };
}

=head2 rest_schema

JSON Schema

=cut

sub rest_schema {
    return (
        id => { type => 'integer', required => 1 },
        name => { type => 'string', required => 1, description => 'If not set part of the email before @ is used' },
        email => { type => 'string', format => 'email', required => 0 },
        active => { type => 'boolean', required => 0 },
        activate_token => { type => 'string', required => 0 },
        is_admin => { type => 'boolean', required => 0 },
        last_modified => { type => 'string', required => 0, description => 'Last modification timestamp' },
    )
}

__PACKAGE__->meta->make_immutable(inline_constructor => 0);
1;

package Resque::Plugin::Status::Manager;

use Moose;
use Data::UUID;
use List::MoreUtils qw/zip/;
use Resque::Plugin::Status::Hash;
use JSON;
use namespace::autoclean;


=head1 NAME

Resque::Plugin::Status::Manager - Provides operations on Redis

=head1 DESCRIPTION

Handling all Redis communication

=head1 METHODS

=cut

has redis => ( is => 'ro', required => 1 );

has encoder => ( is => 'ro', default => sub { JSON->new->utf8->allow_blessed->convert_blessed });

has set_key => ( is => 'rw', isa => 'Str', default => '_statuses' );
has kill_key => ( is => 'rw', isa => 'Str', default => '_kill' );

has uuid_generator => ( is => 'ro', isa => 'Data::UUID', default => sub { Data::UUID->new });

has expire_in => ( is => 'rw', isa => 'Int', default => 0 );

=head2 create

Creates a new status structure L<Resque::Plugin::Status::Hash> with given uuid

=cut

sub create {
    my $self = shift;
    my $uuid = shift;

    my $hash = Resque::Plugin::Status::Hash->new( uuid => $uuid, @_ );
    $self->set($uuid, $hash);
    $self->redis->zadd($self->set_key, time(), $uuid);
    $self->redis->zremrangebyscore($self->set_key, time() - $self->expire_in)
        if $self->expire_in;
    return $uuid;
}

=head2 get

Returns status structure by given uuid

=cut

sub get {
    my ( $self, $uuid ) = @_;
    my $val = $self->redis->get($self->status_key($uuid));
    return unless $val;
    my $hash = $self->decode($val);
    $hash->uuid($uuid);
    return $hash;
}

=head2 decode

Decode status structure from JSON

=cut

sub decode {
    my ( $self, $value ) = @_;
    Resque::Plugin::Status::Hash->new( $self->encoder->decode($value) );
}

=head2 mget

Gets multiple statuses by their uuids

=cut

sub mget {
    my $self = shift;

    my @status_keys = map { $self->status_key($_) } @_;
    my @vals = $self->redis->mget(@status_keys);
    map {
        my $val = pop @vals;
        if ($val) {
            my $hash = $self->decode($val);
            $hash->uuid($_);
            $hash
        } else {
            undef
        }
    } @_;
}

=head2 set

Plain redis set

=cut

sub set {
    my $self = shift;
    my $uuid = shift;

    my $val = (scalar @_ != 1) ? { uuid => $uuid, @_ } : $_[0];
    $self->redis->set($self->status_key($uuid), $self->encoder->encode($val));
    $self->redis->expire($self->status_key($uuid), $self->expire_in)
        if $self->expire_in;
    return $val;
}

=head2 clear

Remove job statuses by in range (NOT USED)

=cut

sub clear {
    my ( $self, $range_start, $range_end ) = @_;
    $self->remove($_) for ($self->status_ids($range_start, $range_end));
}

=head2 clear_completed

By range (NOT USED YET)

=cut

sub clear_completed {
    my ( $self, $range_start, $range_end ) = @_;
    $self->remove($_)
        for (grep { $self->get($_)->is_completed } $self->status_ids($range_start, $range_end));
}

=head2 clear_failed

By range (NOT USED YET)

=cut

sub clear_failed {
    my ( $self, $range_start, $range_end ) = @_;
    $self->remove($_)
        for (grep { $self->get($_)->has_failed } $self->status_ids($range_start, $range_end));
}

=head2 remove

Deletes record from Redis

=cut

sub remove {
    my ( $self, $uuid ) = @_;
    $self->redis->del($self->status_key($uuid));
    $self->redis->zdel($self->set_key, $uuid);
}

=head2 count

Checks how many status structures there are in Redis

=cut

sub count {
    my $self = shift;
    $self->redis->zcard($self->set_key);
}

=head2 statuses

By range (NOT USED YET)

=cut

sub statuses {
    my ( $self, $range_start, $range_end ) = @_;
    return map { $self->get($_) } $self->status_ids($range_start, $range_end);
}

=head2 status_ids

By range (NOT USED YET)

=cut

sub status_ids {
    my ( $self, $range_start, $range_end ) = @_;
    return (defined $range_start and defined $range_end)
        ? ($self->redis->zrevrange($self->set_key, abs($range_start), abs($range_end||1))||())
            : ($self->redis->zrevrange($self->set_key, 0, -1)||());
}

=head2 kill

Marks status for kill by given uuid

=cut

sub kill {
    my ( $self, $uuid ) = @_;
    $self->redis->sadd($self->kill_key, $uuid);
}

=head2 killed

Removes status from kill queue

=cut

sub killed {
    my ( $self, $uuid ) = @_;
    $self->redis->srem($self->kill_key, $uuid);
}

=head2 kill_ids

All ids in the kill queue

=cut

sub kill_ids {
    my $self = shift;
    $self->redis->smembers($self->kill_key);
}

=head2 kill_all

Mark everything as killed by range

=cut

sub kill_all {
    my ( $self, $range_start, $range_end ) = @_;
    $self->kill($_) for ($self->status_ids($range_start, $range_end));
}

=head2 should_kill

Checks whether the uuid is in the kill queue

=cut

sub should_kill {
    my ( $self, $uuid ) = @_;
    $self->redis->sismember($self->kill_key, $uuid);
}

=head2 status_key

Simply creates the status key from uuid

=cut

sub status_key {
    my ( $self, $uuid ) = @_;
    return "status:$uuid";
}

=head2 generate_uuid

Returns new uuid

=cut

sub generate_uuid {
    my $self = shift;
    $self->uuid_generator->create_hex();
}

__PACKAGE__->meta->make_immutable();
1;
__END__

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

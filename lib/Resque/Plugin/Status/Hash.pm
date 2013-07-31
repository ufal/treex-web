package Resque::Plugin::Status::Hash;

use Moose;
use List::MoreUtils qw/none/;
use namespace::autoclean;

=head1 NAME

Resque::Plugin::Status::Hash - Represents status structure in Redis

=head1 SYNOPSIS

   use Resque::Plugin::Status::Hash;

   my $status = Resque::Plugin::Status::Hash->new();

=head1 DESCRIPTION

Helper structure to represent a status in the Redis

=head1 NOTE

TODO: Refactoring needed

=head1 METHODS

=cut

my @STATUSES = qw{queued working completed failed killed};

has uuid => (
    is => 'rw',
    isa => 'Str'
);

has [qw/ name status message time num total /] => ( is => 'rw' );

=head2 BUILD

Constructor automatically sets status to queued

=cut

sub BUILD {
    my $self = shift;

    $self->time(time()) unless $self->time;
    $self->status('queued') unless $self->status;
}

=head2 Status check predicates

=over 2

=item is_queued

=item is_working

=item is_completed

=item has_failed

=item is_killed

=back

=cut

sub is_queued    { $_[0]->status eq 'queued' }
sub is_working   { $_[0]->status eq 'working' }
sub is_completed { $_[0]->status eq 'completed' }
sub has_failed   { $_[0]->status eq 'failed' }
sub is_killed    { $_[0]->status eq 'killed' }

=head2 pct_comlete

How many percent of the job is done (NOT USED)

=cut

sub pct_comlete {
    my $self = shift;

    return 100 if $self->status eq 'completed';
    return 0 if $self->status eq 'queued';
    return int((($self->num||0) / ($self->total||1)) * 100);
}

=head2 is_killable

Predicate whether is possible to kill the job

=cut

sub is_killable {
    my $self = shift;
    none { $_ eq $self->status } qw{failed killed completed};
}

=head2 REST

Returns REST representation (simple hash)

=cut

sub REST {
    my $self = shift;
    return {
        uuid => $self->uuid,
        name => $self->name,
        status => $self->status,
        message => $self->message,
        time => $self->time,
        num => $self->num,
        total => $self->total,
        pct_comlete => $self->pct_comlete
    };
}

=head2 TO_JSON

Alias for REST method

=cut

*TO_JSON = \&REST;

__PACKAGE__->meta->make_immutable;
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

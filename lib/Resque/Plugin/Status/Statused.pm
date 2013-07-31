package Resque::Plugin::Status::Statused;

use Moose::Role;
use Resque::Plugin::Status::Manager;
use Scalar::Util 'blessed';
use namespace::autoclean;

requires qw/redis/;


=head1 NAME

Resque::Plugin::Status::Statused - Role added to Resque

=head1 DESCRIPTION

Enhances every job pushed on queue with a status structure

=head1 METHODS

=cut

has 'status_manager' => (
    is => 'ro',
    isa => 'Resque::Plugin::Status::Manager',
    lazy => 1,
    builder => '_build_status_manager'
);

sub _build_status_manager {
    my $self = shift;

    return Resque::Plugin::Status::Manager->new( redis => $self->redis );
}

=head2 get_status

Gets status from status_manager by it's uuid

=cut

sub get_status {
    my ( $self, $uuid ) = @_;
    $self->status_manager->get($uuid);
}

=head2 set_status

Sets status by it's uuid

=cut

sub set_status {
    my $self = shift;
    my $uuid = shift;

    $self->status_manager->set($uuid, @_);
}

=head2 push

Wrapper around push method adding status structure to Redis

=cut

around 'push' => sub {
    my $orig = shift;
    my ( $self, $queue, $job ) = @_;

    $job = $self->new_job($job) unless blessed($job) && $job->isa('Resque::Job');

    $job->uuid( $self->status_manager->generate_uuid )
        unless $job->uuid;
    $self->status_manager->create($job->uuid);

    if ($self->$orig($queue, $job)) {
        return $job->uuid;
    } else {
        $self->status_manager->remove($job->uuid);
        return undef;
    }
};

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

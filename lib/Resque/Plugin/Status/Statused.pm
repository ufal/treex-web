package Resque::Plugin::Status::Statused;

use Moose::Role;
use Resque::Plugin::Status::Manager;
use Scalar::Util 'blessed';
use namespace::autoclean;

requires qw/redis/;

has 'status_manager' => (
    is => 'ro',
    isa => 'Resque::Plugin::Status::Manager',
    lazy => 1,
    builder => 'build_status_manager'
);

sub build_status_manager {
    my $self = shift;

    return Resque::Plugin::Status::Manager->new( redis => $self->redis );
}

sub get_status {
    my ( $self, $uuid ) = @_;
    $self->status_manager->get($uuid);
}

sub set_status {
    my $self = shift;
    my $uuid = shift;

    $self->status_manager->set($uuid, @_);
}

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

=head1 NAME

Resque::Plugin::Status::Statused - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Resque::Plugin::Status::Statused;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Resque::Plugin::Status::Statused,

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

Michal Sedlak, E<lt>sedlakmichal@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

package Resque::Plugin::Status::Job;

use Moose::Role;
use Moose::Util::TypeConstraints;
use Resque::Plugin::Status::Hash;
use DateTime;
use namespace::autoclean;

use Exception::Class (
    'Resque::Plugin::Status::Exception::Killed' => {
        description => 'Job has been killed'
    }
);

requires qw / resque /;


=head1 NAME

Resque::Plugin::Status::Job - Role added to Resque::Job

=head1 METHODS

=cut

has uuid => (
    is => 'rw',
    isa => 'Str'
);

has killed => ( is => 'rw', default => sub{0} );

has resque  => (
    is      => 'rw',
    handles => [qw/ redis status_manager /],
    default => sub { confess "This Resque::Job isn't associated to any Resque system yet!" }
);

has payload => (
    is   => 'ro',
    isa  => 'HashRef',
    coerce => 1,
    lazy => 1,
    default => sub {{
        class => $_[0]->class,
        args  => $_[0]->args,
        uuid  => $_[0]->uuid,
    }},
    trigger => sub {
        my ( $self, $hr ) = @_;
        $self->class( $hr->{class} );
        $self->args( $hr->{args} ) if $hr->{args};
        $self->uuid( $hr->{uuid} ) if $hr->{uuid};
    }
);

=head2 status

Get status based on current uuid

=cut

sub status {
    return $_[0]->uuid ? $_[0]->resque->get_status($_[0]->uuid) : undef;
}

=head2 set_status

Will set a new status calling C<< $self->resque->set_status >>

=cut

sub set_status {
    my $self = shift;
    my $status = $self->status;
    return unless $status; # doesn't have status

    my %params;
    if ( scalar @_ == 1 ) {
        die "Single parameters to set_status() must be a HASH ref"
            unless defined $_[0] && ref $_[0] eq 'HASH';
        %params = %{$_[0]};
    } else {
        %params = @_; # TODO check number of arguments
    }

    foreach my $key (keys %params) {
        $status->$key($params{$key});
    }
    $self->resque->set_status($self->uuid, $status);
}

after 'perform' => sub {
    return if $_[0]->killed;
    my $status = $_[0]->status;
    $_[0]->completed if $status && $status->is_working;
};

after 'fail' => sub {
    return if $_[0]->killed;
    my $status = $_[0]->status;
    $_[0]->failed if $status && $status->is_working;
};


=head2 at

Reporting method, NOT USED

=cut

sub at {
    my $self = shift;
    my $num = shift;
    my $total = shift;
    $self->tick(
        num => $num,
        total => $total,
        @_
    );
}

=head2 tick

Updates status by either killing it or continues working on ti

=cut

sub tick {
    my $self = shift;
    $self->kill if $self->should_kill;
    $self->set_status(status => 'working', @_);
}

=head2 failed

Sets status to failed. Message is optional

=cut

sub failed {
    my $self = shift;
    my $message = shift;
    return if $self->killed;
    $self->set_status(
        status => 'failed',
        ($message ? (message => $message) : ()),
        @_
    );
}

=head2 completed

Marks job as completed

=cut

sub completed {
    my $self = shift;
    return if $self->killed;
    $self->set_status(
        status => 'completed',
        message => 'Completed at '.DateTime->now->strftime("%Y/%m/%d %H:%M:%S %Z"),
        @_
    );
}

=head2 kill

Kills job and sets status to killed

=cut

sub kill {
    my ( $self, $no_throw ) = @_;
    $self->set_status(
        status => 'killed',
        message => 'Killed at '.DateTime->now->strftime("%Y/%m/%d %H:%M:%S %Z"),
        @_
    );
    $self->killed(1);
    $self->status->status_manager->killed($self->uuid);
    Resque::Plugin::Status::Exception::Killed->throw unless $no_throw;
}

=head2 should_kill

Checks through status_manager whether the status can and should be
killed

=cut

sub should_kill {
    $_[0]->status_manager->should_kill($_[0]->uuid)
}

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

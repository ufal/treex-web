package Resque::Plugin::Status::Job;

use Moose::Role;
use Moose::Util::TypeConstraints;
use Resque::Plugin::Status::Hash;
use DateTime;
use namespace::autoclean;

requires qw / resque /;

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

sub status {
    return $_[0]->uuid ? $_[0]->resque->get_status($_[0]->uuid) : undef;
}

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
        %params = @_;
    }

    foreach my $key (keys %params) {
        $status->$key($params{$key});
    }
    $self->resque->set_status($self->uuid, $status);
}

after 'perform' => sub { $_[0]->completed };

after 'fail' => sub { $_[0]->failed };

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

sub tick {
    my $self = shift;
    $self->kill if $self->should_kill;
    $self->set_status(status => 'working', @_);
}

sub failed {
    my $self = shift;
    return if $self->killed;
    $self->set_status(
        status => 'failed',
        @_
    );
}

sub completed {
    my $self = shift;
    return if $self->killed;
    $self->set_status(
        status => 'completed',
        message => 'Completed at '.DateTime->now->strftime("%Y/%m/%d %H:%M:%S %Z"),
        @_
    );
}

sub kill {
    my ( $self, $no_die ) = @_;
    $self->set_status(
        status => 'killed',
        message => 'Killed at '.DateTime->now->strftime("%Y/%m/%d %H:%M:%S %Z"),
        @_
    );
    $self->killed(1);
    die 'Killed' unless $no_die;
}

sub should_kill {
    $_[0]->status_store->should_kill($_[0]->uuid)
}

1;
__END__

=head1 NAME

Resque::Plugin::Status::Job - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Resque::Plugin::Status::Job;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Resque::Plugin::Status::Job,

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

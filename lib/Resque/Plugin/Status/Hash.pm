package Resque::Plugin::Status::Hash;

use Moose;
use List::MoreUtils qw/none/;
use namespace::autoclean;

my @STATUSES = qw{queued working completed failed killed};

has uuid => (
    is => 'rw',
    isa => 'Str'
);

has [qw/ name status message time num total /] => ( is => 'rw' );

sub BUILD {
    my $self = shift;

    $self->time(time()) unless $self->time;
    $self->status('queued') unless $self->status;
}

sub is_queued    { $_[0]->status eq 'queued' }
sub is_working   { $_[0]->status eq 'working' }
sub is_completed { $_[0]->status eq 'completed' }
sub has_failed   { $_[0]->status eq 'failed' }
sub is_killed    { $_[0]->status eq 'killed' }

sub pct_comlete {
    my $self = shift;

    return 100 if $self->status eq 'completed';
    return 0 if $self->status eq 'queued';
    return int((($self->num||0) / ($self->total||1)) * 100);
}

sub is_killable {
    my $self = shift;
    none { $_ eq $self->status } qw{failed killed completed};
}

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

*TO_JSON = \&REST;

__PACKAGE__->meta->make_immutable;
1;
__END__

=head1 NAME

Resque::Plugin::Status::Hash - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Resque::Plugin::Status::Hash;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Resque::Plugin::Status::Hash,

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

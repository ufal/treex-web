package Resque::Plugin::Status::Worker;

use Moose::Role;
use namespace::autoclean;

=head1 NAME

Resque::Plugin::Status::Worker - Role added to Resque::Worker

=head1 DESCRIPTION

Hooks worker's methods to ensure correct status change

=head1 METHODS

=cut

has current_job => ( is => 'rw' );

=head2 perform

Wrapper around perform method to ensure the status is set to 'working'

=cut

around 'perform' => sub {
    my $orig = shift;
    my ( $self, $job ) = @_;

    $self->current_job($job);
    $job->set_status(status => 'working');

    # we are done here
    my $ret = $self->$orig($job);
    $self->current_job(undef);
    return $ret;
};

after 'kill_child' => sub {
    my $self = shift;
    return unless $self->current_job;
    unless ($self->current_job->killed) {
        $self->current_job->kill(1); # kill but don't call die
    }
    $self->current_job(undef);
};

1;
__END__

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

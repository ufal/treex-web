package Resque::Plugin::Status;
use Resque::Plugin;
use Resque::Plugin::Status::Statused;
use Resque::Plugin::Status::Job;
use Resque::Plugin::Status::Worker;
use namespace::autoclean;

add_to resque => 'Status::Statused';
add_to job => 'Status::Job';
add_to worker => 'Status::Worker';

1;
__END__

=head1 NAME

Resque::Plugin::Status - Plugin for L<Resque>

=head1 DESCRIPTION

This plugin add additional status structure to Redis providing a
status management for each job

TODO: more description

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

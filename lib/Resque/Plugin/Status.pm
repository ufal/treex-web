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

Resque::Plugin::Status - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Resque::Plugin::Status;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Resque::Plugin::Status,

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

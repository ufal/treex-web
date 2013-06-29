package Treex::Web::Api;

use Moose;
use Swagger;
use MooseX::ClassAttribute;
use namespace::autoclean;

our $API_VERSION = '1';

class_has api => (
    isa => 'Swagger',
    is  => 'ro',
    default => sub { Swagger->new(api_version => $API_VERSION) },
);

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Treex::Web::Api - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Api;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Api,

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

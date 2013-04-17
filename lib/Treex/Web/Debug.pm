package Treex::Web::Debug;

use Moose;
use MRO::Compat;
use JSON;
use namespace::clean -except => 'meta';

my $json = JSON->new->allow_nonref->pretty;
sub log_data {
    my $c = shift;

    return unless $c->debug;
    $c->maybe::next::method(@_);
    $c->log->debug("Request data:");
    $c->log->debug($json->encode($c->req->data));
}

1;
__END__

=head1 NAME

Treex::Web::Debug - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Debug;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Debug,

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

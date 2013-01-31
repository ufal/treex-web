#!/usr/bin/env perl
# deploy_theschwartz.pl     sedlakmichal@gmail.com     2013/01/28 12:56:51

our $VERSION="0.1";

use warnings;
use strict;
$|=1;

use Path::Class::File;
use File::Spec;

use Getopt::Long;
use Pod::Usage;
Getopt::Long::Configure ("bundling");
my %opts;
GetOptions(\%opts,
#       'debug|D',
#       'quiet|q',
        'help|h',
        'usage|u',
        'version|V',
        'man',
       ) or $opts{usage}=1;

if ($opts{usage}) {
  pod2usage(-msg => 'deploy_theschwartz.pl');
}
if ($opts{help}) {
  pod2usage(-exitstatus => 0, -verbose => 1);
}
if ($opts{man}) {
  pod2usage(-exitstatus => 0, -verbose => 2);
}
if ($opts{version}) {
  print "$VERSION\n";
  exit;
}

my $self = Path::Class::File->new( File::Spec->rel2abs( $0 ) );
my $app_dir = $self->parent->parent;

my $database = Path::Class::File->new( $app_dir,
                                       "share",
                                       "theschwartz.db" );

my $schema = Path::Class::File->new( $app_dir,
                                     "share",
                                     "etc",
                                     "theschwartz_sqlite_schema.sql" );

-e $schema or die "Schema does not exist: $schema";

$database->remove if -e $database;

0 == system("sqlite3 $database < $schema")
    or die "Couldn't load schema into db: sqlite3 $database < $schema";


__END__

=head1 NAME

deploy_theschwartz.pl

=head1 SYNOPSIS

deploy_theschwartz.pl
or
  deploy_theschwartz.pl -u          for usage
  deploy_theschwartz.pl -h          for help
  deploy_theschwartz.pl --man       for the manual page
  deploy_theschwartz.pl --version   for version

=head1 DESCRIPTION

Stub documentation for deploy_theschwartz.pl,

=over 5

=item B<--usage|-u>

Print a brief help message on usage and exits.

=item B<--help|-h>

Prints the help page and exits.

=item B<--man>

Displays the help as manual page.

=item B<--version>

Print program version.

=back

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

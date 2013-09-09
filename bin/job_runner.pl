#!/usr/bin/env perl
# job_runner.pl     sedlakmichal@gmail.com     2013/01/29 00:52:43

our $VERSION="0.1";

use warnings;
use strict;
$|=1;

use FindBin;
use lib "$FindBin::Bin/../lib";
use Config::Any;

use Path::Class::File;
use File::Spec;
use Resque;

use Getopt::Long;
use Pod::Usage;
Getopt::Long::Configure ("bundling");
my %opts;
GetOptions(\%opts,
           'remote|r=s',
           'user|u=s',
           'password|p=s',
           'port=s',
           'help|h',
           'version|V',
           'man',
       ) or $opts{usage}=1;

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

$ENV{'TREEX_WEB_DATA'} = File::Spec->catdir($app_dir, 'data');

if ($opts{remote}) {            # setup remote
    $ENV{'TREEX_REMOTE'} = 1;
    $ENV{'TREEX_REMOTE_HOST'} = $opts{remote};
    $ENV{'TREEX_REMOTE_USER'} = $opts{user};
    $ENV{'TREEX_REMOTE_PASS'} = $opts{password};
    $ENV{'TREEX_REMOTE_PORT'} = $opts{port};
}
#print STDERR $ENV{'TREEX_WEB_DATA'}."\n";

my $config_file = Path::Class::File->new($app_dir, 'share', 'etc', 'treex_web.pl' );

# A bit of custom config riding/hacking to use the application's
# config for the DB.
my $config = Config::Any->load_files({
    files => [$config_file],
    use_ext => 1,
});
$config = $config->[0]->{$config_file};

my $args = $config->{"Model::Resque"}->{args};

my $w = Resque->new( $args )->worker;
$w->add_queue('treex');
$w->verbose(1);
$w->work;

__END__

=head1 NAME

job_runner.pl

=head1 SYNOPSIS

job_runner.pl

or

  job_runner.pl --remote=host --user=username --password=pwd
  For running on a remote machine

or

  job_runner.pl -h          for help
  job_runner.pl --man       for the manual page
  job_runner.pl --version   for version

=head1 DESCRIPTION

Stub documentation for job_runner.pl,

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

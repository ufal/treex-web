#!/usr/bin/perl -w
# treex_web_gen_schema.pl --- Schema and diff generation script
# Author: Michal Sedlák <sedlakmichal@gmail.com>
# Created: 16 Feb 2012
# Version: 0.01

use warnings;
use strict;

use FindBin;
use File::Spec;
use File::Path qw(make_path);
use lib "$FindBin::Bin/../lib";
use Config::General qw(ParseConfig);

use Pod::Usage;
use Getopt::Long;
use Treex::Web::DB;

my ( $preversion, $help );
GetOptions(
    'p|preversion:s'  => \$preversion,
    'help|?'          => \$help,
) or pod2usage(2);
pod2usage(1) if $help;


my %web_config = ParseConfig("$FindBin::Bin/../treex_web.conf");

my $schema = Treex::Web::DB->connect(
    $web_config{dsn}, $web_config{db_user}, $web_config{db_pwd}
);
my $version = $schema->schema_version();

if ($version && $preversion) {
    print "creating diff between version $version and $preversion\n";
} elsif ($version && !$preversion) {
    print "creating full dump for version $version\n";
} elsif (!$version) {
    print "creating unversioned full dump\n";
}

my @supported_databases = $preversion ? ($web_config{database},) : ('MySQL', 'SQLite', 'PostgreSQL');

map {
    #my $dbname = $_;
    my $sql_dir = File::Spec->catdir($FindBin::Bin, '..', 'sql', $_);
    make_path($sql_dir) unless -d $sql_dir;
    
    $schema->create_ddl_dir( $_, $version, $sql_dir, $preversion );
} @supported_databases;

__END__

=head1 NAME

treex_web_gen_schema.pl - Describe the usage of script briefly

=head1 SYNOPSIS

treex_web_gen_schema.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for treex_web_gen_schema.pl, 

=head1 AUTHOR

Michal Sedlák, E<lt>sedlakmichal@gmail.com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Michal Sedlák

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

#!/usr/bin/perl -w
# treex_web_upgrade_db.pl --- This script checks to see if any sql diffs need to be applied.
# Author: Michal Sedlak <sedlakmichal@gmail.com>
# Created: 17 Feb 2012
# Version: 0.01

use warnings;
use strict;

use FindBin;
use File::Spec;
use lib "$FindBin::Bin/../lib";
use Config::General qw(ParseConfig);

use Treex::Web::DB;

my %web_config = ParseConfig("$FindBin::Bin/../treex_web.conf");

my $sql_dir = File::Spec->catdir($FindBin::Bin, '..', 'sql', $web_config{database});
Treex::Web::DB->upgrade_directory($sql_dir);

my $schema = Treex::Web::DB->connect(
    $web_config{dsn}, $web_config{db_user}, $web_config{db_pwd}
);

if (!$schema->get_db_version()) {
    # schema is unversioned
    print "deploying new schema\n";
    $schema->deploy();
} else {
    print "upgrading database to the newest schema\n";
    $schema->upgrade();
}

__END__

=head1 NAME

treex_web_upgrade_db.pl - Describe the usage of script briefly

=head1 SYNOPSIS

treex_web_upgrade_db.pl [options] args

      -opt --long      Option description

=head1 DESCRIPTION

Stub documentation for treex_web_upgrade_db.pl, 

=head1 AUTHOR

Michal Sedlak, E<lt>sedlakmichal@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

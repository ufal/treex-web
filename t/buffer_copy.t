#!/usr/bin/perl -Iblib/lib -Iblib/arch -I../blib/lib -I../blib/arch
#
# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl buffer_copy.t'

# Test file created outside of h2xs framework.
# Run this like so: `perl buffer_copy.t'
#   Michal Sedlak <sedlakmichal@gmail.com>     2012/03/08 16:30:33

#########################

# This file exist merely to test File::Copy and copying from in-memory handles

use Test::More tests => 7;

BEGIN { use_ok(qw/File::Copy/); use_ok(qw/File::Slurp/); use_ok(qw/IO::Scalar/); }

# create in-memory file
my $buffer = "some content";

my $in_memory = IO::Scalar->new(\$buffer);
is($buffer, <$in_memory>, 'buffer is ok');
$in_memory->seek(0,0);

my $tmp_file = "tmp_file";
ok(copy($in_memory, $tmp_file), "copy is ok");
diag "Error 'stat() on unopened filehandle FH at /usr/share/perl/5.12/File/Copy.pm line 150.' can be ignored.";

ok(-f $tmp_file, "tmpfile exists");

my $file_content = read_file($tmp_file);

is($buffer, $file_content, "tmpfile contains buffer content");

END { unlink $tmp_file; }

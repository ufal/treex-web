#!/usr/bin/env perl
# dirtree.pl     sedlakmichal@gmail.com     2013/07/07 12:15:43
# Based on Arjen Bax's script

our $VERSION="0.1";

use warnings;
use strict;
$|=1;

use File::Find;

my $top = shift @ARGV;
die "specify top directory\n" unless defined $top;
chdir $top or die "cannot chdir to $top: $!\n";

find(sub {
         local $_ = $File::Find::name;
         my @F = split '/';
         printf ".%d %s.\n", scalar @F, @F==1 ? $top : $F[-1];
     }, '.');

#!/usr/bin/env perl
# user.pl     sedlakmichal@gmail.com     2013/07/24 04:11:51

our $VERSION="0.1";

use warnings;
use strict;
$|=1;

use FindBin;
use lib "$FindBin::Bin/../lib";

use Getopt::Long;
use Pod::Usage;
use Treex::Web;
use IO::Prompter;
use Email::Valid;

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
  pod2usage(-msg => 'user.pl');
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

my $selection;
my $db = Treex::Web->model('WebDB::User');

sub enter_password {
    my ($password, $password_confirm);

    while (!$password || !$password_confirm || $password eq $password_confirm) {
        $password = prompt "Enter password:", -echo => '*', -must => {
            'at least 6 characters long' => sub { length($_[0]||'') >= 6 },
        };
        $password_confirm = prompt "Confirm password", -echo => '*';
        last if $password && $password eq ($password_confirm||'');
        print "Passwords doesn't match.";
    }
    return $password;
}

do {
    $selection = (prompt 'Choose wisely...', -menu => [ 'create', 'update', 'remove', 'quit' ], '>') || '';

    if ($selection eq 'create') {
        my $email = prompt "Enter email:",
            -must => {
                'be valid' => sub { Email::Valid->address(shift) },
                'not already exist' => sub { $db->search({ email => ($_[0]||'') })->count == 0 }
            };
        my $password = enter_password();
        my $name = prompt "Username (optional):";

        if ($email and $password) {
            my $user = $db->new_result({
                email => "$email",
                password => "$password",
                ("$name" ? (name => "$name") : ()),
                is_admin => 0,
                active => 1,
            });
            $user->insert;
            print "User saved\n";
        }
    } elsif ($selection eq 'update') {
        my $email = prompt "Enter email:",
            -complete => [ map { $_->email } $db->all ],
                -must => {
                    'be valid' => sub { Email::Valid->address(shift) },
                    'exist' => sub { $db->search({ email => ($_[0]||'') })->count == 1 }
                };
        my $password = enter_password();
        my $name = prompt "Username (optional):";

        if ($email and $password) {
            my $user = $db->single({email => "$email"});
            die "Can't fetch user" unless $user;
            $user->password("$password");
            $user->name("$name"||undef);
            $user->update;
            print "User updated\n";
        }
    } elsif ($selection eq 'remove') {
        my $email = prompt "Enter email:",
            -complete => [ map { $_->email } $db->all ],
                -must => {
                    'be valid' => sub { Email::Valid->address(shift) },
                    'exist' => sub { $db->search({ email => ($_[0]||'') })->count == 1 }
                };
        my $user = $db->search({email => "$email"})->first;
        die "Can't fetch user" unless $user;
        my $yes = prompt("Do you want to delete the user? ", -yn1 );
        if ($yes) {
            $user->delete;
            print "User deleted\n";
        }
    }
} while ($selection && $selection ne 'quit');


__END__

=head1 NAME

user.pl

=head1 SYNOPSIS

user.pl
or
  user.pl -u          for usage
  user.pl -h          for help
  user.pl --man       for the manual page
  user.pl --version   for version

=head1 DESCRIPTION

Stub documentation for user.pl,

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

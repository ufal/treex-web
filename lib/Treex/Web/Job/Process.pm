package Treex::Web::Job::Process;

use strict;
use warnings;
use Cwd;
use File::Path qw(make_path);
use File::Spec;
use Try::Tiny;
use Scalar::Util 'blessed';
use Exception::Class (
    'Treex::Web::Job::Exception::TimedOut' => {
        description => 'Treex job has timed out'
    }
);
use IPC::Run qw(run harness start finish timeout);
use Net::SSH::Perl;
use Net::SFTP;

use Net::SFTP::Constants qw(
                               SSH2_FILEXFER_ATTR_PERMISSIONS
                               SSH2_FILEXFER_VERSION );
use Net::SFTP::Attributes;

=head1 NAME

Treex::Web::Job::Process - Job for executing treex commands

=head1 DESCRIPTION

Run the Treex using L<IPC::Run>

=head1 METHODS

=head2 perform

The method executed by Resque worker

=cut

sub perform {
    my $job = shift;

    my $data_dir = $ENV{'TREEX_WEB_DATA'};
    my $remote = $ENV{'TREEX_REMOTE'};
    die "No data dir in environment" unless $data_dir;

    my $key = $job->uuid;
    my $result_dir = File::Spec->catdir(
        $data_dir,
        'results',
        substr($key, 0, 2),
        $key
    );

    make_path("$result_dir/"); # make sure the dir exists
    print "Result dir: $result_dir\n";
    chdir $result_dir or die "Switch to result_dir has failed.";

    return $remote ? run_remote($job) : run_local($job);
}

sub run_local {
    my $job = shift;
    my $lang = $job->args->[0];

    # Form a command
    my @cmd = qw(treex);# -Len Read::Text scenario.scen Write::Treex to=-);
    push @cmd, "-L$lang" if $lang;
    push @cmd, "scenario.scen";

    open my $err, ">error.log" or die $!;
    my $timeout = 5*60; # 5 minutes
    my ( $ret, $h );
    try {
        $h = harness \@cmd, '<', \undef, '>&', $err, (my $t = timeout($timeout, exception => Treex::Web::Job::Exception::TimedOut->new()));
        $h->start;
        $h->{non_blocking}   = 0;
        $h->{auto_close_ins} = 1;
        $h->{break_on_io}    = 0;
        while ($h->pumpable) {
            $h->_select_loop;
            $job->at($t->end_time - $t->start_time, $timeout);
            sleep(1);
        }
        $ret = $h->finish;
        if (not $ret) {
            $job->failed('Treex failed to execute the scenario');
        }
    } catch {
        if (blessed $_) {
            if ( $_->isa('Resque::Plugin::Status::Exception::Killed') ) {
                # ok we have been killed
            } elsif ( $_->isa('Treex::Web::Job::Exception::TimedOut')) {
                $job->failed($_->description);
            }
        } else {
            $job->failed($_);
        }
        $h->kill_kill(grace => 5); # this can also throw
    };

    return $ret;
}

sub run_remote {
    my $job = shift;
    my $key = $job->uuid;
    my $remote_path = "/tmp/tw-$key";

    my ($host, $user, $pass) =
        @ENV{qw(TREEX_REMOTE_HOST TREEX_REMOTE_USER TREEX_REMOTE_PASS)};

    print "Connect using: $user\@${host} with password: '$pass'\n";

    my $sftp = Net::SFTP->new($host, $user ? (user => $user, ($pass ? (password => $pass) : ())) : ());

    my $a = Net::SFTP::Attributes->new;
    $a->flags( $a->flags | SSH2_FILEXFER_ATTR_PERMISSIONS );
    $a->perm(0777);
    $sftp->do_mkdir($remote_path, $a);

    $sftp->put($_, "$remote_path/$_") for (glob('*')); # copy all files from local directory to remote

    my $ssh = Net::SSH::Perl->new($host);
    $ssh->login($user, $pass) if $user;

    my($stdout, $stderr, $exit) = $ssh->cmd("source ~/.profile; cd $remote_path; treex scenario.scen >error.log 2>&1");

    if ($exit) {
        $job->failed('Treex failed to execute the scenario');
    }

    $sftp->ls($remote_path, sub {
                  my $filename = shift->{filename};
                  return if $filename eq '.' || $filename eq '..';
                  print "$filename\n";
                  $sftp->get("$remote_path/".$filename, $filename);
                  $sftp->do_remove("$remote_path/".$filename);
              });
    $sftp->do_rmdir($remote_path);
}

1;
__END__

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

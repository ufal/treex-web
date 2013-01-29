package Treex::Web::Job::Treex;
use Moose;
use TheSchwartz::Job;
use Cwd;
use Treex::Web;
use File::Path qw(make_path);
use IPC::Run;

extends 'TheSchwartz::Worker';

sub keep_exit_status_for { 7 * 24 * 60 * 60 } # 7 days

sub work {
    my $class = shift;
    my TheSchwartz::Job $job = shift;

    my $lang = $job->arg->{lang};
    my $key = $job->uniqkey;
    my $result_dir = Treex::Web->path_to(
        'data',
        'results',
        substr($key, 0, 2),
        $key
        );

    make_path("$result_dir/"); # make sure the dir exists
    print "Resul dir: $result_dir\n";
    chdir $result_dir  or die "Switch to result_dir has failed.";
    print getcwd;

    # Form a command
    my @cmd = qw(treex);# -Len Read::Text scenario.scen Write::Treex to=-);
    push @cmd, "-L$lang";
    push @cmd, "Read::Text from=input.txt";
    push @cmd, "scenario.scen";
    push @cmd, "Write::Treex to=result.treex";

    open my $err, ">error.log" or die $!;
    my $ret;
    eval { $ret = IPC::Run::run \@cmd, '<', \undef, '>&', $err; };
    if ($@) {
        $job->permanent_failure($@, 1);
    } elsif (not $ret) {
        $job->permanent_failure('Treex failed to execute the scenario', $ret);
    } else {
        $job->completed;
    }

    # Write jobid and wall time to the file
    open my $jid, ">stats" or die $!;
    print $jid $job->jobid;
    close $jid;

}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Treex::Web::Job::Treex - TheSchwartz::Job for executing treex commands

=head1 SYNOPSIS

   use Treex::Web::Job::Treex;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Job::Treex,

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

package Treex::Web::Job::Process;
use Cwd;
use File::Path qw(make_path);
use File::Spec;
use IPC::Run;

sub perform {
    my $job = shift;

    my $data_dir = $ENV{'TREEX_WEB_DATA'};
    die "No data dir in environment" unless $data_dir;

    my $lang = $job->args->[0];
    my $key = $job->uuid;
    my $result_dir = File::Spec->catdir(
        $data_dir,
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
        $job->failed($@);
    } elsif (not $ret) {
        $job->failed('Treex failed to execute the scenario');
    }

    return $ret;
}
1;
__END__

=head1 NAME

Treex::Web::Job::Process - Job for executing treex commands

=head1 SYNOPSIS

   use Treex::Web::Job::Process;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Job::Process,

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

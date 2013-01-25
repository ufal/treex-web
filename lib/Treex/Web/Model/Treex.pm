package Treex::Web::Model::Treex;
use Moose;
use IPC::Run;
use IO::String;
use namespace::autoclean -except => 'meta';

extends 'Catalyst::Model';

=head1 NAME

Treex::Web::Model::Treex - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 METHODS

=cut

sub run {
  my ( $self, $opts ) = @_;
  $opts||={};

  my ($ret, @cmd, $out, $err,
      $scenario, $input_ref, $lang);

  @cmd = qw(treex);# -Len Read::Text scenario.scen Write::Treex to=-);
  $input_ref = $opts->{input_ref};
  $scenario = $opts->{scenario} ? $opts->{scenario} : 'scenario.scen';
  $lang = $opts->{lang} ? $opts->{lang} : 'en';

  push @cmd, "-L$lang";
  push @cmd, "Read::Text";
  push @cmd, "$scenario";
  push @cmd, "Write::Treex to=-";
  if ($$input_ref ne '') {
      $ret = IPC::Run::run \@cmd, $input_ref, \$out, \$err;
  }

  # map in/out/err to file handles
  my $in_handle = IO::String->new($input_ref);
  my $out_handle = IO::String->new(\$out);
  my $err_handle = IO::String->new(\$err);

  # my $in_handle = File::Temp->new(UNLINK => 0);
  # print $in_handle $$input_ref;
  # my $out_handle = File::Temp->new(UNLINK => 0);
  # print $out_handle $out;
  # my $err_handle = File::Temp->new(UNLINK => 0);
  # print $err_handle $err;

  $opts = {
           %$opts,
           input => $in_handle,
           out => $out_handle,
           err => $err_handle,
           cmd => join(' ', @cmd),
           ret => $ret
       };

  return $opts;
}

=head1 AUTHOR

THC,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

package Treex::Web::Model::Treex;
use Moose;
use IPC::Run;
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
  
  my ($ret, @cmd, $in, $out, $err,
      $scenario, $lang);
  
  @cmd = qw(treex);# -Len Read::Text scenario.scen Write::Treex to=-);
  $in = $opts->{text};
  $scenario = $opts->{scenario} ? $opts->{scenario} : 'scenario.scen';
  $lang = $opts->{lang} ? $opts->{lang} : 'en';
  
  push @cmd, "-L$lang";
  push @cmd, "Read::Text";
  push @cmd, "$scenario";
  push @cmd, "Write::Treex to=-";
  if ($in ne '') {
    $ret = IPC::Run::run \@cmd, \$in, \$out, \$err;
  }
  
  $opts = {
           %$opts,
           out => $out,
           err => $err,
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

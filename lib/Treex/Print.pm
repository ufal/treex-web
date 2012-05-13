package Treex::Print;

use Moose;

use File::Spec;
use Treex::Core::Config;
use Treex::Core::TredView;

use lib File::Spec->catdir(Treex::Core::Config->tred_dir, 'tredlib', 'libs', 'tk');

use TrEd::Print;
use TrEd::Config;
use TrEd::Utils qw(readStyleSheetFile);

use namespace::clean -except => 'meta';

# fake TredMacro package so that TMT TrEd macros can be used directly
{
  package TredMacro;
  use List::Util qw(first);
  use vars qw($this $root $grp @EXPORT);
  @EXPORT=qw($this $root $grp FS first GetStyles AddStyle, ListV);
  use Exporter 'import';
  sub FS { $grp->{FSFile}->FS } # used by TectoMT_TredMacros.mak
  sub GetStyles {               # used by TectoMT_TredMacros.mak
      my ($styles,$style,$feature)=@_;
      my $s = $styles->{$style} || return;
      if (defined $feature) {
          return $s->{ $feature };
      } else {
          return %$s;
      }
  }
  
  sub AddStyle {
      my ($styles,$style,%s)=@_;
      if (exists($styles->{$style})) {
          $styles->{$style}{$_}=$s{$_} for keys %s;
      } else {
          $styles->{$style}=\%s;
      }
  }

  sub ListV {
      UNIVERSAL::DOES::does($_[0], 'Treex::PML::List') ? @{$_[0]} : ()
  }


  # maybe more will be needed for drawing arrows, need example
}


sub svg {
    my ($self, $file, $tree,) = @_;
    $tree ||= 1;
    
    my $ext_dir = Treex::Core::Config->tred_extension_dir;

    my $macros = File::Spec->catfile($ext_dir, 'treex', 'contrib', 'treex', 'contrib.mac');
    my $stylesheet = File::Spec->catfile($ext_dir, 'treex', 'stylesheets', 'Treex_stylesheet');
        
    my $style = readStyleSheetFile({}, $stylesheet);

    
    # initialize file
    $TredMacro::grp={ FSFile=>$file };
    require $macros;
    Treex_mode::file_opened_hook();

    #my $tredview = Treex::Core::TredView->new(grp=>{ FSFile=>$TredMacro::grp });
    #print "Grp: ". $tredview->grp->{FSFile} . "\n";
    #$tredview->file_opened_hook();
    
    my $svg = TrEd::Print::Print({
      -fsfile => $file,
      -styleSheetObject => $style,
      -to => 'string',
      -format => 'SVG',
      -range => $tree,
      -quiet => 0,
      -onGetRootStyle => sub {
          my ($treeview, $bundle, $styles)=@_;
          return Treex_mode::root_style_hook($bundle, $styles);
      },
      -onGetNodes => sub{
          my ($treeview,$fsfile,$treeNo,$currentNode)=@_;
          return ($TredMacro::grp->{Nodes},$TredMacro::grp->{currentNode})=
              @{Treex_mode::get_nodelist_hook($fsfile, $treeNo, $currentNode)};
      },
      -onGetNodeStyle => sub {
          my ($treeview, $node, $styles)=@_;
          return Treex_mode::node_style_hook($node,$styles);
      },
    });
}


1;
__END__

=head1 NAME

Treex::Print - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Print;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Print, 

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

Copyright (C) 2012 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

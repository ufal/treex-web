package Treex::Web::Model::Print;
use Moose;
use File::Spec;
use Treex::Core::Document;
use Treex::Core::TredView;
use Treex::PML::Factory;
use Treex::View::TreeLayout;
use Treex::View::Node;
use JSON;
use namespace::autoclean;

extends 'Catalyst::Model';

has 'tree_layout' => (
    is => 'ro',
    isa => 'Treex::View::TreeLayout',
    default => sub { Treex::View::TreeLayout->new },
);

# fake TredMacro package so that TMT TrEd macros can be used directly
{
  package TredMacro;
  use List::Util qw(first);
  use vars qw($this $root $grp @EXPORT);
  @EXPORT=qw($this $root $grp FS first GetStyles AddStyle ListV);
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

sub process {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $file = $curr->result_filename;

    $file = '/home/thc/src/Treex-Web/test.treex';

    -e $file or return '';

    my $doc = Treex::Core::Document->new({ filename => $file });
    $self->tree_layout->treex_doc($doc);
    my $labels = Treex::Core::TredView::Labels->new( _treex_doc => $doc );

    my @bundles;
    foreach my $bundle ($doc->get_bundles) {
        my %bundle;
        my %zones;
        $bundle{zones}=\%zones;
        foreach my $zone ( $bundle->get_all_zones ) {
            my %trees;
            foreach my $tree ( $zone->get_all_trees ) {
                my $tree_label = $self->tree_layout->get_tree_label($tree);
                my @nodes = (map { Treex::View::Node->new(node => $_, labels => $labels) }
                                 $self->tree_layout->get_nodes($tree));
                $trees{$tree_label} = {
                    nodes => \@nodes,
                    language => $tree->language,
                    layer => $tree->get_layer,
                };
            }
            $zones{$self->tree_layout->get_zone_label($zone)} = {
                trees => \%trees,
                sentence => $zone->sentence
            };
        }
        $bundle{desc}=$self->tree_layout->value_line($bundle);
        push @bundles, \%bundle;
    }

    $c->res->content_type('application/json');
    $c->res->body(JSON->new->allow_nonref->allow_blessed->convert_blessed->utf8->
                      pretty->encode({ print => \@bundles}));
}

__PACKAGE__->meta->make_immutable;

=head1 NAME

Treex::Web::Model::Print - Catalyst Model

=head1 DESCRIPTION

Catalyst Model.

=head1 AUTHOR

THC,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

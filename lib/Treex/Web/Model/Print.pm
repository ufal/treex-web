package Treex::Web::Model::Print;
use Moose;
use Treex::Print;
use Treex::Core::Document;
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

sub process {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $file = $curr->result_filename;

    -e $file or return '';

    my $doc = Treex::Core::Document->new({ filename => $file });
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
                sentence => $zone->sentence,
            };
        }
        push @bundles, \%bundle;
        last;
    }

    $c->res->content_type('application/json');
    $c->res->body(JSON->new->allow_nonref->allow_blessed->convert_blessed->
                      pretty->encode({ bundles => \@bundles}));
}

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

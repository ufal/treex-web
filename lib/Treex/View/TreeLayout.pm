package Treex::View::TreeLayout;

use Moose;
use Treex::Core::Types;

has 'treex_doc' => ( is => 'rw' );

my @layers = map {lc} Treex::Core::Types::layers();

sub get_tree_label {
    my ( $self, $tree ) = @_;
    my $label = $tree->language . '-' . $tree->get_layer;
    my $sel   = $tree->selector;
    $label .= '-' . $sel if $sel;
    return $label;
}

sub get_layout_label {
    my ( $self, $bundle ) = @_;

    return unless ref($bundle) eq 'Treex::Core::Bundle';

    my @label;
    my @zones = $bundle->get_all_zones();
    foreach my $zone ( sort { $a->language cmp $b->language } @zones ) {
        push @label, map { $self->get_tree_label($_) } sort { $a->get_layer cmp $b->get_layer } $zone->get_all_trees();
    }

    return join ',', @label;
}

sub get_zone_label {
    my ( $self, $zone ) = @_;
    return $zone->language . ($zone->selector ? '-'.$zone->selector:'')
}

# Copied from Treex::Core::TredView
sub _spread_nodes {
    my ( $self, $node ) = @_;

    my ( $left, $right, $gap, $pos ) = ( -1, 0, 0, 0 );
    my ( @buf, @lower );
    for my $child ( $node->children ) {
        ( $pos, @buf ) = $self->_spread_nodes($child);
        if ( $left < 0 ) {
            $left = $pos;
        }
        $right += $gap;
        $gap = scalar(@buf);
        push @lower, @buf;
    }
    $right += $pos;
    return ( 0, $node ) if !@lower;

    my $mid;
    if ( scalar( $node->children ) == 1 ) {
        $mid = int( ( $#lower + 1 ) / 2 - 1 );
    }
    else {
        $mid = int( ( $left + $right ) / 2 );
    }

    return ( $mid + 1 ), @lower[ 0 .. $mid ], $node, @lower[ ( $mid + 1 ) .. $#lower ];
}

sub get_nodes {
    my ($self, $tree) = @_;
    my @nodes;

    if ( $tree->get_layer eq 'p' ) {
        @nodes = $self->_spread_nodes($tree);
        shift @nodes;
    }
    elsif ( $tree->does('Treex::Core::Node::Ordered') ) {
        @nodes = $tree->get_descendants( { add_self => 1, ordered => 1 } );
    }
    else {
        @nodes = $tree->get_descendants( { add_self => 1 } );
    }
    return @nodes;
}

sub get_sentence_for_a_zone {
    my ( $self, $zone, $alignment ) = @_;
    return if !$zone->has_atree();
    my %refs = ();

    if ( $zone->has_ttree() ) {
        for my $tnode ( $zone->get_ttree->get_descendants ) {
            my $id = $tnode->id;
            for my $aux ( TredMacro::ListV( $tnode->attr('a/aux.rf') ) ) {
                push @{ $refs{$aux} }, $id;
                if ( exists $alignment->{$id} ) {
                    push @{ $refs{$aux} }, @{ $alignment->{ $tnode->get_attr('id') } };
                }
            }
            if ( $tnode->attr('a/lex.rf') ) {
                push @{ $refs{ $tnode->attr('a/lex.rf') } }, $id;
                if ( exists $alignment->{ $tnode->get_attr('id') } ) {
                    push @{ $refs{ $tnode->attr('a/lex.rf') } }, @{ $alignment->{ $tnode->get_attr('id') } };
                }
            }
        }
    }

    my @anodes = $zone->get_atree->get_descendants( { ordered => 1 } );
    for my $anode (@anodes) {
        my $id = $anode->id;
        push @{ $refs{$id} }, $id;
        if ( exists $alignment->{$id} ) {
            push @{ $refs{$id} }, @{ $alignment->{$id} };
        }
        if ( $anode->attr('p_terminal.rf') ) {
            my $pnode = $self->treex_doc->get_node_by_id( $anode->attr('p_terminal.rf') );
            push @{ $refs{$id} }, $pnode->id;
            while ( $pnode->parent ) {
                $pnode = $pnode->parent;
                push @{ $refs{$id} }, $pnode->id;
            }
        }
    }

    my @out;
    for my $anode (@anodes) {
        push @out, [ $anode->form, @{ $refs{ $anode->id } || [] } ];
        if ( !$anode->no_space_after ) {
            push @out, [ ' ', 'space' ];
        }
    }

    push @out, [ "\n", 'newline' ];
    return \@out;
}

sub value_line {
    my ( $self, $bundle ) = @_;

    my %alignment = ();
    foreach my $zone ( $bundle->get_all_zones() ) {
        foreach my $layer (@layers) {
            if ( $zone->has_tree($layer) ) {
                my $root = $zone->get_tree($layer);
                foreach my $node ( $root, $root->get_descendants ) {
                    if ( exists $node->{'alignment'} ) {
                        foreach my $ref ( @{ $node->get_attr('alignment') } ) {
                            push @{ $alignment{ $node->{id} } }, $ref->{'counterpart.rf'};
                            push @{ $alignment{ $ref->{'counterpart.rf'} } }, $node->{id};
                        }
                    }
                }
            }
        }
    }

    my @out = ();
    foreach my $zone ( $bundle->get_all_zones() ) {
        push @out, ( [ '[' . $zone->get_label . ']', 'label' ], [ ' ', 'space' ] );
        if ( my $sentence = $self->get_sentence_for_a_zone( $zone, \%alignment ) ) {
            push @out, @$sentence;
        }
        elsif ( defined $zone->sentence ) {
            push @out, [ $zone->sentence . "\n", 'text' ];
        }
        else {
            push @out, [ "\n", 'newline' ]
        }
    }
    return \@out;
}

__PACKAGE__->meta->make_immutable;

1;
__END__

=head1 NAME

Treex::View::TreeLayout - Inspired by Treex::Core::TredView::TreeLayout.

=head1 SYNOPSIS

   use Treex::View::TreeLayout;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::View::TreeLayout,

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

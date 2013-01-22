package Treex::View::TreeLayout;

use Moose;

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

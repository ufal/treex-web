package Treex::Web::Controller::Print;
use Moose;
use Treex::View::TreeLayout;
use Treex::View::Node;
use JSON;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Treex::Web::Controller::Print - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

has 'treeLayout' => (
    is => 'ro',
    isa => 'Treex::View::TreeLayout',
    default => sub { Treex::View::TreeLayout->new },
);


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    $c->response->body('Matched Treex::Web::Controller::Print in Print.');
    
    use Treex::Print;
    use Treex::Core::Document;
    use Treex::PML::Factory;
    
    my $testfile = "test.treex.gz";
    
    my $doc = Treex::Core::Document->new({filename => $testfile});
    
    #    my $doc = Treex::PML::Factory->createDocumentFromFile($testfile);
    my @bundles;
    foreach my $bundle ($doc->get_bundles) {
        my %bundle;
        foreach ( $bundle->get_all_zones ) {
            my @trees = $_->get_all_trees;
            foreach my $tree ( @trees ) {
                $bundle{$self->treeLayout->get_tree_label($tree)} = Treex::View::Node->new(node => $tree);
            }
        }
        push @bundles, \%bundle;
    }
    
    my $json = JSON->new->allow_nonref
        ->allow_blessed->convert_blessed;
    
    #    my $svg = Treex::Print->svg($doc);
    $c->response->body($json->pretty->encode(\@bundles));
}


=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;
 

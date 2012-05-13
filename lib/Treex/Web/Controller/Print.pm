package Treex::Web::Controller::Print;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Treex::Web::Controller::Print - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Matched Treex::Web::Controller::Print in Print.');

    use Treex::Print;
    use Treex::Core::Document;
    use Treex::PML::Factory;
    
    my $testfile = "test.treex.gz";

    my $doc = Treex::PML::Factory->createDocumentFromFile($testfile);
    
    my $svg = Treex::Print->svg($doc);
    $c->response->body($svg, 1);
}


=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

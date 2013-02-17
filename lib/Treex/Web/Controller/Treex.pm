package Treex::Web::Controller::Treex;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::Treex - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub languages :Local :Args(0) :ActionClass(REST) { }
sub languages_GET {
    my ( $self, $c ) = @_;

    my $res = $c->model('WebDB::LanguageGroup')->search(undef, {
        order_by => { -asc => ['me.position', 'languages.position'] },
        join => { languages => 'language_group' },
        prefetch => [ 'languages' ],
    });
    my @options;
    while (my $group = $res->next) {
        push @options, {
            group => $group->name,
            options => [
                map { {value => $_->id, label => $_->name} } $group->languages
            ]
        };
    }
    $self->status_ok($c, entity => \@options );
}


=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

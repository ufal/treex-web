package Treex::Web::Controller::Treex;
use Moose;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::REST'; }

my $treex_resource = __PACKAGE__->api_resource(
    path => 'treex'
);

=head1 NAME

Treex::Web::Controller::Treex - Auxiliary controller

=head1 DESCRIPTION

Catalyst Restful Controller for common tasks

=head1 METHODS

=cut


=head2 languages

Dummy route for:

=over 2

=item languages_GET

=back

=cut

my $languages_api = $treex_resource->api(
    controller => __PACKAGE__,
    action => 'languages',
    path => '/treex/languages',
    description => 'Common tasks'
);

sub languages :Local :Args(0) :ActionClass(REST) { }

__PACKAGE__->api_model(
    'LanguageOption',
    value => {
        type => 'integer',
        required => 1,
        description => 'Language id'
    },
    label => {
        type => 'string',
        required => 1,
        description => 'Language name e.g. English'
    }
);

__PACKAGE__->api_model(
    'LanguageGroup',
    group => {
        type => 'string',
        required => 1,
        description => 'Group name'
    },
    options => {
        type => 'array',
        items => {
            type => 'LanguageOption'
        },
        description => 'Languages in the group'
    }
);

$languages_api->get(
    summary => 'Returns all available language options',
    response => 'List[LanguageGroup]',
    nickname => 'getLanguages',
);

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

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

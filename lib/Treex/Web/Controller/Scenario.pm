package Treex::Web::Controller::Scenario;

use Moose;
use Treex::Web::Form::Scenario;
use namespace::autoclean;

BEGIN { extends 'Treex::Web::Controller::REST'; }

my $scenario_resource = __PACKAGE__->api_resource(
    path => 'scenarios'
);

__PACKAGE__->api_model(
    'ScenarioPayload',
    name => { type => 'string', required => 1 },
    description => { type => 'string', required => 1 },
    languages => {
        type => 'array',
        items => { type => 'integer' }
    },
    scenario => { type => 'string', required => 1 },
    sample => { type => 'string' },
    public => { type => 'boolean', required => 1 },
);

=head1 NAME

Treex::Web::Controller::Scenario - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 base

Base for all chained methods

=cut

sub base :Chained('/') :PathPart('') :CaptureArgs(0)  {
    my ( $self, $c ) = @_;

    $c->stash->{scenarios} = $c->model('WebDB::Scenario')->search_rs(undef, {
        prefetch => ['user', { scenario_languages => 'language' }]
    });
    $c->stash(
        scenario_form => Treex::Web::Form::Scenario->new(
            schema => $c->model('WebDB')->schema,
        ),
    );
}

my $scenarios_api = $scenario_resource->api(
    controller => __PACKAGE__,
    action => 'scenarios',
    path => '/scenarios',
    description => 'Operations on all scenarios'
);

=head2 scenarios

=over

=item scenarios_GET

=item scenarios_POST

=back

=cut

sub scenarios :Chained('base') :PathPart('scenarios') :Args(0) :ActionClass('REST') {
    my ( $self, $c ) = @_;

    my $scenarios_rs = $c->stash->{scenarios};
    $c->stash->{scenarios} = $c->user_exists ?
        $scenarios_rs->search_rs({
            -or => [
                public => 1,
                user => $c->user->id
            ]
        }) : $scenarios_rs->search_rs({ public => 1 });
}

$scenarios_api->get(
    summary => 'Get list of all scenarios',
    notes => 'Possibly filtered by language',
    response => 'List[Scenario]',
    nickname => 'getScenarios',
    params => [
        __PACKAGE__->api_param(
            param => 'query',
            name => 'language',
            type => 'integer',
            description => 'Language',
            required => 0
        )
    ]
);

sub scenarios_GET {
    my ( $self, $c ) = @_;

    my $lang = $c->req->param('language');
    my $scenarios_rs = $c->stash->{scenarios};

    $scenarios_rs = $scenarios_rs->search({
        -or => [
            'scenario_languages.language' => $lang,
            'scenario_languages.language' => undef,
        ],
    }) if $lang;
    my @all = map { $_->REST } $scenarios_rs->all;
    $self->status_ok($c, entity => \@all);
}

$scenarios_api->post(
    summary => 'Create new scenario for user',
    notes => 'Requires login',
    response => 'Scenario',
    nickname => 'createScenario',
    params => [
        __PACKAGE__->api_param_body('ScenarioPayload', 'New scenario', 'Scenario')
    ]
);

sub scenarios_POST :Does('~NeedsLogin') {
    my ( $self, $c ) = @_;

    my $p = $self->validate_params($c, 'ScenarioPayload');
    my $form = $c->stash->{'scenario_form'};
    my $new_scenario = $c->model('WebDB::Scenario')->new_result({ user => $c->user->id });

    if ($form->process(item => $new_scenario, params => $p)) {
        $self->status_created($c,
                              location => '/scenarios/'.$new_scenario->id,
                              entity => $new_scenario->REST
                          );
    } else {
        $self->status_error( $c, $scenarios_api->errors($form->errors));
    }
}

my $scenarios_languages_api = $scenario_resource->api(
    controller => __PACKAGE__,
    action => 'scenarios_languages',
    path => '/scenarios/languages',
    description => 'Operations on all scenarios'
);

=head2 scenarios_languages

All languages that can be used for filetering the scenarios

=over

=item scenarios_languages_GET

=back

=cut

sub scenarios_languages :Path('/scenarios/languages') :Args(0) :ActionClass('REST') { }

$scenarios_languages_api->get(
    summary => 'Get list of all languages for which there are scenarios available',
    response => 'List[Language]',
    nickname => 'getScenariosLanguages',
);

sub scenarios_languages_GET {
    my ( $self, $c ) = @_;

    my $scenario_rs = $c->user_exists ?
        $c->model('WebDB::Scenario')->search_rs({
            -or => [
                public => 1,
                user => $c->user->id
            ]
        }) : $c->model('WebDB::Scenario')->search_rs({ public => 1 });

    my @languages = $scenario_rs->search_related('scenario_languages', undef, {
        prefetch => [ 'language' ],
        group_by => [ 'language.id' ]
    });

    $self->status_ok($c, entity => [ map { $_->language->REST } @languages ]);
}


my $scenario_api = $scenario_resource->api(
    controller => __PACKAGE__,
    action => 'scenario',
    path => '/scenarios/{scenarioId}',
    description => 'Operations on all scenarios'
);

my @scenario_errors = (
    __PACKAGE__->api_error('not_found', 404, 'Scenario not found'),
    __PACKAGE__->api_error('forbidden', 403, 'Access denied'),
    __PACKAGE__->api_error('id_invalid', 400, 'Scenario id is invalid'),
);

my @scenario_params = (
    __PACKAGE__->api_param_path('integer', 'Scenario id', 'scenarioId')
);

=head2 scenario

Gets scenario from database by it's ID and stores it in the stash as

   $c->stash->{scenario}

=cut

sub scenario :Chained('base') :PathPart('scenarios') CaptureArgs(1) {
    my ( $self, $c, $scenario_id ) = @_;

    $scenario_id = int($scenario_id);
    if ($scenario_id) {
            my $scenario = $c->model('WebDB::Scenario')->find($scenario_id);
            unless ($scenario) {
                $self->status_error($c, $scenario_api->error('not_found'));
                $c->detach;
            }

            unless ($scenario->public || ($c->user_exists && $c->user->id == $scenario->user->id)) {
                $self->status_error($c, $scenario_api->error('forbidden'));
                $c->detach;
            }

            $c->stash(scenario => $scenario);
    } else {
        $self->status_error($c, $scenario_api->error('id_invalid'));
        $c->detach;
    }
}

=head2 item

Operations on the scenario

=over

=item item_GET

=item item_PUT

=item item_DELETE

=back

=cut

sub item :Chained('scenario') :PathPart('') Args(0) :ActionClass('REST') { }

=head2 check_user

Private method for checking user's credentials for scenario operations

=cut

sub check_user :Pivate {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};

    # Check for user existence
    unless ($c->user_exists && $c->user->id == $scenario->user->id) {
        $self->status_error($c, $scenario_api->error('forbidden'));
        $c->detach;
    }
}

$scenario_api->get(
    summary => 'Get scenario by Id',
    notes => "Scenario must be yours or public in order to access it.",
    response => 'Scenario',
    nickname => 'getScenario',
    params => [
        @scenario_params
    ],
    errors => [
        @scenario_errors
    ]
);

sub item_GET {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};
    $self->status_ok($c, entity => $scenario->REST);
}

$scenario_api->put(
    summary => 'Update scenario info',
    notes => "You can only update your own scenarios",
    response => 'Scenario',
    nickname => 'updateScenario',
    params => [
        @scenario_params,
        __PACKAGE__->api_param_body('ScenarioPayload', 'Scenario data', 'Scenario')
    ],
    errors => [
        @scenario_errors
    ]
);

sub item_PUT :Does('~NeedsLogin') {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};
    my $form = $c->stash->{'scenario_form'};

    $c->forward('check_user');

    if ($form->process(item => $scenario, params => $c->req->data)) {
        $self->status_ok($c, entity => $scenario->REST);
    } else {
        $self->status_error($c, $scenario_api->errors($form->errors));
    }
}

$scenario_api->delete(
    summary => 'Deletes scenario',
    notes => "Please note that results of this scenario will remain intact.",
    response => 'Scenario',
    nickname => 'deleteScenario',
    params => [
        @scenario_params,
    ],
    errors => [
        @scenario_errors
    ]
);

sub item_DELETE :Does('~NeedsLogin') {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};

    $c->forward('check_user');

    $scenario->delete;
    $self->status_ok($c, entity => $scenario->REST);
}

=head2 download

Initiate scenario download

=cut

sub download :Chained('scenario') :PathPart('download') :Args(0) {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};

    my $name = $scenario->name||'scenario';
    $name =~ y/A-Z /a-z_/;

    $c->res->content_type('plain/text');
    $c->res->header('Content-Disposition', qq[attachment; filename="$name.scen"]);
    $c->res->body($scenario->scenario);
}

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

package Treex::Web::Controller::Scenario;
use Moose;
use Treex::Web::Form::ScenarioForm;
use Try::Tiny;
use JSON;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::ActionRole'; }

=head1 NAME

Treex::Web::Controller::Scenario - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

=cut

sub base :Chained('/') :PathPart('') :CaptureArgs(0)  {
    my ( $self, $c ) = @_;

    $c->stash->{scenarios} = $c->model('WebDB::Scenario')->search_rs(undef, {
        prefetch => ['user', { scenario_languages => 'language' }]
    });
    $c->stash->{public_scenarios} = $c->model('WebDB::Scenario')->search({public => 1}, {prefetch => 'user'});
    $c->stash(
        scenario_form => Treex::Web::Form::ScenarioForm->new(
            action => $c->uri_for($self->action_for('add')),
            schema => $c->model('WebDB')->schema,
        ),
        template => 'scenarios.tt2',
    );

    $c->stash( user_scenarios => $c->user->search_related_rs('scenarios') )
        if $c->user_exists;
}

sub object :Chained('base') :PathPart('scenario') :CaptureArgs(1) {
    my ( $self, $c, $scenario_id ) = @_;

    my $scenario = $c->model('WebDB::Scenario')->find($scenario_id);
    $c->stash(scenario => $scenario);

    $c->detach($self->action_for('not_found'))
        unless $scenario;

    $c->stash(template => 'scenario.tt2');
}

sub index :Chained('base') :PathPart('scenarios') :Args(0) {
    my ( $self, $c ) = @_;
}

my $json = JSON->new;
sub pick :Chained('base') :PathPart('scenarios/pick') :Args(0) {
    my ( $self, $c ) = @_;

    my $lang = $c->req->param('lang');
    my @scenarios = defined $lang ? $c->stash->{scenarios}->search({
        -or => [
            'scenario_languages.language' => $lang,
            'scenario_languages.language' => undef,
        ],
    }) : $c->stash->{scenarios}->all;

    $c->res->content_type('application/json');
    $c->res->body($json->convert_blessed->encode({scenarios => \@scenarios}));
}

sub not_found :Private {
    my ( $self, $c ) = @_;

    $c->response->status(404);
    $c->stash('template' => 'scenario/not_found.tt2');
}

sub view :Chained('object') :PathPart('') :Args(0) {

}

sub run :Chained('object') :PathPart('run') :Args(0) {
}

sub download :Chained('object') :PathPart('download') :Args(0) {
}

sub add :Chained('base') :PathPart('scenario/add') :Args(0) :Does('NeedsLogin') {
    my ( $self, $c ) = @_;
    my $form = $c->stash->{'scenario_form'};

    if ( $c->req->method eq 'POST' ) {
        my $new_scenario = $c->model('WebDB::Scenario')->new_result({ user => $c->user->id });

        if ($form->process(item => $new_scenario, params => $c->req->parameters)) {
            $c->flash->{status_msg} = 'Scenario successfully created';
            $c->response->redirect($c->uri_for($self->action_for('view'), [$new_scenario->id]));
        } else {
            $c->flash->{error_msg} = 'Saving scenario has failed';
        }
    }

    $c->stash(template => 'scenario/new.tt2');
}

sub edit :Chained('object') :PathPart('edit') :Args(0) :Does('NeedsLogin') {
    my ( $self, $c ) = @_;
    my $form = $c->stash->{'scenario_form'};
    my $scenario = $c->stash->{'scenario'};

    if ( $c->req->method eq 'POST' ) {
        if ($form->process(item => $scenario, params => $c->req->parameters)) {
            $c->flash->{status_msg} = 'Scenario saved';
            $c->response->redirect($c->uri_for($self->action_for('view'), [$scenario->id]));
        } else {
            $c->flash->{error_msg} = 'Saving scenario has failed';
        }
    }
    $c->stash(template => 'scenario/edit.tt2');
}

sub delete :Chained('object') :PathPart('delete') :Args(0) :Does('NeedsLogin') {
    my ( $self, $c ) = @_;

    return unless $c->req->method eq 'POST';

    my $scenario = $c->stash->{scenario};

    if ($scenario->delete) {
        $c->flash->{status_msg} = 'Scenario successfully deleted';
    } else {
        # TODO: throw 500 instead of message
        $c->flash->{status_msg} = 'Scenario delete has failed';
    }
    $c->response->redirect($c->uri_for($self->action_for('index')));
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

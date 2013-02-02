package Treex::Web::Controller::Scenario;
use Moose;
use Treex::Web::Forms::ScenarioForm;
use Try::Tiny;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::Base'; }

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

    $c->stash->{scenarios} = $c->model('WebDB::Scenario')->search(undef, {
        prefetch => 'user'
    });
    $c->stash->{public_scenarios} = $c->model('WebDB::Scenario')->search({public => 1}, {prefetch => 'user'});
    $c->stash(
        scenarioForm => Treex::Web::Forms::ScenarioForm->new(
            action => $c->uri_for($self->action_for('add')),
            schema => $c->model('WebDB')->schema,
        ),
        template => 'scenario.tt2',
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
}

sub index :Chained('base') :PathPart('scenarios') :Args(0) {
    my ( $self, $c ) = @_;
}

sub my_scenarios :Chained('base') :PathPart('my/scenarios') :Args(0) {
    my ( $self, $c ) = @_;

    unless ( $c->user_exists ) {
        $c->response->redirect($c->uri_for($self->action_for('index')));
        $c->detach;
    }

    $c->stash(template => 'scenario/my.tt2');
}

sub not_found :Private {
    my ( $self, $c ) = @_;

    $c->response->status(404);
    $c->stash('template' => 'scenario/not_found.tt2');
}

sub add :Chained('base') :PathPart('scenario/add') :Args(0) {
    my ( $self, $c ) = @_;
    my $form = $c->stash->{'scenarioForm'};

    if ( $c->req->method eq 'POST' && $c->user_exists ) {
        my $new_scenario = $c->model('WebDB::Scenario')->new_result({ user => $c->user->id });

        if ($form->process(item => $new_scenario, params => $c->req->parameters)) {
            $c->flash->{status_msg} = 'Scenario successfully created';
            $c->response->redirect($c->uri_for($self->action_for('index')));
        }
    }

    $c->stash(template => 'scenario/new.tt2');
}

sub delete :Chained('object') :PathPart('delete') :Args(0) {
    my ( $self, $c ) = @_;

    my $scenario = $c->stash->{scenario};

    $c->detach('not_found')
        unless ( $c->user_exists && $scenario->user->id eq $c->user->id);

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

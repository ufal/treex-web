package Treex::Web::Controller::Scenario;
use Moose;
use Treex::Web::Form::ScenarioForm;
use Treex::Web::Form::RunScenario;
use Try::Tiny;
use JSON;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller::REST'; }

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
    $c->stash(
        scenario_form => Treex::Web::Form::ScenarioForm->new(
            schema => $c->model('WebDB')->schema,
        ),
    );
}

sub list :Chained('base') :PathPart('scenarios') :Args(0) :ActionClass('REST') { }

sub list_GET {
    my ( $self, $c ) = @_;

    my $lang = $c->req->param('language');
    my $scenarios_rs = $c->stash->{scenarios};

    $scenarios_rs = $c->user_exists ?
        $scenarios_rs->search_rs({
            -or => [
                public => 1,
                user => $c->user->id
            ]
        }) : $scenarios_rs->search_rs({ public => 1 });

    $scenarios_rs = $scenarios_rs->search({
        -or => [
            'scenario_languages.language' => $lang,
            'scenario_languages.language' => undef,
        ],
    }) if $lang;
    my @all = map { $_->REST } $scenarios_rs->all;
    $self->status_ok($c, entity => \@all);
}

sub scenario :Chained('base') :PathPart('scenario') CaptureArgs(1) {
    my ( $self, $c, $scenario_id ) = @_;

    if ($scenario_id) {
            my $scenario = $c->model('WebDB::Scenario')->find($scenario_id);
            unless ($scenario) {
                $self->status_not_found($c, message => 'Scenario not found.');
                $c->detach;
            }

            unless ($scenario->public || ($c->user_exists && $c->user->id == $scenario->user)) {
                $self->status_forbidden($c, message => 'Access denied');
                $c->detach;
            }

            $c->stash(scenario => $scenario);
    } else {
        unless ($c->user_exists) {
            $self->status_forbidden($c, message => 'Access denied');
            $c->detach;
        }
    }
}

sub item :Chained('scenario') :PathPart('') Args(0) :ActionClass('REST') { }

sub check_user :Pivate {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};

    # Check for user existence
    unless ($c->user_exists && $c->user->id == $scenario->user->id) {
        $self->status_forbidden($c, message => 'Access denied');
        $c->detach;
    }
}

sub item_POST {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{'scenario_form'};
    my $new_scenario = $c->model('WebDB::Scenario')->new_result({ user => $c->user->id });

    if ($form->process(item => $new_scenario, params => $c->req->parameters)) {
        $self->status_created($c,
                              location => "/scenario/${new_scenario->id}",
                              entity => $new_scenario->REST
                          );
    } else {
        $self->status_bad_request($c, message => 'Saving scenario has failed');
    }
}

sub item_GET {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};
    $self->status_ok($c, entity => $scenario->REST);
}

sub item_PUT :Does('NeedsLogin') {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};
    my $form = $c->stash->{'scenario_form'};

    $c->forward('check_user');

    if ($form->process(item => $scenario, params => $c->req->parameters)) {
        $self->status_ok($c, entity => $scenario->REST);
    } else {
        $self->status_bad_request($c, message => 'Updating scenario has failed');
    }
}

sub item_DELETE :Does('NeedsLogin') {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};

    $c->forward('check_user');

    $scenario->delete;
    $self->status_ok($c, entity => $scenario->REST);
}

sub download :Chained('scenario') :PathPart('download') :Args(0) {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};

    $c->res->content_type('plain/text');
    $c->res->header('Content-Disposition', qq[attachment; filename="${scenario->name}.scen"]);
    $c->res->body($scenario->scenario);

}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

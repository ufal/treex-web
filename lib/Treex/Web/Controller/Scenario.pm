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

sub base :Chained('/') :PathPart('scenario') :CaptureArgs(0)  {
    my ( $self, $c ) = @_;
    
    $c->stash->{public_scenarios} = $c->model('WebDB::Scenario')->search({public => 1});
    $c->stash(
        scenarioForm => Treex::Web::Forms::ScenarioForm->new(
            action => $c->uri_for($self->action_for('add')),
            schema => $c->model('WebDB')->schema,
        ),
        template => 'scenario.tt',
    );
    
    $c->stash( user_scenarios => $c->user->search_related_rs('scenarios') )
        if $c->user_exists;
}

sub index :Chained('base') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;
}

sub add :Chained(base) :PathPart('add') :Args(0) {
    my ( $self, $c ) = @_;
    my $form = $c->stash->{'scenarioForm'};
    
    if ( $c->req->method eq 'POST' && $c->user_exists ) {
        my $new_scenario = $c->model('WebDB::Scenario')->new_result({ user => $c->user->id });
        
        if ($form->process(item => $new_scenario, params => $c->req->parameters)) {
            $c->flash->{status_msg} = 'Scenario successfully created';
        }
    }
}

=head1 AUTHOR

root

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

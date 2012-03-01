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

    $c->load_status_msgs;
    
    $c->stash(
        scenarioForm => Treex::Web::Forms::ScenarioForm->new(
            action => $c->uri_for( $self->action_for('add'), ),
            schema => $c->model('WebDB')->schema,
                                                          ),
        template => 'scenario.tt',
    );
}

sub index :Chained('base') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;
}

sub add :Chained(base) :PathPart('add') :Args(0) {
    my ( $self, $c ) = @_;
    my $form = $c->stash->{'scenarioForm'};
    
    if ( $c->req->method eq 'POST' ) {
        if ($form->process(params => $c->req->parameters)) {
            use Data::Dumper;
            local $Data::Dumper::Terse = 1;
            my $str = Dumper($form->value);
            $c->stash( form_values => $str );
            # try {
            #     my $scenario_rs = $c->model('WebDB::Scenario');
            #     my $scenario = $scenario_rs->create( $form->value );
            #     $c->response->redirect($c->uri_for($self->action_for('index')),
            #                            {
            #                                $c->status_msg_stash_key => $c->set_status_msg("Scenario ${scenario->name} successully created.")});
            # } catch {
            #     $c->log->error("$_");
            #     $c->stash( $c->error_msg_stash_key => "$_" );
            #     $c->clear_errors;
            # };
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

package Treex::Web::Controller::Query;
use Moose;
use Treex::Web::Form::QueryForm;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::Query - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 index

Process the scenario and create the new result

=cut

sub index :Path :Args(0) :ActionClass('REST') { }

sub index_POST {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Form::QueryForm->new(
        schema => $c->model('WebDB')->schema,
        ($c->user_exists ? (user => $c->user) : ()),
    );

    $form->process( params => $c->req->parameters );
    unless ($form->is_valid) {
        $self->status_bad_request($c, message => (join "\n", $form->errors));
        return;
    }
    # form is valid, lets create new Result
    my ($scenario_name, $scenario, $scenario_id, $input, $lang)
        = ($form->value->{scenario_name},
           $form->value->{scenario},
           $form->value->{scenario_id},
           $form->value->{input},
           $form->value->{language});
    my $rs = $c->model('WebDB::Result')->new({
#        session => $c->create_session_id_if_needed,
        name => $scenario_name,
        language => $lang,
        ($c->user_exists ? (user => $c->user->id) : ())
    });
    $rs->insert($scenario, $input);
    $c->log->debug("Creating new result: " . $rs->unique_token);

    # post the job
    my $resque = $c->model('Resque');

    $resque->push(treex => {
        uuid => $rs->unique_token,
        class => 'Treex::Web::Job::Process',
        args => [ $rs->language->code ]
    });

    $self->status_created($c,
                          location => "/result/{$rs->unique_token}",
                          entity => $rs->REST);
}

=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

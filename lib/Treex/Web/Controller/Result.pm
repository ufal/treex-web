package Treex::Web::Controller::Result;
use Moose;
use Try::Tiny;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::Base'; }

=head1 NAME

Treex::Web::Controller::Result - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

=head2 base

Puts Treex::Web::DB::Result result set to stash

=cut

sub base :Chained('/') :PathPart('') :CaptureArgs(0)  {
    my ($self, $c) = @_;

    my $rs = $c->model('WebDB::Result')
        ->search_rs({session => $c->create_session_id_if_needed, ($c->user_exists ? (user => $c->user->id) : (user => undef))});
    $c->stash(template => 'result.tt2',
              rs => $rs);
}

sub index :Chained('base') :PathPart('results') :Args(0) {
    my ($self, $c) = @_;

    my $rs = $c->stash->{rs};
    $c->stash(current_result => $rs->first);
}

=head2 show

=cut

sub show :Chained('base') :PathPart('result') :Args(1) {
    my ($self, $c, $unique_token) = @_;

    my $rs = $c->stash->{rs};

    try {
        my $result = $rs->find({ unique_token => $unique_token },
                               { key => 'unique_token' });
        $c->stash(problem => "Result not found!") unless $result;
        $c->stash(current_result => $result);
    } catch {
        $c->log->error("$_");
    }
}

=head2 delete

=cut

sub delete :Chained('result') :PathPart('delete') :Args(0) {
  #TODO
}

sub end : ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Forms::QueryForm->new(
        item => $c->stash->{current_result},
        action => $c->uri_for($c->controller('Query')->action_for('index')),
    );

    $c->stash(
        query_form => $form
    )
}

=head1 AUTHOR

Michal Sedlák

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

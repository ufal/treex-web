package Treex::Web::Controller::Result;
use Moose;
use Try::Tiny;
use JSON;
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

    $c->stash(template => 'results.tt2');
}

sub index :Chained('base') :PathPart('results') :Args(0) {
    my ($self, $c) = @_;

    my $rs = $c->stash->{results_rs};
    $c->stash(current_result => $rs->first);
}

sub result :Chained('base') :PathPart('result') :CaptureArgs(1) {
    my ($self, $c, $unique_token) = @_;

    my $rs = $c->stash->{results_rs};

    try {
        my $result = $rs->find({ unique_token => $unique_token },
                               { key => 'unique_token' });
        $c->stash(current_result => $result);
    } catch {
        $c->log->error("$_");
        # TODO handle not_found
    };
    $c->stash(template => 'result.tt2');
}

=head2 show

=cut

sub show :Chained('result') :PathPart('') :Args(0) {
    my ($self, $c, $unique_token) = @_;

}

sub status :Chained('result') :PathPart('status') :Args(0) {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $status = $curr ? $curr->status($c) : 'unknown';
    $c->res->content_type('application/json');
    $c->res->body(to_json({status => $status}));
}

sub print_result :Chained('result') :PathPart('print') :Args(0) {
    my ( $self, $c ) = @_;
    $c->forward('Model::Print');
}

sub download :Chained('result') :CaptureArgs(0) {
}

=head2 delete

=cut

sub delete :Chained('result') :PathPart('delete') :Args(0) {
  #TODO
}

sub end :ActionClass('RenderView') {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Forms::QueryForm->new(
        item => $c->stash->{current_result},
        action => $c->uri_for($c->controller('Query')->action_for('index')),
    );

    $c->stash(
        query_form => $form
    );
}

=head1 AUTHOR

Michal Sedlák

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

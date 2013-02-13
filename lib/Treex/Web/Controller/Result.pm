package Treex::Web::Controller::Result;
use Moose;
use Try::Tiny;
use JSON;
use Treex::Web::Form::QueryForm;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

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
    my $results_rs = $c->model('WebDB::Result')
        ->search_rs(
            {($c->user_exists ? (user => $c->user->id) : (user => undef))},
            { order_by => { -desc => 'last_modified' } });
    $c->stash(results_rs => $results_rs);
}

sub list :Chained('base') :PathPart('results') :Args(0) :ActionClass('REST') { }

sub list_GET {
    my ($self, $c) = @_;
    my $rs = $c->stash->{results_rs};
    my @all = map { $_->rest_data } $rs->all;
    $self->status_ok($c, entity => \@all )
}

sub result :Chained('base') :PathPart('result') :CaptureArgs(1) {
    my ($self, $c, $unique_token) = @_;

    my $rs = $c->stash->{results_rs};

    try {
        my $result = $rs->find({ unique_token => $unique_token },
                               { key => 'unique_token' });
        $c->stash(current_result => $result);
    } catch {
        $c->status_not_found(
            $c,
            message => "Cannot find result you were looking for!"
        );
        $c->detach;
    };
}

=head2 show

=cut

sub item :Chained('result') :PathPart('') :Args(0) :ActionClass('REST') { }

sub item_GET {
    my ( $self, $c ) = @_;
    $self->status_ok($c, entity => $c->stash->{current_result}->rest_data );
}

sub item_DELETE {
    my ( $self, $c ) = @_;
    my $res = $c->stash->{current_result};
    $res->delete;
    $self->status_ok($c, entity => $res->rest_data );
}

sub status :Chained('result') :PathPart('status') :Args(0) :ActionClass('REST') { }

sub status_GET {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $status = $curr ? $curr->status : 'unknown';
    $self->status_ok($c, entity => { status => $status } );
}

sub print_result :Chained('result') :PathPart('print') :Args(0) {
    my ( $self, $c ) = @_;
    $c->forward('Model::Print');
}

sub download :Chained('result') :CaptureArgs(0) {
}

=head1 AUTHOR

Michal Sedlák

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

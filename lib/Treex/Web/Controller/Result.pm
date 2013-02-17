package Treex::Web::Controller::Result;
use Moose;
use Try::Tiny;
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
    my @all = map { $_->REST } $rs->all;

    my @statuses = $c->model('Resque')->status_manager->mget( map { $_->{token} } @all );
    for (@all) {
        my $status = pop @statuses;
        $_->{status} = $status ? $status->status : 'unknown';
    }
    $self->status_ok($c, entity => \@all )
}

sub result :Chained('base') :PathPart('result') :CaptureArgs(1) {
    my ($self, $c, $unique_token) = @_;

    my $rs = $c->stash->{results_rs};

    try {
        my $result = $rs->find({ unique_token => $unique_token },
                               { key => 'unique_token' });
        die 'No result' unless $result;
        $c->stash(current_result => $result);
    } catch {
        $self->status_not_found(
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
    my $curr = $c->stash->{current_result};
    my $item = $curr->REST;
    my $status = $c->model('Resque')->status_manager->get($curr->unique_token);
    $item->{status} = $status ? $status->status : 'unknown';
    $self->status_ok($c, entity => $item );
}

sub item_DELETE {
    my ( $self, $c ) = @_;
    my $res = $c->stash->{current_result};
    $res->delete;
    $self->status_ok($c, entity => $res->REST );
}

sub status   :Chained('result') :PathPart(status)   :Args(0) :ActionClass('REST') { };
sub input    :Chained('result') :PathPart(input)    :Args(0) :ActionClass('REST') { };
sub error    :Chained('result') :PathPart(error)    :Args(0) :ActionClass('REST') { };
sub scenario :Chained('result') :PathPart(scenario) :Args(0) :ActionClass('REST') { };

sub status_GET {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $status = $c->model('Resque')->status_manager->get($curr->unique_token);
    $self->status_ok($c, entity => $status ? $status->REST : { status => 'unknown' } );
}

sub input_GET {
    my ( $self, $c ) = @_;
    my $curr = $c->stash->{current_result};
    $self->status_ok($c, entity => { input => $curr->input } );
}

sub error_GET {
    my ( $self, $c ) = @_;
    my $curr = $c->stash->{current_result};
    $self->status_ok($c, entity => { error => $curr->error_log } );
}

sub scenario_GET {
    my ( $self, $c ) = @_;
    my $curr = $c->stash->{current_result};
    $self->status_ok($c, entity => { scenario => $curr->scenario } );
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

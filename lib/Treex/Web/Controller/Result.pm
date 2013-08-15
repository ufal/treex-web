package Treex::Web::Controller::Result;
use Moose;
use Try::Tiny;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::Result - Catalyst Controller

=head1 DESCRIPTION

Mostly CRUD routes operating over L<Treex::Web::DB::Result>

=head1 METHODS

=cut

=head2 base

Base chain method. Puts L<Treex::Web::DB::Result> result set to the
stash and makes it available to all other routes in the chain.

  $c->stash->{results_rs}

=cut

sub base :Chained('/') :PathPart('') :CaptureArgs(0)  {
    my ($self, $c) = @_;
    my $results_rs = $c->model('WebDB::Result')
        ->search_rs(
            {($c->user_exists ? (user => $c->user->id) : (session => $c->create_session_id_if_needed))},
            { order_by => { -desc => 'last_modified' } });
    $c->stash(results_rs => $results_rs);
}

=head2 results

Dummy method serving as a base for REST routes.

Using C<ActionClass('REST')>

See L<results_GET>

=cut

sub results :Chained('base') :PathPart('results') :Args(0) :ActionClass('REST') { }

=head2 results_GET

Fetches a list of results

=cut

sub results_GET {
    my ($self, $c) = @_;
    my $rs = $c->stash->{results_rs};
    my @all = map { $_->REST } $rs->all;

    if (scalar @all > 0) {
        my @statuses = $c->model('Resque')->status_manager->mget( map { $_->{token} } @all );
        for (@all) {
            my $job = pop @statuses;
            $_->{job} = $job ? $job->REST : {status => 'unknown'};
        }
    }
    $self->status_ok($c, entity => \@all )
}

=head2 result

Will try to fetch a result by it's C<unique_token> and save to stash.

  $c->stash->{current_result}

=cut

sub result :Chained('base') :PathPart('results') :CaptureArgs(1) {
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

=head2 item

Dummy method serving as a base for REST routes

See L<item_GET> and L<item_DELETE>

=cut

sub item :Chained('result') :PathPart('') :Args(0) :ActionClass('REST') { }

=head2 item_GET

Returns REST representation of C<current_result> in the stash

=cut

sub item_GET {
    my ( $self, $c ) = @_;
    my $curr = $c->stash->{current_result};
    my $item = $curr->REST;
    my $job = $c->model('Resque')->status_manager->get($curr->unique_token);
    $item->{job} = $job ? $job->REST : {status =>'unknown'};
    $self->status_ok($c, entity => $item );
}

=head2 item_DELETE

Deletes C<current_result> in the stash if user has the credentials to
do so

=cut

sub item_DELETE {
    my ( $self, $c ) = @_;
    my $curr = $c->stash->{current_result};
    my $resque = $c->model('Resque');
    my $status = $resque->status_manager->get($curr->unique_token);
    if ($status && $status->is_killable) {
        $resque->status_manager->kill($status->uuid);
    }
    $curr->delete;
    $self->status_ok($c, entity => $curr->REST );
}

=head2 status

=head2 input

=head2 error

=head2 scenario

All above serves as dummy methods using C<:ActionClass('REST')>

=cut

sub status   :Chained('result') :PathPart(status)   :Args(0) :ActionClass('REST') { };
sub input    :Chained('result') :PathPart(input)    :Args(0) :ActionClass('REST') { };
sub error    :Chained('result') :PathPart(error)    :Args(0) :ActionClass('REST') { };
sub scenario :Chained('result') :PathPart(scenario) :Args(0) :ActionClass('REST') { };

=head2 status_GET

Returns C<current_result>'s status

=cut

sub status_GET {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $status = $c->model('Resque')->status_manager->get($curr->unique_token);
    $self->status_ok($c, entity => $status ? $status->REST : { status => 'unknown' } );
}

=head2 input_GET

Returns C<current_result>'s input unless is too large or is not a
plain text

=cut

sub input_GET {
    my ( $self, $c ) = @_;
    my $curr = $c->stash->{current_result};
    $self->status_ok($c, entity => { input => $curr->input } );
}

=head2 error_GET

Returns C<current_result>'s error log

=cut

sub error_GET {
    my ( $self, $c ) = @_;
    my $curr = $c->stash->{current_result};
    $self->status_ok($c, entity => { error => $curr->error_log } );
}

=head2 scenario_GET

Returns C<current_result>'s scenario

=cut

sub scenario_GET {
    my ( $self, $c ) = @_;
    my $curr = $c->stash->{current_result};
    $self->status_ok($c, entity => { scenario => $curr->scenario } );
}

=head2 print_result

Returns JSON representation of the result for printing by forwarding
request to L<Treex::Web::Model::Print>

This method is not using REST interface and will only return JSON

=cut

sub print_result :Chained('result') :PathPart('print') :Args(0) {
    my ( $self, $c ) = @_;
    $c->forward('Model::Print');
}

=head2 download

Dummy method serving as a chain hook for L<Treex::Web::Controller::Result::Download>

=cut

sub download :Chained('result') :CaptureArgs(0) {
}

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

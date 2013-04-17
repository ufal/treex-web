package Treex::Web::Controller::Scenario;
use Moose;
use Try::Tiny;
use JSON;
use DBIx::Class::ResultSet::RecursiveUpdate;
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

sub base :Chained('/') :PathPart('scenarios') :CaptureArgs(0)  {
    my ( $self, $c ) = @_;

    $c->stash->{scenarios} = $c->model('WebDB::Scenario')->search_rs(undef, {
        prefetch => ['user', { scenario_languages => 'language' }]
    });
}

sub scenarios :Chained('base') :PathPart('') :Args(0) :ActionClass('REST') { }

sub scenarios_GET {
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
        'scenario_languages.language' => $lang,
    }) if $lang;
    my @all = map { $_->REST } $scenarios_rs->all;
    $self->status_ok($c, entity => \@all);
}

sub scenarios_POST {
    my ( $self, $c ) = @_;

    my $new_scenario = $c->model('WebDB::Scenario')->new_result(user => $c->user->id);
    $new_scenario->set_params($c->req->data);

    try {
        $c->model('WebDB')->txn_do(
            sub {
                if ($new_scenario->validate) {
                    $new_scenario->insert;
                    $self->status_created($c,
                                          location => "/scenario/${new_scenario->id}",
                                          entity => $new_scenario->REST
                                      );
                } else {
                    $self->status_bad_request($c, message => "Can't save invalid scenario:\n". join "\n", @{$new_scenario->validation_errors});
                }
            });
    } catch {
        $c->error("Scenario save error: $_");
    };
}

sub scenario :Chained('base') :PathPart('') CaptureArgs(1) {
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

sub item_GET {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};
    $self->status_ok($c, entity => $scenario->REST);
}

sub item_PUT :Does('NeedsLogin') {
    my ( $self, $c ) = @_;
    my $scenario = $c->stash->{scenario};
    $c->forward('check_user');
    $c->log_data;

    try {
        $c->model('WebDB')->txn_do(
            sub {
                $scenario->set_params($c->req->data);
                if ($scenario->validate) {
                    use Data::Dumper;
                    print STDERR Dumper($scenario->get_params);
                    DBIx::Class::ResultSet::RecursiveUpdate::Functions::recursive_update(
                        resultset => $c->model('WebDB::Scenario'),
                        updates => $scenario->get_params,
                        object => $scenario
                    );
                    $scenario->discard_changes;
                    $self->status_ok($c, entity => $scenario->REST);
                } else {
                    $self->status_bad_request($c, message => "Parameters are invalid:\n". join "\n", @{$scenario->validation_errors});
                }
            });
    } catch {
        $c->error("Scenario update error: $_");
    };
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

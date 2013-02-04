package Treex::Web::Controller::Query;
use Moose;
use Try::Tiny;
use HTML::FormatText;
use TheSchwartz::Job;
use LWP::UserAgent;
use Treex::Web::Form::QueryForm;
use Regexp::Common qw /URI/;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::Base'; }

=head1 NAME

Treex::Web::Controller::Query - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut

sub begin :Private {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Form::QueryForm->new(
        schema => $c->model('WebDB')->schema,
        action => $c->uri_for($self->action_for('index')),
    );
    $c->stash( query_form => $form,
               template => 'query.tt2');
}

=head2 index

Process the scenario and create the new result

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # we have a post form
    if ( lc $c->req->method eq 'post' ) {
        # get form from stash
        my $form = $c->stash->{query_form};
        $form->process( params => $c->req->parameters );
        return unless $form->is_valid;

        # form is valid, lets create new Result
        my ($scenario, $input, $lang) = ($form->value->{scenario},
                                         $form->value->{input},
                                         $form->value->{language});
        my $rs = $c->model('WebDB::Result')->new({
#            session => $c->create_session_id_if_needed,
            ($c->user_exists ? (user => $c->user->id) : ())
        });
        $rs->insert(\$scenario, \$input);
        $c->log->debug("Creating new result: " . $rs->unique_token);

        # post job
        my $job = TheSchwartz::Job->new(
            funcname => "Treex::Web::Job::Treex",
            uniqkey  => $rs->unique_token,
            arg      => { lang => $lang }
        );
        my $job_handle = $c->model("TheSchwartz")->insert($job);
        if ($job_handle) {
            $rs->job_handle($job_handle->as_string);
            $rs->update;
        }

        my $uri = $c->uri_for(
            $c->controller('Result')->action_for('show'),
            [ $rs->unique_token ],
        );
        $c->response->redirect($uri);
    }
}

sub extract_text_from_url :Local :Args(0) {
    my ( $self, $c ) = @_;

    return unless ( lc $c->req->method eq 'post' );

    my $url = $c->req->param('url');
    unless ($url =~ /$RE{URI}{HTTP}/) {
        $c->res->body("Bad url: $url");
        $c->res->status(400);
        return
    }

    my $browser = LWP::UserAgent->new();
    my $res = $browser->get($url);

    $c->res->body(HTML::FormatText->format_string($res->content));
    $c->res->content_type('plain/text');
}

=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

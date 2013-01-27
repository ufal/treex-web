package Treex::Web::Controller::Query;
use Moose;
use Try::Tiny;
use HTML::FormatText;
use LWP::UserAgent;
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

    my $form = Treex::Web::Forms::QueryForm->new(
        action => $c->uri_for($self->action_for('index')),
    );

    $c->stash( queryForm => $form,
               template => 'query.tt2');
}

=head2 index

Process the scenario and create the new result

=cut

sub index :Path :Args(0) {
    my ( $self, $c ) = @_;

    # we have a post form
    if ( lc $c->req->method eq 'post' ) {
        $c->forward('process_form');
        if ( my $result = $c->stash->{result} ) {
            my $uri = $c->uri_for(
                $c->controller('Result')->action_for('show'),
                [ $result->result_hash ],
            );
            $c->flash->{status_msg} = "Treex result successully created";
            $c->response->redirect($uri);
        } else {
            $c->stash->{error_msg} = "Something went wrong... Treex did not returned any results";
        }
    }
}

sub process_form :Private {
    my ( $self, $c ) = @_;

    my $form = $c->stash->{queryForm};
    if ( $form->process( params => $c->req->parameters ) ) {
        my ($scenario, $input) = ($form->value->{scenario}, $form->value->{input});

        try {
            my $result = $c->model('Treex')->run({ scenario => $scenario, input_ref => \$input });
            use Data::Dumper;
            $c->log->info(Dumper($result));

            my $rs = $c->model('WebDB::Result')->new({
                scenario => $result->{scenario},
                stdin => $result->{input},
                cmd => $result->{cmd},
                stdout => $result->{out},
                stderr => $result->{err},
                ret => $result->{ret},
            });

            $rs->insert;
            $c->stash( result => $rs );
        } catch {
            $c->log->error("$_");
        }
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

package Treex::Web::Controller::Query;
use Moose;
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
    
    $c->stash( queryForm => $self->queryForm,
               template => 'query/form.tt');
}

=head2 index

Process the scenario and create the new result

=cut
    
sub index :Path :Args(0) {
    my ( $self, $c ) = @_;
    
    # we have a post form
    if ( lc $c->req->method eq 'post' ) {
        
    }
    
    my $text = $c->req->body_params->{text};
    my $scenario = $c->req->body_params->{scenario};
    
    $c->log->debug("Got text to process '$text'") if $text;
    $c->log->debug("Got scenario '$scenario'") if $scenario;
    my $result;
    if ($text) {
        $result = $c->model('Treex')->run({text => $text, scenario => $scenario});
    }
    
    unless ($result) {
        $result = 'No result!'
    }
    
    $c->stash( result => $result );
}

sub process_form :Private {
    my ( $self, $c ) = @_;
    
    my $form = $c->stash->{queryForm};
    if ( $form->process( params => $c->req->parameters ) ) {
        my $result = $c->model('Treex')->run($form->value);

        my $rs = $c->model('WebDB::Result');
        #my $result_hash = $rs->
    }
    
}

=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

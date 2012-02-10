package Treex::Web::Controller::Root;
use Moose;
use namespace::autoclean;

BEGIN { extends 'Catalyst::Controller' }

#
# Sets the actions in this controller to be registered with no prefix
# so they function identically to actions created in MyApp.pm
#
__PACKAGE__->config(namespace => '');

=head1 NAME

Treex::Web::Controller::Root - Root Controller for Treex::Web

=head1 DESCRIPTION

[enter your description here]

=head1 METHODS

=head2 index

The root page (/)

=cut

sub index :Path :Args(0) {
  my ( $self, $c ) = @_;
  
  # Hello World
  #$c->response->body( $c->welcome_message );
}

=head2 process

Process the main input form

=cut

sub process :Local :Args(0) {
  my ( $self, $c ) = @_;
  
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
  
  $c->go('index');
}

=head2 default

Standard 404 error page

=cut

sub default :Path {
  my ( $self, $c ) = @_;
  $c->response->body( 'Page not found' );
  $c->response->status(404);
}

=head2 end

Attempt to render a view, if needed.

=cut

sub end : ActionClass('RenderView') {}

=head1 AUTHOR

THC,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

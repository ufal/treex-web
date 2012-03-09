package Treex::Web::Controller::Result;
use Moose;
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

sub base :Chained('/') :PathPart('result') :CaptureArgs(0)  {
  my ($self, $c) = @_;
  $c->stash(result_rs => $c->model('WebDB::Result'));
}

sub index :Chained('base') :PathPart('') :Args(0) {
    ## list all results use have 
}

=head2 result

=cut

sub result :Chained('base') :PathPart('') :Args(1) {
  my ($self, $c, $result_hash) = @_;
  
  my $result_rs = $c->stash->{result_rs};
  my $result = $result_rs->find({ result_hash => $result_hash },
                                { key => 'hash_unique' });
  
  die 'Result does not exists!' unless $result;
  
  $c->stash(current_result => $result);
}

=head2 delete

=cut

sub delete :Chained('result') :PathPart('delete') :Args(0) {
  #TODO
}

=head1 AUTHOR

Michal Sedlák

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

package Treex::Web::Controller::Result::Download;
use Moose;
use Archive::Zip qw(:ERROR_CODES :CONSTANTS);
use IO::Scalar;
use File::Spec;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller'; }

=head1 NAME

Treex::Web::Controller::Result::Download - Catalyst Controller

=head1 DESCRIPTION

Routes for downloading result files.

=head1 METHODS

=cut

=head2 base

Base method hooked on Result chain

See L<Treex::Web::Controller::Result/download>

=cut

sub base :Chained('../result') :PathPart('download') :CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

=head2 all

Initiate download of whole result content in a zip archive using
L<Archive::Zip>

=cut

sub all :Chained('base') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $filename = 'result_'.($curr->name||$curr->id).'.zip';

    my $zip = Archive::Zip->new();
    my $data;
    my $fh = new IO::Scalar \$data;

    my $path = $curr->files_path;
    for (qw/scenario.scen error.log out.log/, 'input.'.$curr->input_type, 'result.'.$curr->output_type) {
        my $file = File::Spec->catfile($path, $_);
        next unless -e $file;
        $zip->addFile($file, $_);
    }
    $zip->writeToFileHandle($fh);

    $c->res->content_type('application/zip');
    $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);
    $c->res->body($data);
}

=head2 input

Initiate input download. It will try to guess input type from result's
L<input_type|Treex::Web::DB::Result::Result/input_type>

See L<result>

=cut

sub input :Chained('base') :PathPart('input') :Args(0) {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $path = $curr->files_path;
    my $filename = 'input.'.$curr->input_type;
    my $file = File::Spec->catfile($path, $filename);
    if (-f $file) {
        $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);
        $c->serve_static_file($file);
    } else {
        $c->res->code(404);
    }
}

=head2 result

Initiate result download. It will try to guess result type from result's
L<output_type|Treex::Web::DB::Result::Result/output_type>

See L<input>

=cut

sub result :Chained('base') :PathPart('result') :Args(0) {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $path = $curr->files_path;
    my $filename = 'result.'.$curr->output_type;
    my $file = File::Spec->catfile($path, $filename);
    if (-f $file) {
        $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);
        $c->serve_static_file($file);
    } else {
        $c->res->code(404);
    }
}

=head2 scenario

Initiate download of scenario as a plain text C<scenario.scen> file

=cut

sub scenario :Chained('base') :PathPart('scenario') :Args(0) {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $path = $curr->files_path;
    my $filename = 'scenario.scen';
    my $file = File::Spec->catfile($path, $filename);
    if (-f $file) {
        $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);
        $c->serve_static_file($file);
    } else {
        $c->res->code(404);
    }
}

=head2 output

Downloads standard output if any

=cut

sub output :Chained('base') :PathPart('output') :Args(0) {
  my ( $self, $c ) = @_;

  my $curr = $c->stash->{current_result};
  my $path = $curr->files_path;
  my $filename = 'out.log';
  my $file = File::Spec->catfile($path, $filename);
  if (-f $file) {
    $c->res->header('Content-Disposition', qq[attachment; filename="output.txt"]);
    $c->serve_static_file($file);
  } else {
    $c->res->code(404);
  }
}

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

package Treex::Web::Controller::Result::Download;
use Moose;
use Archive::Zip qw(:ERROR_CODES :CONSTANTS);
use IO::Scalar;
use File::Spec;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::Base'; }

=head1 NAME

Treex::Web::Controller::Result::Download - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=head1 METHODS

=cut


=head2 index

=cut

sub base :Chained('../result') :PathPart('download') :CaptureArgs(0) {
    my ( $self, $c ) = @_;
}

sub all :Chained('base') :PathPart('') :Args(0) {
    my ( $self, $c ) = @_;

    my $curr = $c->stash->{current_result};
    my $filename = 'result_'.$curr->unique_token.'.zip';

    my $zip = Archive::Zip->new();
    my $data;
    my $fh = new IO::Scalar \$data;

    my $path = $curr->files_path;
    for (qw/input.txt scenario.scen result.treex error.log/) {
        my $file = File::Spec->catfile($path, $_);
        next unless -e $file;
        $zip->addFile($file, $_);
    }
    $zip->writeToFileHandle($fh);

    $c->res->content_type('application/zip');
    $c->res->header('Content-Disposition', qq[attachment; filename="$filename"]);
    $c->res->body($data);
}

sub scenario :Chained('base') :PathPart('scenario') :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Download scenario.');
}

sub output :Chained('base') :PathPart('output') :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Download output.');
}

sub input :Chained('base') :PathPart('input') :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Download input.');
}

sub error :Chained('base') :PathPart('error') :Args(0) {
    my ( $self, $c ) = @_;

    $c->response->body('Download error.');
}

=head1 AUTHOR

Michal Sedlák,,,

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

__PACKAGE__->meta->make_immutable;

1;

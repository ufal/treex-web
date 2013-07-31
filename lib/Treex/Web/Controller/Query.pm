package Treex::Web::Controller::Query;
use Moose;
use Treex::Web::Form::QueryForm;
use jQuery::File::Upload;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

=head1 NAME

Treex::Web::Controller::Query - Turns query into Treex result

=head1 DESCRIPTION

Treex query and file upload/download

=head1 TODO

Missing API documentation

=head1 METHODS

=cut

=head2 index

Process the scenario and create a new result

=over

=item index_POST

=back

=cut

sub index :Path :Args(0) :ActionClass('REST') { }

sub index_POST {
    my ( $self, $c ) = @_;

    my $form = Treex::Web::Form::QueryForm->new(
        schema => $c->model('WebDB')->schema,
        ($c->user_exists ? (user => $c->user) : ()),
    );

    $form->process( params => $c->req->data );
    unless ($form->is_valid) {
        $self->status_bad_request($c, message => (join "\n", $form->errors));
        return;
    }
    # form is valid, lets create new Result
    my ($name, $scenario, $input, $filename, $lang)
        = ( map { $form->value->{$_} } (qw/name scenario input filename language/) );

    my $rs = $c->model('WebDB::Result')->new({
        session => $c->create_session_id_if_needed,
        input_type => 'txt',
        name => $name,
        language => $lang,
        ($c->user_exists ? (user => $c->user->id) : ())
    });

    my $upload = $c->session->{upload};
    if ($filename && $upload && ($upload->{filename}||'') eq $filename) {
        $filename =~ s/[^-a-zA-Z0-9_.]/_/go;
        my $file_path = $c->path_to('tmp', $filename);
        unless (-f $file_path) {
            $self->status_bad_request($c, message => 'Uploaded file not found');
            return;
        }
        my ($type) = $upload->{name} =~ /\.(\w+?(?:\.gz)?)$/;
        $rs->input_file($file_path, $type);
        $input = undef;
        delete $c->session->{upload};
    } elsif (not $input) {
        $self->status_bad_request($c, message => 'Input is empty');
        return;
    }

    $rs->insert($scenario, $input); # TODO: we need transaction here

    $c->log->debug("Creating new result: " . $rs->unique_token);

    # post the job
    my $resque = $c->model('Resque');

    $resque->push(treex => {
        uuid => $rs->unique_token,
        class => 'Treex::Web::Job::Process',
        args => [ $rs->get_column('language') ? $rs->language->code : '' ]
    });

    $self->status_created($c,
                          location => "/result/{$rs->unique_token}",
                          entity => $rs->REST);
}

=head2 upload

Upload operations

=over

=item upload_GET

=item upload_POST

=item upload_item

=item upload_item_DELETE

=back

=cut

sub upload :Local :Args(0) :ActionClass('REST') {
    my ( $self, $c ) = @_;
}

sub upload_GET {
    my ( $self, $c ) = @_;

    $self->status_ok($c, entity => {files => [$c->session->{upload}||()]});
}

sub upload_POST {
    my ( $self, $c ) = @_;

    my $jq_upload = jQuery::File::Upload->new(
        field_name => 'file',
        upload_dir => $c->path_to('tmp'),
        ctx => $c,
        max_file_size => (5*1024*1024), # 5MB
    );

    $jq_upload->handle_request();

    my %resp = (
        filename => $jq_upload->filename,
        name => $jq_upload->show_client_filename ? $jq_upload->client_filename . "" : $jq_upload->filename,
        size => $jq_upload->{file_size},
        url => 'query/download/'.$jq_upload->filename,
        deleteUrl => 'query/upload/'.$jq_upload->filename,
        deleteType => 'DELETE',
    );
    $resp{'error'} = $jq_upload->_generate_error;

    if ($c->session->{upload} && $c->session->{upload}->{filename}) {
        my $file_path = $c->path_to('tmp', $c->session->{upload}->{filename});
        unlink $file_path;
    }
    $c->session->{upload} = \%resp;

    my $json = JSON->new->ascii->pretty->allow_nonref;
    my $output = $json->encode({files => [\%resp]});

    my $content_type = 'text/plain';
    if ($c->req->headers->header('Accept') =~ qr(application/json) ) {
        $content_type = 'application/json';
    }
    $c->stash->{current_view} = '';
    $c->res->content_type("$content_type; charset=utf-8");
    $c->res->body($output);
}

sub upload_item :Path('upload') :Args(1) :ActionClass('REST') {
}

sub upload_item_DELETE {
    my ( $self, $c, $filename ) = @_;
    $filename =~ s/[^-a-zA-Z0-9_.]/_/go;

    my $file_path = $c->path_to('tmp', $filename);
    unlink $file_path;
    if ($c->session->{upload} && ($c->session->{upload}->{filename}||'') eq $filename) {
        delete $c->session->{upload};
    }

    $self->status_no_content($c);
}

=head2 download

Download file uploaded for this query

=cut

sub download :Local :Args(1) {
    my ( $self, $c, $filename ) = @_;

    $filename =~ s/[^-a-zA-Z0-9_.]/_/go;
    my $file_path = $c->path_to('tmp', $filename);
    my $name = $filename;

    if ($c->session->{upload} && ($c->session->{upload}->{filename}||'') eq $filename) {
        $name = $c->session->{upload}->{name};
    }

    if (-f $file_path) {
        $c->res->header('Content-Disposition', qq[attachment; filename="$name"]);
        $c->serve_static_file($file_path);
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

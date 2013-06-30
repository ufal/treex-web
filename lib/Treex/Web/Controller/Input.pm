package Treex::Web::Controller::Input;
use Moose;
use Regexp::Common qw /URI/;
use LWP::UserAgent;
use HTML::FormatText;
use namespace::autoclean;

BEGIN {extends 'Treex::Web::Controller::REST'; }

my $input_resource = __PACKAGE__->api_resource(
    path => 'input'
);

__PACKAGE__->api_model(
    'UrlPayload',
    url => {
        type => 'string',
        required => 1,
        description => 'A valid URL'
    }
);

__PACKAGE__->api_model(
    'UrlContent',
    content => {
        type => 'string',
        required => 1,
        description => 'Text content of given URL'
    }
);

=head1 NAME

Treex::Web::Controller::Input - Catalyst Controller

=head1 DESCRIPTION

Catalyst Controller.

=cut

has 'browser' => (
    is => 'ro',
    isa => 'LWP::UserAgent',
    default => sub { LWP::UserAgent->new(agent => 'Mozilla/5.0', timeout => 30) }
);

=head1 METHODS

=cut


=head2 url

=cut

my $url_api = $input_resource->api(
    controller => __PACKAGE__,
    action => 'url',
    path => '/input/url',
    description => 'Downloads html content by url'
);

sub url :Local :Args(0) :ActionClass('REST') { }

$url_api->post(
    summary => 'Downloads html content from given url',
    notes => 'Output will be formated using HTML::FormatText. For details see http://search.cpan.org/perldoc?HTML::FormatText',
    response => 'UrlContent',
    nickname => 'urlDownload',
    params => [
        __PACKAGE__->api_param_body('UrlPayload', 'The url', 'Url')
    ],
    errors => [
        __PACKAGE__->api_error('bad_url', 400, 'Url has bad format'),
        __PACKAGE__->api_error('get_failed', 404, "Url can't be downloaded")
    ]
);

sub url_POST {
    my ( $self, $c ) = @_;

    my $p = $self->validate_params($c, 'UrlPayload');
    my $url = $p->{url};
    unless ($url && $url =~ /$RE{URI}{HTTP}/) {
        $self->status_error($c, $url_api->error('bad_url'));
        return;
    }

    my $res = $self->browser->get($url);
    if ($res->is_success) {
        my $content = $res->decoded_content;
        $self->status_ok($c, entity => { content => HTML::FormatText->format_string($content) });
    } else {
        $self->status_error($c, $url_api->error('get_failed'));
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

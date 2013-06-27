package Treex::Web::Controller::Input;
use Moose;
use Regexp::Common qw /URI/;
use LWP::UserAgent;
use HTML::FormatText;
use namespace::autoclean;

BEGIN {extends 'Catalyst::Controller::REST'; }

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


=head2 index

=cut

sub url :Local :Args(0) :ActionClass('REST') { }
sub url_POST {
    my ( $self, $c ) = @_;

    my $url = $c->req->data->{url} || '';
    unless ($url && $url =~ /$RE{URI}{HTTP}/) {
        $self->status_bad_request($c, message => "Bad url: '$url'");
        return;
    }

    my $res = $self->browser->get($url);
    if ($res->is_success) {
        my $content = $res->decoded_content;
        $self->status_ok($c, entity => { content => HTML::FormatText->format_string($content) });
    } else {
        $self->status_bad_request($c, message => $res->message);
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

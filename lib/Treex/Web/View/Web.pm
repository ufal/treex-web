package Treex::Web::View::Web;

use strict;
use warnings;

use base 'Catalyst::View::TT';

__PACKAGE__->config(
    TEMPLATE_EXTENSION => '.tt',
    ENCODING           => 'utf-8',
    CATALYST_VAR       => 'c',
    WRAPPER            => 'page.tt',
    render_die         => 1,
);

=head1 NAME

Treex::Web::View::Web - TT View for Treex::Web

=cut



=head1 DESCRIPTION

TT View for Treex::Web.

=head1 SEE ALSO

L<Treex::Web>

=head1 AUTHOR

Michal Sedlák

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

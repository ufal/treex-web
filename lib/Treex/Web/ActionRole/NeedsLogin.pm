package Treex::Web::ActionRole::NeedsLogin;
use Moose::Role;
use namespace::autoclean;

around execute => sub {
    my $orig = shift;
    my $self = shift;
    my ($controller, $c, @args) = @_;

    if (!$c->user_exists) {
        $c->response->code(401);
        if ($controller->isa('Treex::Web::Controller::REST')) {
            $c->stash->{ $controller->{'stash_key'} } = {
                error => 'Login required'
            };
        } else {
            $c->response->body('Access denied');
        }
        $c->detach;
    } else {
        return $self->$orig(@_);
    }
};

1;
__END__

=head1 NAME

Treex::Web::ActionRole::NeedsLogin

=head1 DESCRIPTION

Ensures user is logged in or returns code 401

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

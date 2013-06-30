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

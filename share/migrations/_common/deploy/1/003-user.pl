use strict;
use warnings;
use DBIx::Class::Migration::RunScript;
use DateTime;

migrate {
    my $db = shift;
    my $user_rs;
    eval {
        $user_rs = $db
            ->schema->resultset("User");
    };
    return if $@;        # Skip deployment if table doesn't exists

    # create treex user
    $user_rs->create({
        email => 'treex@ufal.mff.cuni.cz',
        password => 'LetMeIn',
        name => 'Treex',
        is_admin => 1,
        active => 1,
        last_modified => DateTime->now,
    });
};

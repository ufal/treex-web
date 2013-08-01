use strict;
use warnings;
use DBIx::Class::Migration::RunScript;
use DBIx::Class::EncodedColumn::Crypt::Eksblowfish::Bcrypt;
use DateTime;

migrate {
    my $db = shift;
    my $user_rs;
    eval {
        $user_rs = $db
            ->schema->resultset("User");
    };
    return if $@;        # Skip deployment if table doesn't exists

    my $encoder = DBIx::Class::EncodedColumn::Crypt::Eksblowfish::Bcrypt->make_encode_sub('password', { cost => 8, key_nul => 0 });

    # create treex user
    $user_rs->create({
        email => 'treex@ufal.mff.cuni.cz',
        password => $encoder->('LetMeIn'),
        name => 'Treex',
        is_admin => 1,
        active => 1,
        last_modified => DateTime->now,
    });
};

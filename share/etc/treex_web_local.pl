## configuration used for development
my $config = {
    name => 'Treex::Web',
    'Model::WebDB' => {
        connect_info => { dsn => '', user => '', sqlite_unicode => 1, unicode => 1 },
    },
};

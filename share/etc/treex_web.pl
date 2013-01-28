## Config used for production
my $config = {
    name => 'Treex::Web',
    'Model::WebDB' => {
        connect_info => {
            dsn => 'dbi:Pg:dbname=treex',
            user => 'treex',
            password => '',
            auto_savepoint => 1,
            quote_names => 1,
        },
    },
    'Model::TheSchwartz' => {
        args => {
            verbose => 1,
            databases => [{
                dsn => 'dbi:SQLite:__path_to(share/theschwartz.db)__'
            }]
        }
    }
};

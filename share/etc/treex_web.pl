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
    'Model::Resque' => {
        args => {
            redis => '127.0.0.1:6379', # standard redis configuration
            namespace => 'treex_resque',
            plugins => [ 'Status' ]
        }
    },
};

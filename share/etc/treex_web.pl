## Config used for production
my $config = {
    name => 'Treex::Web',
    'Model::WebDB' => {
        schema_class => 'Treex::Web::DB',
        traits => ['Caching', 'FromMigration'],
        install_if_needed => {
            default_fixture_sets => ['all_tables'],
        },
        
        connect_info => {
            dsn => 'dbi:Pg:dbname=treex',
            user => 'treex',
            password => '',
            auto_savepoint => 1,
            quote_names => 1,
        },
    },
};

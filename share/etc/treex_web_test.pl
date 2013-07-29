## Configration used for testing
my $config = {
    'Model::WebDB' => {
        connect_info => {
            dsn => '',
            user => '',
            password => '',
            auto_savepoint => 1,
            quote_names => 1,
        },

        extra_migration_args => {
            db_sandbox_builder_class => 'DBIx::Class::Migration::TempDirSandboxBuilder',
            db_sandbox_class => 'DBIx::Class::Migration::SqliteSandbox',
        },
    },
};

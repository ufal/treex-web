# Treex::Web

Web frontend for NLP framework Treex

## How to run it

### Perl API

Following will start development server http://localhost:3000/

    cpanm --instaldeps
    ./bin/server.pl -rd

### Angular Frontend

Frontend is separate app. For frontend to work you will need working
node.js, npm, grunt and bower installed. Also having Yeoman installed
is recommended.

Following will start development server at http://localhost:9000/ it
will automatically proxy API server at http://localhost:9000/APO/v1

    cd frontend
    npm install
    bower install
    grunt server

Production build is done by `grunt build` and output is saved in
`dist` directory. Additional configuration can be done directly in
`Gruntfile`.

### Job queue

    ./bin/job_runner.pl

## Reporting a bug

Go to:
https://redmine.ms.mff.cuni.cz/projects/treex-web/issues

## Maintenance NOTES

Generate SQL schema (for SQLite, Postgres and Mysql)

    ./bin/migration.pl --force_overwrite prepare

In order to update SQL schema go to Treex::Web::DB and increment
$VERSION. Make sure you have at least one db running with the old
schema and use:

    ./bin/migration.pl update

## History

July 2013 - first public beta
February 2012 - initial commit

## Credits

2012 - 2013 Michal Sedlák <sedlak@ufal.ms.mff.cuni.cz>

## License

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.


requires 'Catalyst::Runtime', '5.90007';
requires 'Catalyst::Plugin::ConfigLoader';
requires 'Catalyst::Plugin::Static::Simple';
requires 'Catalyst::Model::Adaptor';
requires 'Moose';
requires 'MooseX::SemiAffordanceAccessor';
requires 'namespace::autoclean';
requires 'Config::Any'; # This should reflect the config file format you've chosen
                        # See Catalyst::Plugin::ConfigLoader for supported forma

# DB stuff
requires 'Catalyst::Model::DBIC::Schema';
requires 'DBIx::Class::Migration';
requires 'DBIx::Class::Cursor::Cached';
requires 'DBIx::Class::TimeStamp';
requires 'DBIx::Class::UUIDColumns';
requires 'DBIx::Class::EncodedColumn';
requires 'DBIx::Class::InflateColumn::FS';
requires 'DBIx::Class::InflateColumn::Boolean';
requires 'SQL::Translator';
requires 'Email::Valid';        # used to check user mails
requires 'Data::Uniqid';        # used to generate UUID Columns
requires 'Data::TUID';
requires 'Crypt::Eksblowfish::Bcrypt'; # used for encrypting password
requires 'Data::UUID';
requires 'Data::Rmap';

# Auth stuff
requires 'Catalyst::Plugin::Authentication';
requires 'Catalyst::Authentication::Store::DBIx::Class';
requires 'Catalyst::Plugin::Authorization::Roles';
requires 'Catalyst::Plugin::Session::State::Cookie';
requires 'Catalyst::Plugin::Session::Store::FastMmap';
requires 'CatalystX::SimpleLogin';

# HTML::FormHandler
requires 'HTML::FormHandler' => '0.40001';
requires 'HTML::FormHandler::Model::DBIC';

# PML
requires 'Treex::PML';
requires 'PerlIO::via::gzip';
requires 'Cache::LRU';


# misc
requires 'Catalyst::Plugin::Assets';
requires 'IPC::Run';            # used to run treex command
requires 'HTML::Content::Extractor';
requires 'Resque';              # job processing queue
requires 'Regexp::Common';
requires 'Scalar::Util';
requires 'MooseX::ClassAttribute';
requires 'MooseX::MarkAsMethods';
requires 'MooseX::MarkAsMethods';
requires 'MooseX::NonMoose';
requires 'MooseX::Types::Common::String';
requires 'Params::Validate';
requires 'LWP::UserAgent';
requires 'List::MoreUtils';
requires 'JSON::Schema';
requires 'Exception::Class';
requires 'Encode';
requires 'Archive::Zip';
requires 'boolean';
requires 'Net::SFTP';
requires 'CHI';
requires 'Digest::SHA';
requires 'jQuery::File::Upload';

on 'test' => sub {
  requires 'Test::More' => '0.88';
  requires 'DBICx::TestDatabase';
};

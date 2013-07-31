package Treex::Web;
use Moose;
use namespace::autoclean;

use Catalyst::Runtime 5.90;

# Set flags and add plugins for the application.
#
# Note that ORDERING IS IMPORTANT here as plugins are initialized in order,
# therefore you almost certainly want to keep ConfigLoader at the head of the
# list if you're using it.
#
#         -Debug: activates the debug mode for very useful log messages
#   ConfigLoader: will load the configuration from a Config::General file in the
#                 application's home directory
# Static::Simple: will serve static files from the application's root
#                 directory

use Catalyst qw/
    ConfigLoader
    Session
    Session::Store::FastMmap
    Session::State::Cookie
    Authentication
    Static::Simple
/;
#    Authorization::Roles

extends 'Catalyst';

our $VERSION = '0.01';

# Configure the application.
#
# Note that settings in share/etc/treex_web.conf (or other external
# configuration file that you set up manually) take precedence
# over this when using ConfigLoader. Thus configuration
# details given here can function as a default configuration,
# with an external configuration file acting as an override for
# local deployment.

__PACKAGE__->config(
    name => 'Treex::Web',
    # Disable deprecated behavior needed by old applications
    disable_component_resolution_regex_fallback => 1,
    enable_catalyst_header => 1, # Send X-Catalyst header
    'Plugin::Authentication' => {
        default_realm => 'members',
        realms => {
            members => {
                credential => {
                    class => 'Password',
                    password_type => 'self_check',
                },
                store => {
                    class => 'DBIx::Class',
                    user_model => 'WebDB::User',
                }
            }
        }
    },
    'Plugin::ConfigLoader' => {
        file => __PACKAGE__->path_to('share', 'etc'),
    },
    'Plugin::Session' => {
        expires => 3600 * 24,
        storage => '/tmp/session',
    },
    'Model::WebDB' => {
        schema_class => 'Treex::Web::DB',
        traits => ['Caching', 'FromMigration', 'SchemaProxy'],
        install_if_needed => {
            default_fixture_sets => ['all_tables'],
        },
    },
    'Controller::Login' => {
        traits => [
            'WithRedirect', # Optional, enables redirect-back feature
            '-RenderAsTTTemplate', # Optional, allows you to use your own template
        ],
    },
);

# Start the application
__PACKAGE__->setup();

=head1 NAME

Treex::Web - Catalyst based application

=head1 SYNOPSIS

    bin/server.pl

=head1 DESCRIPTION

Treex::Web is a web interface for NLP framework Treex

=head1 SEE ALSO

L<Treex::Web::Controller::Root>, L<Catalyst>, L<Treex::Core>

=head1 AUTHOR

Michal Sedlak E<lt>sedlak@ufal.mff.cuni.czE<gt>

=head1 LICENSE

This library is free software. You can redistribute it and/or modify
it under the same terms as Perl itself.

=cut

1;

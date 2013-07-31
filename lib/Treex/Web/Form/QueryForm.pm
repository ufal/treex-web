package Treex::Web::Form::QueryForm;

use HTML::FormHandler::Moose;
BEGIN {extends 'HTML::FormHandler';}

with 'Treex::Web::Form::Role::Base';
with 'Treex::Web::Form::Role::LanguageOptions';

=head1 NAME

Treex::Web::Forms::QueryForm - Treex query form

=head1 METHODS

=cut

has 'schema' => (is => 'rw');
has 'user' => (is => 'rw', isa => 'Maybe[Object]');

has '+name' => (default => 'query-form');

has_field 'language' => (type => 'Select', widget => 'Select', options_method => \&language_options);
has_field 'result_hash' => (type => 'Hidden');
has_field 'scenario' => (type => 'TextArea', required => 1);
has_field 'name' => (type => 'Text');
has_field 'input' => (type => 'TextArea');
has_field 'filename' => (type => 'Text');

=head2 validate

=cut

sub validate {
    my $self = shift;

    my $language = $self->field('language')->value;
    if ($language && $language !~ /\d+/) {
        $self->field('language')->value($self->fetch_language_id($language));
    }

    $self->field('scenario')->add_error('Scenario is empty')
        unless $self->field('scenario')->value;

    $self->field('input')->add_error('Input not specified')
        unless $self->field('input')->value || $self->field('filename')->value;
}

=head2 fetch_scenario

=cut

sub fetch_scenario {
    my ( $self, $scenario_id ) = @_;
    return unless $self->schema;

    my $scenario = $self->schema->resultset('Scenario')->search({
        id => $scenario_id,
        -or => [
            public => 1,
            ($self->user ? (user => $self->user->id) : (user => undef)),
        ]
    }, { columns => [qw/scenario public user/] })->single;
    return unless $scenario;
    return $scenario->scenario;
}

=head2 fetch_language_id

=cut

sub fetch_language_id {
    my ( $self, $code ) = @_;
    return unless $self->schema;

    my $language = $self->schema->resultset('Language')->find({
        code => $code
    }, { columns => qw/id/ });
    return $language ? undef : $language->id;
}

no HTML::FormHandler::Moose;
1;
__END__

=head1 AUTHOR

Michal Sedlak, E<lt>sedlakmichal@gmail.comE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2012 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

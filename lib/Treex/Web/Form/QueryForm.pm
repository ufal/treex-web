package Treex::Web::Form::QueryForm;

use HTML::FormHandler::Moose;
BEGIN {extends 'HTML::FormHandler';}

with 'Treex::Web::Form::Role::Base';
with 'Treex::Web::Form::Role::LanguageOptions';

has 'schema' => (is => 'rw');
has 'user' => (is => 'rw', isa => 'Maybe[Object]');

has '+widget_wrapper' => ( default => 'None' );
has '+name' => (default => 'query-form');

has_field 'language' => (type => 'Select', widget => 'Select', options_method => \&language_options);
has_field 'result_hash' => (type => 'Hidden');
has_field 'scenario_id' => (type => 'Hidden');
has_field 'scenario' => (type => 'TextArea');
has_field 'input' => (type => 'TextArea', required => 1, rows => 10, element_attr => { class => 'input-block-level' });
has_field 'submit' => (type => 'Submit', value => 'Run this Treex scenario', element_attr => { class => 'btn btn-primary btn-large'});

sub validate {
    my $self = shift;

    my $id = $self->field('scenario_id')->value;
    $self->field('scenario')->value($self->fetch_scenario($id))
        if ($id && $id =~ /\d+/);
    $self->field('scenario')->add_error('Scenario is empty')
        unless $self->field('scenario')->value;
}

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

no HTML::FormHandler::Moose;
1;
__END__

=head1 NAME

Treex::Web::Forms::QueryForm - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Forms::QueryForm;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Forms::QueryForm,

Blah blah blah.

=head2 EXPORT

None by default.

=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

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
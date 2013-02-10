package Treex::Web::Form::RunScenario;

use HTML::FormHandler::Moose;
BEGIN {extends 'Treex::Web::Form::QueryForm';}

has 'scenario' => (is => 'ro', isa => 'Object');

has '+name' => (default => 'scenario-run-form');

sub after_build {
    my $self = shift;

    my $language_field = $self->field('language');
    $language_field->options_method(\&scenario_languages)
        if $self->scenario->languages->count;
    $self->field('scenario')->widget('NoRender');
    $self->field('scenario_id')->widget('NoRender');
}

sub scenario_languages {
    my $self = shift;
    $self = $self->form if $self->isa('HTML::FormHandler::Field');
    return unless $self->scenario;
    return map { { value => $_->id, label => $_->name } } $self->scenario->languages;
}

no HTML::FormHandler::Moose;
1;
__END__

=head1 NAME

Treex::Web::Form::RunScenario - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Form::RunScenario;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Form::RunScenario,

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

Copyright (C) 2013 by Michal Sedlak

This program is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.2 or,
at your option, any later version of Perl 5 you may have available.

=head1 BUGS

None reported... yet.

=cut

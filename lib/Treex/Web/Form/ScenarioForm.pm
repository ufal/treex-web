package Treex::Web::Form::ScenarioForm;

use strict;
use warnings;

use HTML::FormHandler::Moose;
extends 'Treex::Web::Form::Base';
with 'Treex::Web::Form::Role::LanguageOptions';
with 'HTML::FormHandler::TraitFor::Model::DBIC';

has '+item_class' => ( default => 'Treex::Web::DB::Result::Scenario' );
has '+name' => ( default => 'scenario-form' );
has '+widget_wrapper' => ( default => 'None' );

has '+unique_messages' => (
    default => sub {
        { name_user_unique => "Duplicate value for name" };
    }
);

has_field 'name' => (
    type => 'Text',
    value => '',
    maxlength => 120,
    required => 1,
    element_attr => { class => 'input-xxlarge', placeholder => 'Scenario name'}
);
has_field 'languages' => (type => 'Multiple', options_method => \&language_options, element_attr => { class => 'language-select input-xxlarge' });
has_field 'scenario' => (type => 'TextArea', required => 1);
has_field 'description' => (type => 'TextArea', required => 1, rows => 12, element_attr => { class => 'editor', placeholder => 'Scenario Description' });
has_field 'public' => (type => 'Boolean', do_label => 0, default => 0);
has_field 'user' => (type => 'Integer', widget => 'NoRender');
has_field 'submit' => (type => 'Submit', value => 'Submit');

no HTML::FormHandler::Moose;
1;
__END__

=head1 NAME

Treex::Web::Forms::ScenarioForm - Perl extension for blah blah blah

=head1 SYNOPSIS

   use Treex::Web::Forms::ScenarioForm;
   blah blah blah

=head1 DESCRIPTION

Stub documentation for Treex::Web::Forms::ScenarioForm,

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

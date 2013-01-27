package Treex::Web::Forms::QueryForm;

use HTML::FormHandler::Moose;
BEGIN {extends 'HTML::FormHandler';}

with 'Treex::Web::Forms::Role::Base';

has '+widget_wrapper' => ( default => 'None' );
has '+name' => (default => 'query_form');

has_field 'language' => (type => 'Select', widget => 'Select');
has_field 'result_hash' => (type => 'Hidden');
has_field 'scenario' => (type => 'Hidden', required => 1);
has_field 'input' => (type => 'TextArea', required => 1, rows => 10, element_attr => { class => 'input-block-level' });
has_field 'submit' => (type => 'Submit', value => 'Run this Treex scenario', element_attr => { class => 'btn btn-primary btn-large'});

sub options_language { (
    {
        group => 'Major Languages',
        options => [
            { value => 'en', label => 'English' },
            { value => 'de', label => 'German' },
            { value => 'fr', label => 'French' },
            { value => 'es', label => 'Spanish' },
            { value => 'it', label => 'Italian' },
            { value => 'ru', label => 'Russian' },
            { value => 'ar', label => 'Arabic' },
            { value => 'zh', label => 'Chinese' },
        ]
    },
    {
        group => 'Other Slavic languages',
        options => [
            { value => 'cs', label => 'Czech' },
            { value => 'sk', label => 'Slovak' },
            { value => 'pl', label => 'Polish' },
            { value => 'dsb', label => 'Lower Sorbian' },
            { value => 'hsb', label => 'Upper Sorbian' },
            { value => 'be', label => 'Belarusian' },
            { value => 'uk', label => 'Ukrainian' },
            { value => 'sl', label => 'Slovene' },
            { value => 'hr', label => 'Croatian' },
            { value => 'sr', label => 'Serbian' },
            { value => 'mk', label => 'Macedonian' },
            { value => 'bg', label => 'Bulgarian' },
            { value => 'cu', label => 'Old Church Slavonic' },
        ]
    },
    {
        group => 'Other Germanic languages',
        options => [
            { value => 'nl', label => 'Dutch' },
            { value => 'af', label => 'Afrikaans' },
            { value => 'fy', label => 'Frisian' },
            { value => 'lb', label => 'Luxemburgish' },
            { value => 'yi', label => 'Yiddish' },
            { value => 'da', label => 'Danish' },
            { value => 'sv', label => 'Swedish' },
            { value => 'no', label => 'Norwegian' },
            { value => 'nn', label => 'Nynorsk (New Norwegian)' },
            { value => 'fo', label => 'Faroese' },
            { value => 'is', label => 'Icelandic' },
        ]
    },
    {
        group => 'Other Romance and Italic languages',
        options => [
            { value => 'la', label => 'Latin' },
            { value => 'pt', label => 'Portuguese' },
            { value => 'gl', label => 'Galician' },
            { value => 'ca', label => 'Catalan' },
            { value => 'oc', label => 'Occitan' },
            { value => 'rm', label => 'Rhaeto-Romance' },
            { value => 'co', label => 'Corsican' },
            { value => 'sc', label => 'Sardinian' },
            { value => 'ro', label => 'Romanian' },
            { value => 'mo', label => 'Moldovan (deprecated: use Romanian)' },
        ]
    },
    {
        group => 'Celtic languages',
        options => [
            { value => 'ga', label => 'Irish' },
            { value => 'gd', label => 'Scottish' },
            { value => 'cy', label => 'Welsh' },
            { value => 'br', label => 'Breton' },
        ]
    },
    {
        group => 'Baltic languages',
        options => [
            { value => 'lt', label => 'Lithuanian' },
            { value => 'lv', label => 'Latvian' },
        ]
    },
    {
        group => 'Other Indo-European languages in Europe and Caucasus',
        options => [
            { value => 'sq', label => 'Albanian' },
            { value => 'el', label => 'Greek' },
            { value => 'grc', label => 'Ancient Greek' },
            { value => 'hy', label => 'Armenian' },
        ]
    },
    {
        group => 'Iranian languages',
        options => [
            { value => 'fa', label => 'Persian' },
            { value => 'ku-latn', label => 'Kurdish in Latin script' },
            { value => 'ku-arab', label => 'Kurdish in Arabic script' },
            { value => 'ku-cyrl', label => 'Kurdish in Cyrillic script' },
            { value => 'os', label => 'Ossetic' },
            { value => 'tg', label => 'Tajiki (in Cyrillic script)' },
            { value => 'ps', label => 'Pashto' },
        ]
    },
    {
        group => 'Indo-Aryan languages',
        options => [
            { value => 'ks', label => 'Kashmiri (in Arabic script)' },
            { value => 'sd', label => 'Sindhi' },
            { value => 'pa', label => 'Punjabi' },
            { value => 'ur', label => 'Urdu' },
            { value => 'hi', label => 'Hindi' },
            { value => 'gu', label => 'Gujarati' },
            { value => 'mr', label => 'Marathi' },
            { value => 'ne', label => 'Nepali' },
            { value => 'or', label => 'Oriya' },
            { value => 'bn', label => 'Bengali' },
            { value => 'as', label => 'Assamese' },
            { value => 'rmy', label => 'Romany' },
        ]
    },
    {
        group => 'Other Semitic languages',
        options => [
            { value => 'mt', label => 'Maltese' },
            { value => 'he', label => 'Hebrew' },
            { value => 'am', label => 'Amharic' },
        ]
    },
    {
        group => 'Finno-Ugric languages',
        options => [
            { value => 'hu', label => 'Hungarian' },
            { value => 'fi', label => 'Finnish' },
            { value => 'et', label => 'Estonian' },
        ]
    },
    {
        group => 'Other European and Caucasian languages',
        options => [
            { value => 'eu', label => 'Basque' },
            { value => 'ka', label => 'Georgian' },
            { value => 'ab', label => 'Abkhaz' },
            { value => 'ce', label => 'Chechen' },
        ]
    },
    {
        group => 'Turkic languages',
        options => [
            { value => 'tr', label => 'Turkish' },
            { value => 'az', label => 'Azeri' },
            { value => 'cv', label => 'Chuvash' },
            { value => 'ba', label => 'Bashkir' },
            { value => 'tt', label => 'Tatar' },
            { value => 'tk', label => 'Turkmen' },
            { value => 'uz', label => 'Uzbek' },
            { value => 'kaa', label => 'Karakalpak' },
            { value => 'kk', label => 'Kazakh' },
            { value => 'ky', label => 'Kyrgyz' },
            { value => 'ug', label => 'Uyghur' },
            { value => 'sah', label => 'Yakut' },
        ]
    },
    {
        group => 'Other Altay languages',
        options => [
            { value => 'xal', label => 'Kalmyk' },
            { value => 'bxr', label => 'Buryat' },
            { value => 'mn', label => 'Mongol' },
            { value => 'ko', label => 'Korean' },
            { value => 'ja', label => 'Japanese' },
        ]
    },
    {
        group => 'Dravidian languages',
        options => [
            { value => 'te', label => 'Telugu' },
            { value => 'kn', label => 'Kannada' },
            { value => 'ml', label => 'Malayalam' },
            { value => 'ta', label => 'Tamil' },
        ]
    },
    {
        group => 'Sino-Tibetan languages',
        options => [
            { value => 'zh', label => 'Mandarin Chinese' },
            { value => 'hak', label => 'Hakka' },
            { value => 'nan', label => 'Taiwanese' },
            { value => 'yue', label => 'Cantonese' },
            { value => 'lo', label => 'Lao' },
            { value => 'th', label => 'Thai' },
            { value => 'my', label => 'Burmese' },
            { value => 'bo', label => 'Tibetan' },
        ]
    },
    {
        group => 'Austro-Asian languages',
        options => [
            { value => 'vi', label => 'Vietnamese' },
            { value => 'km', label => 'Khmer' },
        ]
    },
    {
        group => 'Other languages',
        options => [
            { value => 'sw', label => 'Swahili' },
            { value => 'eo', label => 'Esperanto' },
            { value => 'und', label => 'undetermined/unknown language' },
        ]
    }
)}

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

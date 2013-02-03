use strict;
use warnings;
use DBIx::Class::Migration::RunScript;


migrate {
    my $lang_group_rs = shift
        ->schema->resultset("LanguageGroup");

    $lang_group_rs->create(
        name => 'Major Languages',
        languages => [
            { code => 'en', name => 'English' },
            { code => 'de', name => 'German' },
            { code => 'fr', name => 'French' },
            { code => 'es', name => 'Spanish' },
            { code => 'it', name => 'Italian' },
            { code => 'ru', name => 'Russian' },
            { code => 'ar', name => 'Arabic' },
            { code => 'zh', name => 'Chinese' },
        ]
    );
    $lang_group_rs->create(
        name => 'Other Slavic languages',
        languages => [
            { code => 'cs', name => 'Czech' },
            { code => 'sk', name => 'Slovak' },
            { code => 'pl', name => 'Polish' },
            { code => 'dsb', name => 'Lower Sorbian' },
            { code => 'hsb', name => 'Upper Sorbian' },
            { code => 'be', name => 'Belarusian' },
            { code => 'uk', name => 'Ukrainian' },
            { code => 'sl', name => 'Slovene' },
            { code => 'hr', name => 'Croatian' },
            { code => 'sr', name => 'Serbian' },
            { code => 'mk', name => 'Macedonian' },
            { code => 'bg', name => 'Bulgarian' },
            { code => 'cu', name => 'Old Church Slavonic' },
        ]
    );
    $lang_group_rs->create(
        name => 'Other Germanic languages',
        languages => [
            { code => 'nl', name => 'Dutch' },
            { code => 'af', name => 'Afrikaans' },
            { code => 'fy', name => 'Frisian' },
            { code => 'lb', name => 'Luxemburgish' },
            { code => 'yi', name => 'Yiddish' },
            { code => 'da', name => 'Danish' },
            { code => 'sv', name => 'Swedish' },
            { code => 'no', name => 'Norwegian' },
            { code => 'nn', name => 'Nynorsk (New Norwegian)' },
            { code => 'fo', name => 'Faroese' },
            { code => 'is', name => 'Icelandic' },
        ]
    );
    $lang_group_rs->create(
        name => 'Other Romance and Italic languages',
        languages => [
            { code => 'la', name => 'Latin' },
            { code => 'pt', name => 'Portuguese' },
            { code => 'gl', name => 'Galician' },
            { code => 'ca', name => 'Catalan' },
            { code => 'oc', name => 'Occitan' },
            { code => 'rm', name => 'Rhaeto-Romance' },
            { code => 'co', name => 'Corsican' },
            { code => 'sc', name => 'Sardinian' },
            { code => 'ro', name => 'Romanian' },
            { code => 'mo', name => 'Moldovan (deprecated: use Romanian)' },
        ]
    );
    $lang_group_rs->create(
        name => 'Celtic languages',
        languages => [
            { code => 'ga', name => 'Irish' },
            { code => 'gd', name => 'Scottish' },
            { code => 'cy', name => 'Welsh' },
            { code => 'br', name => 'Breton' },
        ]
    );
    $lang_group_rs->create(
        name => 'Baltic languages',
        languages => [
            { code => 'lt', name => 'Lithuanian' },
            { code => 'lv', name => 'Latvian' },
        ]
    );
    $lang_group_rs->create(
        Name => 'Other Indo-European languages in Europe and Caucasus',
        languages => [
            { code => 'sq', name => 'Albanian' },
            { code => 'el', name => 'Greek' },
            { code => 'grc', name => 'Ancient Greek' },
            { code => 'hy', name => 'Armenian' },
        ]
    );
    $lang_group_rs->create(
        name => 'Iranian languages',
        languages => [
            { code => 'fa', name => 'Persian' },
            { code => 'ku-latn', name => 'Kurdish in Latin script' },
            { code => 'ku-arab', name => 'Kurdish in Arabic script' },
            { code => 'ku-cyrl', name => 'Kurdish in Cyrillic script' },
            { code => 'os', name => 'Ossetic' },
            { code => 'tg', name => 'Tajiki (in Cyrillic script)' },
            { code => 'ps', name => 'Pashto' },
        ]
    );
    $lang_group_rs->create(
        name => 'Indo-Aryan languages',
        languages => [
            { code => 'ks', name => 'Kashmiri (in Arabic script)' },
            { code => 'sd', name => 'Sindhi' },
            { code => 'pa', name => 'Punjabi' },
            { code => 'ur', name => 'Urdu' },
            { code => 'hi', name => 'Hindi' },
            { code => 'gu', name => 'Gujarati' },
            { code => 'mr', name => 'Marathi' },
            { code => 'ne', name => 'Nepali' },
            { code => 'or', name => 'Oriya' },
            { code => 'bn', name => 'Bengali' },
            { code => 'as', name => 'Assamese' },
            { code => 'rmy', name => 'Romany' },
        ]
    );
    $lang_group_rs->create(
        name => 'Other Semitic languages',
        languages => [
            { code => 'mt', name => 'Maltese' },
            { code => 'he', name => 'Hebrew' },
            { code => 'am', name => 'Amharic' },
        ]
    );
    $lang_group_rs->create(
        name => 'Finno-Ugric languages',
        languages => [
            { code => 'hu', name => 'Hungarian' },
            { code => 'fi', name => 'Finnish' },
            { code => 'et', name => 'Estonian' },
        ]
    );
    $lang_group_rs->create(
        name => 'Other European and Caucasian languages',
        languages => [
            { code => 'eu', name => 'Basque' },
            { code => 'ka', name => 'Georgian' },
            { code => 'ab', name => 'Abkhaz' },
            { code => 'ce', name => 'Chechen' },
        ]
    );
    $lang_group_rs->create(
        name => 'Turkic languages',
        languages => [
            { code => 'tr', name => 'Turkish' },
            { code => 'az', name => 'Azeri' },
            { code => 'cv', name => 'Chuvash' },
            { code => 'ba', name => 'Bashkir' },
            { code => 'tt', name => 'Tatar' },
            { code => 'tk', name => 'Turkmen' },
            { code => 'uz', name => 'Uzbek' },
            { code => 'kaa', name => 'Karakalpak' },
            { code => 'kk', name => 'Kazakh' },
            { code => 'ky', name => 'Kyrgyz' },
            { code => 'ug', name => 'Uyghur' },
            { code => 'sah', name => 'Yakut' },
        ]
    );
    $lang_group_rs->create(
        name => 'Other Altay languages',
        languages => [
            { code => 'xal', name => 'Kalmyk' },
            { code => 'bxr', name => 'Buryat' },
            { code => 'mn', name => 'Mongol' },
            { code => 'ko', name => 'Korean' },
            { code => 'ja', name => 'Japanese' },
        ]
    );
    $lang_group_rs->create(
        name => 'Dravidian languages',
        languages => [
            { code => 'te', name => 'Telugu' },
            { code => 'kn', name => 'Kannada' },
            { code => 'ml', name => 'Malayalam' },
            { code => 'ta', name => 'Tamil' },
        ]
    );
    $lang_group_rs->create(
        name => 'Sino-Tibetan languages',
        languages => [
            { code => 'zh', name => 'Mandarin Chinese' },
            { code => 'hak', name => 'Hakka' },
            { code => 'nan', name => 'Taiwanese' },
            { code => 'yue', name => 'Cantonese' },
            { code => 'lo', name => 'Lao' },
            { code => 'th', name => 'Thai' },
            { code => 'my', name => 'Burmese' },
            { code => 'bo', name => 'Tibetan' },
        ]
    );
    $lang_group_rs->create(
        name => 'Austro-Asian languages',
        languages => [
            { code => 'vi', name => 'Vietnamese' },
            { code => 'km', name => 'Khmer' },
        ]
    );
    $lang_group_rs->create(
        name => 'Other languages',
        languages => [
            { code => 'sw', name => 'Swahili' },
            { code => 'eo', name => 'Esperanto' },
            { code => 'und', name => 'undetermined/unknown language' },
        ]
    );
};

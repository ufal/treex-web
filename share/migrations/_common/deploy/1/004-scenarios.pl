use utf8;
use strict;
use warnings;
use DBIx::Class::Migration::RunScript;
use DateTime;

migrate {
    my $db = shift;
    my ($scenario_rs, $language_rs, $user_rs);
    eval {
        $scenario_rs = $db
            ->schema->resultset("Scenario");
        $language_rs = $db
            ->schema->resultset("Language");
        $user_rs = $db
            ->schema->resultset("User");
    };
    return if $@;            # Skip deployment if table doesn't exists

    my $user = $user_rs->single({ name => 'Treex' });
    my $en = $language_rs->single({ code => 'en' });
    my $cs = $language_rs->single({ code => 'cs' });

    # Huge wall of text first

    my $czech_sample = <<SAMPLE;
Český jazyk neboli čeština je západoslovanský jazyk, nejvíce příbuzný se slovenštinou, poté polštinou a lužickou srbštinou. Patří mezi slovanské jazyky, do rodiny jazyků indoevropských. Čeština se vyvinula ze západních nářečí praslovanštiny na konci 10. století. Česky psaná literatura se objevuje od 14. století. První písemné památky jsou však již z 12. století. Dělí se na spisovnou č., určenou pro oficiální styk (je kodifikována v mluvnicích a slovnících), a nespisovnou č., která zahrnuje dialekty (nářečí) a sociolekty (slangy) včetně vulgarismů a argotu. Spisovná čeština má dvě podoby: vypjatě spisovnou a hovorovou. Hovorovou češtinu je třeba odlišovat od češtiny obecné.
SAMPLE
    my $english_sample_long = <<SAMPLE;
Food: Where European inflation slipped up
The skyward zoom in food prices is the dominant force behind the speed up in eurozone inflation.
November price hikes were higher than expected in the 13 eurozone countries, with October's 2.6 percent yr/yr inflation rate followed by 3.1 percent in November, the EU's Luxembourg-based statistical office reported.
Official forecasts predicted just 3 percent, Bloomberg said.
As opposed to the US, UK, and Canadian central banks, the European Central Bank (ECB) did not cut interest rates, arguing that a rate drop combined with rising raw material prices and declining unemployment would trigger an inflationary spiral.
The ECB wants to hold inflation to under two percent, or somewhere in that vicinity.
According to one analyst, ECB has been caught in a Catch-22: It needs to "talk down" inflation, to keep from having to take action to push it down later in the game.
Germany's November inflation rate of 3.3 percent counts as a record; in Spain the rate shot up to 4.1 percent from an earlier 3.6.
Soaring food and energy prices sent eurozone inflation into the stratosphere.
Wheat futures were up by 88 percent and soybean prices were at their highest since 1973.
Consumers also have had to pay significantly more for vegetable oils and dairy products in 2007.
The world market price of crude oil shot up by 52 percent this year, with the black gold costing nearly 100 dollars a barrel last month.
The ECB predicts that 2008 inflation will climb to 2.5 percent from the earlier 2.1, but will drop back to 1.9 percent in 2009.
Analysts see the 12-month inflation rate as holding steady at about 3 percent over the next 3-4 months, but say that the annual average rate will be 2.1 percent.
They also predict that the ECB will cut interest rates twice during the course of 2008.
Government crisis coming, says Gallup
Fidesz support shot up significantly in early December after a lengthy period of just holding its own. This gives it the strongest support base it has seen since 2002, while Gallup reports support for the socialists at an all-time low of 13 percent.
Among people with a clear party preference, given the stronger resolve of opposition voters, Fidesz support exceeds the two-thirds mark (71 percent), while MSZP has garnered but one-fifth (20 percent).
The poll puts MDF and SZDSZ numbers below the threshold needed to get into parliament; garnering about 2 percent support each within the entire sample.
Among people with clear party preferences who say they definitely would vote, support for these two parties is 3 percent each.
The public mood regarding the economy has managed to sink even lower than the rock-bottom last measured. The proportion who believe the country's economy is in the pits is an unprecedented 41 percent, while another 46 percent just think it is in bad shape.
Following higher hopes in spring and summer, people are again more pessimistic about the financial prospects for their families.
For next year, over half the public expects things to get worse and only one in ten predicts an improvement.
In Gallup's December poll, more respondents than ever before - 71 percent - said the prime minister was doing a poor rather than a good job.
Thirteen percent of the sample said it trusted or highly trusted Ferenc Gyurcsány, while 38 percent put their trust in Viktor Orbán.
SAMPLE

    my $english_sample = <<'SAMPLE';
I got a gift for my brother. "Contributing factors were the long-term trend toward warmer temperatures, as well as a moderate El Nino in the Pacific," Jay Lawrimore of NOAA's National Climatic Data Center said in a telephone interview from Asheville, North Carolina. The next-warmest winter on record was in 2004, and the third warmest winter was in 1998, Lawrimore said. The 10 warmest years on record have occurred since 1995. "We don't say this winter is evidence of the influence of greenhouse gases," Lawrimore said.
SAMPLE

    my $translation = <<SCEN;
Util::SetGlobal language=en selector=src
Read::Text
W2A::EN::Segment

#W2A::ResegmentSentences
W2A::EN::Tokenize
W2A::EN::NormalizeForms
W2A::EN::FixTokenization
W2A::EN::TagMorce
W2A::EN::FixTags
W2A::EN::Lemmatize
A2N::EN::StanfordNamedEntities model=ner-eng-ie.crf-3-all2008.ser.gz
A2N::EN::DistinguishPersonalNames
W2A::MarkChunks
W2A::EN::ParseMST model=conll_mcd_order2_0.01.model
W2A::EN::SetIsMemberFromDeprel
W2A::EN::RehangConllToPdtStyle
W2A::EN::FixNominalGroups
W2A::EN::FixIsMember
W2A::EN::FixAtree
W2A::EN::FixMultiwordPrepAndConj
W2A::EN::FixDicendiVerbs
W2A::EN::SetAfunAuxCPCoord
W2A::EN::SetAfun
W2A::FixQuotes
A2T::EN::MarkEdgesToCollapse
A2T::EN::MarkEdgesToCollapseNeg
A2T::BuildTtree
A2T::SetIsMember
A2T::EN::MoveAuxFromCoordToMembers
A2T::EN::FixTlemmas
A2T::EN::SetCoapFunctors
A2T::EN::FixEitherOr
A2T::EN::FixHowPlusAdjective
A2T::FixIsMember
A2T::EN::MarkClauseHeads
A2T::EN::SetFunctors
A2T::EN::MarkInfin
A2T::EN::MarkRelClauseHeads
A2T::EN::MarkRelClauseCoref
A2T::EN::MarkDspRoot
A2T::MarkParentheses
A2T::SetNodetype
A2T::EN::SetFormeme
A2T::EN::SetTense
A2T::EN::SetGrammatemes
A2T::SetSentmod
A2T::EN::RehangSharedAttr
A2T::EN::SetVoice
A2T::EN::FixImperatives
A2T::EN::SetIsNameOfPerson
A2T::EN::SetGenderOfPerson
A2T::EN::AddCorAct
T2T::SetClauseNumber
A2T::EN::FixRelClauseNoRelPron
A2T::EN::FindTextCoref
Util::SetGlobal language=cs selector=tst

T2T::CopyTtree source_language=en source_selector=src

T2T::EN2CS::TrLFPhrases
T2T::EN2CS::TrLFJointStatic
T2T::EN2CS::DeleteSuperfluousTnodes
T2T::EN2CS::TrFTryRules
T2T::EN2CS::TrFAddVariants maxent_features_version=0.9
T2T::EN2CS::TrFRerank
T2T::EN2CS::TrLTryRules
T2T::EN2CS::TrLHackNNP
T2T::EN2CS::TrLAddVariants
T2T::EN2CS::TrLFNumeralsByRules
T2T::EN2CS::TrLFilterAspect
T2T::EN2CS::TransformPassiveConstructions
T2T::EN2CS::PrunePersonalNameVariants
T2T::EN2CS::RemoveUnpassivizableVariants
T2T::EN2CS::TrLFCompounds
Util::DefinedAttr tnode=t_lemma,formeme message='after TrLFCompounds'
T2T::EN2CS::CutVariants lemma_prob_sum=0.5 formeme_prob_sum=0.9 max_lemma_variants=7 max_formeme_variants=7
T2T::RehangToEffParents
T2T::EN2CS::TrLFTreeViterbi
T2T::RehangToOrigParents
T2T::EN2CS::CutVariants max_lemma_variants=3 max_formeme_variants=3
T2T::EN2CS::FixTransferChoices
T2T::EN2CS::ReplaceVerbWithAdj
T2T::EN2CS::DeletePossPronBeforeVlastni
T2T::EN2CS::TrLFemaleSurnames
T2T::EN2CS::AddNounGender
T2T::EN2CS::MarkNewRelClauses
T2T::EN2CS::AddRelpronBelowRc
T2T::EN2CS::ChangeCorToPersPron
T2T::EN2CS::AddPersPronBelowVfin
T2T::EN2CS::AddVerbAspect
T2T::EN2CS::FixDateTime
T2T::EN2CS::FixGrammatemesAfterTransfer
T2T::EN2CS::FixNegation
T2T::EN2CS::MoveAdjsBeforeNouns
T2T::EN2CS::MoveGenitivesRight
T2T::EN2CS::MoveRelClauseRight
T2T::EN2CS::MoveDicendiCloserToDsp
T2T::EN2CS::MovePersPronNextToVerb
T2T::EN2CS::MoveEnoughBeforeAdj
T2T::EN2CS::MoveJesteBeforeVerb
T2T::EN2CS::FixMoney
T2T::EN2CS::FindGramCorefForReflPron
T2T::EN2CS::NeutPersPronGenderFromAntec
T2T::EN2CS::ValencyRelatedRules
T2T::SetClauseNumber
T2T::EN2CS::TurnTextCorefToGramCoref
T2T::EN2CS::FixAdjComplAgreement
Util::SetGlobal language=cs selector=tst
T2A::CopyTtree
T2A::CS::DistinguishHomonymousMlemmas
T2A::CS::ReverseNumberNounDependency
T2A::CS::InitMorphcat
T2A::CS::FixPossessiveAdjs
Util::DefinedAttr tnode=t_lemma,formeme,functor,clause_number anode=lemma message='after InitMorphcat and FixPossessiveAdjs'
T2A::CS::MarkSubject
T2A::CS::ImposePronZAgr
T2A::CS::ImposeRelPronAgr
T2A::CS::ImposeSubjpredAgr
T2A::CS::ImposeAttrAgr
T2A::CS::ImposeComplAgr
T2A::CS::DropSubjPersProns
T2A::CS::AddPrepos
T2A::CS::AddSubconjs
T2A::CS::AddReflexParticles
T2A::CS::AddAuxVerbCompoundPassive
T2A::CS::AddAuxVerbModal
T2A::CS::AddAuxVerbCompoundFuture
T2A::CS::AddAuxVerbConditional
T2A::CS::AddAuxVerbCompoundPast
T2A::CS::AddClausalExpletivePronouns
T2A::CS::MoveQuotes
T2A::CS::ResolveVerbs
T2A::CS::ProjectClauseNumber
Util::DefinedAttr anode=clause_number message='after ProjectClauseNumber'
T2A::CS::AddParentheses
T2A::CS::AddSentFinalPunct
T2A::CS::AddSubordClausePunct
T2A::CS::AddCoordPunct
T2A::CS::AddAppositionPunct
T2A::CS::ChooseMlemmaForPersPron
T2A::CS::GenerateWordforms
T2A::CS::DeleteSuperfluousAuxCP
T2A::CS::MoveCliticsToWackernagel
T2A::CS::DeleteEmptyNouns
T2A::CS::VocalizePrepos
T2A::CS::CapitalizeSentStart
T2A::CS::CapitalizeNamedEntitiesAfterTransfer
A2W::ConcatenateTokens
A2W::CS::ApplySubstitutions
A2W::CS::DetokenizeUsingRules
A2W::CS::RemoveRepeatedTokens
Write::Treex
SCEN

        my $english_t_layer = <<"SCEN";
Util::SetGlobal language=en
Read::Text
W2A::EN::Segment
# to m-layer
W2A::EN::Tokenize
W2A::EN::NormalizeForms
W2A::EN::FixTokenization
W2A::EN::TagMorce
W2A::EN::FixTags
W2A::EN::Lemmatize
# named entities
A2N::EN::StanfordNamedEntities model=ner-eng-ie.crf-3-all2008.ser.gz
A2N::EN::DistinguishPersonalNames
# to a-layer
W2A::MarkChunks
W2A::EN::ParseMST model=conll_mcd_order2_0.1.model
W2A::EN::SetIsMemberFromDeprel
W2A::EN::RehangConllToPdtStyle
W2A::EN::FixNominalGroups
W2A::EN::FixIsMember
W2A::EN::FixAtree
W2A::EN::FixMultiwordPrepAndConj
W2A::EN::FixDicendiVerbs
W2A::EN::SetAfunAuxCPCoord
W2A::EN::SetAfun
W2A::FixQuotes
# to t-layer
A2T::EN::MarkEdgesToCollapse
A2T::EN::MarkEdgesToCollapseNeg
A2T::BuildTtree
A2T::SetIsMember
A2T::EN::MoveAuxFromCoordToMembers
A2T::EN::FixTlemmas
A2T::EN::SetCoapFunctors
A2T::EN::FixEitherOr
A2T::EN::FixHowPlusAdjective
A2T::FixIsMember
A2T::EN::MarkClauseHeads
# A2T::EN::MarkPassives
A2T::EN::SetFunctors
A2T::EN::MarkInfin
A2T::EN::MarkRelClauseHeads
A2T::EN::MarkRelClauseCoref
A2T::EN::MarkDspRoot
A2T::MarkParentheses
A2T::SetNodetype
A2T::EN::SetTense
A2T::EN::SetGrammatemes
A2T::SetSentmod
A2T::EN::SetFormeme
A2T::EN::RehangSharedAttr
A2T::EN::SetVoice
A2T::EN::FixImperatives
A2T::EN::SetIsNameOfPerson
A2T::EN::SetGenderOfPerson
A2T::EN::AddCorAct
T2T::SetClauseNumber
A2T::EN::FixRelClauseNoRelPron
A2T::EN::FindTextCoref
Write::Treex
SCEN

    my $english_a_layer = <<SCEN;
Util::SetGlobal language=en
Read::Text
W2A::EN::Segment
# to m-layer
W2A::EN::Tokenize
W2A::EN::NormalizeForms
W2A::EN::FixTokenization
W2A::EN::TagMorce
W2A::EN::FixTags
W2A::EN::Lemmatize
# named entities
A2N::EN::StanfordNamedEntities model=ner-eng-ie.crf-3-all2008.ser.gz
A2N::EN::DistinguishPersonalNames
# to a-layer
W2A::MarkChunks
W2A::EN::ParseMST model=conll_mcd_order2_0.1.model
W2A::EN::SetIsMemberFromDeprel
W2A::EN::RehangConllToPdtStyle
W2A::EN::FixNominalGroups
W2A::EN::FixIsMember
W2A::EN::FixAtree
W2A::EN::FixMultiwordPrepAndConj
W2A::EN::FixDicendiVerbs
W2A::EN::SetAfunAuxCPCoord
W2A::EN::SetAfun
W2A::FixQuotes
Write::Treex
SCEN

    my $czech_a_layer = <<'SCEN';
Util::SetGlobal language=cs
Read::Text
W2A::CS::Segment

# m-layer
W2A::CS::Tokenize
W2A::CS::TagFeaturama lemmatize=1
W2A::CS::FixMorphoErrors

# a-layer
W2A::CS::ParseMSTAdapted
W2A::CS::FixAtreeAfterMcD
W2A::CS::FixIsMember
W2A::CS::FixPrepositionalCase
W2A::CS::FixReflexiveTantum
W2A::CS::FixReflexivePronouns
Write::Treex
SCEN

    my $czech_t_layer = <<'SCEN';
#
# tecto-analysis of Czech
#
Util::SetGlobal language=cs
Read::Text
W2A::CS::Segment

# m-layer
W2A::CS::Tokenize
W2A::CS::TagFeaturama lemmatize=1
W2A::CS::FixMorphoErrors

# a-layer
W2A::CS::ParseMSTAdapted
W2A::CS::FixAtreeAfterMcD
W2A::CS::FixIsMember
W2A::CS::FixPrepositionalCase
W2A::CS::FixReflexiveTantum
W2A::CS::FixReflexivePronouns
A2N::CS::SimpleRuleNER

# t-layer
A2T::CS::MarkEdgesToCollapse
A2T::BuildTtree
A2T::RehangUnaryCoordConj
A2T::SetIsMember
A2T::CS::SetCoapFunctors
A2T::FixIsMember
A2T::MarkParentheses
A2T::CS::DistribCoordAux
A2T::CS::MarkClauseHeads
A2T::CS::MarkRelClauseHeads
A2T::CS::MarkRelClauseCoref
#A2T::DeleteChildlessPunctuation #quotes on t-layer are ok for transfer
A2T::CS::FixTlemmas
A2T::CS::FixNumerals
A2T::SetNodetype
A2T::CS::SetFormeme use_version=2 fix_prep=0
A2T::CS::SetDiathesis
A2T::CS::SetFunctors memory=2g
A2T::CS::SetMissingFunctors
A2T::SetNodetype
A2T::FixAtomicNodes
A2T::CS::SetGrammatemes
A2T::CS::MarkReflexivePassiveGen
A2T::CS::AddPersPron
T2T::SetClauseNumber
A2T::CS::MarkReflpronCoref
Write::Treex
SCEN

    # english t-layer
    $scenario_rs->create({
        scenario => $english_t_layer,
        name => 'English t-layer analysis',
        description => 'Rule-based segmentation and tokenization, Morce PoS tagger, lemmatizer, Stanford named entities recognizer, MST parser, rule-based conversion to PDT-style dependencies, dependency labels (afun) assingnment, tectogrammatical analysis.',
        sample => $english_sample,
        public => 1,
        scenario_languages => [ { language => $en->id } ],
        user => $user->id,
        created_at => DateTime->now,
        last_modified => DateTime->now,
    });

    $scenario_rs->create({
        scenario => $english_a_layer,
        name => 'English a-layer analysis',
        description => 'Rule-based segmentation and tokenization, Morce PoS tagger, lemmatizer, Stanford named entities recognizer, MST parser, rule-based conversion to PDT-style dependencies, dependency labels (afun) assingnment.',
        sample => $english_sample,
        public => 1,
        scenario_languages => [ { language => $en->id } ],
        user => $user->id,
        created_at => DateTime->now,
        last_modified => DateTime->now,
    });

    $scenario_rs->create({
        scenario => $translation,
        name => 'English-Czech translation',
        description => 'English-to-Czech translation with TectoMT (full scenario).',
        sample => $english_sample_long,
        public => 1,
        scenario_languages => [ { language => $en->id } ],
        user => $user->id,
        created_at => DateTime->now,
        last_modified => DateTime->now,
    });

    $scenario_rs->create({
        scenario => $czech_t_layer,
        name => 'Czech t-layer analysis',
        description => 'Rule-based tokenization, Featurama tagging & lemmatization, MST parsing, several rule-based blocks to fix tagging and parsing, tectogrammatical analysis.',
        sample => $czech_sample,
        public => 1,
        scenario_languages => [ { language => $cs->id } ],
        user => $user->id,
        created_at => DateTime->now,
        last_modified => DateTime->now,
    });

    $scenario_rs->create({
        scenario => $czech_a_layer,
        name => 'Czech a-layer analysis',
        description => 'Rule-based tokenization, Featurama tagging & lemmatization, MST parsing, several rule-based blocks to fix tagging and parsing.',
        sample => $czech_sample,
        public => 1,
        scenario_languages => [ { language => $cs->id } ],
        user => $user->id,
        created_at => DateTime->now,
        last_modified => DateTime->now,
    });

    my $convertor = <<SCEN;
Util::SetGlobal language=und selector=conll # set language and selector you want to convert
Read::Treex
Write::CoNLLX
SCEN

    $scenario_rs->create({
        scenario => $convertor,
        name => 'Treex -> CoNLLX convertor',
        description => 'Convert Treex to CoNLLX',
        public => 1,
        scenario_languages => [],
        user => $user->id,
        created_at => DateTime->now,
        last_modified => DateTime->now,
    });

    $convertor = <<SCEN;
Util::SetGlobal language=und selector=conll # set language and selector
Read::CoNLLX
Write::Treex
SCEN

    $scenario_rs->create({
        scenario => $convertor,
        name => 'CoNLLX -> Treex convertor',
        description => 'Convert CoNLLX to Treex',
        public => 1,
        scenario_languages => [],
        user => $user->id,
        created_at => DateTime->now,
        last_modified => DateTime->now,
    });
};

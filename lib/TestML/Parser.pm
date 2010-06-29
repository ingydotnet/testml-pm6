use v6;
module TestML::Parser;

use TestML::Document;

# http://perlcabal.org/syn/S05.html

our $doc;
our $data;

grammar TestMLGrammar { ... }
grammar TestMLDataSection { ... }
grammar TestMLActions { ... }

class Parser;
method parse($testml) {
    $doc = TestML::Document.new();
    my $rc1 = TestMLGrammar.parse($testml, :actions(TestMLActions));
    if (not $rc1) {
        fail "Parse TestML failed";
    }
    my $rc2 = TestMLDataSection.parse($data, :actions(TestMLActions));
    if (not $rc2) {
        fail "Parse TestML Data failed";
    }
    return $doc;
}

grammar TestMLAtoms;
regex ANY       { .                 } # Any unicode character
regex SPACE     { <[\ \t]>          } # A space or tab character
regex BREAK     { \n                } # A newline character
regex EOL       { \r? \n            } # A Unix or DOS line ending
regex NON_BREAK { \N                } # Any character except newline
regex NON_SPACE_BREAK
                { <![\ \n]>         } # Any character except space or newline
regex LOWER     { <[a..z]>          } # Lower case ASCII alphabetic character
regex UPPER     { <[A..Z]>          } # Upper case ASCII alphabetic character
regex ALPHANUM  { <[A..Za..z0..9]>  } # ASCII alphanumeric character
regex WORD      { <[A..Za..z0..9_]> } # A "word" character
regex DIGIT     { <[0..9]>          } # A numeric digit
regex STAR      { '*'               } # An asterisk
regex DOT       { '.'               } # A period character
regex HASH      { '#'               } # An octothorpe (or hash) character
regex BACK      { '\\'              } # A backslash character
regex SINGLE    { "'"               } # A single quote character
regex DOUBLE    { '"'               } # A double quote character
regex ESCAPE    { <[0nt]>           } # One of the escapable character IDs 
regex comment { <HASH> <line> }
regex line { <NON_BREAK>* <EOL> }
regex blank_line { <SPACE>* <EOL> }


grammar TestMLGrammar is TestMLAtoms;
regex TOP { ^ <document> $ }

regex document {
    <meta_section> <test_section> <data_section>?
}

regex meta_section {
    [ <comment> | <blank_line> ]*
    <meta_testml_statement>
    [ <meta_statement> | <comment> | <blank_line> ]*
}

regex meta_testml_statement {
    '%TestML:' <SPACE>+ <testml_version> [ <SPACE>+ <comment> | <EOL> ]
}

regex testml_version { <.DIGIT> <.DOT> <.DIGIT>+ }

regex meta_statement {
    '%' <meta_keyword> ':' <SPACE>+ <meta_value>
    [ <SPACE>+ <comment> | <EOL> ]
}

regex meta_keyword {
    <core_meta_keyword> | <user_meta_keyword>
}

regex core_meta_keyword {
    Title | Data | Plan | BlockMarker | PointMarker
    # rakudo not yet implemented
    #< Title Data Plan BlockMarker PointMarker >
}

regex user_meta_keyword {
    <LOWER> <WORD>*
}

regex meta_value {
    <quoted_string> | <unquoted_string>
}

regex quoted_string {
    <single_quoted_string> | <double_quoted_string>
}

regex single_quoted_string {
    <SINGLE>
    <ANY>*?
    <SINGLE>
#         <SINGLE>
#         [
#             [ <ANY> - [ <BREAK> | <BACK> | <SINGLE> ] ] |
#             <BACK> <SINGLE> |
#             <BACK> <BACK>
#         ]*
#         <SINGLE>
}

regex double_quoted_string {
    <DOUBLE>
    <ANY>*?
    <DOUBLE>
#         <DOUBLE>
#         [
#             <![\n\\"]> [ <ANY> - [ <BREAK> | <BACK> | <DOUBLE> ] ] |
#             <BACK> <DOUBLE> |
#             <BACK> <BACK> |
#             <BACK> <ESCAPE>
#         ]*
#         <DOUBLE>
}

regex unquoted_string {
    [
        <!before <HASH>>
        <!before <EOL>>
        <!before <SPACE>>
        <ANY>
    ]+
#         <![\ \\#]> [ <ANY> - [ <SPACE> | <BREAK> | <HASH> ] ]
#         [
#             <![\n#]>*  [ <ANY> - [ <BREAK> | <HASH> ] ]*
#             <![\ \n#]> [ <ANY> - [ <SPACE> | <BREAK> | <HASH> ] ]
#         ]?
}

regex test_section {
    [ <wspace> | <test_statement> ]*
}

regex wspace {
    <SPACE> | <EOL> | <comment>
}

regex test_statement {
    <test_expression> <assertion_expression>? ';'
}

regex test_expression {
    <sub_expression>
    [
        <!assertion_call>
        <call_indicator>
        <sub_expression>
    ]*
}

regex sub_expression {
    <transform_call> | <data_point> | <quoted_string> | <constant>
}

regex transform_call {
    <transform_name> '(' <wspace>* <argument_list> <wspace>* ')'
}

regex transform_name {
    <user_transform> | <core_transform>
}

regex user_transform {
    <LOWER> <WORD>*
}

regex core_transform {
    <UPPER> <WORD>*
}

regex call_indicator {
    <DOT> <wspace>* | <wspace>* <DOT>
}

regex data_point {
    <STAR> <LOWER> <WORD>*
}

regex constant {
    <UPPER> <WORD>*
}

regex argument_list {
    [ <argument> [ <wspace>* ',' <wspace>* <argument> ]* ]?
}

regex argument {
    <sub_expression>
}

regex assertion_expression {
    <assertion_operation> | <assertion_call>
}

regex assertion_operation {
    <wspace>+ <assertion_operator> <wspace>+ <test_expression>
}

regex assertion_operator {
    '=='
}

regex assertion_call {
    <call_indicator> <assertion_name>
    '(' <wspace>* <test_expression> <wspace>* ')'
}

regex assertion_name {
    <UPPER>+
}

regex data_section {
    <ANY>*
}


grammar TestMLDataSection is TestMLAtoms;
regex TOP { ^ <data_section> $ }

regex data_section {
    <data_block>*
}

regex data_block {
    <block_header> [ <blank_line> | <comment> ]* <block_point>*
}

regex block_header {
    <block_marker> [ <SPACE>+ <block_label> ]? <SPACE>* <EOL>
}

regex block_marker {
    '==='
}

regex block_label {
#          [ <ANY> - [ <SPACE> | <BREAK> ] ]
#          [ <NON_BREAK>* [ <ANY> - [ <SPACE> | <BREAK> ] ] ]?
     <NON_SPACE_BREAK> [ <NON_BREAK>* <NON_SPACE_BREAK> ]?
}

regex block_point {
    <lines_point> | <phrase_point>
}

regex lines_point {
    <point_marker> <SPACE>+ <user_point_name> <SPACE>* <EOL>
    <!before block_header> <line>
}

regex phrase_point {
    <point_marker> <SPACE>+ <user_point_name> ':'
    [ <SPACE> <NON_BREAK>* ]? <EOL> <blank_line>*
}

regex user_point_name {
    <LOWER> <WORD>*
}

regex point_marker {
    '---'
}


class TestMLActions;

### Meta Section ###
method meta_testml_statement($/) {
    $doc.meta.data<TestML> = ~$<testml_version>;
}

method meta_statement($/) {
    $doc.meta.data{~$<meta_keyword>} = $<meta_value>.ast;
}

method meta_value($/) {
    make $<quoted_string>
        ?? $<quoted_string>.ast
        !! $<unquoted_string>.ast;
}

method quoted_string($/) {
    make ~$/.substr(1, -1);
}

method unquoted_string($/) {
    make ~$/;
}

### Data Section ###
method data_section($/) {
    $data = ~$/;
}

method data_block($/) {
    my $block = TestML::Block.new;

    $block.label = ~$<block_label>;

    $doc.data.blocks.push($block);
}



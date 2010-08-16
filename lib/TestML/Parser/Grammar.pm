use v6;

grammar TestML::Parser::Grammar;

our $block_marker = '===';
our $point_marker = '---';

regex ALWAYS    { <?>               } # Always match
regex NEVER     { <!>               } # Never match
regex ALL       { .                 } # Any unicode character
regex ANY       { \N                } # Any character except newline
regex BLANK     { <blank>           } # A space or tab character
regex EOL       { \r? \n            } # A Unix or DOS line ending
regex LOWER     { <[a..z]>          } # Lower case ASCII alphabetic character
regex UPPER     { <[A..Z]>          } # Upper case ASCII alphabetic character
regex WORD      { <[A..Za..z0..9_]> } # A "word" character
regex DIGIT     { <[0..9]>          } # A numeric digit
regex PERCENT   { '%' }
regex STAR      { '*' }
regex COMMA     { ',' }
regex DOT       { '.' }
regex COLON     { ':' }
regex SEMI      { ';' }
regex HASH      { '#' }
regex TILDE     { '~' }
regex EQUAL     { '=' }
regex LPAREN    { '(' }
regex RPAREN    { ')' }

token line      { <ANY>* <EOL> }
token blank_line { <BLANK>* <EOL> }
token comment   { <HASH> <line> }
token wspace    { <BLANK> | <EOL> | <comment> }

token quoted_string {
    <single_quoted_string> |
    <double_quoted_string>
}

token single_quoted_string {
    \' ~ \'
    [
        <sq_string> |
        \\ <sq_escape>
    ]*
}
token sq_string {
    [
        <!before \n>
        <!before \\>
        <!before \'>
        <ALL>
    ]+
}
token sq_escape { <['\\]> }

token double_quoted_string {
    \" ~ \"
    [
        <dq_string> |
        \\ <dq_escape>
    ]*
}
token dq_string {
    [
        <!before \t>
        <!before \n>
        <!before \\>
        <!before \">
        <ALL>
    ]+
}
token dq_escape { <["\\nrt]> }

token unquoted_string {
    [
        <!before <BLANK>+ <HASH>>
        <!before <BLANK>* <EOL>>
        <ALL>
    ]+
}


#------------------------------------------------------------------------------#
# This is the TOP rule:
rule document {^
    <meta_section>
    <test_section>
    <data_section>?
$}

#------------------------------------------------------------------------------#
token meta_section {
    [ <comment> | <blank_line> ]*
    [ <meta_testml_statement> | <.panic: "No TestML meta directive found"> ]
    [ <meta_statement> | <comment> | <blank_line> ]*
}

token meta_testml_statement {
    <PERCENT> 'TestML' <COLON> <BLANK>+ <testml_version>
    [ <BLANK>+ <comment> | <EOL> ]
}

token testml_version { <.DIGIT> <.DOT> <.DIGIT>+ }

token meta_statement {
    <PERCENT> <meta_keyword> <COLON> <BLANK>+ <meta_value>
    [ <BLANK>+ <comment> | <EOL> ]
}

token meta_keyword {
    <core_meta_keyword> | <user_meta_keyword>
}

token core_meta_keyword {
    Title | Data | Plan | BlockMarker | PointMarker
}

token user_meta_keyword {
    <LOWER> <WORD>*
}

token meta_value {
    <quoted_string> | <unquoted_string>
}


#------------------------------------------------------------------------------#
token test_section {
    [ <wspace> | <test_statement> ]*
}

token test_statement {
    <try_test_statement>
    <test_expression>
    <assertion_call>? 
    [ <SEMI> | <.panic: "You seem to be missing a semicolon"> ]
}

token try_test_statement { <ALWAYS> }

token test_expression {
    <sub_expression>
    [
        <!assertion_call_test>
        <call_indicator>
        <sub_expression>
    ]*
}

token sub_expression {
    <point_call> |
    <string_call> |
    <transform_call>
}

token point_call {
    <.STAR> ( <.LOWER> <.WORD>* )
}

token string_call {
    <quoted_string>
}

token transform_call {
    <transform_name>
    <transform_argument_list>?
}

token transform_name {
    <user_transform> | <core_transform>
}

token user_transform {
    <LOWER> <WORD>*
}

token core_transform {
    <UPPER> <WORD>*
}

token call_indicator {
    <DOT> <wspace>* | <wspace>* <DOT>
}

token transform_argument_list {
    <LPAREN> <wspace>*
    <transform_arguments>?
    <wspace>* <RPAREN>
}

token transform_arguments {
    <transform_argument>
    [ <wspace>* <COMMA> <wspace>* <transform_argument> ]*
}

token transform_argument {
    <sub_expression>
}

token assertion_call_test {
    <call_indicator> [ 'EQ' | 'OK' | 'HAS' ]
}

token assertion_call {
    [
        <try_assertion_call>
        [ <assertion_eq> | <assertion_ok> | <assertion_has> ]
    ] | [ <not_assertion_call> <NEVER> ]
}

token try_assertion_call { <ALWAYS> }

token not_assertion_call { <ALWAYS> }

token assertion_eq {
    <assertion_operator_eq> | <assertion_function_eq>
}

token assertion_operator_eq {
    <wspace>+ <EQUAL> <EQUAL> <wspace>+
    <test_expression>
}

token assertion_function_eq {
    <call_indicator> 'EQ' <LPAREN>
    <test_expression>
    <RPAREN>
}

token assertion_ok {
    <assertion_function_ok>
}

token assertion_function_ok {
    <call_indicator> 'OK' <empty_parens>?
}

token assertion_has {
    <assertion_operator_has> | <assertion_function_has>
}

token assertion_operator_has {
    <wspace>+ <TILDE> <TILDE> <wspace>+
    <test_expression>
}

token assertion_function_has {
    <call_indicator> 'HAS' <LPAREN>
    <test_expression>
    <RPAREN>
}

token empty_parens {
    <LPAREN> <wspace>* <RPAREN>
}


#------------------------------------------------------------------------------#
token data_section {
    <data_block>*
}

token data_block {
    <block_header> [ <blank_line> | <comment> ]* <block_point>*
}

token block_header {
    <block_marker> [ <BLANK>+ <block_label> ]? <BLANK>* <EOL>
}

token block_marker {
    $block_marker
}

token block_label {
    <unquoted_string>
}

token block_point {
    <lines_point> | <phrase_point>
}

token lines_point {
    <point_marker> <BLANK>+ <point_name> <BLANK>* <EOL>
    ([
        <!block_marker>
        <!point_marker>
        <line>
    ]*)
}

token phrase_point {
    <point_marker> <BLANK>+ <point_name> <COLON> <BLANK>+
    (<unquoted_string>) <BLANK>* <EOL>
    [<blank_line> | <comment>]*
}

token point_marker {
    $point_marker
}

token point_name {
    <core_point_name> | <user_point_name>
}

token core_point_name {
    <UPPER> <WORD>*
}

token user_point_name {
    <LOWER> <WORD>*
}


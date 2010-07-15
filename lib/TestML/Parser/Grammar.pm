grammar TestML::Parser::Grammar::Base;

regex ALWAYS    { <?>               } # Always match
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

token comment { <HASH> <line> }
token line { <NON_BREAK>* <EOL> }
token blank_line { <SPACE>* <EOL> }
token unquoted_string {
    [
        <!before <SPACE>+ <HASH>>
        <!before <SPACE>* <EOL>>
        <ANY>
    ]+
}
token single_quoted_string {
    \' ~ \' [ <sq_string> | \\ <sq_escape> ]*
}
token sq_string {
    [
        <!before \n>
        <!before \\>
        <!before \'>
        <ANY>
    ]+
}
token sq_escape {
    <['\\]>
}
token double_quoted_string {
    \" ~ \" [ <dq_string> | \\ <dq_escape> ]*
}
token dq_string {
    [
        <!before \t>
        <!before \n>
        <!before \\>
        <!before \">
        <ANY>
    ]+
}
token dq_escape {
    <["\\nrt]>
}


#------------------------------------------------------------------------------#
grammar TestML::Parser::Grammar is TestML::Parser::Grammar::Base;

rule TOP {^ <document> $}

rule document {
    <meta_section> <test_section> <data_section>?
}

#------------------------------------------------------------------------------#
rule meta_section {
    [ <comment> | <blank_line> ]*
    <meta_testml_statement>
    [ <meta_statement> | <comment> | <blank_line> ]*
}

regex meta_testml_statement {
    '%TestML:' <SPACE>+ <testml_version>
    [ <SPACE>+ <comment> | <EOL> ]
}

token testml_version { <.DIGIT> <.DOT> <.DIGIT>+ }

regex meta_statement {
    '%' <meta_keyword> ':' <SPACE>+ <meta_value>
    [ <SPACE>+ <comment> | <EOL> ]
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

token quoted_string {
    <single_quoted_string> | <double_quoted_string>
}


#------------------------------------------------------------------------------#
token test_section {
    [ <wspace> | <test_statement> ]*
}

token wspace {
    <SPACE> | <EOL> | <comment>
}

token test_statement {
    <test_statement_start>
    <test_expression> <assertion_expression>? ';'
}

token test_statement_start {
    <ALWAYS>
}

token test_expression {
    <sub_expression>
    [
        <!assertion_call>
        <call_indicator>
        <sub_expression>
    ]*
}

token sub_expression {
    <transform_call> | <data_point> | <expression_string> | <constant>
}

token expression_string {
    <quoted_string>
}

token transform_call {
    <transform_name> '(' <wspace>* <argument_list> <wspace>* ')'
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

token data_point {
    <.STAR> ( <.LOWER> <.WORD>* )
}

token constant {
    <UPPER> <WORD>*
}

token argument_list {
    [ <argument> [ <wspace>* ',' <wspace>* <argument> ]* ]?
}

token argument {
    <quoted_string>
#     <sub_expression>
}

token assertion_expression {
    <assertion_operation> | <assertion_call>
}

token assertion_operation {
    <wspace>+ <assertion_operator> <wspace>+ <test_expression>
}

token assertion_operator {
    '=='
}

token assertion_call {
    <call_indicator> <assertion_name>
    '(' <wspace>* <test_expression> <wspace>* ')'
}

token assertion_name {
    <UPPER>+
}

token data_section {
    <ANY>*
}


#------------------------------------------------------------------------------#
grammar TestML::Parser::Grammar::DataSection is TestML::Parser::Grammar::Base;

our $block_marker = '===';
our $point_marker = '---';

token TOP { ^ <data_section> $ }

token data_section {
    <data_block>*
}

token data_block {
    <block_header> [ <blank_line> | <comment> ]* <block_point>*
}

token block_header {
    <block_marker> [ <SPACE>+ <block_label> ]? <SPACE>* <EOL>
}

token block_marker {
    $block_marker
}

token block_label {
#          [ <ANY> - [ <SPACE> | <BREAK> ] ]
#          [ <NON_BREAK>* [ <ANY> - [ <SPACE> | <BREAK> ] ] ]?
    <unquoted_string>
}

token block_point {
    <lines_point> | <phrase_point>
}

token lines_point {
    <point_marker> <SPACE>+ <point_name> <SPACE>* <EOL>
    ([
        <!before <block_marker>>
        <!before <point_marker>>
        <line>
    ]*)
}

token phrase_point {
    <point_marker> <SPACE>+ <point_name> ':' <SPACE>+
    (<unquoted_string>) <SPACE>* <EOL>
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

use v6;
module TestML::Parser;

use TestML::Document;

my $doc;
my $data;
my $statement;
my @stack;

grammar TestMLGrammar { ... }
grammar TestMLDataSection { ... }
grammar TestMLActions { ... }

class Parser;
method parse($testml) {
    $doc = TestML::Document.new();
    @stack = ();
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

grammar TestMLBase;
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


grammar TestMLGrammar is TestMLBase;
rule TOP {^ <document> $}

rule document {
    <meta_section> <test_section> <data_section>?
}

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


regex test_section {
    [ <wspace> | <test_statement> ]*
}

regex wspace {
    <SPACE> | <EOL> | <comment>
}

regex test_statement {
    <test_statement_start>
    <test_expression> <assertion_expression>? ';'
}

regex test_statement_start {
    <ALWAYS>
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
    <.STAR> ( <.LOWER> <.WORD>* )
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


grammar TestMLDataSection is TestMLBase;
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
    <unquoted_string>
}

regex block_point {
    <lines_point> | <phrase_point>
}

regex lines_point {
    <point_marker> <SPACE>+ <point_name> <SPACE>* <EOL>
    <!before block_header>
    <line>
}

regex phrase_point {
    <point_marker> <SPACE>+ <point_name> ':' <SPACE>+
    (<unquoted_string>) <SPACE>* <EOL>
    [<blank_line> | <comment>]*
}

regex point_marker {
    '---'
}

regex point_name {
    <core_point_name> | <user_point_name>
}

regex core_point_name {
    <UPPER> <WORD>*
}

regex user_point_name {
    <LOWER> <WORD>*
}


class TestMLActions;

### Base Section ###

method quoted_string($/) {
    make ~$/.substr(1, -1);
}

method unquoted_string($/) {
    make ~$/;
}

method dq_string($/) { make ~$/ }

method dq_escape($/) {
    my %h = '\\' => "\\",
            'n'  => "\n",
            't'  => "\t",
            'f'  => "\f",
            'r'  => "\r";
    make %h{~$/};
}

method sq_string($/) { make ~$/ }

method sq_escape($/) {
    my %h = '\\' => "\\",
    make %h{~$/};
}


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


### Test Section ###
method test_statement_start($/) {
    $statement = TestML::Statement.new;
}

method test_statement($/) {
    $doc.test.statements.push($statement);
}

method sub_expression($/) {
    my $ast = $<transform_call> ?? $<transform_call>.ast !!
        $<data_point> ?? $<data_point>.ast !!
        $<quoted_string> ?? $<quoted_string>.ast !!
        $<constant>.ast;
    make $ast;
}

method data_point($/) {
    $statement.points.push(~$0);
    make ~$0;
}

method transform_call($/) {
    make $0;
}

### Data Section ###
method data_section($/) {
    $data = ~$/;
}

method data_block($/) {
    my $block = TestML::Block.new;
    $block.label = ~$<block_header><block_label>;
    for $<block_point> -> $point {
        my $name = ~$point<phrase_point><point_name>;
        my $value = ~$point<phrase_point>[0];
        $block.points{$name} = $value;
    }

    $doc.data.blocks.push($block);
}


# #-----------------------------------------------------------------------------
# class TestML::Document::Tests;
# 
# has $.statements = [];
# 
# #-----------------------------------------------------------------------------
# class TestML::Statement;
# 
# has $.points = [];
# has $.left_expression = [];
# has $.assertion_operator;
# has $.right_expression = [];
# 
# #-----------------------------------------------------------------------------
# class TestML::Expression;
# 
# has $.transforms = [];
# 
# #-----------------------------------------------------------------------------
# class TestML::Transform;
# 
# has $.name;
# has $.args = [];


# tests: !!perl/hash:TestML::Document::Tests
#   statements:
#     - !!perl/hash:TestML::Statement
#       left_expression:
#         - !!perl/hash:TestML::Expression
#           transforms:
#             - !!perl/hash:TestML::Transform
#               args:
#                 - foo
#               name: Point
#       points:
#         - bar
#         - foo
#       right_expression:
#         - !!perl/hash:TestML::Expression
#           transforms:
#             - !!perl/hash:TestML::Transform
#               args:
#                 - bar
#               name: Point

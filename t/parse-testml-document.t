use v6;
use Test;
plan 14;

BEGIN { @*INC.unshift: 'lib' }
use TestML::Parser;

my $testml = '
%TestML: 1.0
%Plan: 2
%Title: O HAI TEST
 %PointMarker: +++         #A line comment

*input.uppercase() == *output;

=== Test mixed case string
--- input: I Like Pie
--- output: I LIKE PIE

=== Test lower case string
--- input: i love lucy
--- output: I LOVE LUCY
';

try {
    my $match = Parser.parse($testml);
    ok $match, 'TestML string matches against TestML grammar';
    is $match.meta.data<TestML>, '1.0', 'Version parses';
    is $match.meta.data<Plan>, '2', 'Plan parses';
    is $match.meta.data<Title>, 'O HAI TEST', 'Title parses';
    is $match.meta.data<PointMarker>, '+++', 'PointMarker parses';

    is $match.test.statements.elems, 1, 'One test statement';
    is $match.test.statements[0].points.join('-'), 'input-output',
        'Point list is correct';

    is $match.data.blocks.elems, 2, 'Two data blocks';
    my ($block1, $block2) = $match.data.blocks;
    is $block1.label, 'Test mixed case string', 'Block 1 label ok';
    is $block1.points<input>, 'I Like Pie', 'Block 1, input point';
    is $block1.points<output>, 'I LIKE PIE', 'Block 1, output point';
    is $block2.label, 'Test lower case string', 'Block 2 label ok';
    is $block2.points<input>, 'i love lucy', 'Block 2, input point';
    is $block2.points<output>, 'I LOVE LUCY', 'Block 2, output point';
    CATCH {
        diag "TestML parse failed: $!";
    }
}


# my $data_section = '
# === Test mixed case string
# --- input: I Like Pie
# --- output: I LIKE PIE
# 
# === Test lower case string
# --- input: i love lucy
# --- output: I LOVE LUCY
# ';

# is $match<document><meta_section>.trim, '%TestML: 1.0',
#     'meta_section parses';
# 
# is $match<document><test_section>.trim, '*input.uppercase() == *output;',
#     'test_section parses';
# 
# is $match<document><data_section>.trim, $data_section.trim,
#     'data_section parses';
# 
# is $match<document><meta_section><meta_testml_statement><testml_version>, '1.0',
#     'testml_version parses';
# 
# diag "$_: [[" ~ $match<document>{$_} ~ "]]"
#     for < meta_section test_section data_section >;
# 
# my $data_section_match = $match<document><data_section>;
# $match = TestMLDataSection.parse($data_section_match);
# ok $match, 'data_section string matches against TestMLDataSection grammar';

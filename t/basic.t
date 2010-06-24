use v6;
use Test;
plan 5;

BEGIN { @*INC.unshift: 'lib' }
use TestML::Parser::Grammar;

my $testml = '
%TestML: 1.0

*input.uppercase() == *output;

=== Test mixed case string
--- input: I Like Pie
--- output: I LIKE PIE

=== Test lower case string
--- input: i love lucy
--- output: I LOVE LUCY
';

my $data_section = '
=== Test mixed case string
--- input: I Like Pie
--- output: I LIKE PIE

=== Test lower case string
--- input: i love lucy
--- output: I LOVE LUCY
';

my $match = TestML.parse($testml);
ok $match, 'TestML string matches against TestML grammar';

is $match<document><meta_section>.trim, '%TestML: 1.0',
    'meta_section parses';

is $match<document><test_section>.trim, '*input.uppercase() == *output;',
    'test_section parses';

is $match<document><data_section>.trim, $data_section.trim,
    'data_section parses';

is $match<document><meta_section><meta_testml_statement><testml_version>, '1.0',
    'testml_version parses';

diag "$_: [[" ~ $match<document>{$_} ~ "]]"
    for < meta_section test_section data_section >;

use v6;
use Test;
plan 1;

BEGIN { @*INC.unshift: 'lib' }
use TestML::Parser::Grammar;

#ok TestML::Parser::Grammar.grammar, 'call grammar method';
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


#ok TestML::Parser::Grammar::TestML.parse($testml), 'match against grammar';
ok TestML.parse($testml), 'match against grammar';

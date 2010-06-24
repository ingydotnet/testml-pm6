use v6;
use Test;
plan 1;

BEGIN { @*INC.unshift: 'lib' }
use TestML::Parser::Grammar;

ok grammar6(), 'imported grammar6 from TestML::Parser::Grammar';

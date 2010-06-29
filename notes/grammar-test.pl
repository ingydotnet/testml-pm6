use v6;

grammar Grammar1 {
    regex ANY { . }
    regex SPACE { <[\ \t]> }
    regex BREAK { \n }
    regex EOL { \r? \n }
    regex NON_BREAK { \N }
    regex NON_SPACE_BREAK
    { <![\ \n]> }
    regex LOWER { <[a..z]> }
    regex UPPER { <[A..Z]> }
    regex ALPHANUM { <[A..Za..z0..9]> }
    regex WORD { <[A..Za..z0..9_]> }
    regex DIGIT { <[0..9]> }
    regex STAR { '*' }
    regex DOT { '.' }
    regex HASH { '#' }
    regex BACK { '\\' }
    regex SINGLE { "'" }
    regex DOUBLE { '"' }
    regex ESCAPE { <[0nt]> }

    regex TOP {
        <equation>
    }
    regex equation {
        <lvalue>
        <SPACE>+
        <assignment>
        <SPACE>+
        <operand>
        <SPACE>+
        <operator>
        <SPACE>+
        <operand>
        <SPACE>+
        <ending>
        <SPACE>*
        <EOS>
    }
    regex operand {
        <number> | <quoted_string> | <variable>
    }
    regex lvalue { <WORD>+ }
    regex ending { ; }
}

class Actions {
}

my $text = "$foo = $bar + 'O HAI';\n";

my $match = Grammar1.parse($testml, :actions(Actions));
say $match.perl;

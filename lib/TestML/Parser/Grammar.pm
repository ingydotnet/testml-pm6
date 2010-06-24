use v6;

# http://perlcabal.org/syn/S05.html

grammar TestML {
    regex TOP { <document> }

    regex ANY       { . }                 # Any unicode character
    regex SPACE     { <[\ \t]> }          # A space or tab character
    regex BREAK     { \n }                # A newline character
    regex EOL       { \r? \n }            # A Unix or DOS line ending
    regex NON-BREAK { . }                 # Any character except newline
    regex LOWER     { <[a..z]> }          # Lower case ASCII alphabetic character
    regex UPPER     { <[A..Z]> }          # Upper case ASCII alphabetic character
    regex ALPHANUM  { <[A..Za..z0..9]> }  # ASCII alphanumeric character
    regex WORD      { <[A..Za..z0..9_]> } # A ``word'' character
    regex DIGIT     { <[0..9]> }          # A numeric digit
    regex STAR      { '*' }               # An asterisk
    regex DOT       { '.' }               # A period character
    regex HASH      { '#' }               # An octothorpe (or hash) character
    regex BACK      { '\\' }              # A backslash character
    regex SINGLE    { "'" }               # A single quote character
    regex DOUBLE    { '"' }               # A double quote character
    regex ESCAPE    { <[0nt]> }           # One of the escapable character IDs 

    regex document {
        <meta-section> <test-section> <data-section>?
    }

    regex meta-section {
        [ <comment> | <blank-line> ]*
        <meta-testml-statement>
        [ <meta-statement> | <comment> | <blank-line> ]*
    }

    regex comment { HASH <line> }

    regex line { <NON-BREAK>* <EOL> }

    regex blank-line { <SPACE>* <EOL> }

    regex meta-testml-statement {
        '%TestML:' <SPACE>+ <testml-version> [ <SPACE>+ <comment> | <EOL> ]
    }

    regex testml-version { <DIGIT> <DOT> <DIGIT>+ }

    regex meta-statement {
        '%' meta-keyword ':' <SPACE>+ <meta-value>
        [<SPACE>+ <comment> | <EOL>]
    }

    regex meta-keyword { <core-meta-keyword> | <user-meta-keyword> }

    regex core-meta-keyword {
        [ Title | Data | Plan | BlockMarker | PointMarker ]
    }

    regex user-meta-keyword { <LOWER> <WORD>* }

    regex meta-value { [ <quoted-string> | <unquoted-string> ] }

    regex quoted-string { <single-quoted-string> | <double-quoted-string> }

    regex single-quoted-string {
        <SINGLE>
        [
            [<ANY> - [<BREAK> | <BACK> | <SINGLE>]] |
            <BACK> <SINGLE> |
            <BACK> <BACK>
        ]*
        <SINGLE>
    }

    regex double-quoted-string {
        <DOUBLE>
        [
            [<ANY> - [<BREAK> | <BACK> | <DOUBLE>]] |
            <BACK> <DOUBLE> |
            <BACK> <BACK> |
            <BACK> <ESCAPE>
        ]*
        <DOUBLE>
    }

    regex unquoted-string {
        [<ANY> - [<SPACE> | <BREAK> | <HASH>]]
        [
            [<ANY> - [<BREAK> | <HASH>]]*
            [<ANY> - [<SPACE> | <BREAK> | <HASH>]]
        ]?
    }

    regex test-section { <ANY>* }

    regex data-section { <ANY>* }
}

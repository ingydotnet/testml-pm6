use v6;

# http://perlcabal.org/syn/S05.html

grammar TestML {
    regex TOP { <document> }

    regex ANY       { . }                 # Any unicode character
    regex SPACE     { <[\ \t]> }          # A space or tab character
    regex BREAK     { \n }                # A newline character
    regex EOL       { \r? \n }            # A Unix or DOS line ending
    regex NON_BREAK { . }                 # Any character except newline
    regex LOWER     { <[a..z]> }          # Lower case ASCII alphabetic character
    regex UPPER     { <[A..Z]> }          # Upper case ASCII alphabetic character
    regex ALPHANUM  { <[A..Za..z0..9]> }  # ASCII alphanumeric character
    regex WORD      { <[A..Za..z0..9_]> } # A "word" character
    regex DIGIT     { <[0..9]> }          # A numeric digit
    regex STAR      { '*' }               # An asterisk
    regex DOT       { '.' }               # A period character
    regex HASH      { '#' }               # An octothorpe (or hash) character
    regex BACK      { '\\' }              # A backslash character
    regex SINGLE    { "'" }               # A single quote character
    regex DOUBLE    { '"' }               # A double quote character
    regex ESCAPE    { <[0nt]> }           # One of the escapable character IDs 

    regex document {
        <meta_section> <test_section> <data_section>?
    }

    regex meta_section {
        [ <comment> | <blank_line> ]*
        <meta_testml_statement>
        [ <meta_statement> | <comment> | <blank_line> ]*
    }

    regex comment { <HASH> <line> }

    regex line { <NON_BREAK>* <EOL> }

    regex blank_line { <SPACE>* <EOL> }

    regex meta_testml_statement {
        '%TestML:' <SPACE>+ <testml_version> [ <SPACE>+ <comment> | <EOL> ]
    }

    regex testml_version { <DIGIT> <DOT> <DIGIT>+ }

    regex meta_statement {
        '%' <meta_keyword> ':' <SPACE>+ <meta_value>
        [ <SPACE>+ <comment> | <EOL> ]
    }

    regex meta_keyword { <core_meta_keyword> | <user_meta_keyword> }

    regex core_meta_keyword {
        [ Title | Data | Plan | BlockMarker | PointMarker ]
    }

    regex user_meta_keyword { <LOWER> <WORD>* }

    regex meta_value { <quoted_string> | <unquoted_string> }

    regex quoted_string { <single_quoted_string> | <double_quoted_string> }

    regex single_quoted_string {
        <SINGLE>
        [
            <![\n\\']> #[ <ANY> '-' [ <BREAK> | <BACK> | <SINGLE> ] ] |
            <BACK> <SINGLE> |
            <BACK> <BACK>
        ]*
        <SINGLE>
    }

    regex double_quoted_string {
        <DOUBLE>
        [
            <![\n\\"]> #[ <ANY> '-' [ <BREAK> | <BACK> | <DOUBLE> ] ] |
            <BACK> <DOUBLE> |
            <BACK> <BACK> |
            <BACK> <ESCAPE>
        ]*
        <DOUBLE>
    }

    regex unquoted_string {
        <![\ \\#]> #[ <ANY> '-' [ <SPACE> | <BREAK> | <HASH> ] ]
        [
            <![\n#]>*  #[ <ANY> '-' [ <BREAK> | <HASH> ] ]*
            <![\ \n#]> #[ <ANY> '-' [ <SPACE> | <BREAK> | <HASH> ] ]
        ]?
    }

    regex test_section { <ANY>* }

    regex data_section { <ANY>* }
}

use v6;

# http://perlcabal.org/syn/S05.html

grammar TestML {
    rule TOP { <document> }

    rule ANY       { . }                 # Any unicode character
    rule SPACE     { <[\ \t]> }          # A space or tab character
    rule BREAK     { \n }                # A newline character
    rule EOL       { \r? \n }            # A Unix or DOS line ending
    rule NON-BREAK { . }                 # Any character except newline
    rule LOWER     { <[a..z]> }          # Lower case ASCII alphabetic character
    rule UPPER     { <[A..Z]> }          # Upper case ASCII alphabetic character
    rule ALPHANUM  { <[A..Za..z0..9]> }  # ASCII alphanumeric character
    rule WORD      { <[A..Za..z0..9_]> } # A ``word'' character
    rule DIGIT     { <[0..9]> }          # A numeric digit
    rule STAR      { '*' }               # An asterisk
    rule DOT       { '.' }               # A period character
    rule HASH      { '#' }               # An octothorpe (or hash) character
    rule BACK      { '\\' }              # A backslash character
    rule SINGLE    { "'" }               # A single quote character
    rule DOUBLE    { '"' }               # A double quote character
    rule ESCAPE    { <[0nt]> }           # One of the escapable character IDs 

    rule document {
        <meta-section> <test-section> <data-section>?
    }

    rule meta-section { [ <comment> | <blank-line> ]* <meta-testml-statement> }

    rule comment { ^^ '#' \N* \n }
    rule blank-line { ^^ \s*? \n }


    rule test-section { }
    rule data-section { }


    rule SPACE { <[\ \t]> }

    rule meta-testml-statement { '%TestML:' <SPACE>+ <testml-version> [ <SPACE>+ <comment> | <EOL> ] }
    rule testml-version { <DIGIT> <DOT> <DIGIT>+ }
}


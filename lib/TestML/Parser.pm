use v6;
class TestML::Parser;

use TestML::Parser::Grammar;
use TestML::Document;

my $doc;
my $data;
my $statement;
my @insertion_stack;

grammar TestML::Parser::Actions { ... }

method parse($testml) {
    $doc = TestML::Document.new();
    @insertion_stack = ();
    my $rc1 = TestML::Parser::Grammar.parse($testml, :actions(TestML::Parser::Actions));
    if (not $rc1) {
        die "Parse TestML failed";
    }
    my $rc2 = TestML::Parser::Grammar::DataSection.parse(
        $data, :actions(TestML::Parser::Actions)
    );
    if (not $rc2) {
        die "Parse TestML Data failed";
    }
    return $doc;
}

method parse_data ($parser) {
    my $builder = $parser.receiver;
    my $document = $builder.document;
    for $document.meta.data<Data> -> $file {
        if $file eq '_' {
            $parser.stream($builder.inline_data);
        }
        else {
            $parser.open("self.base/$file");
        }
        $parser.parse;
        $document.data.blocks.push(|$parser.receiver.blocks);
    }
}

#------------------------------------------------------------------------------#
class TestML::Parser::Actions;

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
    @insertion_stack.push($statement.expression);
}

method test_statement($/) {
    $doc.test.statements.push($statement);
}

method data_point($/) {
    my $point_name = ~$0;
    my $transform = TestML::Transform.new(name => 'Point', args => [$point_name]);
    @insertion_stack[*-1].transforms.push($transform);
    $statement.points.push($point_name);
}

method transform_call($/) {
    my $transform_name = ~$<transform_name>;
    my $transform = TestML::Transform.new(name => $transform_name);
    for $<argument_list><argument> -> $argument {
        if $argument<sub_expression><quoted_string> {
            $transform.args.push($argument<sub_expression><quoted_string>.ast);
        }
    }
    @insertion_stack[*-1].transforms.push($transform);
}

method assertion_operator($/) {
    @insertion_stack.pop();
    $statement.assertion = TestML::Assertion.new(name => 'EQ');
    @insertion_stack.push($statement.assertion.expression);
}

### Data Section ###
method data_section($/) {
    $data = ~$/;
}

method data_block($/) {
    my $block = TestML::Block.new;
    $block.label = ~$<block_header><block_label>;
    for $<block_point> -> $point {
        my ($name, $value);
        if $point<phrase_point> {
            $name = ~$point<phrase_point><point_name>;
            $value = ~$point<phrase_point>[0];
        }
        else {
            $name = ~$point<lines_point><point_name>;
            $value = ~$point<lines_point>[0];
        }
        $block.points{$name} = $value;
    }
    $doc.data.blocks.push($block);
}


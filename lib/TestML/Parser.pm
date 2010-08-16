use v6;
class TestML::Parser { ... }
class TestML::Parser::Actions { ... }

use TestML::Parser::Grammar;
use TestML::Document;

class TestML::Parser;

my $document;
my $data;
my $statement;
my $transform_arguments;
my @expression_stack;

method parse($testml) {
    $document = TestML::Document.new();
    @expression_stack = ();
    TestML::Parser::Grammar.parse(
        $testml,
        :rule('document'),
        :actions(TestML::Parser::Actions),
    ) or die "Parse TestML failed";
    return $document;
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
method meta_section($/) {
    $TestML::Parser::Grammar::block_marker = $document.meta.data<BlockMarker>;
    $TestML::Parser::Grammar::point_marker = $document.meta.data<PointMarker>;
}

method meta_testml_statement($/) {
    $document.meta.data<TestML> = ~$<testml_version>;
}

method meta_statement($/) {
    $document.meta.data{~$<meta_keyword>} = $<meta_value>.ast;
}

method meta_value($/) {
    make $<quoted_string>
        ?? $<quoted_string>.ast
        !! $<unquoted_string>.ast;
}


### Test Section ###
method try_test_statement($/) {
    $statement = TestML::Statement.new;
    @expression_stack.push($statement.expression);
}

method test_statement($/) {
    $document.test.statements.push($statement);
    @expression_stack.pop();
}

method point_call($/) {
    my $point_name = ~$0;
    my $transform = TestML::Transform.new(name => 'Point', args => [$point_name]);
    @expression_stack[*-1].transforms.push($transform);
    $statement.points.push($point_name);
}

method transform_call($/) {
    @expression_stack.pop();
    my $transform_name = ~$<transform_name>;
    my $transform = TestML::Transform.new(
        name => $transform_name,
        args => $transform_arguments,
    );
    @expression_stack[*-1].transforms.push($transform);
}

method transform_name($/) {
    @expression_stack.push(TestML::Expression.new);
    $transform_arguments = [];
}

method transform_argument($/) {
    $transform_arguments.push(@expression_stack.pop());
    @expression_stack.push(TestML::Expression.new);
}

method string_call($/) {
    my $string = $<quoted_string>.ast;
    my $transform = TestML::String.new(
        value => $string,
    );
    @expression_stack[*-1].transforms.push($transform);
}

method try_assertion_call($/) {
    $statement.assertion = TestML::Assertion.new;
    @expression_stack.push($statement.assertion.expression);
}

method assertion_call($/) {
    @expression_stack.pop();
}

method not_assertion_call($/) {
    $statement.assertion = Nil;
    @expression_stack.pop();
}

method assertion_eq($/) {
    $statement.assertion.name = 'EQ';
}

method assertion_ok($/) {
    $statement.assertion.name = 'OK';
}

method assertion_has($/) {
    $statement.assertion.name = 'HAS';
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
    $document.data.blocks.push($block);
}

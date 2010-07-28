use v6;
class TestML::Parser { ... }
class TestML::Parser::Actions { ... }

use TestML::Parser::Grammar;
use TestML::Document;

class TestML::Parser;

method parse($testml) {
    my $actions = TestML::Parser::Actions.new();
    TestML::Parser::Grammar.parse(
        $testml,
        :actions($actions),
        :rule('document'),
    ) or die "Parse TestML failed";
    return $actions.document;
}

# TODO - No tests for external data files yet...
# method parse_data ($parser) {
#     my $builder = $parser.receiver;
#     my $document = $builder.document;
#     for $document.meta.data<Data> -> $file {
#         if $file eq '_' {
#             $parser.stream($builder.inline_data);
#         }
#         else {
#             $parser.open("self.base/$file");
#         }
#         $parser.parse;
#         $document.data.blocks.push(|$parser.receiver.blocks);
#     }
# }

#------------------------------------------------------------------------------#
class TestML::Parser::Actions;

has $.document = TestML::Document.new;
has $.data;
has $.statement is rw;
has $.transform_arguments is rw;
has @.expression_stack = ();


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
    $TestML::Parser::Grammar::block_marker = $.document.meta.data<BlockMarker>;
    $TestML::Parser::Grammar::point_marker = $.document.meta.data<PointMarker>;
}

method meta_testml_statement($/) {
    $.document.meta.data<TestML> = ~$<testml_version>;
}

method meta_statement($/) {
    $.document.meta.data{~$<meta_keyword>} = $<meta_value>.ast;
}

method meta_value($/) {
    make $<quoted_string>
        ?? $<quoted_string>.ast
        !! $<unquoted_string>.ast;
}


### Test Section ###
method test_statement_start($/) {
    $.statement = TestML::Statement.new;
    @.expression_stack.push($.statement.expression);
}

method test_statement($/) {
    $.document.test.statements.push($.statement);
    @.expression_stack.pop();
}

method point_call($/) {
    my $point_name = ~$0;
    my $transform = TestML::Transform.new(name => 'Point', args => [$point_name]);
    @.expression_stack[*-1].transforms.push($transform);
    $.statement.points.push($point_name);
}

method transform_call($/) {
    my $transform_name = ~$<transform_name>;
    my $transform = TestML::Transform.new(
        name => $transform_name,
        args => $.transform_arguments,
    );
    @.expression_stack[*-1].transforms.push($transform);
}

method transform_argument_list_start($/) {
    @.expression_stack.push(TestML::Expression.new);
    $.transform_arguments = [];
}

method transform_argument($/) {
    $.transform_arguments.push(@.expression_stack.pop());
    @.expression_stack.push(TestML::Expression.new);
}

method transform_argument_list_stop($/) {
    @.expression_stack.pop();
}

method string_call($/) {
    my $string = $<quoted_string>.ast;
    my $transform = TestML::Transform.new(
        name => 'String',
        args => [ $string ],
    );
    @.expression_stack[*-1].transforms.push($transform);
}

method assertion_operator($/) {
    @.expression_stack.pop();
    $.statement.assertion = TestML::Assertion.new(name => 'EQ');
    @.expression_stack.push($.statement.assertion.expression);
}


### Data Section ###
# method data_section($/) {
#     $.data = ~$/;
# }

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
    $.document.data.blocks.push($block);
}

method SEMICOLON_ERROR($/) {
    die "You seem to be missing a semicolon";
}
method NO_META_TESTML_ERROR($/) {
    die "No TestML meta directive found";
}

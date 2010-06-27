class TestML::Runner;
use v6;
# Base is just my cheap Moose...
# use TestML::Base -base;

use TestML::Document;
use TestML::Parser;

has $bridge;
has $document;
has $base;
has $doc    = $self.parse();
has $Bridge = $self.init_bridge;

method setup {
    fail "\nDon't use TestML::Runner directly.\nUse an appropriate subclass like TestML::Runner::TAP.\n";
}

method init_bridge {
    fail "'init_bridge' must be implemented in subclass";
}

method run () {
    # TODO $self.base(($*PROGRAM_NAME ~~ /(.*)'/'/) ?? $<0> !! '.');
    $self.title();
    $self.plan_begin();

    for $self.doc.tests.statements -> $statement {
        my $points = $statement.points;
        if not $points.elems {
            my $left = $self.evaluate_expression($statement.left_expression[0]);
            if $statement.right_expression.elems {
                my $right = $self.evaluate_expression(
                    $statement.right_expression[0]
                );
                $self.do_test('EQ', $left, $right, Nil);
            }
            next;
        }
        my @blocks = $self.select_blocks($points);
        for @blocks -> $block {
            my $left = $self.evaluate_expression(
                $statement.left_expression[0],
                $block,
            );
            if $statement.right_expression.elems {
                my $right = $self.evaluate_expression(
                    $statement.right_expression[0],
                    $block,
                );
                $self.do_test('EQ', $left, $right, $block.label);
            }
        }
    }
    $self.plan_end();
}

method select_blocks ($points) {
    my @blocks = [];

    OUTER:
    for $self.doc.data.blocks -> $block {
        $block.points.exists('SKIP') and next;
        $block.points.exists('LAST') and last;
        for @$points -> $point {
            next OUTER unless $block.points.exists($point);
        }
        if $block.points.exists('ONLY') {
            @blocks = $block;
            last;
        }
        @blocks.push($block);
    }

    return @blocks;
}

method evaluate_expression ($expression, $block) {
    my $context = TestML::Context.new(
        document => $self.doc,
        block => $block,
        value => undef,
    );

    for $expression.transforms -> $transform {
        my $transform_name = $transform.name;
        next if $context.error and $transform_name ne 'Catch';
        my $function = $self.Bridge.__get_transform_function($transform_name);
        my $value;
        try {
            $function(
                $context,
                $transform.args.map: {
                    ($_.WHAT eq 'TestML::Expression')
                    ?? $self.evaluate_expression($_, $block)
                    !! $_
                }; 
            );
             ($@) {
                $context.error($@);
            }
        };
        else {
            $context.value($value);
        }
    }
    if $context.error {
        fail $context.error;
    }
    return $context;
}

method parse {
    my $self = shift;

    my $parser = TestML::Parser.new(
        receiver => TestML::Document::Builder.new(),
        start_token => 'document',
    );
    $parser.receiver.grammar($parser.grammar);

    $parser.open($self.document);
    $parser.parse;

    $self.parse_data($parser);
    return $parser.receiver.document;
}

method parse_data {
    my $self = shift;
    my $parser = shift;
    my $builder = $parser.receiver;
    my $document = $builder.document;
    for my $file (@{$document.meta.data.{Data}}) {
        my $parser = TestML::Parser.new(
            receiver => TestML::Document::Builder.new(),
            grammar => $parser.grammar,
            start_token => 'data',
        );

        if ($file eq '_') {
            $parser.stream($builder.inline_data);
        }
        else {
            $parser.open($self.base . '/' . $file);
        }
        $parser.parse;
        push @{$document.data.blocks}, @{$parser.receiver.blocks};
    }
}

package TestML::Context;
use TestML::Base -base;

field 'document';
field 'block';
field 'point';
field 'value';
field 'error';

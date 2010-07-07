class TestML::Runner;
class TestML::Context { ... }
use v6;

use TestML::Document;
use TestML::Parser;

has $.bridge;
has $.document;
has $.base = 't';
has $.doc = self.parse();
has $.Bridge = self.init_bridge;

method setup {
    die "\nDon't use TestML::Runner directly.\nUse an appropriate subclass like TestML::Runner::TAP.\n";
}

method init_bridge () {
    my $class_name = self.bridge;
    if $class_name ne 'main' {
        eval "use $class_name";
        my $class = eval($class_name);
        die "Can't use $class_name " ~ ~@*INC
            unless ~$class;
    }
    return eval "$class_name.new";
}

method plan_begin () { ... }
method plan_end () { ... }

method run () {
    # TODO self.base(($*PROGRAM_NAME ~~ /(.*)'/'/) ?? $<0> !! '.');
    self.title();
    self.plan_begin();

    for self.doc.test.statements -> $statement {
        my $points = $statement.points;
        if not $points.elems {
            my $left = self.evaluate_expression($statement.expression);
            if $statement.assertion {
                my $right = self.evaluate_expression(
                    $statement.assertion.expression
                );
                self.do_test('EQ', $left, $right, Nil);
            }
            next;
        }
        my @blocks = self.select_blocks($points);
        for @blocks -> $block {
            my $left = self.evaluate_expression(
                $statement.expression,
                $block,
            );
            if $statement.assertion.expression {
                my $right = self.evaluate_expression(
                    $statement.assertion.expression,
                    $block,
                );
                self.do_test('EQ', $left, $right, $block.label);
            }
        }
    }
    self.plan_end();
}

method select_blocks ($points) {
    my @selected;
    my $blocks = self.doc.data.blocks;

    for @($blocks) -> $block {
        my %points = $block.points;
        next if %points.exists('SKIP');
        last if %points.exists('LAST');
        my $next = 0;
        for @($points) -> $point {
            $next = 1 unless %points.exists($point);
        }
        next if $next;
        if %points.exists('ONLY') {
            @selected = ($block);
            last;
        }
        @selected.push($block);
    }
    return @selected;
}

method evaluate_expression ($expression, $block) {
    my $context = TestML::Context.new(
        document => self.doc,
        block => $block,
        value => *,
    );

    for $expression.transforms -> $transform {
        my $transform_name = $transform.name;
        next if $context.error and $transform_name ne 'Catch';
        my $function = self.Bridge.__get_transform_function($transform_name);
        my $value;
#         try {
#             $function(
#                 $context,
#                 $transform.args.map: {
#                     ($_.WHAT eq 'TestML::Expression')
#                     ?? self.evaluate_expression($_, $block)
#                     !! $_
#                 };
#             );
#             CATCH {
#                 $context.error($!);
#             }
#         };
#         else {
#             $context.value($value);
#         }
    }
    if $context.error {
        die $context.error;
    }
    return $context;
}

method parse () {
    my $testml = slurp join '/', self.base, self.document;
    my $document = Parser.parse($testml)
        or die "TestML document failed to parse";
    return $document;
}

method parse_data ($parser) {
    my $builder = $parser.receiver;
    my $document = $builder.document;
    for $document.meta.data<Data> -> $file {
#         my $parser = TestML::Parser.new(
#             receiver => TestML::Document::Builder.new(),
#             grammar => $parser.grammar,
#             start_token => 'data',
#         );

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

class TestML::Context;

has $.document;
has $.block;
has $.point;
has $.value;
has $.error;

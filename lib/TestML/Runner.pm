use v6;
class TestML::Runner;

class TestML::Context { ... }

use TestML::Parser;

has $.bridge;
has $.document;
has $.base = $*PROGRAM_NAME.flip.subst(/.*?'/'/, '').flip;   #'RAKUDO
has $.doc = self.parse();
has $.transform_modules = self.init_transform_modules;

method title () { ... }
method plan_begin () { ... }
method plan_end () { ... }

method run () {
    self.title();
    self.plan_begin();

    for self.doc.test.statements -> $statement {
        my @blocks = $statement.points.elems
            ?? self.select_blocks($statement.points)
            !! TestML::Block.new; !1;
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
                self.EQ($left, $right, $block.label);
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
    );

    for $expression.transforms -> $transform {
        my $transform_name = $transform.name;
#         say "transform_name > $transform_name";
#         next if $context.error and $transform_name ne 'Catch';
        my $function = self.get_transform_function($transform_name);
        {
#             $function(
#                 $context,
#                 $transform.args.map: {
#                     ($_.WHAT eq 'TestML::Expression')
#                     ?? self.evaluate_expression($_, $block)
#                     !! $_
#                 }
#             );/

            $context.value = $function($context, |@($transform.args));
#             say "context.value > " ~ $context.value;

#             CATCH {
#                 $context.error($!);
#                 $context.value = Nil;
#             }
        }
    }

    if $context.error {
        die $context.error;
    }

    return $context;
}

method get_transform_function ($name) {
    my @modules = self.transform_modules;
    for @modules -> $module_name {
        my $function = eval "&$module_name" ~ "::$name";
        return $function if $function;
    }
    die "Can't locate function '$name'";
}

method parse () {
    my $testml = slurp join '/', self.base, self.document;
    my $document = TestML::Parser.parse($testml)
        or die "TestML document failed to parse";
    return $document;
}

method init_transform_modules() {
    my @modules = (
        self.bridge,
        'TestML::Standard',
    );
    for @modules -> $module_name {
        eval "use $module_name";
        my $module = eval($module_name);
        die "Can't use $module_name " ~ ~@*INC
            unless ~$module;
    }
    return @modules;
}


class TestML::Context;

has $.document is rw;
has $.block is rw;
has $.point is rw;
has $.value is rw;
has $.error is rw;

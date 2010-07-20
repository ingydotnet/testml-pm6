use v6;
class TestML::Runner;

class TestML::Context { ... }

use TestML::Parser;

has $.bridge;
has $.document;
has $.base = $*PROGRAM_NAME.flip.subst(/.*?'/'/, '').flip;   #'RAKUDO
has $.doc = $.parse_document();
has $.transform_modules = $._transform_modules;

method title () { ... }
method plan_begin () { ... }
method plan_end () { ... }

method run () {
    $.title();
    $.plan_begin();

    for $.doc.test.statements -> $statement {
        my @blocks = $statement.points.elems
            ?? $.select_blocks($statement.points)
            !! TestML::Block.new; !1;
        for @blocks -> $block {
            my $left = $.evaluate_expression(
                $statement.expression,
                $block,
            );
            if $statement.assertion.expression {
                my $right = $.evaluate_expression(
                    $statement.assertion.expression,
                    $block,
                );
                $.EQ($left, $right, $block.label);
            }
        }
    }
    $.plan_end();
}

method select_blocks ($points) {
    my @selected;

    for @($.doc.data.blocks) -> $block {
        my %points = $block.points;
        next if %points.exists('SKIP');
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
        last if %points.exists('LAST');
    }
    return @selected;
}

method evaluate_expression ($expression, $block) {
    my $context = TestML::Context.new(
        document => $.doc,
        block => $block,
    );

    for $expression.transforms -> $transform {
        my $transform_name = $transform.name;
        next if $context.error and $transform_name ne 'Catch';
        my $function = $.get_transform_function($transform_name);
        try {
            $context.value = $function(
                $context, 
                | $transform.args.map({
                    $_ ~~ TestML::Expression
                        ?? $.evaluate_expression($_, $block)
                        !! $_
                })
            );

            CATCH {
                $context.error = "$!";
                $context.value = Nil;
            }
        }
    }

    if $context.error {
        die $context.error;
    }

    return $context;
}

method get_transform_function ($name) {
    my @modules = $.transform_modules;
    for @modules -> $module_name {
        my $function = eval "&$module_name" ~ "::$name";
        return $function if $function;
    }
    die "Can't locate function '$name'";
}

method parse_document () {
    my $testml = slurp join '/', $.base, $.document;
    my $document = TestML::Parser.parse($testml)
        or die "TestML document failed to parse";
    return $document;
}

method _transform_modules() {
    my @modules = (
        'TestML::Standard',
    );
    if $.bridge {
        @modules.push($.bridge);
    }
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

# vim ft=perl6

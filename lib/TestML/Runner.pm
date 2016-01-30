use v6;
class TestML::Runner { ... }
class TestML::Context { ... }

use TestML::Parser;

class TestML::Runner {
    has $.bridge;
    has $.document;
    has $.base = $*PROGRAM-NAME.flip.subst(/.*?'/'/, '').flip;   #'RAKUDO
    has $!doc;
    has $!transform_modules;

    method doc {
        unless $!doc {
            $!doc = $.parse_document();
        }
        return $!doc;
    }

    method transform_modules {
        unless $!transform_modules {
            $!transform_modules = $._transform_modules;
        }
        return $!transform_modules;
    }

    method title() { ... }
    method plan_begin() { ... }
    method plan_end() { ... }

    method run() {
        $.title();
        $.plan_begin();

        for $.doc.test.statements.list -> $statement {
            my @blocks = $statement.points.elems
                ?? $.select_blocks($statement.points).list
                !! TestML::Block.new; !1;
            for @blocks -> $block {
                my $left = $.evaluate_expression(
                    $statement.expression,
                    $block,
                );
                if $statement.assertion -> $assertion {
                    my $method = 'assert_' ~ $assertion.name;
                    if $assertion.expression.transforms.elems {
                        my $right = $.evaluate_expression(
                            $statement.assertion.expression,
                            $block,
                        );
                        self."$method"($left, $right, $block.label);
                    }
                    else {
                        self."$method"($left, $block.label);
                    }
                }
            }
        }
        $.plan_end();
    }

    method select_blocks($points) {
        my @selected;

        for @($.doc.data.blocks) -> $block {
            my %points = %($block.points);
            next if %points<SKIP> :exists;
            my $next = 0;
            for @($points) -> $point {
                $next = 1 unless %points{$point} :exists;
            }
            next if $next;
            if %points<ONLY> :exists {
                @selected = ($block);
                last;
            }
            @selected.push($block);
            last if %points<LAST> :exists;
        }
        return @selected;
    }

    method evaluate_expression($expression, $block) {
        my $context = TestML::Context.new(
            :document($.doc),
            :block($block),
            :not(0),
            :type('None'),
        );

        for $expression.transforms.list -> $transform {
            my $transform_name = $transform.name;
            #my $what = $transform.WHAT;
            #if ("$what" eq 'TestML::String()') {
            if $transform ~~ TestML::String {
                $context.set('Str', $transform.value);
                next;
            }
            if $transform_name eq 'Not' {
                $context.not = not $context.not;
                next;
            }
            next if $context.error and $transform_name ne 'Catch';
            my $function = $.get_transform_function($transform_name);
            $context._set = 0;
            my $value;
            try {
                $value = $function(
                    $context, 
                    | $transform.args.map({
                        $_ ~~ TestML::Expression
                            ?? $.evaluate_expression($_, $block)
                            !! $_
                    })
                );

                CATCH {
                    default {
                        $context.type = 'Error';
                        $context.error = $_.message;
                        $context.value = Nil;
                    }
                }
            }
            if !$context._set && !$context.error {
                $context.value = $value;
            }
        }

        if $context.error {
            die $context.error;
        }

        return $context;
    }

    method get_transform_function($name) {
        my @modules = $.transform_modules.list;
        for @modules -> $module_name {
            use MONKEY-SEE-NO-EVAL;
            my $function = EVAL "&$module_name" ~ "::$name";
            return $function if $function;
        }
        die "Can't locate function '$name'";
    }

    method parse_document() {
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
            require ::($module_name);
        }
        return @modules;
    }

    method throw($msg) {
        die $msg;
    }
}

class TestML::Context {
    has $.document is rw;
    has $.block is rw;
    has $.point is rw;
    has $.value is rw;
    has $.error is rw;
    has $.type is rw;
    has $.not is rw;
    has $._set is rw;

    method set($type, $value) {
        $.throw("Invalid context type '$type'")
            unless $type ~~ /^[None|Str|Num|Bool|List]$/;
        $.type = $type;
        $.value = $value;
        $._set = 1;
    }

    # TODO 
    method get_value_if_type(*@types) {
        my $type = $.type;
        return $.value if @types.grep($type).Bool;
        $.throw("context object is type '$type', but '@types' required");
    }

    method get_value_as_str() {
        my $type = $.type;
        my $value = $.value;
        return
            $type eq 'Str' ?? $value !!
            $type eq 'List' ?? $value.join("") !!
            $type eq 'Bool' ?? $value ?? '1' !! '' !!
            $type eq 'Num' ?? "$value" !!
            $type eq 'None' ?? '' !!
            $.throw("Str type error: '$type'");
    }

    method get_value_as_num() {
        my $type = $.type;
        my $value = $.value;
        return
            $type eq 'Str' ?? $value + 0 !!
            $type eq 'List' ?? $value.elems !!
            $type eq 'Bool' ?? $value ?? 1 !! 0 !!
            $type eq 'Num' ?? $value !!
            $type eq 'None' ?? 0 !!
            $.throw("Num type error: '$type'");
    }

    method get_value_as_bool() {
        my $type = $.type;
        my $value = $.value;
        return
            $type eq 'Str' ?? $value.chars.Bool !!
            $type eq 'List' ?? $value.elems.Bool !!
            $type eq 'Bool' ?? $value !!
            $type eq 'Num' ?? $value.Bool !!
            $type eq 'None' ?? Bool::False !!
            $.throw("Bool type error: '$type'");
    }

    method throw($msg) {
        die $msg;
    }
}

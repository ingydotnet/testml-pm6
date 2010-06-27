class TestML::Runner::TAP;
use v6;

use Test::Builder;

has $test_builder = Test::Builder.new();

method init_bridge () {
    @*INC.unshift: 't', 'lib';

    my $class = $self.bridge;
    if $class ne 'main' {
        try {
            #XXX: check on P6 require
            require $class;
            CATCH {
                fail "Error loading bridge class '$class': $!";
            }
        }
    }

    return $class.new();
}

method title () {
    if $self.doc.meta.data<Title> -> $title {
        say "=== $title ===";
    }
}

method plan_begin () {
    if $self.doc.meta.data<Plan> -> $tests {
        $self.test_builder.plan(tests => $tests);
    }
    else {
        $self.test_builder.no_plan();
    }
}

method plan_end () {
}

# TODO - Refactor so that standard lib finds this comparison through EQ
method do_test ($operator, $left, $right, $label) {
    if ($operator eq 'EQ') {
        $self.test_builder.is_eq($left.value, $right.value, $label);
    }
}

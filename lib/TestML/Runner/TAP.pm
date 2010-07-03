use v6;
class TestML::Runner::TAP is TestML::Runner;

use Test;

method init_bridge ($self) {
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

method title ($self) {
    if $self.doc.meta.data<Title> -> $title {
        say "=== $title ===";
    }
}

method plan_begin ($self, $tests) {
    if $self.doc.meta.data<Plan> -> $tests {
        Test::plan($tests);
    }
    else {
        Test::plan(*);
    }
}

method plan_end () {
}

# TODO - Refactor so that standard lib finds this comparison through EQ
method do_test ($operator, $left, $right, $label) {
    if ($operator eq 'EQ') {
        Test::is($left.value, $right.value, $label);
    }
}

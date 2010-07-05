use v6;
use TestML::Runner;
class TestML::Runner::TAP is TestML::Runner;

use Test;

method init_bridge () {
    my $class = self.bridge;
    if $class ne 'main' {
        try {
            eval "use $class";
            CATCH {
                die("Error loading bridge class '$class': $!");
            }
        }
    }

    use Bridge1;
    return Bridge1.new();
    return eval "$class.new()";

}

method title () {
    if self.doc.meta.data<Title> -> $title {
        say "=== $title ===";
    }
}

method plan_begin () {
    if self.doc.meta.data<Plan> -> $tests {
        plan($tests);
    }
    else {
        plan(*);
    }
}

method plan_end () {
}

method do_test ($operator, $left, $right, $label) {
    if ($operator eq 'EQ') {
        is($left.value, $right.value, $label);
    }
}

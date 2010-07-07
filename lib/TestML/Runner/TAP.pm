use v6;
use TestML::Runner;
class TestML::Runner::TAP is TestML::Runner;

use Test;

method title () {
    if self.doc.meta.data<Title> -> $title {
        note("=== $title ===");
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

method do_test ($op, $left, $right, $label) {
    is($left.value, $right.value, $label);
}

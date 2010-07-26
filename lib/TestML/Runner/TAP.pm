use v6;

use Test;
use TestML::Runner;

class TestML::Runner::TAP is TestML::Runner;

method title () {
    if $.doc.meta.data<Title> -> $title {
        note("=== $title ===");
    }
}

method plan_begin () {
    if $.doc.meta.data<Plan> -> $tests {
        plan($tests);
    }
    else {
        plan(*);
    }
}

method EQ ($left, $right, $label) {
    is($left.value, $right.value, $label);
}

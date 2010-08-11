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

method assert_EQ ($left, $right, $label) {
    my @label = $label ?? ($label) !! ();
    is($left.value, $right.value, |@label);
}

method assert_HAS ($left, $right, $label) {
    my $assertion = (index $left.value, $right.value) >= 0;
    my @label = $label ?? ($label) !! ();
    ok($assertion, |@label);
}

method assert_OK ($left, $label) {
    my $assertion = $left.value;
    my @label = $label ?? ($label) !! ();
    ok($assertion, |@label);
}


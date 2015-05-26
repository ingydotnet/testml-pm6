use v6;

use Test;
use TestML::Runner;

unit class TestML::Runner::TAP is TestML::Runner;

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

method plan_end () {

}

method assert_EQ ($left, $right, $label) {
    my $left_type = $left.type;
    my $right_type = $right.type;
    $.throw(
        "Assertion type error: left side is '$left_type' and right side is '$right_type'"
    ) unless $left_type eq $right_type;
    my @label = $label ?? ($label) !! ();
    return $.assert_EQ_list($left, $right, |@label)
        if $left_type eq 'List';
    is($left.value, $right.value, |@label);
}

method assert_HAS ($left, $right, $label) {
    my $left_type = $left.type;
    my $right_type = $right.type;
    $.throw(
        "HAS assertion requires left and right side types be 'Str'.\n" ~
        "Left side is '$left_type' and right side is '$right_type'"
    ) unless $left_type eq $right_type;
    my @label = $label ?? ($label) !! ();
    my $assertion = (index $left.value, $right.value) >= 0;
    ok($assertion, |@label);
}

method assert_OK ($context, $label) {
    my @label = $label ?? ($label) !! ();
    my $assertion = ( $context.get_value_as_bool ^^ $context.not )
        ?? Bool::True !! Bool::False;
    ok($assertion, |@label);
}


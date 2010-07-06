use v6;
use TestML::Runner;
class TestML::Runner::TAP is TestML::Runner;

use Test;

method init_bridge () {
    my $class_name = self.bridge;
    if $class_name ne 'main' {
        eval "use $class_name";
        my $class = eval($class_name);
        die "Can't use $class_name " ~ ~@*INC
            unless ~$class;
    }
    return eval "$class_name.new";
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

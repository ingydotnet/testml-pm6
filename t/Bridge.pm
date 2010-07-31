use v6;

module t::Bridge;

our sub uppercase($this) {
    return $this.value.uc;
}

our sub my_thing($this) {
    my $str = $this.value.subst(/\n$/, "");
    return $str.split("\n").join(' - ');
}

our sub combine {
    return @_.map({$_.value}).join(' ');
}

our sub parse_testml($this) {
    eval "use TestML::Parser";
    TestML::Parser.parse($this.value);
}

our sub msg($this) {
    return $this.value;
}

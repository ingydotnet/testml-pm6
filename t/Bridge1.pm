use v6;

module Bridge1;

our sub uppercase($this) {
    return $this.value.uc;
}

our sub my_thing($this) {
    my $str = $this.value.=subst(/\n$/, "");
    return $str.split("\n").join(' - ');
}

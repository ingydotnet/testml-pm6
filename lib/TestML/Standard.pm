use v6;

class TestML::Standard;

method Select () {
    return (shift).value;
}

method Point ($name) {
    $self.point($name);
    my $value = $self.block.points{$name};
    if $value ~~ s/\n+$/\n/ and $value eq "\n" {
        $value = '';
    }
    return $value;
}

method Raw () {
    my $point = $self.point
        orelse fail "Raw called but there is no point";
    return $self.block.points{$point};
}

method Catch () {
    my $error = $self.error
        orelse fail "Catch called but no TestML error found";
    $error ~~ s/' at ' .* ' line ' \d+ '.' \n $//;
    $self.error(Nil);
    return $error;
}

method Throw ($msg) {
    fail $msg;
}

method Throw () {
    fail "Throw called without an error msg";
}

method String (Str $string) {
    return $string;
}

method String (TestML::XXX $xxx) {
    return $xxx.value;
}

method String () {
    $self.raise(
        'StandardLibraryException',
        'String transform called but no string available'
    ) unless $self.value.defined;
    return $self.value;
}

method BoolStr () {
    return $self.value ?? 'True' !! 'False';
}

method List () {
    return $self.value.split(/\n/);
}

method Join ($separator = '') {
    my @list = $self.value;
    return @list.join($separator);
}

method Reverse () {
    my @list = $self.value;
    return @list.reverse;
}

method Sort () {
    my @list = $self.value;
    return @list.sort;
}

method Item () {
    my @list = $self.value;
    return (@list, '').join("\n");
}

# TODO: review this one
method Union () {
    my @list = $self.value;
    # my @list2 = shift;
    my @list2 = @list;
    return |@list, |@list2;
}

# TODO
method Unique () {
#     my @list = $self.value;
#     return [ ... ];
}

method Chomp () {
    my $string = $self.value;
    return $string.chomp;
}


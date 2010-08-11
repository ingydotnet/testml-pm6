use v6;
module TestML::Standard;

our sub Point ($this, $name) {
    $this.point = $name;
    my $value = $this.block.points{$name};
    $value.=subst(/\n+$/, "\n");
    if $value eq "\n" {
        $value = '';
    }
    return $value;
}

our sub String ($this, $string) {
    my $str = ~$string.WHAT eq 'TestML::Context()' ?? $string.value !! $string;
    return $str.Str;
}

our sub True ($this) {
    return Bool::True;
}

our sub False ($this) {
    return Bool::False;
}

our sub List ($this) {
    my Str $str = $this.value.Str;
    $str.=subst(/\n$/, '');
    return $str.split("\n");
}

our sub Join ($this, $separator) {
    return @($this.value).join($separator.value);
}

our sub Reverse ($this) {
    return @($this.value).reverse;
}

our sub Sort ($this) {
    return @($this.value).sort;
}

our sub Item ($this) {
    my @list = @($this.value);
    @list.push('');
    return @list.join("\n");
}

our sub Catch ($this) {
    my $error = $this.error
        or die "Catch called but no TestML error found";
#     $error ~~ s/' at ' .* ' line ' \d+ '.' \n $//;
    $this.error = Nil;
    return $error;
}

# sub Select () {
#     return (shift).value;
# }
# 
# sub Raw () {
#     my $point = this.point
#         or die "Raw called but there is no point";
#     return this.block.points{$point};
# }
# 
# multi sub Throw ($msg) {
#     fail $msg;
# }
# 
# multi sub Throw () {
#     fail "Throw called without an error msg";
# }
# 
# multi sub String ($xxx) {
#     return $xxx.value;
# }
# 
# multi sub String () {
#     this.raise(
#         'StandardLibraryException',
#         'String transform called but no string available'
#     ) unless this.value.defined;
#     return this.value;
# }
# 
# sub BoolStr () {
#     return this.value ?? 'True' !! 'False';
# }
# 
# sub Chomp () {
#     my $string = this.value;
#     return $string.chomp;
# }
# 

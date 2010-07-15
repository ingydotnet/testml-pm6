use v6;
module TestML::Standard;

# sub Select () {
#     return (shift).value;
# }

our sub Point ($this, $name) {
    $this.point = $name;
    my $value = $this.block.points{$name};
    $value.=subst(/\n+$/, "\n");
    if $value eq "\n" {
        $value = '';
    }
    return $value;
}

# sub Raw () {
#     my $point = this.point
#         or die "Raw called but there is no point";
#     return this.block.points{$point};
# }
# 
# sub Catch () {
#     my $error = this.error
#         or die "Catch called but no TestML error found";
#     $error ~~ s/' at ' .* ' line ' \d+ '.' \n $//;
#     this.error(Nil);
#     return $error;
# }
# 
# multi sub Throw ($msg) {
#     fail $msg;
# }
# 
# multi sub Throw () {
#     fail "Throw called without an error msg";
# }

our sub String ($this, $string) {
    return $string.Str;
}

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

our sub List ($this) {
    my Str $str = $this.value.Str;
    $str.=subst(/\n$/, '');
    return $str.split("\n");
}

our sub Join ($this, $separator = ' - ') {
    return @($this.value).join($separator);
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

# # TODO: review this one
# sub Union () {
#     my @list = this.value;
#     # my @list2 = shift;
#     my @list2 = @list;
#     return |@list, |@list2;
# }
# 
# # TODO
# sub Unique () {
# #     my @list = this.value;
# #     return [ ... ];
# }
# 
# sub Chomp () {
#     my $string = this.value;
#     return $string.chomp;
# }
# 

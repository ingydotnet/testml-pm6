use v6;
module TestML::Standard;

our sub Point ($context, $name) {
    $context.point = $name;
    my $value = $context.block.points{$name};
    $value.=subst(/\n+$/, "\n");
    if $value eq "\n" {
        $value = '';
    }
    return $value;
}

our sub String ($context, $string) {
    my $str = ~$string.WHAT eq 'TestML::Context()' ?? $string.value !! $string;
    return $str.Str;
}

our sub True ($context) {
    return Bool::True;
}

our sub False ($context) {
    return Bool::False;
}

our sub List ($context) {
    my Str $str = $context.value.Str;
    $str.=subst(/\n$/, '');
    return $str.split("\n");
}

our sub Join ($context, $separator) {
    return @($context.value).join($separator.value);
}

our sub Reverse ($context) {
    return @($context.value).reverse;
}

our sub Sort ($context) {
    return @($context.value).sort;
}

our sub Item ($context) {
    my @list = @($context.value);
    @list.push('');
    return @list.join("\n");
}

our sub Catch ($context) {
    my $error = $context.error
        or die "Catch called but no TestML error found";
#     $error ~~ s/' at ' .* ' line ' \d+ '.' \n $//;
    $context.error = Nil;
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

use v6;
unit module TestML::Standard;

our sub Point($context, $name) {
    $context.point = $name;
    my $value = $context.block.points{$name};
    $value.=subst(/\n+$/, "\n");
    if $value eq "\n" {
        $value = '';
    }
    $context.set('Str', $value);
}

our sub Catch($context) {
    my $error = $context.error
        or die "Catch called but no TestML error found";
    $context.error = Nil;
    $context.set('Str', $error);
}

our sub Throw($msg) {
    die $msg;
}

our sub Str($context) {
    $context.set('Str', $context.get_value_as_str);
}

our sub Bool($context) {
    $context.set('Bool', $context.get_value_as_bool);
}

our sub Num($context) {
    $context.set('Num', $context.get_value_as_num);
}

our sub True($context) {
    $context.set('Bool', Bool::True);
}

our sub False($context) {
    $context.set('Bool', Bool::False);
}

# our sub List($context) {
#     my Str $str = $context.value.Str;
#     $str.=subst(/\n$/, '');
#     return $str.split("\n");
# }

# our sub Join($context, $separator) {
#     return @($context.value).join($separator.value);
# }
# 
# our sub Reverse($context) {
#     return @($context.value).reverse;
# }
# 
# our sub Sort($context) {
#     return @($context.value).sort;
# }
# 
# our sub Item($context) {
#     my @list = @($context.value);
#     @list.push('');
#     return @list.join("\n");
# }
# 
# our sub Text($context) {
#     my @value = $context.get_value_if_type('List');
#     $context.set('Str', @value.join(''));
# }
# 
# our sub Lines($context) {
#     my $value = $context.value || '';
#     $value = $value.split("\n");
#     $context.set('List', $value);
# }

# sub Select() {
#     return (shift).value;
# }
# 
# sub Raw() {
#     my $point = this.point
#         or die "Raw called but there is no point";
#     return this.block.points{$point};
# }
# 
# multi sub Throw() {
#     fail "Throw called without an error msg";
# }
# 
# multi sub String($xxx) {
#     return $xxx.value;
# }
# 
# multi sub String() {
#     this.raise(
#         'StandardLibraryException',
#         'String transform called but no string available'
#     ) unless this.value.defined;
#     return this.value;
# }
# 
# sub BoolStr() {
#     return this.value ?? 'True' !! 'False';
# }
# 
# sub Chomp() {
#     my $string = this.value;
#     return $string.chomp;
# }
# 

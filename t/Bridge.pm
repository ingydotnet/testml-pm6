use v6;

unit module t::Bridge;

our sub my_lower($context) {
    return $context.value.lc;
}

our sub my_upper($context) {
    return $context.value.uc;
}

our sub uppercase($context) {
    return $context.value.uc;
}

our sub combine {
    return @_.map({$_.value}).join(' ');
}

our sub parse_testml($context) {
    require TestML::Parser;
    ::('TestML::Parser').parse($context.value);
}

our sub msg($context) {
    return $context.value;
}

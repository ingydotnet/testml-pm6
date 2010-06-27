use v6;

class TestML::Bridge;

method __transform_classes () {
    my @list = <
        TestML::Standard    
    >;
    if not($self.WHAT eq any @list) {
        @list.unshift($self.WHAT);
    }
    return @list;
}

method __get_transform_function ($name) {
    my @classes = $self.__transform_classes();
    my $function;
    for @classes -> $class {
        try {
            use $class;
        }
        $function = $class->can($name) and last;
    }
    if not $function {
        fail "Can't locate function '$name'";
    }
    return $function;
}


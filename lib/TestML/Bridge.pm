use v6;

class TestML::Bridge;

method __transform_classes () {
    my @list = < TestML::Standard >;
    my $class = substr(~self.WHAT, 0, -2);
    unless ($class eq any @list) {
        @list.unshift($class);
    }
    return @list;
}

method __get_transform_function ($name) {
    my @classes = self.__transform_classes();
    my ($class, $function);
    for @classes -> $class_name {
        eval "use $class_name";
        $class = eval($class_name);
        die "Can't use $class_name " ~ ~@*INC
            unless ~$class;
        last if $function = $class.can($name);
    }

    unless $function {
        die "Can't locate function '$name'";
    }

    return [$class, $function];
}

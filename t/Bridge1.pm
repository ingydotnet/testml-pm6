use v6;
use TestML::Bridge;

class Bridge1 is TestML::Bridge;

method uppercase() {
    return self.value.uc;
}

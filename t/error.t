use v6;
use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 'testml-tml/error.tml',
    bridge => 't::Bridge',
).run();

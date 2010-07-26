use v6;
use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 't1.tml',
    bridge => 't::Bridge',
).run();

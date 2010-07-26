use v6;
use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 'testml-tml/arguments.tml',
    bridge => 't::Bridge',
).run();

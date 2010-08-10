use v6;
use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 'testml-tml/exceptions.tml',
    bridge => 't::Bridge',
).run();

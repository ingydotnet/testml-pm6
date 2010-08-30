use v6;
use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 'testml/dataless.tml',
    bridge => 't::Bridge',
).run();

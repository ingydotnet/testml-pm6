use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 'testml-tml/basic.tml',
    bridge => 't::Bridge',
).run();

use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 't1.tml',
    bridge => 'Bridge',
).run();

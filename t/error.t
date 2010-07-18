use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 'testml-tml/error.tml',
    bridge => 'Bridge',
).run();

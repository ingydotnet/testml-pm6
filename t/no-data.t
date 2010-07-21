use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 'testml-tml/no-data.tml',
    bridge => 't::Bridge',
).run();

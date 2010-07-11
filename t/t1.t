BEGIN { @*INC.unshift: 't', 'lib'; }
use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 't1.tml',
    bridge => 'Bridge',
).run();

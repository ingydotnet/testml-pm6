BEGIN { @*INC.unshift: 't', 'lib'; }
use TestML::Runner::TAP;

TestML::Runner::TAP.new(
    document => 'testml-tml/basic.tml',
    bridge => 'Bridge',
).run();

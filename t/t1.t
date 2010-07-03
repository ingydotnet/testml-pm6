BEGIN { @*INC.unshift: 't', 'lib'; }
use TestML::Runner::TAP;

my $runner = TestML::Runner::TAP.new(
    document => 't1.tml',
    bridge => 'Bridge1',
    base => 't',
);

$runner.run();

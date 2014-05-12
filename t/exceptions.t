use v6;
use TestML::Runner::TAP;

use lib '.';

TestML::Runner::TAP.new(
    document => 'testml/exceptions.tml',
    bridge => 't::Bridge',
).run();

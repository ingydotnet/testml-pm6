use YAML::XS;
use Data::Dumper;

$Data::Dumper::Terse = 1;
$Data::Dumper::Indent = 1;

my $hash = Data::Dumper::Dumper YAML::XS::LoadFile(shift);
chomp($hash);

print <<"...";
module TestML::Parser::Grammar;
use v6;

sub grammar {
    return $hash;
}
...

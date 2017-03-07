use strict;
use warnings;

use ElectricCommander;
use Getopt::Long;


my ($plugin_name, $version, $property, $file);
GetOptions(
    'plugin-name=s' => \$plugin_name,
    'version=s' => \$version,
    'property=s' => \$property,
    'file=s' => \$file
) or die;

my $path = "/projects/$plugin_name-$version/$property";
open my $fh, $file or die "Cannot open $file: $!";
my $content = join '' => <$fh>;
close $fh;

my $ec = ElectricCommander->new;
$ec->setProperty($path, $content);
print "Updated: $path\n";

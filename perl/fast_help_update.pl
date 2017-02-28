use strict;
use warnings;
use Cwd qw(getcwd);
use Getopt::Long;
use File::Copy::Recursive qw(dircopy);
use File::Find;

my ($plugin_name, $plugin_version);

GetOptions('plugin-name=s' => \$plugin_name, 'plugin-version=s' => \$plugin_version) or die;

$ENV{COMMANDER_HOME} || die 'ENV variable COMMANDER_HOME is not set';
my $plugin_home = "$ENV{COMMANDER_HOME}/plugins/$plugin_name-$plugin_version";

unless( -d $plugin_home) {
    die "Plugin directory $plugin_home is not found";
}

my $cwd = getcwd();
if ( -d "$cwd/pages" ) {
    my $result = dircopy("$cwd/pages", "$plugin_home/pages");
    unless ($result) {
        die "Cannot copy $cwd/pages: $!";
    }
}

if ( -d "$cwd/htdocs") {
    my $result = dircopy("$cwd/htdocs", "$plugin_home/htdocs");
    unless ($result) {
        die "Cannot copy $cwd/htdocs: $!";
    }
    else {
        print "Copied $cwd/htdocs\n";
    }
}

replace_placeholders();


sub replace_placeholders {
    find(sub {
        return unless -f $File::Find::name;

        my $filename = $_;

        open my $fh, $filename or die $!;
        my $content = join '' => <$fh>;
        close $fh;

        my $plugin_name_placeholder = '@PLUGIN_NAME@';
        my $plugin_key_placeholder = '@PLUGIN_KEY@';
        my $plugin_version_placeholder = '@PLUGIN_VERSION@';

        $content =~ s/$plugin_key_placeholder/$plugin_name/gms;
        $content =~ s/$plugin_name_placeholder/$plugin_name-$plugin_version/gms;
        $content =~ s/$plugin_version_placeholder/$plugin_version/gms;

        open $fh, ">$filename" or die $!;
        print $fh $content;
        close $fh;

    }, "$plugin_home/htdocs", "$plugin_home/pages");
}

#!/usr/bin/env perl

use strict;
use warnings;
use File::Find;
use Getopt::Long;


my ($license_file, $dir);
GetOptions('license=s' => \$license_file, 'dir=s' => \$dir) or die;

open my $fh, $license_file or die "Cannot open $license_file: $!";
my $license = join '' => <$fh>;
close $fh;

find(sub {
    return unless $File::Find::name =~ m/\.(pl|pm|xml|py|js)/;
    my $filename = $_;

    open my $fh, $filename or die "Cannot open $_: $!";
    my $content = join '' => <$fh>;
    close $fh;

    unless(has_license($content)){
        $content = add_license($content, $_);
        open my $fh, ">$filename" or die "Cannot open $filename for writing: $!";
        print $fh $content;
        close $fh;

        print "License was added to $filename\n";
    }
}, $dir);


sub has_license {
    my ($content) = @_;

    my @lines = split (/\n/ => $license);
    my $first = $lines[0];

    if ($content =~ m/$first/) {
        return 1;
    }

    return;
}


sub add_license {
    my ($content, $filename) = @_;

    if ($filename =~ m/\.(pl|pm|py)/) {
        my @lines = split /\n/ => $license;
        @lines = map { "# $_"} @lines;
        my $commented = join "\n" => @lines;
        $content = $commented . "\n\n" . $content;
        return $content;
    }
    elsif ($filename =~ m/\.xml/) {
        my $commented = "<!--\n$license\n-->";
        $content = $commented . "\n\n" . $content;
        return $content;
    }
}

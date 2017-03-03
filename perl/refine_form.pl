use strict;
use warnings;
use Getopt::Long;
use Data::Dumper;
use File::Find;


my $form;
my $save;
my $dir;

GetOptions('form=s' => \$form, 'save' => \$save, 'dir=s' =>  \$dir);


if ($dir) {
    find(sub {
        return unless /\.xml$/;
        refine_form($_);
    }, $dir)
}
else {
    refine_form($form);
}


sub refine_form {
    my ($form) = @_;

    open my $fh, $form or die "Cannot open $form: $!";
    my $content = join '', <$fh>;
    close $fh;


    my $refine_label = sub {
        my ($label) = @_;

        $label =~ s/\w*\(required\)//ig;

        my @words = split /\s+/ => $label;
        my $first = shift @words;

        for my $word (@words) {
            if ($word =~ m/[[:upper:]][[:lower:]]+/) {
                $word = lc $word;
            }
        }

        $first = ucfirst $first;
        return '<label>'. join(' ', $first, @words) . '</label>';
    };


    my $refine_doc = sub {
        my ($doc) = @_;

        $doc =~ s/\s*\(required\)//ig;
        $doc .= '.' unless $doc =~ m/\.$/;
        return "<documentation>$doc</documentation>";
    };

    $content =~ s/<label>(.+)<\/label>/$refine_label->($1)/eg;
    $content =~ s/<documentation>(.+)<\/documentation>/$refine_doc->($1)/eg;

    if ($save) {
        open my $fh, ">$form" or die "Cannot open $form: $!";
        print $fh $content;
        close $fh;
        print "Saved $form\n";
    }
    else {
        print $content;
    }
}


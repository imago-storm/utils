use strict;
use warnings;
use Getopt::Long;
use XML::Simple;
use Data::Dumper;
my $form;
GetOptions('form=s' => \$form);


open my $fh, $form or die "Cannot open $form: $!";
my $content = join '', <$fh>;
close $fh;


my $xml = XMLin($content);
for my $form_element (@{$xml->{formElement}}) {
    my $label = $form_element->{label};
    my $doc = $form_element->{documentation};
    my $required = $form_element->{required};

    my $required_class = $required ? ' class="required"' : '';

    my $block = qq{
        <tr>
            <td$required_class>
                $label
            </td>
            <td>
                $doc
            </td>
        </tr>
};

    print $block;
}

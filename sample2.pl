#/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;

use lib('lib');
use Algorithm::TWCNB;

my $cnb = Algorithm::TWCNB->new();

my @pos_data = qw(a b ab bb aaab);
my @neg_data = qw(cc d cd ddd ccd);

foreach my $d (@pos_data) {
    my $tmp = make_attributes($d);
    $cnb->add_instance(attributes => $tmp, label => 'positive');
}
foreach my $d (@neg_data) {
    my $tmp = make_attributes($d);
    $cnb->add_instance(attributes => $tmp, label =>'negative');
}

$cnb->train();

foreach my $d qw(abccd adf) {
    my $tmp   = make_attributes($d);
    my $score = $cnb->predict(attributes => $tmp);
    print Dumper($d, $score);
}

print Dumper($cnb->labels);


sub make_attributes {
    my $data = shift;

    my $attributes = {};
    foreach my $chr (split(//, $data)) {
        $attributes->{$chr}++;
    }

    $attributes;
}


package Algorithm::TWCNB;

use strict;
use warnings;

use Data::Dumper;

our $VERSION = '0.0.1';

sub new {
    my $class = shift;
    my $self = {
        dnum => 0,
        fdata => [],
        ldata => [],
        dlen => [],
        lnum => {},
        df => {},
        weight => {}
    } ;
    bless $self, $class;
}

sub add_instance {
    my ($self, %params) = @_;

    my $attributes = $params{attributes} or die "No params: attributes";
    my $label     = $params{label}     or die "No params: label";
    die "attributes is not hash ref"   unless ref($attributes) eq 'HASH';
    die "attributes is empty hash ref" unless keys %$attributes;
    $label = [$label] unless ref($label) eq 'ARRAY';


    foreach my $l (@$label) {
        my $dlen = 0;

        foreach my $i (keys %$attributes) {
            $self->{df}{$i}++;
            $dlen += $attributes->{$i} ** 2;
        }

        $dlen = sqrt($dlen);

        push(@{$self->{fdata}}, $attributes);
        push(@{$self->{ldata}}, $l);
        push(@{$self->{dlen}}, $dlen);

        $self->{lnum}{$l}++;
        $self->{dnum}++;
    }
}

sub train {
    my ($self, %params) = @_;

    my $alpha = $params{alpha};
    $alpha = 1.0 unless defined($alpha);
    die "alpha is le 0" unless $alpha > 0;

    my $dnum = $self->{dnum};

    my $cdata = {};

    for (my $j = 0; $j < $dnum; $j++) {
        my $attributes = $self->{fdata}[$j];
        my $label = $self->{ldata}[$j];
        my $dlen = $self->{dlen}[$j];
        foreach my $i (keys %$attributes) {
            my $d = $attributes->{$i};
            $d = log($d + 1); # TF transform
            $d = $d * log($dnum / $self->{df}{$i}); # IDF transform
            $d = $d / $dlen; # length norm
            $cdata->{all}{$i} += $d;
            $cdata->{label}{$label}{$i} += $d;
        }
    }

    my $ctheta = {};
    my $weight = $self->{weight};

    foreach my $label (keys %{$cdata->{label}}) {
        my $csum = 0;
        foreach my $f (keys %{$cdata->{all}}) {
            $ctheta->{$label}{$f} = $cdata->{all}{$f};
            if (defined($cdata->{label}{$label}{$f})) {
                $ctheta->{$label}{$f} -= $cdata->{label}{$label}{$f};
            }
            $ctheta->{$label}{$f} += $alpha;
            $csum += $ctheta->{$label}{$f};
        }

        my $wsum = 0;
        foreach my $f (keys %{$ctheta->{$label}}) {
            $ctheta->{$label}{$f} /= $csum;
            $weight->{$label}{$f} = log($ctheta->{$label}{$f});
            $wsum += $weight->{$label}{$f};
        }

        foreach my $f (keys %{$weight->{$label}}) {
            $weight->{$label}{$f} /= $wsum; # weight normalization
        }
    }
    1;
}

sub predict {
    my ($self, %params) = @_;

    my $attributes = $params{attributes} or die "No params: attributes";
    die "attributes is not hash ref"   unless ref($attributes) eq 'HASH';
    die "attributes is empty hash ref" unless keys %$attributes;

    my $weight = $self->{weight};
    return {} unless %$weight;

    my $score = {};
    foreach my $label (keys %$weight) {
        $score->{$label} = 0;
        foreach my $f (keys %$attributes) {
            next unless $weight->{$label}{$f};
            $score->{$label} += $attributes->{$f} * $weight->{$label}{$f};
        }
    }

    $score;
}

sub labels {
    my $self = shift;
    keys %{$self->{lnum}};
}

__END__

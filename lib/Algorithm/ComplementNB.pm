package Algorithm::ComplementNB;

use strict;
use warnings;

our $VERSION = '0.0.1';

sub new {
    my $class = shift;
    my $self = {
        dnum => 0,
        data => {},
        lnum => {},
        ctheta => {},
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
        foreach my $f (keys %$attributes) {
            $self->{data}{label}{$l}{$f} += $attributes->{$f};
            $self->{data}{all}{$f} += $attributes->{$f};
        }
        $self->{lnum}{$l}++;
        $self->{dnum}++;
    }
}

sub train {
    my ($self, %params) = @_;

    my $alpha = $params{alpha};
    $alpha = 1.0 unless defined($alpha);
    die "alpha is le 0" unless $alpha > 0;

    my $ctheta = $self->{ctheta};
    my $csum  = {};

    foreach my $label (keys %{$self->{data}{label}}) {
        my $csum = 0;
        foreach my $f (keys %{$self->{data}{all}}) {
            $ctheta->{$label}{$f} = $self->{data}{all}{$f};
            if (defined($self->{data}{label}{$label}{$f})) {
                $ctheta->{$label}{$f} -= $self->{data}{label}{$label}{$f};
            }
            $ctheta->{$label}{$f} += $alpha;
            $csum += $ctheta->{$label}{$f};
        }

        foreach my $f (keys %{$ctheta->{$label}}) {
            $ctheta->{$label}{$f} /= $csum;
        }
    }
    1;
}

sub predict {
    my ($self, %params) = @_;

    my $attributes = $params{attributes} or die "No params: attributes";
    die "attributes is not hash ref"   unless ref($attributes) eq 'HASH';
    die "attributes is empty hash ref" unless keys %$attributes;

    my $ctheta = $self->{ctheta};
    my $dnum   = $self->{dnum};
    my $lnum   = $self->{lnum};

    return {} unless %$ctheta;

    my $score = {};
    foreach my $label (keys %{$lnum}) {
        $score->{$label} = log($lnum->{$label} / $dnum);
        foreach my $f (keys %$attributes) {
            next unless $ctheta->{$label}{$f};
            $score->{$label} -= $attributes->{$f} * log($ctheta->{$label}{$f});
        }
    }

    $score;
}

sub labels {
    my $self = shift;
    keys %{$self->{lnum}};
}

1;
__END__


=head1 NAME

Algorithm::ComplementNB - Complement Naive Bayes Classifier

=head1 SYNOPSIS

  use Algorithm::ComplementNB;

  my $cnb= Algorithm::ComplementNB->new();
  
  $cnb->add_instance(
      attributes => {a => 2, b => 3},
      label => 'positive'
  );
  
  $cnb->add_instance(
      attributes => {c => 3, d => 1},
      label => 'negative'
  );
  
  $cnb->train();
  
  my $score = $cnb->predict(
                  attributes => {a => 1, b => 1, d => 1, e =>1}
              );

=head1 DESCRIPTION

This module implements a Complement Naive Bayes. Algorithm::ComplementNB is a simple CNB, and Algorithm::TWCNB is a Transformed Weight-normalized version of CNB.

=head1 AUTHOR

TAGAMI Yukihiro <tagami.yukihiro@gmail.com>

=head1 LICENSE

This library is distributed under the term of the MIT license.

L<http://opensource.org/licenses/mit-license.php>


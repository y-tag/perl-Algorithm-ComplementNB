#!/usr/bin/perl

use strict;
use warnings;

use Test::More "no_plan";
use File::Spec;
use lib('lib');
use Algorithm::ComplementNB;

my $cnb = Algorithm::ComplementNB->new();
ok($cnb, "new() returns instance");
isa_ok($cnb, 'Algorithm::ComplementNB', "right instance");

$cnb->add_instance(attributes => hash(qw(a)), label => 'positive');
is($cnb->labels(), 1, "1 label");

$cnb->add_instance(attributes => hash(qw(b)),       label => 'positive');
$cnb->add_instance(attributes => hash(qw(a b)),     label => 'positive');
$cnb->add_instance(attributes => hash(qw(b b)),     label => ['positive']);
$cnb->add_instance(attributes => hash(qw(a a a b)), label => ['positive']);
is($cnb->labels(), 1, "1 label yet");

$cnb->add_instance(attributes => hash(qw(c c)),    label => 'negative');
$cnb->add_instance(attributes => hash(qw(d)),      label => 'negative');
$cnb->add_instance(attributes => hash(qw(c d)),    label => 'negative');
$cnb->add_instance(attributes => hash(qw(d d d )), label => ['negative']);
$cnb->add_instance(attributes => hash(qw(c c d)),  label => ['negative']);
is($cnb->labels(), 2, "2 label");

eval {$cnb->add_instance(label => 'other')};
ok($@, "no attributes in add_instance()");

eval {$cnb->add_instance(attributes => 'attributes', label => 'other')};
ok($@, "string attributes in add_instance()");

eval {$cnb->add_instance(attributes => undef, label => 'other')};
ok($@, "undef attributes in add_instance()");

eval {$cnb->add_instance(attributes => {}, label => 'other')};
ok($@, "empty attributes in add_instance()");

eval {$cnb->add_instance(attributes => hash(qw(other)))};
ok($@, "no label in add_instance()");

eval {$cnb->add_instance(attributes => hash(qw(other)), label => undef)};
ok($@, "undef label in add_instance()");

eval {$cnb->add_instance(attributes => hash(qw(other)), label => '')};
ok($@, "empty label in add_instance()");

$cnb->train();

my $ret;

$ret = $cnb->predict(attributes => &hash(qw(a a b b c d)));
ok($ret->{positive} > $ret->{negative}, "predict positive");

$ret = $cnb->predict(attributes => &hash(qw(a b c c d d)));
ok($ret->{positive} < $ret->{negative}, "predict negative");

$ret = $cnb->predict(attributes => &hash(qw(a c f)));
ok($ret->{positive} > $ret->{negative}, "contains unknown feature");

$ret = $cnb->predict(attributes => &hash(qw(f f f f)));
ok($ret->{positive} == $ret->{negative}, "all unknown feature");

$ret = eval {$cnb->predict()};
ok($@, "no attributes in predict()");

$ret = eval {$cnb->predict(attributes => 'attributes')};
ok($@, "string attributes in predict()");

$ret = eval {$cnb->predict(attributes => undef)};
ok($@, "undef attributes in predict()");

$ret = eval {$cnb->predict(attributes => {})};
ok($@, "empty attributes in predict()");


$cnb = Algorithm::ComplementNB->new();

$cnb->add_instance(attributes => hash(qw(a)), label => 'positive');

$ret = $cnb->predict(attributes => &hash(qw(a a b b c d)));
is(keys %$ret, 0, "predict() before learn()");

eval {$cnb->train(alpha => 0.0)};
like($@, qr(alpha),  "alpha is le 0.0");



sub hash {
    my $h = {};
    $h->{$_}++ for @_;
    $h;
}

#!/usr/bin/perl -w

use strict;
use Math::Random qw(random_uniform_integer random_normal);

my $knownUsers = $ARGV[0];
my $probUserAttr = $ARGV[1];	# a percentage
my $mean = $ARGV[2];
my $sd = $ARGV[3];
my $bound = 1;
if (defined $ARGV[4]) {
  $bound = $ARGV[4];
}

my $fileName = "k$knownUsers.p$probUserAttr.m$mean.s$sd.b$bound.txt";
open(my $fh, ">", $fileName);

print $fh "$knownUsers known users\n";
print $fh "$probUserAttr prob user has attribute\n";
print $fh "mean $mean, sd $sd, bound $bound\n";

if ($knownUsers >= $mean) {
  print $fh "the number of known users $knownUsers should be less than the mean $mean\n";
  exit;
}

my $tries = 10000000;
my $falsePos = 0;
my $falseNeg = 0;
my $truePos = 0;
my $trueNeg = 0;
my $numPos = 0;
my $numNeg = 0;
my $numHas = 0;
my $totRight = 0;
my $numHasNot = 0;
my $progThresh = 1000000;
my $prog = 0;
my $hasAttr = 0;
for (1..$tries) {
  #decide randomly if user has attribute or not
  my $ran1 = random_uniform_integer(1, 0, 99);
  $hasAttr = 0;
  if ($ran1 < $probUserAttr) {
    $hasAttr = 1;
  }
  my $totUsers = $knownUsers + $hasAttr;
  my $thresh = random_normal(1, $mean, $sd);
  if ($thresh < $bound) { $thresh = $bound; }
  my $report = 0;
  if ($totUsers > $thresh) {
    $report = 1;
  }
  #print $fh "thresh $thresh, users $totUsers, report $report\n";
  if ($report && $hasAttr) {
    $truePos++;
    $numPos++;
    $numHas++;
  }
  elsif ($report && !$hasAttr) {
    $falsePos++;
    $numPos++;
    $numHasNot++;
  }
  elsif (!$report && $hasAttr) {
    $falseNeg++;
    $numNeg++;
    $numHas++;
  }
  else {
    $trueNeg++;
    $numNeg++;
    $numHasNot++;
  }
}
my $percentReports = ($numPos / $tries) * 100;
my $percentNotReports = ($numNeg / $tries) * 100;
my $percentHasAttrCorrect = 100;
if ($numPos) {
  $percentHasAttrCorrect = ($truePos / $numPos) * 100;
}
my $percentHasNotAttrCorrect = 100;
if ($numNeg) {
  $percentHasNotAttrCorrect = ($trueNeg / $numNeg) * 100;
}
print $fh "$percentReports percent of tries were reported\n";


#my $totalPercentRight = ($percentHasAttrCorrect+$percentHasNotAttrCorrect)/2;
my $totalPercentRight = (($truePos+$trueNeg)/$tries) * 100;
print $fh "Victim has attr:\n";
print $fh "   $percentHasAttrCorrect percent correct\n";
print $fh "Victim does not have attr:\n";
print $fh "   $percentHasNotAttrCorrect percent correct\n";
print $fh "Total percent right: $totalPercentRight\n";




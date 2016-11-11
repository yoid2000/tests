#!/usr/bin/perl -w

use strict;
use Math::Random qw(random_uniform_integer random_normal);
use Math::Round;

my $tries = 10000000;
my @stats = (0,0,0,0,0,0,0,0,0,0,0,0,0);

foreach (1..$tries) {
  my $trueVal = random_uniform_integer(1, 2, 10);
  my $thresh = random_normal(1, 4, 0.6);
  if ($thresh < 1) { $thresh = 1; }
  next if ($trueVal <= $thresh);
  # if we get here, then we have not been low-count filtered
  my $noise = round(random_normal(1, 0, 2));
  my $noisyVal = $trueVal + $noise;
  next if ($noisyVal > 2);
  # if we get here, then the noisy answer is 2.  Now record what produced
  # this noisy answer
  $stats[$trueVal]++;
}

my $total = 0;
foreach (@stats) {
  $total += $_;
}
my $hitsPerTry = $total / $tries;
my $str = sprintf "%.2f", $hitsPerTry;
print "$total hits of $tries tries ($str)\n";

for (my $i = 2; $i <= 10; $i++) {
  my $frac = $stats[$i] / $total;
  print "$i: $frac\n";
}

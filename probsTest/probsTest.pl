#!/usr/bin/perl -w

use strict;
use Math::Random qw(random_uniform_integer random_normal);
use Math::Round;

my @right = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
my @total = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0);
my $tries = 10000000000;
my $progThresh = 1000000;
my $prog = 0;
for (1..$tries) {
  #decide randomly if true answer is 0 or 1
  my $true = random_uniform_integer(1, 0, 1);
  my $answer = round(random_normal(1, $true, 2));
  my $index;
  my $guess;
  if ($answer >= 1) {
    $index = $answer - 1;
    $guess = 1;
  }
  else {
    $index = -$answer;
    $guess = 0;
  }
  $total[$index]++;
  if ($guess == $true) {
    $right[$index]++;
  }
  ++$prog;
  my $rem = $prog % $progThresh;
  #print "$prog, $rem\n";
  if ($rem == 0) {
    my $frac = $prog / $tries;
    #print "$frac\n";
  }
}

print "\n";
my $i = 0;
while($total[$i] > 0) {
  my $fracRight = $right[$i] / $total[$i];
  my $probCase = $total[$i] / $tries;
  print "$i: $fracRight right, $probCase likelihood (total $total[$i])\n";
  $i++;
}

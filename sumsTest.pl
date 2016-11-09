#!/usr/bin/perl -w

use strict;
use List::Util qw(sum min max);
use Math::Random qw(random_uniform_integer random_normal random_beta);
use Math::Round;
use Statistics::Basic qw(stddev mean);

my $numInit = 100;
my $doBeta = 1;
my $numAdd = 30;

print "Initially $numInit users, ";
if ($doBeta) {
  print "Beta distribution (a=2, b=10)\n";
}
else {
  print "Binary distribution (100 versus 10000000)\n";
}

#experiment 2:


my $exp = 3;
my $errStats = [];
my $estStats = [];
my @table = ();

for (my $i = 0; $i < $numAdd; $i++) {
  $errStats->[$i] = [];
  $estStats->[$i] = [];
}

foreach (1..500) {
  @table = ();
  if ($doBeta) {
    @table = random_beta($numInit, 2, 20);
    for (my $i = 0; $i <= $#table; $i++) {
      $table[$i] *= 1000000;
      $table[$i] += 30000;
      $table[$i] = round $table[$i];
    }
  }
  else {
    for (my $i = 0; $i < $numInit; $i++) {
      $table[$i] = 100;
    }
  }
  
  my $lastNoisyCount = getNoisyCount([ @table ]);
  my $lastTrueCount = $#table + 1;
  my $lastNoisySum = getNoisySum([ @table ]);
  my $lastTrueSum = sum(@table);
  
  my $newSalary = 10000000;
  
  #print "True Sum\tTrue Avg\tNoisy Sum\tabs\t\tpercent\n";
  for (my $round = 0; $round < $numAdd; $round++) {
    # new salary is 10x the previous average
    push @table, $newSalary;
    my $newTrueCount = $#table + 1;
    my $newTrueSum = sum(@table);
    my $newNoisyCount = getNoisyCount([ @table ]);
    my $newNoisySum = getNoisySum([ @table ]);
    my $estNewSalary = $newNoisySum - $lastNoisySum;
  
    my $absError = abs($estNewSalary - $newSalary);
    my $percentError = ($absError / $newSalary) * 100;
    my $aStr = sprintf "%.2f", $absError;
    my $pStr = sprintf "%.2f", $percentError;
    my $nnsStr = sprintf "%.2f", $newNoisySum;
    my $ntsStr = sprintf "%9d", $newTrueSum;
    my $ntaStr = sprintf "%.2f", ($newTrueSum / $newTrueCount);
    #print "$ntsStr\t$ntaStr\t$nnsStr\t$aStr\t$pStr\n";
    $errStats = addStat($errStats, $round, $percentError);
    $estStats = addStat($estStats, $round, $estNewSalary);
  
    $lastTrueSum = $newTrueSum;
    $lastTrueCount = $newTrueCount;
    $lastNoisySum = $newNoisySum;
    $lastNoisyCount = $newNoisyCount;
  }
}

printStats();

my $sum = sum(@table);
my $min = min(@table);
my $max = max(@table);
my $avg = $sum / ($#table + 1);
#print "average is $avg, min is $min, max is $max\n";

sub printStats {
  my @errStats = @{ $errStats };
  my @estStats = @{ $estStats };
  print "average\tstddev\t\taverage\n";
  print "percent\t\t\testimated\n";
  print "error\t\t\tsalary\n";
  for (my $i = 0; $i <= $#errStats; $i++) {
    my @array = @{ $errStats[$i] };
    my $stddev = round(stddev(@array));
    my $avg = round(mean(@array));
    print "$avg\t$stddev\t\t";
    @array = @{ $estStats[$i] };
    $avg = round(mean(@array));
    print "($avg)\n";
  }
}

sub addStat {
my($stats, $index, $val) = @_;
  my @stats = @{ $stats };
  my @array = @{ $stats[$index] };
  push @array, $val;
  $stats[$index] = [ @array ];
  return([ @stats ]);
}

sub printTable {
my($tab) = @_;
  foreach (@{ $tab }) {
    print "$_\n";
  }
}

sub getNoisyCount {
my($tab) = @_;
  my @table = @{ $tab };

  # assume each row is a distinct user
  # also, don't need to worry about fixed noise, cause anyway we won't
  # repeat any tables
  my $noise = random_normal(1, 0, 2);
  return(round($noise + $#table + 1));
}

sub getNoisySum {
my($tab) = @_;
  my @table = @{ $tab };

  my $t1 = random_normal(1, 5, 1);
  my $t2 = random_normal(1, 6, 1);

  my @sorted = sort {$b <=> $a} @table;
  #printTable([@sorted]);

  my @group1 = ();
  my @group2 = ();
  my @rest = ();

  for (my $i = 0; $i < $#sorted; $i++) {
    if ($i <= $t1) {
      push @group1, $sorted[$i];
    }
    elsif ($i <= ($t1 + $t2)) {
      push @group2, $sorted[$i];
    }
    else {
      push @rest, $sorted[$i];
    }
  }

  #print ("--------  group 1 ---------\n");
  #foreach (@group1) { print "$_\n"; }
  #print ("--------  group 2 ---------\n");
  #foreach (@group2) { print "$_\n"; }
  #print ("--------  rest  ---------\n");
  #foreach (@rest) { print "$_\n"; }

  # get the average of group 2
  my $sum = sum(@group2);
  my $avg2 = $sum / ($#group2 + 1);
  #print "average group 2 is $avg2\n";

  # assign these to group 1
  for (my $i = 0; $i <= $#group1; $i++) {
    $group1[$i] = $avg2;
  }

  # get the average of group 2 and rest
  $sum = sum(@group2, @rest);
  my $avg = $sum / ($#group2 + $#rest + 2);
  #print "average rest is $avg\n";

  # get noise based on this average
  my $noise = random_normal(1, 0, ($avg * 2));
  #print "noise is $noise\n";

  return(sum(@group1, @group2, @rest) + $noise);
}

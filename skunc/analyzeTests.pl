use strict;
use Statistics::Basic qw(stddev mean);

my $dir = $ARGV[0];
my $fileIn = $ARGV[1];
my $fileOut = $ARGV[2];

my @freqCats = (0.00001, 0.0001, 0.001, 0.01, 0.1, 0.5, 0.7, 0.8, 0.9);  # ones
my @freqStrs = ("0.0    ", "0.00001", "0.0001 ", "0.001  ", "0.01   ", "0.1    ", "0.5    ", "0.7    ", "0.8    ", "0.9    ", "1.0    ");  # ones
my @colCats = (1, 2, 3, 5, 10, 20, 30);
my @colStrs = (" 0", " 1", " 2", " 3", " 5", "10", "20", "30");
my @userCats = (1, 2, 3, 4, 5);
my @userStrs = ("0", "1", "2", "3", "4", "5");

my @results = ();
for (my $i = 0; $i < 1000; $i++) {
  $results[$i] = 0;
}

my @hitList = ();

my $rowNum = 0;
my $lastTest = -1;
my $numHits = 0;
open(my $ofh, '>', $fileOut);
opendir(my $dh, $dir);
while (readdir $dh) {
  if (($_ =~ /$fileIn/) && ($_ =~ /csv$/)) {
    print "Opening file $_\n";
    open(my $fh, '<', $dir.$_)
      or die "Could not open file '$_' $!";
    while (my $row = <$fh>) {
      $rowNum++;
      chomp $row;
      (my $test, my $numUser, my $numCol, 
       my $mask, my $freq, my $dc1, my $dc2) = split(',', $row);
      if ($test != $lastTest) {
        # starting a new try
        if ($lastTest >= 0) {
          push @hitList, $numHits;
        }
        $lastTest = $test;
        $numHits = 0;
      }
      my $index = 0;
      my $val = getVal([ @freqCats ], $freq);
      $index += $val;
      my $val = getVal([ @colCats ], $numCol);
      $index += ($val * 10);
      my $val = getVal([ @userCats ], $numUser);
      $index += ($val * 100);
      #if (($numCol == 0) && ($numUser == 0)) {
        #print "$index: $row\n";
      #}
      $results[$index]++;
      if ($numUser) {
        $numHits++;
      }
    }
    #print "$_\n";
    close $fh;
  }
}
# ok, we have our counts and stats, now print

my $avg = mean(@hitList);
my $std = stddev(@hitList);
print $ofh "av hits $avg, std dev hits $std\n";
print $ofh "$rowNum total rows\n";

my @userTotals = (0,0,0,0,0,0,0,0);
my %tosort = ();

my $sum = 0.0;
for (my $u = 0; $u <= $#userCats; $u++) {
  for (my $c = 0; $c <= $#colCats; $c++) {
    for (my $f = 0; $f <= $#freqCats; $f++) {
      my $index = $f + ($c * 10) + ($u * 100);
      if ($results[$index] > 0) {
        $userTotals[$u] += $results[$index];
        my $frac = $results[$index] / $rowNum;
        my $str = sprintf "%3d: u %s, c %s, f %s, %7d    (%f)", 
                           $index, $userStrs[$u], $colStrs[$c], $freqStrs[$f],
                           $results[$index], $frac;
        $sum += $frac;
        $tosort{$results[$index]} = $str;
        print $ofh "$str\t($sum)\n";
      }
    }
  }
} 

print $ofh "---------------------------------------------------\n";
for (my $i = 0; $i <= $#userTotals; $i++) {
  my $val = $userTotals[$i];
  my $frac = $val / $rowNum;
  print $ofh "$i users: $val\t\t($frac)\n";
}
print $ofh "---------------------------------------------------\n";

my @sorted = sort {$b <=> $a} (keys %tosort);
foreach (@sorted) {
  print $ofh $tosort{$_}."\n";
}

closedir $dh;
close $ofh;

sub getVal {
my($array, $val) = @_;
  my $index = 0;
  foreach (@{ $array }) {
    if ($val < $_) {
      return $index;
    }
    $index++;
  }
  return $index;
}

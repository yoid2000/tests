use strict;
use Math::Random qw(random_uniform_integer random_set_seed_from_phrase);

my $vb = 0;	# verbose

my $maxCols = 60;

sub doLcTest {
my($colNames, $table, $distinctUsers, $ofh) = @_;

  random_set_seed_from_phrase("seed1");
  print $ofh "testNum,numMatchingUsers,numMatchingColumns,columnMask,attrFreq";
  
  my @colNames = @{ $colNames };
  my @table = @{ $table };
  if ($vb) { print "There are ".($#colNames + 1)." column names:\n"; }
  if ($vb) { print $ofh "There are ".($#colNames + 1)." column names:\n"; }
  foreach (@colNames) {
    if ($vb) { print $ofh "$_\n"; }
    if ($vb) { print "$_\n"; }
  }
  if ($vb) { print "There are $distinctUsers distinct users\n"; }
  if ($vb) { print $ofh "There are $distinctUsers distinct users\n"; }
  if ($vb) { print "There are ".($#table + 1)." table rows\n"; }
  if ($vb) { print $ofh "There are ".($#table + 1)." table rows\n"; }
  if ($#colNames > $maxCols) {
    if ($vb) { print "Too many columns.  Exiting.\n"; }
    if ($vb) { print $ofh "Too many columns.  Exiting.\n"; }
  }
  if (0) {
    foreach (@table) {
      if ($vb) { printRow($_, $ofh); }
    }
    flush $ofh;
    exit;
  }
  flush $ofh;
  
  # various statistics
  my $totTries = 0;
  my $numDupUidMatches = 0;
  my $nullUid = "abcdefghijkl";
  my $numTrack = 4;
  my @totNumMatchUsers = ();
  my @totNumMatchColumns = ();
  for (my $i = 0; $i <= $#colNames; $i++) { $totNumMatchColumns[$i] = 0; }
  for (my $i = 0; $i <= $numTrack; $i++) { $totNumMatchUsers[$i] = 0; }
  
  while(1) {
    $totTries++;
    # pick a random row
    my $ranRow = random_uniform_integer(1, 0, $#table);
    my $vRow = $table[$ranRow];
    my $v = $vRow->[0];
    my $vAttr = random_uniform_integer(1, 1, $#colNames);
    my $vAttrName = $colNames[$vAttr];
    my $vAttrVal = $vRow->[$vAttr];
    if ($vb) { print $ofh "---------------------------------------------\n"; }
    if ($vb) { print $ofh "Try victim $v row, attr $vAttr ($vAttrName):\n"; }
    if ($vb) { print "Try victim $v row, attr $vAttr ($vAttrName):\n"; }
    if ($vb) { printRow($vRow, $ofh); }
    # ok, now go through whole table and find attack configurations
    my %numMatches = ();
    my %matchUids = ();
    my %matchRows = ();
    my $debug = 0;
    #if (($v == 1639114) && ($vRow->[$vAttr] == 16948)) { $debug = 1; }
    my $freqTot = 0;
    for (my $rowIndex = 0; $rowIndex <= $#table; $rowIndex++) {
      my $row = $table[$rowIndex];
      # can't be an attack row if the target attribute doesn't match
      next if ($row->[$vAttr] ne $vRow->[$vAttr]);
      $freqTot++;
      if ($debug) { print $ofh "$rowIndex: $row->[$vAttr]\n"; }
      # can't be an attack row if same UID as victim
      next if ($row->[0] eq $v);
      my $match = 0;
      # now go through and see if what other columns match if any
      for (my $i = 1, my $mul = 1; $i <= $#colNames; $i++, $mul *= 2) {
        # note that this will check the target attribute column, which
        # will definitely match because we already filtered for it 
        if ($row->[$i] eq $vRow->[$i]) {
          $match += $mul;
        }
      }
      if ($debug) { print $ofh "match is $match\n"; }
      # we have one or more matching columns (including target column)
      if ($numMatches{$match} >= 1) {
        my $num = $numMatches{$match};
        # can't use attack matches if too many users
        next if ($num >= $numTrack);
        # check to see if we are already using this UID for this match
        my $alreadyUsing = 0;
        for (my $i = 0; $i < $num; $i++) {
          if ($matchUids{$match}->[$i] eq $row->[0]) {
            $numDupUidMatches++;
            $alreadyUsing = 1;
          }
        }
        if ($debug) { print $ofh "already using is $alreadyUsing\n"; }
        next if $alreadyUsing;
        if ($debug) { print $ofh "add user\n"; }
        # we have matching columns from a fresh user
        $numMatches{$match}++;
        $matchUids{$match}->[$num] = $row->[0];
        $matchRows{$match}->[$num] = $rowIndex;
      }
      else {
        if ($debug) { print $ofh "initialize\n"; }
        # initialize match
        $numMatches{$match} = 1;
        for (my $j = 0; $j < $numTrack; $j++) {
          $matchUids{$match}->[$j] = $nullUid;
        }
        $matchUids{$match}->[0] = $row->[0];
        $matchRows{$match}->[0] = $rowIndex;
        next;
      }
    }
    my $freq = $freqTot / ($#table + 1);
    if ($freq > 0.98) {
      $totTries--;
      next;
    }
    my $freqStr = sprintf "%.5f", $freq;
    foreach my $match (keys %numMatches) {
      next if ($numMatches{$match} >= $numTrack);
      my $numOnes = getNumOnes($match);
      my $numMatches = $numMatches{$match};
      $totNumMatchColumns[$numOnes] += $numMatches;
      $totNumMatchUsers[$numMatches]++;
      my $str = sprintf("%x", $match);
      print $ofh "$totTries,$numMatches,$numOnes,\"$str\",$freqStr,\"$vAttrName\",\"$vAttrVal\"\n";
      print "$totTries,$numMatches,$numOnes,\"$str\",$freqStr,\"$vAttrName\",\"$vAttrVal\"\n";
      if ($vb) { print $ofh "Got $numMatches matching users over $numOnes columns $str:\n"; }
      for (my $j = 0; $j < $numMatches; $j++) {
        my $rowIndex = $matchRows{$match}->[$j];
        if ($vb) { printRow($table[$rowIndex], $ofh); }
      }
    }
    if ($vb) { print $ofh "\nAfter $totTries tries:\n"; }
    for (my $i = 1; $i <= $#colNames; $i++) {
      my $avg = $totNumMatchColumns[$i] / $totTries;
      my $str = sprintf("%.6f", $avg);
      if ($vb) { print $ofh "    $str matches with $i columns\n"; }
    }
    if ($vb) { print $ofh "-----\n"; }
    for (my $i = 0; $i <= $numTrack; $i++) { 
      my $avg = $totNumMatchUsers[$i] / $totTries;
      my $str = sprintf("%.6f", $avg);
      if ($vb) { print $ofh "    $str matches with $i users\n"; }
    }
    flush $ofh;
  }
}

sub printRow {
my($row, $fh) = @_;
  if (!defined $fh) {
    $fh = *STDOUT;
  }
  my @row = @{ $row };
  foreach my $entry (@row) {
    print $fh "$entry, ";
  }
  print $fh "\n";
}

sub getNumOnes {
my($val) = @_;
  my $numOnes = 0;
  #my $valstr = sprintf("%x", $val);
  for (my $fac = 1; $fac < 2**$maxCols; $fac *= 2) {
    #my $facstr = sprintf("%x", $fac);
    #print "compare $valstr and $facstr\n";
    if ($fac & $val) {
      #print "                               got hit!\n";
      $numOnes++;
    }
  }
  return $numOnes;
}

sub printTable {
my($table, $fh) = @_;
  my @table = @{ $table };
  foreach (@table) {
    my @row = @{ $_ };
    foreach my $element (@row) {
      print $fh "$element, ";
    }
    print $fh "\n";
  }
}
1;


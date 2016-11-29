use strict;

#foreach my $seed (5,6,7,8) {
#  foreach my $numNames (1000, 10000, 100000, 250000) {
#    my $inFileName = "table.".$seed.".".$numNames.".txt";
#    my $outFileName = "result.".$seed.".".$numNames.".txt";
#    getInstances($inFileName, $outFileName);
#  }
#}

getInstances("searches.csv", "search_results.txt");

sub getInstances {
my($inFileName, $outFileName) = @_;
  my @uniques = ();
  my @others = ();
  my %allFreqs = ();
  my %safe = ();
  my $totalFreq = 0;
  my $numHits = 0;
  
  open(my $fh, '<', $inFileName)
    or die "Could not open file '$inFileName' $!";
  open(my $ofh, '>', $outFileName)
    or die "Could not open file '$outFileName' $!";
   
  while (my $row = <$fh>) {
    chomp $row;
    (my $name, my $freq) = split(',', $row);
    if ($freq > 2) {
      push @others, $name;
      $allFreqs{$name} = $freq;
    }
    elsif ($freq == 1) {
      push @uniques, $name;
      $allFreqs{$name} = 1;
    }
  }
  
  foreach my $uniq (@uniques) {
    print $ofh "Try $uniq\n";
    foreach my $name (@others) {
      next if ($safe{$name} == 1);
      if ($uniq =~ m/$name/) {
        print $ofh "     $name is in $uniq\n";
        # now we need to see if name is anywhere else
        my $numOther = 0;
        foreach my $try (@uniques, @others) {
          next if ($try eq $uniq);
          next if ($try eq $name);
          if ($try =~ m/$name/) {
            $numOther += $allFreqs{$try};
          }
        }
        if ($numOther == 0) {
          my $numUids = $allFreqs{$name};
          $totalFreq += $numUids;
          $numHits++;
          print $ofh "FOUND VICTIM! ($name in $uniq, $numUids others)\n";
        }
        else {
          print $ofh "          $numOther others, phew!\n";
          $safe{$name} = 1;
        }
      }
    }
  }
  my $avg = 0;
  if ($numHits) {
    $avg = $totalFreq / $numHits;
  }
  print $ofh "$totalFreq users over $numHits instances ($avg user per hit)\n";
  close $fh;
  close $ofh;
}

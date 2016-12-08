use strict;
require "../doLcTest.pl";

my $inFileName = $ARGV[0];
my $seed = $ARGV[1];
my $outFileName = $inFileName.".".$seed.".out.csv";
open(my $ofh, '>', $outFileName)
  or die "Could not open file '$outFileName' $!";
open(my $fh, '<', $inFileName)
  or die "Could not open file '$inFileName' $!";

my $movId;
my $index = 0;
my $colNames = [ "uid", "movieId", "rating", "year", "month", "day" ];
my $table;
my $numDistinct = 0;
my %users = ();
 
while (my $row = <$fh>) {
  chomp $row;
  if ($row =~ m/:/) {
    # this is a new movie ID
    ($movId, my $dontCare) = split(':', $row);
    next;
  }
  (my $uid, my $rating, my $date) = split(",", $row);
  if ($users{$uid} != 1) {
    $numDistinct++;
    $users{$uid} = 1;
  }
  (my $year, my $mon, my $day) = split("-", $date);
  $table->[$index] = [ $uid, $movId, $rating, $year, $mon, $day ];
  #print "$uid, $movId, $rating, $year, $mon, $day\n";
  $index++;
}

#printTable($table, $ofh);

close $fh;
doLcTest($colNames, $table, $numDistinct, $ofh, $seed);

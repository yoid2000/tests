use strict;
require "../../doLcTest.pl";

my $inFileName = $ARGV[0];
my $outFileName = $ARGV[1];
open(my $ofh, '>', $outFileName)
  or die "Could not open file '$outFileName' $!";
open(my $fh, '<', $inFileName)
  or die "Could not open file '$inFileName' $!";

my $index = 0;
my $colNames = [ "uid", "year", "month", "day", "hour", "min", "sec",
                 "doc", "country", "city" ];
my $table;
my $numDistinct = 0;
my %users = ();
 
while (my $row = <$fh>) {
  chomp $row;
  (my $datetime, my $doc, my $uid, my $country, my $city, my $dontCare) = 
                                                      split("\t", $row);
  if ($users{$uid} != 1) {
    $numDistinct++;
    $users{$uid} = 1;
  }
  (my $date, my $time) = split(" ", $datetime);
  (my $year, my $mon, my $day) = split("-", $date);
  (my $hour, my $min, my $sec) = split(":", $time);
  $table->[$index] = [ $uid, $year, $mon, $day, $hour, $min, $sec,
                       $doc, $country, $city ];
  #print " $uid, $year, $mon, $day, $hour, $min, $sec, $doc, $country, $city\n";
  $index++;
}

close $fh;
doLcTest($colNames, $table, $numDistinct, $ofh);

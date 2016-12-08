use strict;
require "../../doLcTest.pl";

my $inFileName = $ARGV[0];
my $outFileName = $ARGV[1];
open(my $ofh, '>', $outFileName)
  or die "Could not open file '$outFileName' $!";
open(my $fh, '<', $inFileName)
  or die "Could not open file '$inFileName' $!";

my $index = 0;
my $colNames = [ "UID","PERWT","SEX","AGE","MARST","BIRTHYR","BPL",
                 "CITIZEN","YRIMMIG","YRSUSA1","LANGUAGE","SPEAKENG",
                 "HCOVANY","HCOVPRIV","HINSEMP","HINSPUR","HINSTRI",
                 "HCOVPUB","SCHOOL","EDUC","SCHLTYPE","DEGFIELD",
                 "DEGFIELD2","EMPSTAT","LABFORCE","OCC","IND",
                 "UHRSWORK","LOOKING","AVAILBLE","INCTOT","FTOTINC",
                 "INCSS","INCRETIR","INCEARN","POVERTY","DIFFREM",
                 "DIFFCARE","DIFFSENS","VETSTAT","PWSTATE2",
                 "PWPUMA00","TRANWORK","TRANTIME" ];
my $table;
my $numDistinct = 0;
my %users = ();
 
while (my $row = <$fh>) {
  chomp $row;
  (my $uid, my @rest) = split(",", $row);
  if ($users{$uid} != 1) {
    $numDistinct++;
    $users{$uid} = 1;
  }
  #print "$uid @rest\n";
  $table->[$index] = [ $uid, @rest ];
  $index++;
}

close $fh;
doLcTest($colNames, $table, $numDistinct, $ofh);

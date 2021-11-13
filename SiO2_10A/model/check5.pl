#!/usr/bin/perl -w

use PDB;

open(IN,"sio2_pore_check4.bond");
while(<IN>) {
  chomp;
  s/^\s+//g;
  @data=split;
  if(defined($bond{$data[0]})) {
    push(@{$bond{$data[0]}},$data[1]);
  } else {
    $bond{$data[0]}=[$data[1]];
  }
  if(defined($bond{$data[1]})) {
    push(@{$bond{$data[1]}},$data[0]);
  } else {
    $bond{$data[1]}=[$data[0]];
  }
}
close(IN);
open(IN,"sio2_pore_check4.angle");
while(<IN>) {
  chomp;
  s/^\s+//g;
  @data=split;
  if(defined($angle{$data[0]})) {
    push(@{$angle{$data[0]}},$data[2]);
  } else {
    $angle{$data[0]}=[$data[2]];
  }
  if(defined($angle{$data[2]})) {
    push(@{$angle{$data[2]}},$data[0]);
  } else {
    $angle{$data[2]}=[$data[0]];
  }
}
close(IN);

$a=PDB->new();
$a->read(fname => "sio2_pore_check4.pdb");
open(LOG,">check5.log");
print LOG "Atoms that have incorrect numbers of bonds are listed.\n";
for($i=0;$i<$a->{natom};$i++) {
  $atnam=$a->{atnam}->[$i];
  $resnam=$a->{resnam}->[$i];
  $resnum=$a->{resnum}->[$i];
  $chain=$a->{chain}->[$i];
  if(!defined($bond{$i+1})) {
    $nbond=0;
  } else {
    $nbond=@{$bond{$i+1}};
  }
  if($atnam =~ /^SI/ && $nbond != 4) {
    printf(LOG "%d %s %d %s %s: nbond=%d\n",$i+1,$resnam,$resnum,$chain,$atnam,$nbond);
  } elsif($atnam =~ /^O/ && $nbond != 2) {
    printf(LOG "%d %s %d %s %s: nbond=%d\n",$i+1,$resnam,$resnum,$chain,$atnam,$nbond);
  } elsif($atnam =~ /^H/ && $nbond != 1) {
    printf(LOG "%d %s %d %s %s: nbond=%d\n",$i+1,$resnam,$resnum,$chain,$atnam,$nbond);
  }
}
print LOG "Si Atoms that are not connected to another Si are listed.\n";
for($i=0;$i<$a->{natom};$i++) {
  $atnam=$a->{atnam}->[$i];
  next if(!($atnam =~ /^SI/));
  $resnam=$a->{resnam}->[$i];
  $resnum=$a->{resnum}->[$i];
  $chain=$a->{chain}->[$i];
  if(!defined($angle{$i+1})) {
    $nangle=0;
  } else {
    $nangle=@{$angle{$i+1}};
  }
  $ok=0;
  for($jj=0;$jj<$nangle;$jj++) {
    $j=$angle{$i+1}->[$jj]-1;
    if($a->{atnam}->[$j]=~/^SI/) {
      $ok=1;
      last;
    }
  }
  if(!$ok) {
    printf(LOG "%d %s %d %s %s\n",$i+1,$resnam,$resnum,$chain,$atnam);
  }
}
close(LOG);

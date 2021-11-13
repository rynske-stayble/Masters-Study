#!/usr/bin/perl -w

use PDB;

open(IN,"sio2_pore.bond");
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

$a=PDB->new();
$a->read(fname => "sio2_pore.pdb");
@list=();
open(LOG,">check1.log");
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
    printf(LOG "%d %s %d %s %s is not satisfied (nbond=%d) and is deleted.\n",$i+1,$resnam,$resnum,$chain,$atnam,$nbond);
    next;
  }
  push(@list,$i);
}
close(LOG);
for($i=0;$i<@list;$i++) {
  $a->{atnum}->[$list[$i]]=$i+1;
}
$a->write(fname => "sio2_pore_check1.pdb", selection => \@list);

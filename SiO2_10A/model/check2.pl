#!/usr/bin/perl -w

use PDB;

open(IN,"sio2_pore_check1.angle");
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
$a->read(fname => "sio2_pore_check1.pdb");
@list=();
open(LOG,">check2.log");
for($i=0;$i<$a->{natom};$i++) {
  $atnam=$a->{atnam}->[$i];
  $resnam=$a->{resnam}->[$i];
  $resnum=$a->{resnum}->[$i];
  $chain=$a->{chain}->[$i];
  if(!defined($angle{$i+1})) {
    $nangle=0;
  } else {
    $nangle=@{$angle{$i+1}};
  }
  if($atnam =~ /^SI/) {
    $ok=0;
    for($jj=0;$jj<$nangle;$jj++) {
      $j=$angle{$i+1}->[$jj]-1;
      if($a->{atnam}->[$j]=~/^SI/) {
        $ok=1;
        last;
      }
    }
    if(!$ok) {
      printf(LOG "%d %s %d %s %s is not connected to another Si and is deleted.\n",$i+1,$resnam,$resnum,$chain,$atnam);
      next;
    }
  }
  push(@list,$i);
}
close(LOG);
for($i=0;$i<@list;$i++) {
  $a->{atnum}->[$list[$i]]=$i+1;
}
$a->write(fname => "sio2_pore_check2.pdb", selection => \@list);

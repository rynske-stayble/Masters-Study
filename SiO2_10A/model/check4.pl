#!/usr/bin/perl -w

use PDB;

open(IN,"sio2_pore_check3.bond");
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
open(IN,"sio2_pore_check3.angle");
while(<IN>) {
  chomp;
  s/^\s+//g;
  @data=split;
  $key=$data[0].":".$data[1];
  if(defined($angle{$key})) {
    push(@{$angle{$key}},$data[2]);
  } else {
    $angle{$key}=[$data[2]];
  }
  $key=$data[2].":".$data[1];
  if(defined($angle{$key})) {
    push(@{$angle{$key}},$data[0]);
  } else {
    $angle{$key}=[$data[0]];
  }
}
close(IN);

$a=PDB->new();
$a->read(fname => "sio2_pore_check3.pdb");
$b=PDB->new();
for($i=0;$i<$a->{natom};$i++) {
  $c=$a->copy(selection => [$i]);
  $atnam=$a->{atnam}->[$i];
  $resnam=$a->{resnam}->[$i];
  $resnum=$a->{resnum}->[$i];
  $chain=$a->{chain}->[$i];
  $alt=$a->{alt}->[$i];
  $insert=$a->{insert}->[$i];
  $segname=$a->{segname}->[$i];
  if(!defined($bond{$i+1})) {
    printf(STDERR "%d %s %d %s %s is isolated.\n",$i+1,$resnam,$resnum,$chain,$atnam);
    die "Aborted.\n";
  }
  $nbond=@{$bond{$i+1}};
  if($atnam =~ /^O/ && $nbond == 1) {
    $b->append($c);
    $j=$bond{$i+1}->[0]-1;
    $key=sprintf("%d:%d",$i+1,$j+1);
    if(!defined($angle{$key})) {
      die "Angle for $key is not defined.\n";
    }
    $k=$angle{$key}->[0]-1;
    $x2[0]=$a->{x}->[$i];
    $x2[1]=$a->{y}->[$i];
    $x2[2]=$a->{z}->[$i];
    $x1[0]=$a->{x}->[$j];
    $x1[1]=$a->{y}->[$j];
    $x1[2]=$a->{z}->[$j];
    $x0[0]=$a->{x}->[$k];
    $x0[1]=$a->{y}->[$k];
    $x0[2]=$a->{z}->[$k];
    @x3=&PDB::zmat_build(\@x0,\@x1,\@x2,0.945,115.9,180.0);
    $d=PDB->new();
    $atnamH=$atnam;
    $atnamH=~s/^O/H/g;
    $d->add(atnam => $atnamH, resnam => $resnam, resnum => $resnum, chain => $chain, alt => $alt, insert => $insert, segname => $segname);
    $d->{x}->[0]=$x3[0];
    $d->{y}->[0]=$x3[1];
    $d->{z}->[0]=$x3[2];
    $b->append($d);
  } elsif($atnam =~ /^O/ && $nbond == 2) {
    $b->append($c);
  } elsif($atnam =~ /^SI/ && $nbond != 4) {
    printf(STDERR "%d %s %d %s %s is not satisfied (nbond=%d).\n",$i+1,$resnam,$resnum,$chain,$atnam,$nbond);
    die "Aborted.\n";
  } elsif($atnam =~ /^SI/ && $nbond == 4) {
    $b->append($c);
  } elsif($atnam =~ /^H/ && $nbond == 1) {
    $b->append($c);
  } elsif($atnam =~ /^H/) {
    printf(STDERR "%d %s %d %s %s has more than one bond (nbond=%d).\n",$i+1,$resnam,$resnum,$chain,$atnam,$nbond);
    die "Aborted.\n";
  } else {
    printf(STDERR "%d %s %d %s %s has unknown atom type (nbond=%d).\n",$i+1,$resnam,$resnum,$chain,$atnam,$nbond);
    die "Aborted.\n";
  }
}
for($i=0;$i<$b->{natom};$i++) {
  $b->{atnum}->[$i]=$i+1;
}
$b->write(fname => "sio2_pore_check4.pdb");

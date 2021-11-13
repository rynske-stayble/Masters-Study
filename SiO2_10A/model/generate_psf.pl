#!/usr/bin/perl -w

use PDB;

if(@ARGV != 1) {
  die "Usage: generate_psf.pl pdb_in\n";
}

$pdb_in=$ARGV[0];
$bond_in=$ARGV[0];
if($bond_in =~ /\.pdb$/) {
  $bond_in=~s/\.pdb/.bond/;
} else {
  $bond_in.=".bond";
}
$angle_in=$ARGV[0];
if($angle_in =~ /\.pdb$/) {
  $angle_in=~s/\.pdb/.angle/;
} else {
  $angle_in.=".angle";
}
$psf_out=$ARGV[0];
if($psf_out =~ /\.pdb$/) {
  $psf_out=~s/\.pdb/.psf/;
} else {
  $psf_out.=".psf";
}
open(IN,$bond_in);
@bond_list=();
while(<IN>) {
  chomp;
  s/^\s+//g;
  @data=split;
  push(@bond_list,[@data]);
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
open(IN,$angle_in);
@angle_list=();
while(<IN>) {
  chomp;
  s/^\s+//g;
  @data=split;
  push(@angle_list,[@data]);
}
close(IN);

$a=PDB->new();
$a->read(fname => $pdb_in);
open(OUT,">$psf_out");
printf(OUT "PSF\n\n");
printf(OUT "%8d !NTITLE\n",1);
printf(OUT " REMARKS PSF file for %s\n\n",$pdb_in);
printf(OUT "%8d !NATOM\n",$a->{natom});

for($i=0;$i<$a->{natom};$i++) {
  $atnam=$a->{atnam}->[$i];
  $segname=$a->{segname}->[$i];
  $resnum=$a->{resnum}->[$i];
  $resnam=$a->{resnam}->[$i];
  $atnam=$a->{atnam}->[$i];
  if($atnam =~ /^SI/) {
    $type[$i]="SISLC";
    $charge[$i]=1.1;
    $mass[$i]=28.0855;
  } elsif($atnam =~ /^O/) {
    $type[$i]="OSLC";
    $charge[$i]=-0.55;
    $mass[$i]=15.9994;
    foreach $j (@{$bond{$i+1}}) {
      if($a->{atnam}->[$j-1] =~ /^H/) {
        $type[$i]="OHSLC";
        $charge[$i]=-0.675;
        last;
      }
    }
  } elsif($atnam =~ /^H/) {
    $type[$i]="HSLC";
    $charge[$i]=0.4;
    $mass[$i]=1.00800;
  }
  printf(OUT "%8d %-4s %4d %-4s %-4s %-4s %9.6f %9.5f %1d\n",$i+1,$segname,$resnum,$resnam,$atnam,$type[$i],$charge[$i],$mass[$i],0);
}
printf(OUT "\n");

$nbond=@bond_list;
printf(OUT "%8d !NBOND: bonds\n",$nbond);
for($i=0;$i<$nbond;$i++) {
  printf(OUT " %7d %7d",@{$bond_list[$i]});
  if(($i+1) % 4 == 0) {
    printf(OUT "\n");
  }
}
if($nbond % 4 != 0) {
  printf(OUT "\n");
}
printf(OUT "\n");

$nangle=@angle_list;
printf(OUT "%8d !NTHETA: angles\n",$nangle);
for($i=0;$i<$nangle;$i++) {
  printf(OUT " %7d %7d %7d",@{$angle_list[$i]});
  if(($i+1) % 3 == 0) {
    printf(OUT "\n");
  }
}
if($nbond % 3 != 0) {
  printf(OUT "\n");
}
printf(OUT "\n");

printf(OUT "%8d !NPHI: dihedrals\n\n\n",0);
printf(OUT "%8d !NIMPHI: impropers\n\n\n",0);
printf(OUT "%8d !NDON: donors\n\n\n",0);
printf(OUT "%8d !NACC: acceptors\n\n\n",0);
printf(OUT "%8d !NNB\n\n",0);

for($i=0;$i<$a->{natom};$i++) {
  printf(OUT " %7d",0);
  if(($i+1) % 8 == 0) {
    printf(OUT "\n");
  }
}
if($a->{natom} % 8 != 0) {
  printf(OUT "\n");
}
printf(OUT "\n\n");

printf(OUT " %7d %7d !NGRP\n",1,0);
printf(OUT " %7d %7d %7d\n\n",0,0,0);

close(OUT);

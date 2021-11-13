#!/usr/bin/perl -w

use PDB;

open(IN,"../model/sio2_pore_check4.bond");
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
$a->read(fname => "../model/sio2_pore_check4.pdb");
%si_list=();
for($i=0;$i<$a->{natom};$i++) {
  $atnam=$a->{atnam}->[$i];
  if(!defined($bond{$i+1})) {
    $nbond=0;
  } else {
    $nbond=@{$bond{$i+1}};
  }
  if($atnam =~ /^O/ and $nbond == 2) {
    $h=-1;
    $si=-1;
    foreach $j (@{$bond{$i+1}}) {
      $atnam2=$a->{atnam}->[$j-1];
      if($atnam2 =~ /^H/) {
        $h=$j-1;
      }
      if($atnam2 =~ /^SI/) {
        $si=$j-1;
      }
    }
    if($h >= 0 && $si >= 0) {
      if(defined($si_list{$si})) {
        push(@{$si_list{$si}},$h);
      } else {
        $si_list{$si}=[$h];
      }
    }
  }
}
open(LOG,">deprotonate.log");
print(LOG "First hydrogen is replaced by sodium ion.\n");
@sod=();
foreach $i (sort {$a <=> $b} keys(%si_list)) {
  printf(LOG "%3s-%3d.%1s\@%-4s(%4d):",$a->{resnam}->[$i],$a->{resnum}->[$i],$a->{chain}->[$i],$a->{atnam}->[$i],$i+1);
  push(@sod,$si_list{$i}->[0]);
  foreach $j (@{$si_list{$i}}) {
    printf(LOG " %3s-%3d.%1s\@%-4s(%4d)",$a->{resnam}->[$j],$a->{resnum}->[$j],$a->{chain}->[$j],$a->{atnam}->[$j],$j+1);
  }
  printf(LOG "\n");
}
$resnum=1;
$d_SOD_O=0.5*(3.47+3.17);	# from Emami et al. (2014), Table 3.
@sod_new=();
foreach $i (@sod) {
  if(rand() <= 0.248) {
    $a->{atnam}->[$i]="SOD";
    $a->{resnam}->[$i]="SOD";
    $a->{resnum}->[$i]=$resnum++;
    $a->{chain}->[$i]="I";
    $a->{segname}->[$i]="ION";
    push(@sod_new,$i);
  }
}
@list=();
for($i=0;$i<$a->{natom};$i++) {
  if($a->{resnam}->[$i] ne "SOD") {
    push(@list,$i);
  }
}
$j=1;
foreach $i (@list) {
  $a->{atnum}->[$i]=$j++;
}
foreach $i (@sod_new) {
  $a->{atnum}->[$i]=$j++;
}
open(OUT,">deprotonated.pdb");
$a->write(fh => \*OUT, selection => \@list);
$a->write(fh => \*OUT, selection => \@sod_new);
close(OUT);
#!/usr/bin/perl -w

@files=<msd_???.csv>;

for($i=0;$i<@files;$i++) {
  open(IN,$files[$i]);
  $j=0;
  while(<IN>) {
    chomp;
    @data=split(",",$_);
    if($i == 0) {
      $t[$j]=$data[0];
      $lateral[$j]=$data[1]+$data[2];
      $axial[$j]=$data[3];
    } else {
      $lateral[$j]+=$data[1]+$data[2];
      $axial[$j]+=$data[3];
    }
    $j++;
  }
  close(IN);
}
open(OUT,">msd_ave.csv");
for($i=0;$i<@t;$i++) {
  printf(OUT "%f,%f,%f\n",$t[$i],$lateral[$i],$axial[$i]);
}
close(OUT);

  

#!/usr/bin/perl -w

@files=<com_???.out>;
$dt=0.001;	# in ns

foreach $file (@files) {
  $file=~/com_(\d+)/;
  $fout="msd_".$1.".csv";

  open(IN,$file);
  $i=0;
  while(<IN>) {
    chomp;
    s/^\s+//g;
    @data=split;
    $x[$i]=$data[1];
    $y[$i]=$data[2];
    $z[$i]=$data[3];
    $i++;
  }
  close(IN);
  $ndata=$i;

  open(OUT,">$fout");
  for($i=0;$i<$ndata;$i++) {
    $dx2[$i]=0;
    $dy2[$i]=0;
    $dz2[$i]=0;
    next if($i == 0);
    for($j=0;$j<$ndata-$i;$j++) {
      $dx2[$i]+=($x[$j+$i]-$x[$j])**2;
      $dy2[$i]+=($y[$j+$i]-$y[$j])**2;
      $dz2[$i]+=($z[$j+$i]-$z[$j])**2;
    }
    $dx2[$i]/=$ndata-$i;
    $dy2[$i]/=$ndata-$i;
    $dz2[$i]/=$ndata-$i;
  }
  for($i=0;$i<$ndata;$i++) {
    printf(OUT "%f,%f,%f,%f\n",$i*$dt,$dx2[$i],$dy2[$i],$dz2[$i]);
  }
  close(OUT);
}

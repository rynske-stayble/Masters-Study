#!/usr/bin/perl -w

use PDB;
use POSIX;

if(@ARGV != 1) {
  die "Usage: find_bond2.pl pdb.in\n";
}
$pdb_in=$ARGV[0];
$bond_out=$ARGV[0];
if($bond_out =~ /\.pdb$/) {
  $bond_out=~s/\.pdb/.bond/;
} else {
  $bond_out.=".bond";
}
$angle_out=$ARGV[0];
if($angle_out =~ /\.pdb$/) {
  $angle_out=~s/\.pdb/.angle/;
} else {
  $angle_out.=".angle";
}
$dihedral_out=$ARGV[0];
if($dihedral_out =~ /\.pdb$/) {
  $dihedral_out=~s/\.pdb/.dihedral/;
} else {
  $dihedral_out.=".dihedral";
}

$cut_Si_O=2.2;
$cut_O_H=1.2;
$ndiv=10;

$a=PDB->new();
$a->read(fname => $pdb_in);
$xmin=99999.0;
$ymin=99999.0;
$zmin=99999.0;
$xmax=-99999.0;
$ymax=-99999.0;
$zmax=-99999.0;
for($i=0;$i<$a->{natom};$i++) {
  $xmin=$a->{x}->[$i] if($xmin > $a->{x}->[$i]);
  $ymin=$a->{y}->[$i] if($ymin > $a->{y}->[$i]);
  $zmin=$a->{z}->[$i] if($zmin > $a->{z}->[$i]);
  $xmax=$a->{x}->[$i] if($xmax < $a->{x}->[$i]);
  $ymax=$a->{y}->[$i] if($ymax < $a->{y}->[$i]);
  $zmax=$a->{z}->[$i] if($zmax < $a->{z}->[$i]);
}
$xmin=floor($xmin);
$xmax=ceil($xmax+0.1);
printf("x [%f,%f]\n",$xmin,$xmax);
$xbin=($xmax-$xmin)/$ndiv;
$ymin=floor($ymin);
$ymax=ceil($ymax+0.1);
printf("y [%f,%f]\n",$ymin,$ymax);
$ybin=($ymax-$ymin)/$ndiv;
$zmin=floor($zmin);
$zmax=ceil($zmax+0.1);
printf("z [%f,%f]\n",$zmin,$zmax);
$zbin=($zmax-$zmin)/$ndiv;
for($i=0;$i<$ndiv*$ndiv*$ndiv;$i++) {
  $nlist[$i]=0;
}
for($i=0;$i<$a->{natom};$i++) {
  $ix=floor(($a->{x}->[$i]-$xmin)/$xbin);
  $iy=floor(($a->{y}->[$i]-$ymin)/$ybin);
  $iz=floor(($a->{z}->[$i]-$zmin)/$zbin);
  $index=$ix*$ndiv*$ndiv+$iy*$ndiv+$iz;
  $list[$index][$nlist[$index]]=$i;
  $nlist[$index]++;
}

for($i=0;$i<$a->{natom};$i++) {
  $atnam=$a->{atnam}->[$i];
  if($atnam =~ /^SI/) {
    $type[$i]=14;
  } elsif($atnam =~ /^O/) {
    $type[$i]=8;
  } elsif($atnam =~ /^H/) {
    $type[$i]=1;
  } elsif($atnam =~ /^SOD/) {
    $type[$i]=11;
  } else {
    die "Unknown atom type at $i ($atnam).\n";
  }
}

open(BOND,">$bond_out");
for($ix=0;$ix<$ndiv;$ix++) {
  for($iy=0;$iy<$ndiv;$iy++) {
    for($iz=0;$iz<$ndiv;$iz++) {
      $index=$ix*$ndiv*$ndiv+$iy*$ndiv+$iz;
      for($ii=0;$ii<$nlist[$index];$ii++) {
        $i=$list[$index][$ii];
        for($jx=-1;$jx<=1;$jx++) {
          next if($ix+$jx < 0 || $ix+$jx >= $ndiv);
          for($jy=-1;$jy<=1;$jy++) {
            next if($iy+$jy < 0 || $iy+$jy >= $ndiv);
            for($jz=-1;$jz<=1;$jz++) {
              next if($iz+$jz < 0 || $iz+$jz >= $ndiv);
              $neighbor=($ix+$jx)*$ndiv*$ndiv+($iy+$jy)*$ndiv+($iz+$jz);
              for($jj=0;$jj<$nlist[$neighbor];$jj++) {
                $j=$list[$neighbor][$jj];
                next if($i >= $j);
                $d=$a->distance($i,$j);
                if(($type[$i] ==  1 && $type[$j] ==  8 && $d < $cut_O_H)  ||
                   ($type[$i] ==  8 && $type[$j] ==  1 && $d < $cut_O_H)  ||
                   ($type[$i] == 14 && $type[$j] ==  8 && $d < $cut_Si_O) ||
                   ($type[$i] ==  8 && $type[$j] == 14 && $d < $cut_Si_O)) {
                  @data=($i+1,$j+1);
                  printf(BOND "%d %d\n",@data);
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
              }
            }
          }
        }
      }
    }
  }
}
close(BOND);

open(ANGL,">$angle_out");
open(DIHE,">$dihedral_out");
@atom_list=sort {$a <=> $b} (keys(%bond));
foreach $i (@atom_list) {
  @bond_list=@{$bond{$i}};
  foreach $j (@bond_list) {
    @bond_list2=@{$bond{$j}};
    foreach $k (@bond_list2) {
      if($i < $k) {
        printf(ANGL "%d %d %d\n",$i,$j,$k);
        @bond_list3=@{$bond{$k}};
        foreach $l (@bond_list3) {
          if($l != $j) {
            printf(DIHE "%d %d %d %d\n",$i,$j,$k,$l);
          }
        }
      }
    }
  }
}
close(ANGL);
close(DIHE);

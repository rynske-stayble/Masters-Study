#!/bin/tcsh
set prev=""
set i=1
while ( $i <= 20 )
  set dir=`printf "%03d" $i`
  cd $dir
  if ($prev == "" ) then
    qsub run.sh > qsub.out
  else
    set dep=`cat $prev`
    qsub "-W depend=afterany:"$dep run.sh > qsub.out
  endif
  set prev="../"$dir"/qsub.out"
  @ i ++
  cd ..
end

set psf ../../../model/sio2_pore_lig_sol.psf
set nrun 10

for { set i 1 } { $i <= $nrun } { incr i } {
  set fname [format "../../%03d/md.dcd" $i]
  set fout [format "com_%03d.out" $i]
  set fp [open $fout w]
# mol delete top
  set molid [mol new $psf type psf]
  mol addfile $fname type dcd waitfor -1 molid $molid
# mol load psf $psf dcd $fname
# mol list
  set num [molinfo top get numframes]
  set sel [atomselect top "segname LIG"]

  for { set j 0 } { $j <  $num } { incr j } {
    $sel frame $j
    set com [measure center $sel weight mass]
    set iframe [expr $j + 1]
    puts $fp "$iframe $com"
  }
  close $fp
  mol delete $molid
}

exit

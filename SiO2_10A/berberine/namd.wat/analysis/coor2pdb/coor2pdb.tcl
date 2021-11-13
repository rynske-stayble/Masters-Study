for { set i 1 } { $i <= 10 } { incr i } {
  mol delete top
  mol new ../../../model/sio2_pore_lig_sol.psf
  set fname [format "../../%03d/md.coor" $i]
  set fout  [format "md_%03d.pdb" $i]
  mol addfile $fname

  set sel [atomselect top all]
  $sel writepdb $fout
}
quit

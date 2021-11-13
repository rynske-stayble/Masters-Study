set radius 10
set r2 [expr $radius*$radius]
mol delete all
mol new sio2.pdb
set pore [atomselect top "(name SI1 or name SI2 or name SI3 or name SI4) and x*x+y*y < $r2"]
#set pore [atomselect top "x*x+y*y < $r2"]
set seglist [$pore get segid]
set reslist [$pore get resid]
set atlist [$pore get name]
mol delete all
package require psfgen
resetpsf
readpsf sio2.psf
coordpdb sio2.pdb
foreach segid $seglist resid $reslist atnam $atlist {
  delatom $segid $resid $atnam
}
writepdb sio2_pore.pdb
writepsf sio2_pore.psf
exit

mol delete all
mol new sio2_pore_lig.pdb
set sel [atomselect top all]
set box_size [measure minmax $sel]
set xmin [expr [lindex [lindex $box_size 0] 0] - 10.0]
set xmax [expr [lindex [lindex $box_size 1] 0] + 10.0]
set ymin [expr [lindex [lindex $box_size 0] 1] - 10.0]
set ymax [expr [lindex [lindex $box_size 1] 1] + 10.0]
set zmin [expr [lindex [lindex $box_size 0] 2] - 10.0]
set zmax [expr [lindex [lindex $box_size 1] 2] + 10.0]
set box_size [list [list $xmin $ymin $zmin] [list $xmax $ymax $zmax]]
$sel delete
mol delete all
package require solvate
solvate sio2_pore_lig.psf sio2_pore_lig.pdb -o sio2_pore_lig_sol -b 1.5 -minmax $box_size
quit

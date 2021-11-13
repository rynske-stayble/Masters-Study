mol new sio2_pore_lig_sol.pdb
set all [atomselect top all]
$all set beta 0
set sel [atomselect top "not water and not hydrogen"]
$sel set beta 1
$all writepdb sio2_pore_lig_sol.fix_all
$sel delete
$all set beta 0
set sel [atomselect top "name SI1 SI2 SI3 SI4"]
$sel set beta 1
$all writepdb sio2_pore_lig_sol.fix_SI
$sel delete
exit

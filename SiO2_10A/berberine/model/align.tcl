mol load psf ligandrm_mod.psf pdb ../charmm-gui/ligandrm.pdb

# align ligand
set lig [atomselect top all]
$lig move [transaxis y 90.0 deg]
$lig writepdb lig_align.pdb
$lig delete

exit

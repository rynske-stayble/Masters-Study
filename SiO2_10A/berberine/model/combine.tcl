package require psfgen

resetpsf
readpsf ../../deprotonate/deprotonated.psf
coordpdb ../../deprotonate/deprotonated.pdb
readpsf ligandrm_mod.psf
coordpdb lig_align.pdb
readpsf cla.psf
coordpdb cla.pdb

writepsf sio2_pore_lig.psf
writepdb sio2_pore_lig.pdb

exit

#!/bin/tcsh
setenv PERL5LIB /home/apps/PDB
/home/apps/vmd/1.9.3/bin/vmd -dispdev text -e build.tcl
/home/apps/vmd/1.9.3/bin/vmd -dispdev text -e create_pore.tcl
./find_bond2.pl sio2_pore.pdb
./check1.pl
./find_bond2.pl sio2_pore_check1.pdb
./check2.pl
./find_bond2.pl sio2_pore_check2.pdb
./check3.pl
./find_bond2.pl sio2_pore_check3.pdb
./check4.pl
./find_bond2.pl sio2_pore_check4.pdb
./check5.pl
./generate_psf.pl sio2_pore_check4.pdb

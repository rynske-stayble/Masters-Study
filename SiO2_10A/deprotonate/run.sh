#!/bin/tcsh
setenv PERL5LIB /home/apps/PDB
./deprotonate.pl
./find_bond2.pl deprotonated.pdb
./generate_psf.pl deprotonated.pdb

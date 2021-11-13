#!/bin/tcsh
/home/apps/vmd/1.9.3/bin/vmd -dispdev text -e align.tcl
/home/apps/vmd/1.9.3/bin/vmd -dispdev text -e combine.tcl
/home/apps/vmd/1.9.3/bin/vmd -dispdev text -e solvate.tcl
/home/apps/vmd/1.9.3/bin/vmd -dispdev text -e gen_rest.tcl

#!/usr/bin/perl -w

# Common settings
$psf="../../model/sio2_pore_lig_sol.psf";
$pdb="../../model/sio2_pore_lig_sol.pdb";
$fix_ref="../../model/sio2_pore_lig_sol.fix_all";
$rest_ref1="../../model/sio2_pore_lig_sol.fix_all";
$rest_ref2="../../model/sio2_pore_lig_sol.fix_SI";
$systype="soluble";	# soluble or membrane
$rigid_bonds="all";	# water or all
$temp=300.00;
$logfreq=500;
$trafreq=5000;
$nstep=250000;
$nstep_eq4=1250000;
$nstep_min=1000;
$a=59.912;
$b=58.796;
$c=186.482;
$xori=0.0;
$yori=0.0;
$zori=0.0;
$fftx=64;
$ffty=64;
$fftz=192;
$flexible_cell="no";
$ef="no";
$Ez=0.0;
$exclude="scaled1-4";	# 1-3 or scaled1-4
$taup=100;		# in fs

$inp="
structure            \$psf
coordinates          \$pdb
parameters          ../../../toppar/par_all36m_prot.prm
parameters          ../../../toppar/par_all36_na.prm
parameters          ../../../toppar/par_all36_carb.prm
parameters          ../../../toppar/par_all36_lipid.prm
parameters          ../../../toppar/par_all36_cgenff.prm
parameters          ../../../toppar/par_interface.prm
parameters          ../../../toppar/toppar_water_ions_namd.str
parameters          ../../../toppar/sio2.par
parameters          ../../charmm-gui/lig/lig.prm
paraTypeCharmm       on
if { \$inname != \"none\" } {
binvelocities        \$inname.vel
bincoordinates       \$inname.coor
}

outputname           \$outname
restartfreq          \$trafreq
DCDfreq              \$trafreq

outputEnergies       \$logfreq

timestep             2.0
stepspercycle        20

cutoff               12.0
switching            on
vdwForceSwitching    on
switchdist           10.0
pairlistdist         16.0
pairlistsPerCycle    2

exclude              \$exclude
if { \$inname == \"none\" } {
temperature          \$temp
}
1-4scaling           1.0
rigidBonds           \$rigid_bonds

PME                  on
PMEInterpOrder       6
PMEGridSizeX         \$fftx
PMEGridSizeY         \$ffty
PMEGridSizeZ         \$fftz

fullElectFrequency   1
nonbondedFreq        1

if { \$nstep_nvt > 0 || \$nstep_npt > 0 } {
langevin             on
langevinTemp         \$temp
langevinDamping      1.0
langevinHydrogen     off
}

if { \$nstep_anneal > 0 } {
reassignFreq         500
set tincr  [expr double(\$temp) * 500.0 / double(\$nstep_anneal) ]
reassignTemp         \$tincr
reassignIncr         \$tincr
reassignHold         \$temp
}

if { \$inname == \"none\" } {
cellBasisVector1     \$a 0.0 0.0
cellBasisVector2     0.0 \$b 0.0
cellBasisVector3     0.0 0.0 \$c
cellOrigin           \$xori \$yori \$zori
} else {
extendedSystem       \$inname.xsc
}
xstfreq              \$trafreq
wrapWater            on
wrapAll              on
wrapNearest          off

useGroupPressure     yes
useFlexibleCell      \$flexible_cell
if { \$systype == \"membrane\" } {
useConstantRatio     yes
} else {
useConstantRatio     no
}

if { \$nstep_npt > 0 } {
BerendsenPressure    on
BerendsenPressureTarget 1.01325
BerendsenPressureCompressibility 4.57E-5
BerendsenPressureRelaxationTime \$taup
BerendsenPressureFreq 1
}

if { \$ref != \"none\" } {
constraints          on
consref              \$ref
conskfile            \$ref
conskcol             B
constraintScaling    \$posres_k
}

if { \$fix_ref != \"none\" } {
fixedAtoms           on
fixedAtomsFile       \$fix_ref
fixedAtomsCol        B
fixedAtomsForces     on
}

if {\$ef == \"yes\" } {
eFieldOn             yes
eField               0.0 0.0 \$Ez
}

if { \$tcl_scr != \"none\" } {
tclForces           on
tclForcesScript     \$tcl_scr
}

# Minimization
if { \$nstep_min > 0 } {
minimization         on
minimize             \$nstep_min
}

# Annealing
if { \$nstep_anneal > 0 } {
run                  \$nstep_anneal
}

# Constant volume simulation
if { \$nstep_nvt > 0 } {
run                  \$nstep_nvt
}

# Constant pressure simulation
if { \$nstep_npt > 0 } {
run                  \$nstep_npt
}
";

$vars="
set systype $systype
set temp $temp
set rigid_bonds $rigid_bonds
set logfreq $logfreq
set trafreq $trafreq
set a $a
set b $b
set c $c
set xori $xori
set yori $yori
set zori $zori
set fftx $fftx
set ffty $ffty
set fftz $fftz
set flexible_cell $flexible_cell
set ef $ef
set Ez $Ez
set exclude $exclude
";

$shell=
"#!/bin/bash
#PBS -l nodes=1:ppn=24:gpu:groupC

cd \$PBS_O_WORKDIR
export LD_LIBRARY_PATH /usr/local/cuda-9.1/lib64:\$LD_LIBRARY_PATH

NAMD_DIR=/home/apps/NAMD_Git-2019-11-13_Linux-x86_64-multicore-CUDA

\$NAMD_DIR/namd2 +p24 +setcpuaffinity +devices 0 min1.inp > min1.log
\$NAMD_DIR/namd2 +p24 +setcpuaffinity +devices 0 min2.inp > min2.log
\$NAMD_DIR/namd2 +p24 +setcpuaffinity +devices 0 eq1.inp > eq1.log
\$NAMD_DIR/namd2 +p24 +setcpuaffinity +devices 0 eq2.inp > eq2.log
\$NAMD_DIR/namd2 +p24 +setcpuaffinity +devices 0 eq3.inp > eq3.log
\$NAMD_DIR/namd2 +p24 +setcpuaffinity +devices 0 eq4.inp > eq4.log
";

mkdir("equil",0755) unless(-e "equil");
chdir("equil");

open(OUT,">min1.inp");
print OUT <<END;
set psf $psf
set pdb $pdb
set outname min1
set inname none
set ref none
set posres_k 0.0
set fix_ref none
set nstep_min $nstep_min
set nstep_anneal 0
set nstep_nvt 0
set nstep_npt 0
set tcl_scr none
set rigid_bonds water
set taup $taup
END
print OUT $vars;
print OUT $inp;
close(OUT);
#
open(OUT,">min2.inp");
print OUT <<END;
set psf $psf
set pdb $pdb
set outname min2
set inname min1
set ref none
set posres_k 0.0
set fix_ref $fix_ref
set nstep_min $nstep_min
set nstep_anneal 0
set nstep_nvt 0
set nstep_npt 0
set tcl_scr none
set rigid_bonds all
set taup $taup
END
print OUT $vars;
print OUT $inp;
close(OUT);
open(OUT,">run.sh");
print OUT $shell;
close(OUT);
#
open(OUT,">eq1.inp");
print OUT <<END;
set psf $psf
set pdb $pdb
set outname eq1
set inname min2
set ref none
set posres_k 0.0
set fix_ref $fix_ref
set nstep_min 0
set nstep_anneal 0
set nstep_nvt $nstep
set nstep_npt 0
set tcl_scr none
set rigid_bonds all
set taup $taup
END
print OUT $vars;
print OUT $inp;
close(OUT);
#
open(OUT,">eq2.inp");
print OUT <<END;
set psf $psf
set pdb $pdb
set outname eq2
set inname eq1
set ref $rest_ref1
set posres_k 10.0
set fix_ref none
set nstep_min 0
set nstep_anneal 0
set nstep_nvt $nstep
set nstep_npt 0
set tcl_scr none
set rigid_bonds all
set taup $taup
END
print OUT $vars;
print OUT $inp;
close(OUT);
#
open(OUT,">eq3.inp");
print OUT <<END;
set psf $psf
set pdb $pdb
set outname eq3
set inname eq2
set ref $rest_ref1
set posres_k 10.0
set fix_ref none
set nstep_min 0
set nstep_anneal 0
set nstep_nvt 0
set nstep_npt $nstep
set tcl_scr none
set rigid_bonds all
set taup 10000
END
print OUT $vars;
print OUT $inp;
close(OUT);
#
open(OUT,">eq4.inp");
print OUT <<END;
set psf $psf
set pdb $pdb
set outname eq4
set inname eq3
set ref $rest_ref2
set posres_k 10.0
set fix_ref none
set nstep_min 0
set nstep_anneal 0
set nstep_nvt 0
set nstep_npt $nstep_eq4
set tcl_scr none
set rigid_bonds all
set taup $taup
END
print OUT $vars;
print OUT $inp;
#
open(OUT,">run.sh");
print OUT $shell;
close(OUT);
system("chmod +x run.sh");

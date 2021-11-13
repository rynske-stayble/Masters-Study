package require inorganicbuilder
package require psfgen
set nx 8
set ny 8
set nz 24
inorganicBuilder::initMaterials
set box [inorganicBuilder::newMaterialBox SiO2 {0 0 0} [list $nx $ny $nz]]
inorganicBuilder::buildBox $box sio2
exit

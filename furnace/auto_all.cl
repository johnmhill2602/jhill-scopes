# AUTO_ALL.CL --- script to generate a big set of cl scripts from the database
# 	This simple script makes multiple calls to furnace.autos.
#
# Created by J. M. Hill, Steward Observatory 06JAN97
# Revised 10JUN97 for new control zones
# Revised 08APR02 for old control zones 
# This script was wrong for Mag2 and LBT2 since we cancelled the extra zone.
# This version is appropriate for 6.5m base control - divides at r=130.
# Revised 19JUL05 for 8.4m - divides at r=155 for gz4ttmp versus gz3ttmp.
# Updated 10JAN12 for 8.4m - divides at r=160 for gz4hpwr versus gz3hpwr.

procedure auto_all ()

begin

# Lid TCs
print ("Creating glidttmp.cl")
delete ("glidttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=INDEF, thmin=0, thmax=360, zmin=94, zmax=96,
    > "glidttmp.cl" )

# Cone TCs
print ("Creating gconettmp.cl") 
delete ("gconettmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=INDEF, thmin=0, thmax=360, zmin=52, zmax=93,
    > "gconettmp.cl" )

# Wall TCs
print ("Creating gwallttmp.cl")
delete ("gwallttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=187, rmax=193, thmin=0, thmax=360, zmin=0, zmax=51,
    > "gwallttmp.cl" )

# Outer Base (outside the mold) TCs
print ("Creating gz3ttmp.cl")
delete ("gz3ttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=155, rmax=INDEF, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gz3ttmp.cl" )

# Inner Base (under the mold) TCs
print ("Creating gz4ttmp.cl")
delete ("gz4ttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=45, rmax=155, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gz4ttmp.cl" )

# Center Base (mostly inside the Cass hole)
print ("Creating gcenter.cl")
delete ("gcenter.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=46, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gcenter.cl" )

# Mold TCs
print ("Creating gmoldttmp.cl")
delete ("gmoldttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=168, thmin=0, thmax=360, zmin=19, zmax=21,
    > "gmoldttmp.cl" )

# Lid Heaters
print ("Creating gz0hpwr.cl")
delete ("gz0hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=0, rmax=INDEF, thmin=0, thmax=360, zmin=94, zmax=96,
    > "gz0hpwr.cl" )

# Cone Heaters
print ("Creating gz1hpwr.cl") 
delete ("gz1hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=130, rmax=167, thmin=0, thmax=360, zmin=52, zmax=93,
    > "gz1hpwr.cl" )

# Wall Heaters
print ("Creating gz2hpwr.cl")
delete ("gz2hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=170, rmax=190, thmin=0, thmax=360, zmin=12, zmax=51,
    > "gz2hpwr.cl" )

# Outer base heaters
print ("Creating gz3hpwr.cl")
delete ("gz3hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=161, rmax=193, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gz3hpwr.cl" )

# Inner base heaters
print ("Creating gz4hpwr.cl")
delete ("gz4hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=0, rmax=160, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gz4hpwr.cl" )

end

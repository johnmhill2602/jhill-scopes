# AUTO_ALL.CL --- script to generate a big set of cl scripts from the database
# 	This simple script makes multiple calls to furnace.autos.
#
# Created by J. M. Hill, Steward Observatory 06JAN97
# Revised 10JUN97 for new control zones

procedure auto_all ()

begin

print ("Creating glidttmp.cl")
delete ("glidttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=INDEF, thmin=0, thmax=360, zmin=94, zmax=96,
    > "glidttmp.cl" )

print ("Creating gconettmp.cl") 
delete ("gconettmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=INDEF, thmin=0, thmax=360, zmin=52, zmax=93,
    > "gconettmp.cl" )


print ("Creating gwallttmp.cl")
delete ("gwallttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=187, rmax=193, thmin=0, thmax=360, zmin=0, zmax=96,
    > "gwallttmp.cl" )

print ("Creating gz4ttmp.cl")
delete ("gz4ttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=166, rmax=INDEF, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gz4ttmp.cl" )

print ("Creating gz5ttmp.cl")
delete ("gz5ttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=168, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gz5ttmp.cl" )

print ("Creating gcenter.cl")
delete ("gcenter.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=46, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gcenter.cl" )

print ("Creating gmoldttmp.cl")
delete ("gmoldttmp.cl", verify-)
autos ( dataf="databasc", gtype="tc", verb=5,
    rmin=0, rmax=168, thmin=0, thmax=360, zmin=19, zmax=21,
    > "gmoldttmp.cl" )

print ("Creating gz0hpwr.cl")
delete ("gz0hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=0, rmax=INDEF, thmin=0, thmax=360, zmin=94, zmax=96,
    > "gz0hpwr.cl" )

print ("Creating gz1hpwr.cl") 
delete ("gz1hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=130, rmax=167, thmin=0, thmax=360, zmin=52, zmax=93,
    > "gz1hpwr.cl" )

print ("Creating gz2hpwr.cl")
delete ("gz2hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=170, rmax=190, thmin=0, thmax=360, zmin=52, zmax=93,
    > "gz2hpwr.cl" )

print ("Creating gz3hpwr.cl")
delete ("gz3hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=187, rmax=193, thmin=0, thmax=360, zmin=0, zmax=96,
    > "gz3hpwr.cl" )

print ("Creating gz4hpwr.cl")
delete ("gz4hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=166, rmax=INDEF, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gz4hpwr.cl" )

print ("Creating gz5hpwr.cl")
delete ("gz5hpwr.cl", verify-)
autos ( dataf="databasc", gtype="he0", verb=5,
    rmin=0, rmax=168, thmin=0, thmax=360, zmin=0, zmax=6,
    > "gz5hpwr.cl" )

end

# cass_sub7.x
# generates raytrace input file (lens) for ZEMAX raytrace program

# 08NOV94 - created by J. M. Hill, Steward Observatory from cass_sub4.x

procedure zemax_rays (rayfile, title)

include "cass_common.h"

# To Do:

# Parameter Variables
char	rayfile[ARB]	# name of the raytrace input file
char	title[ARB]	# name of the telescope

# Local Variables
string  version   "08-NOV-94"

int	xfd		# file descriptor

int     isurf           # surface counter
# keeps track of number of tracing surfaces

int     iref            # reflection counter
# toggles to keep track of sign convention on distances at mirrors
# also serves to convert meters to millimeters

double  netang, netcng          # net coordinate rotation for tilts
# variable to keep track of the previous rotations at fold mirrors

begin

# Introduction
   call printf ("Writing of ZEMAX format input file is not yet implemented.\n")
   call flush (STDOUT)

end

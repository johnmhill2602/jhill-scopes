# AUTOCASS.CL -- Run program CASS automatically using a specified parameter
# 			file.

# Written by J. M. Hill,  Steward Observatory

# Created 04NOV94

procedure autocass(tname)

string  tname="junk" {prompt='name of the telescope configuration'}
bool    clean=yes    {prompt='restore parameters to original state?'}
string  version="23NOV94" {prompt='version date of script'}

begin

# define variables
file	outfile
file	parfile
string  xname

# begin code
	xname = tname

	# introduction
	print ("AUTOCASS:   processing ", xname)

	parfile = xname // ".par"
	outfile = xname // "_res"

	# delete previous cass parameters
	if ( access("uparm$opscass.bak") )
	    delete ( "uparm$opscass.bak", ver- )
	if ( access("uparm$opscass.par") )
	    rename ( "uparm$opscass.par", "uparm$opscass.bak" )

	# replace with cass parameters of default name
	copy ( parfile, "uparm$opscass.par", verbose+ )

	# check if this file has all the new parameters
	if ( !defpar ("cass.rayprog") ) {   # added 07NOV94
		print ("AUTOCASS:  parameter file is out of date")
		if ( access("uparm$opscass.dpm") )
		    delete ( "uparm$opscass.dpm", ver- )
		dparam ( "cass", > "uparm$opscass.dpm" )
		unlearn ( "cass" )
		cl ( , < "uparm$opscass.dpm" )
		print ("AUTOCASS:  trying to clean things up")
	        delete ( "uparm$opscass.dpm", ver- )
		if ( !defpar ("cass.rayprog") ) {
			print ("AUTOCASS:  failed to recover parameter file")
			bye
		}
		else {
			print ("AUTOCASS:  OK")
		# This script does not modify the original parameter file.
		}
	}

	# delete result file of default name
	if ( access(outfile) )
	    delete ( outfile, ver- )

	# run task scopes.optics.cass
	cass ( mode=h, > outfile )
	
	# restore previous cass parameters
	if ( clean ) {
	    delete ( "uparm$opscass.par", ver- )
	    if ( access("uparm$opscass.bak") )
	        rename ( "uparm$opscass.bak", "uparm$opscass.par" )
	}

	print ("AUTOCASS:   done with ", outfile)

	# type ( outfile )
end

procedure psi2gif(outname)

# script to retrieve a postscript file from device=psidump and
#   and turn it into a gif image
#
# created 24SEP98

string  outname			{prompt="Output GIF file"}
bool    clobber=yes      	{prompt="overwrite existing images?"}
bool	clean=no		{prompt="delete postscript images?"}
int	verb=4  		{prompt="verbosity"}
string	version="25 September 1998" {prompt="Version date of this routine"}

begin

file	psname

	if ( verb > 3 )
	    print ("PSI2GIF:   version ", version )

# clobber old files
	if ( access("/tmp/psi2gif.ppm") )
	    delete ("/tmp/psi2gif.ppm", verify=no)
	if ( access("/tmp/psi2gif.ps") )
	    delete ("/tmp/psi2gif.ps", verify=no)
	if ( access("/tmp/psi2gifp.ps") )
	    delete ("/tmp/psi2gifp.ps", verify=no)
	if ( access("/tmp/psi2gif.gif") )
	    delete ("/tmp/psi2gif.gif", verify=no)

# flush graphics buffer
	    gflush

# get the most recent output file name which was created with the PSIKERN
#   from device=psidump
	    dir ("/tmp/psi*.ps", ncols=1) |
	    sort (column=0, reverse=yes) |
            head (nlines=1) | 
	    scan (psname)
	    copy (psname, "/tmp/psi2gif.ps")

# tricks to get reasonable aspect ratio for Portrait mode
# sed edit the postscript file
# not satisfactory using psidumpp
   !sed 's/PortraitMode false/PortraitMode true/' /tmp/psi2gif.ps > /tmp/psi2gifp.ps

# convert postscript to ppm
   !gs -q -dNOPAUSE -sDEVICE=ppm -sOutputFile=/tmp/psi2gif.ppm -g792x684 /tmp/psi2gifp.ps -c quit

# convert ppm to gif
   !(ppmtogif /tmp/psi2gif.ppm > /tmp/psi2gif.gif) >& /dev/null

# copy output file to specified destination
	if (clobber)
	    delete (outname, verify=no)
	copy ("/tmp/psi2gif.gif", outname)

# clean up
	if (clean) {
	    delete (psname, verify=no)
	    delete ("/tmp/psi2gif.ppm", verify=no)
	    delete ("/tmp/psi2gif.ps", verify=no)
	    delete ("/tmp/psi2gifp.ps", verify=no)
	    delete ("/tmp/psi2gif.gif", verify=no)
	}

	if ( verb > 3 )
	    print ("PSI2GIF complete, output= ", outname )
end




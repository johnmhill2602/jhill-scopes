procedure psi2png(outname)

# script to retrieve a postscript file from IRAF device=psidump or psdump and
#   and turn it into a png image
#
# created for IRAF 2.16 on Fedora Linux JMH 20JAN21 based on psi2gif.cl


string  outname			{prompt="Output PNG file"}
bool    clobber=yes      	{prompt="overwrite existing images?"}
bool	clean=no		{prompt="delete postscript images?"}
int	verb=4  		{prompt="verbosity"}
string	version="20 January 2021" {prompt="Version date of this routine"}


begin

file	pngname
file	psname

pngname = outname # to make just one prompt if outname not on command line

if ( verb > 3 )
   print ("PSI2PNG:   version ", version )

# clobber old files
if ( access("/tmp/psi2png.ps") )
    delete ("/tmp/psi2png.ps", verify=no)
if ( access("/tmp/psi2png.png") )
    delete ("/tmp/psi2png.png", verify=no)

# flush graphics buffer
gflush  # necessary to create the Postscript file in /tmp/
sleep(1)

# get the most recent output file name which was created with the PSIKERN
      	  #   from device=psdump
	  #     dir ("/tmp/irafdmp*.ps", ncols=1) |
	  #   from device=psidump
          #     dir ("/tmp/psi*.ps", ncols=1) |
	  # The following is not robust to mixing types, but works for either one.
	  # Maybe better to have a time sort? (not an option in cl.dir)
dir ("/tmp/psi*.ps,/tmp/irafdmp*.ps", ncols=1, sort=yes) |
sort (column=0, reverse=yes) |
head (nlines=1) | 
scan (psname)

if ( verb > 3 )
   print ("processing ", psname )

if ( access(psname) )
   copy (psname, "/tmp/psi2png.ps")
else
   print ("Error - file not found: ", psname)
		

	
# convert postscript to png256 for Fedora Linux
!gs -sDEVICE=png256 -sOutputFile=/tmp/psi2png.png  -r150 -dBATCH -dNOPAUSE /tmp/psi2png.ps -c quit >& /dev/null


# copy output file to specified destination
if (clobber) {
   if ( access(pngname) )
      delete (pngname, verify=no)
   copy ("/tmp/psi2png.png", pngname)
}

# clean up
if (clean) {
    delete (psname, verify=no)
    delete ("/tmp/psi2png.ps", verify=no)
    delete ("/tmp/psi2png.png", verify=no)
}

if ( verb > 3 )
   print ("PSI2PNG complete, output= ", pngname )
end

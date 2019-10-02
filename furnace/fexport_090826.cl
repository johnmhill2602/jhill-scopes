procedure fexport (fname)

# cl script to convert a FITS image to IRAF format and export to GIF format
# Created 18JAN97 by J. M. Hill, Steward Observatory
# Version 14SEP98 -- fits file "*"
# Version 19MAY00 -- image scaling factor
# Version 21JUL05 -- less verbose export
# Version 26AUG09 -- don't reprocess if output image exists
# Version 26AUG09 -- reduce area of image for imstat scaling

string  fname			{prompt="list of FITS image to read"}
string  iname=""		{prompt="temporary IRAF image name"}
string	format="gif"		{prompt="image format for export"}
bool    clobber=no      	{prompt="overwrite existing IRAF images?"}
bool    force=yes	      	{prompt="force reprocessing of GIF files?"}
bool	isave=no		{prompt="save IRAF image"}
bool	autoscale=yes		{prompt="autoscale pixel intensities?"}
#string  scale="zscale (b1, 0, 255, 256)" {prompt="intensity scaling factor"}
string  regstr="[50:704,50:436]" {prompt="region for image statistics"}
int     reduce=0                {prompt="factor for reduction to small image"}
int	verb=4  		{prompt="verbosity"}
string	version="26 Aug 2009" {prompt="Version date of this routine"}
struct	*list1

begin
	# define variables
	string rname, sname, jname, kname, lname, gname, temp1, ename
	string scale, jregion
	int minpix, maxpix

	# expand 'fname' into a list 
	temp1=mktemp("tmp$temp")
	files(fname, >temp1)
	list1 = temp1

	# loop over list of files
	while ( fscan(list1, gname) != EOF) {	

	    # check for .fts extension
	    if ( substr(gname, strlen(gname)-3, strlen(gname) ) == ".fts" )
		rname = gname
	    else
		rname = gname // ".fts"

	    # generate default IRAF image name
	    # warning: old files with this name will be clobbered
	    if ( strlen(iname) == 0 ) {
		jname = substr(rname, 1, strlen(rname)-4) // ".imh"
		while (stridx("/", jname) > 0) {
		# strip leading directory paths
		    jname = substr(jname,stridx("/",jname)+1,strlen(jname))
		} #end while
		while (stridx("$", jname) > 0) {
		# strip leading indirect path
		    jname = substr(jname,stridx("$",jname)+1,strlen(jname))
		} #end while
	    } # end if
	    else {
		# use specified default name and path
		# warning: old files with this name will be clobbered
		jname = iname
	    } # end else

	    # create the name of the export image
	    ename = substr(jname, 1, strlen(jname)-4) // "." // format

	    # check here to see if we should skip processing
	    # because the output image already exists
	    # this check added in August 2009
	    if ( access(ename) && !force ) {
		print ("FEXPORT>  Warning file exists: ", ename, " No reprocessing will be done.")
	    }
	    else {

	    # does the temporary IRAF image already exist?
	    if ( access(jname) )
		# delete the temporary IRAF image
		imdelete (jname, verify=no)

	    # read the FITS image with task rfits
	    rfits (rname, file_list="*", iraf_file=jname, make_image=yes,
		long_header=no, short_header=no, datatype="",
		scale=no, oldirafname=no, offset=0)

	    # autoscale pixel intensities
	    if ( autoscale ) {
	        jregion = jname // regstr

		imstat (jregion, fields="min,max", format=no ) | scan (minpix, maxpix)
	        print ("Pixel range: ", minpix, " to ", maxpix, " in ", jregion )
		scale = "zscale(b1, " // minpix // ", " // maxpix // ", 256)"
		print ("    Outbands= ", scale)
	    }
	    else {
		scale = "zscale (b1, 0, 255, 256)"
	    }	


	    if ( clobber && access(ename) ) {
		# delete old file
		delete (ename, verify=no)

		# export the image using the selected format
		export (jname, ename, format=format, header=no, 
			bswap=no, outbands=scale, verbose=no)
	    }
#	    else if ( access(jname) ) {
#		print ("FEXPORT>  Warning file exists: ", jname )
#	    }
	    else {
		# export the image using the selected format
		export (jname, ename, format=format, header=no, 
			bswap=no, outbands=scale, verbose=no)
	    }

	    if ( reduce > 0 ) {
                # create the output name
                kname = substr(jname, 1, strlen(jname)-4) // "_" // reduce // ".imh"
	    	# does the temporary IRAF image already exist?
	    	if ( access(kname) )
		# delete the temporary IRAF image
		imdelete (kname, verify=no)

	        # blkavg the image to a smaller size
		blkavg ( input=jname, output=kname, b1=reduce, b2=reduce )

  	    # create the name of the export image
	    lname = substr(kname, 1, strlen(kname)-4) // "." // format

	    if ( clobber && access(lname) ) {
		# delete old file
		delete (lname, verify=no)

		# export the image using the selected format
		export (kname, lname, format=format, header=no, 
			bswap=no, outbands=scale, verbose=no)
	    }
#	    else if ( access(lname) ) {
#		print ("FEXPORT>  Warning file exists: ", lname )
#	    }
	    else {
		# export the image using the selected format
		export (kname, lname, format=format, header=no, 
			bswap=no, outbands=scale, verbose=no)
	    }
	    } # end if reduce

	    if ( !isave ) {
		# delete the temporary IRAF image
		imdelete (jname, verify=no)
	        if ( reduce > 0 )
		    imdelete (kname, verify=no)
	    } # end if isave

	    } # end of the processing branch

	} # end while

	delete(temp1,verify=no)
        list1=""

	if ( verb > 3 )
	    print ("FEXPORT is complete.")

end

procedure xgifc.cl

# script to export oven video images as gif files
#
# Created by J. M. Hill, 06JUN97 for the new on-board video system

begin

	string lastpict, lasttemp, exptfile, exptout, temp1, camera
	int lindex, jj

temp1 = mktemp("tmp$xgif")

while (0<1) {
    # only do this if a last picture file was specified
    if ( strlen(lastfile) > 0 ) {

	# check for an existing last picture file and scan it for the index
	if ( access (lastfile) ) {

	    # copy the last n lines of the file to a temporary file
	    tail ( lastfile, nlines=numlast+1, > temp1 )
	    list1 = temp1

	    # dummy scan of the first line --- it might be the time header
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF) #time
		jj = lindex

	    # scan to get the names of the image files
	    while (fscan(list1, lastpict, lasttemp, lindex) !=EOF) {

		# locate the suffix in the path name
		#   assuming no dots in the directory path
		jj = stridx( ".", lastpic )
		# extract the camera identifier
		camera = substr( lastpic, jj-1, jj-1 )

		# temporary IRAF filename
		exptfile = xpath // xroot // camera // ".imh"
		# export output filename
		exptout = xpath // xroot // camera // ".gif"
		if ( verb > 4 )
		    print ( lastpic, " => ", exptout )

		# delete the old gif file if it exists
		if ( access(exptout) )
		    delete ( exptout, verify=no )
		# convert the FITS image to IRAF and export it to GIF
		fexport ( lastpic, iname=exptfile, format="gif",
			isave=no, verb=verb )

		sleep (10) # delay before next export

	    } # end while fscan for image names
	    delete ( temp1, verify=no )

	} # end if access

    } # end if strlen

    if ( verb > 2 )
	date    

    # sleep for the specified longer interval
    sleep (delay)

} # loop back to beginning

end







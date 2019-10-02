procedure shortc

# script to take a repeated series of oven video images
#	This script generates a sequence of names and uses takepic to
# 	acquire on-board video images.  ovenw is used to minimize
# 	collisions with oven database traffic.
#
# normally this script would be run from a non-oven workstation 
#	so that crater is only involved in one image write and
#	one image read.
#
# The normal sequence of activity is:
    # wait for sync with oven minute traffic
    # take the picture and wait for image file to appear
    # display the image
    # repeat with the next camera

# The exposure sequences are hardwired in this version.  It would be better
#    if this script worked from an exposure sequence that could be changed
#    on the fly.
#
# Created by J. M. Hill, 12MAY97 for the new on-board video system
# Short version for post-casting pictures 11JUN97
# Added export code 14JUN97 (now in dataio for V2.11 14OCT97)
# Added Camera F, 10SEP98

begin

    string lastpict, lasttemp, exptfile, exptout, camera
    int lindex, jj

    # load mirror package for ovenw
    mirror

    if ( verb > 2 ) {
	print ("Starting new copy of shortc.cl")
	print ("  version of 10SEP98,   vindex = ", vindex)
    } # end if

    if ( strlen(vlogfile) > 0 ) {
	print ("Starting new copy of videoc.cl", >> vlogfile )
	print ("  version of 10SEP98,   vindex = ", vindex, >> vlogfile )
    } # end if

    # check logfile for last index used
    if ( strlen(lastfile) > 0 ) {
	# check for an existing last picture file and scan it for the index
	if ( access (lastfile) ) {
	    list1 = lastfile
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF) #time
		jj = lindex
	    while (fscan(list1, lastpict, lasttemp, lindex) !=EOF) {
		vindex = lindex + 1
	    }
	    delete ( lastfile, verify=no )
	}
	# create the file if it didn't exist or make a fresh one
	time ( > lastfile) # first line of image logfile has time and date
	list1 = lastfile
	if (fscan(list1, lastpict) !=EOF) # scan over the first line
		print ("Using vindex = ", vindex )
    } # end if strlen
    else {
	# no image names to display
	display = no
    }

    # endless loop
    while ( 0 <  1) {

    if ( strlen(vlogfile) > 0 ) {
	time ( >> vlogfile) # time tag the videoc logfile
    } # end if

    ovenw
    takepic ( vroot, camera="a", flash="cd", exposure=vfexp, 
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, auto=vauto,
	logfile=lastfile, clobber=yes, verb=3 )

    jj = fscan(list1, lastpict, lasttemp, lindex)

	if (display) {
   	    display ( lastpict, 1, xmag=1, ymag=0.75)
	}	

	if (export) {
		# locate suffix in the path name and extract camera identifier
		jj = stridx( ".", lasttemp )
		camera = substr( lasttemp, jj-1, jj-1 )
		# temporary IRAF filename
		exptfile = xpath // xroot // camera // ".imh"
		# export output filename
		exptout = xpath // xroot // camera // ".gif"
		# convert the FITS image to IRAF and export it to GIF
		fexport ( lastpic, iname=exptfile, format="gif",
			isave=no, clobber=yes, verb=verb )
	} # end if export

    ovenw
    takepic ( vroot, camera="b", flash="bc", exposure=4,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, auto=vauto, 
	logfile=lastfile, clobber=yes, verb=3 )

    jj = fscan(list1, lastpict, lasttemp, lindex)

	if (display) {
	    	display ( lastpict, 2, xmag=0.75, ymag=1)
	}	

	if (export) {
		# locate suffix in the path name and extract camera identifier
		jj = stridx( ".", lasttemp )
		camera = substr( lasttemp, jj-1, jj-1 )
		# temporary IRAF filename
		exptfile = xpath // xroot // camera // ".imh"
		# export output filename
		exptout = xpath // xroot // camera // ".gif"
		# convert the FITS image to IRAF and export it to GIF
		fexport ( lastpic, iname=exptfile, format="gif",
			isave=no, clobber=yes, verb=verb )
	} # end if export

    ovenw
    takepic ( vroot, camera="e", flash="ac", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, auto=vauto,
	logfile=lastfile, clobber=yes, verb=3 )

    jj = fscan(list1, lastpict, lasttemp, lindex)

	if (display) {
	    	display ( lastpict, 4, xmag=0.75, ymag=1)
	}	

	if (export) {
		# locate suffix in the path name and extract camera identifier
		jj = stridx( ".", lasttemp )
		camera = substr( lasttemp, jj-1, jj-1 )
		# temporary IRAF filename
		exptfile = xpath // xroot // camera // ".imh"
		# export output filename
		exptout = xpath // xroot // camera // ".gif"
		# convert the FITS image to IRAF and export it to GIF
		fexport ( lastpic, iname=exptfile, format="gif",
			isave=no, clobber=yes, verb=verb )
	} # end if export

    ovenw
    takepic ( vroot, camera="c", flash="ab", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, auto=vauto,
	logfile=lastfile, clobber=yes, verb=3 )

    jj = fscan(list1, lastpict, lasttemp, lindex)

	if (display) {
	    	display ( lastpict, 1, xmag=0.75, ymag=1)
	}	

	if (export) {
		# locate suffix in the path name and extract camera identifier
		jj = stridx( ".", lasttemp )
		camera = substr( lasttemp, jj-1, jj-1 )
		# temporary IRAF filename
		exptfile = xpath // xroot // camera // ".imh"
		# export output filename
		exptout = xpath // xroot // camera // ".gif"
		# convert the FITS image to IRAF and export it to GIF
		fexport ( lastpic, iname=exptfile, format="gif",
			isave=no, clobber=yes, verb=verb )
	} # end if export

    ovenw
    takepic ( vroot, camera="f", flash="bd", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, auto=vauto,
	logfile=lastfile, clobber=yes, verb=3 )

    jj = fscan(list1, lastpict, lasttemp, lindex)

	if (display) {
	    	display ( lastpict, 4, xmag=0.75, ymag=1)
	}	

	if (export) {
		# locate suffix in the path name and extract camera identifier
		jj = stridx( ".", lasttemp )
		camera = substr( lasttemp, jj-1, jj-1 )
		# temporary IRAF filename
		exptfile = xpath // xroot // camera // ".imh"
		# export output filename
		exptout = xpath // xroot // camera // ".gif"
		# convert the FITS image to IRAF and export it to GIF
		fexport ( lastpic, iname=exptfile, format="gif",
			isave=no, clobber=yes, verb=verb )
	} # end if export

    ovenw
    takepic ( vroot, camera="d", flash="bd", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, auto=vauto,
	logfile=lastfile, clobber=yes, verb=3 )

    jj = fscan(list1, lastpict, lasttemp, lindex)

	if (display) {
	    	display ( lastpict, 2, xmag=0.75, ymag=1)
	} # end if display

	if (export) {
		# locate suffix in the path name and extract camera identifier
		jj = stridx( ".", lasttemp )
		camera = substr( lasttemp, jj-1, jj-1 )
		# temporary IRAF filename
		exptfile = xpath // xroot // camera // ".imh"
		# export output filename
		exptout = xpath // xroot // camera // ".gif"
		# convert the FITS image to IRAF and export it to GIF
		fexport ( lastpic, iname=exptfile, format="gif",
			isave=no, clobber=yes, verb=verb )
	} # end if export

    # increment the index
    vindex = vindex + 1

    # log the current oven zone temperatures
    temp

    if ( verb > 2 )
	date

    # deselect flashes if we aren't using them
    if ( delay > 500 )
	flkill	# send tcs command

    # sleep for a longer interval
    sleep (delay)

    } # loop back to beginning

end

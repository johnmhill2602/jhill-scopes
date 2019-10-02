procedure videoc

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
# Auto display feature added 05JUN97
# Self-indexing from logfile added 06JUN97
# Added dark and infrared images 09JUN97

begin

    string lastpict, lasttemp
    int lindex, jj

    # load mirror package for ovenw
    mirror

    if ( verb > 2 ) {
	print ("Starting new copy of videoc.cl")
	print ("  version of 09JUN97,   vindex = ", vindex)
    } # end if

    if ( strlen(vlogfile) > 0 ) {
	print ("Starting new copy of videoc.cl", >> vlogfile )
	print ("  version of 09JUN97,   vindex = ", vindex, >> vlogfile )
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
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 1, xmag=1, ymag=0.75)
	}	

    ovenw
    takepic ( vroot, camera="b", flash="bc", exposure=4,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, 
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 2, xmag=0.75, ymag=1)
	}	

    ovenw
    takepic ( vroot, camera="e", flash="ac", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 4, xmag=0.75, ymag=1)
	}	

    ovenw
    takepic ( vroot, camera="c", flash="ab", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 1, xmag=0.75, ymag=1)
	}	

    ovenw
    takepic ( vroot, camera="d", flash="bd", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 2, xmag=0.75, ymag=1)
	}

    # infrared frames
    ovenw
    takepic ( iroot, camera="d", flash="x", exposure=viexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile="", verb=3 )

    takepic ( iroot, camera="c", flash="x", exposure=viexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile="", verb=3 )

    takepic ( iroot, camera="a", flash="x", exposure=viexp, 
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile="", verb=3 )

    takepic ( iroot, camera="b", flash="x", exposure=viexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, 
	logfile="", verb=3 )

    takepic ( iroot, camera="e", flash="x", exposure=viexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile="", verb=3 )

    # increment the index
    vindex = vindex + 1

    # copy a recent metacode plot from crater
	# using Unix cp to overwrite previous version
    if (access("/home/pilot/onowa.mc"))
	!cp -p "/home/pilot/onowa.mc" .

    ovenw
    takepic ( vroot, camera="a", flash="cd", exposure=vfexp, 
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 1, xmag=1, ymag=0.75)
	}	

    ovenw
    takepic ( vroot, camera="b", flash="bc", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, 
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 2, xmag=0.75, ymag=1)
	}	

    ovenw
    takepic ( vroot, camera="e", flash="ac", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 4, xmag=0.75, ymag=1)
	}	

    ovenw
    takepic ( vroot, camera="c", flash="ab", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 1, xmag=0.75, ymag=1)
	}	

    ovenw
    takepic ( vroot, camera="d", flash="bd", exposure=vfexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile=lastfile, verb=3 )

	if (display) {
	    if (fscan(list1, lastpict, lasttemp, lindex) !=EOF)
	    	display ( lastpict, 3, xmag=0.75, ymag=1)
	}


    # dark frames
    ovenw
    takepic ( droot, camera="d", flash="x", exposure=vdexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile="", verb=3 )

    takepic ( droot, camera="c", flash="x", exposure=vdexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile="", verb=3 )

    takepic ( droot, camera="a", flash="x", exposure=vdexp, 
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile="", verb=3 )

    takepic ( droot, camera="b", flash="x", exposure=vdexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost, 
	logfile="", verb=3 )

    takepic ( droot, camera="e", flash="x", exposure=vdexp,
	index=vindex, pname=vpath, xname=vtemp, xhost=vhost,
	logfile="", verb=3 )

    # increment the index
    vindex = vindex + 1

    # log the current oven zone temperatures
    temp

    if ( verb > 2 )
	date

    # kill selected flashes if we aren't using them
    if ( delay > 500 )
	flkill

    # sleep for a longer interval
    sleep (delay)

    } # loop back to beginning

end

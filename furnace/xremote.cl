procedure xremote.cl

# script to display the most recent oven video images
#
# Created by J. M. Hill, 07JUN97 for the new on-board video system

begin

	string lastpict, lasttemp, exptfile, exptout, temp1, camera
	int lindex, jj

    temp1 = mktemp("tmp$xrem")

    # load the tv & iis packages
    tv
    iis
    display.erase=yes

    display ("dev$pix[*,*]", frame=1)
    display ("dev$pix[-*,*]", frame=2)
    display ("dev$pix[*,-*]", frame=3)
    display ("dev$pix[-*,-*]", frame=4)

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
		# scan to get the name of the image file
		while (fscan(list1, lastpict, lasttemp, lindex) !=EOF) {
		    # locate the suffix in the path name
		    jj = stridx( ".", lastpic )
		    # extract the camera identifier
		    camera = substr( lastpic, jj-1, jj-1 )
		    if ( verb > 4 )
			print ( lastpic, camera )
		    if ( camera == "a" )
	    		display ( lastpict, 1, xmag=1, ymag=0.75)
		    else if ( camera == "b" )
	    	    	display ( lastpict, 2, xmag=0.75, ymag=1)
		    else if ( camera == "c" )
	    		display ( lastpict, 1, xmag=0.75, ymag=1)
		    else if ( camera == "d" )
	    		display ( lastpict, 3, xmag=0.75, ymag=1)
		    else if ( camera == "e" )
	    		display ( lastpict, 2, xmag=0.75, ymag=1)
		    sleep (30) # delay before next display
		} # end while fscan
		delete ( temp1, verify=no )
		time

		erase (fr=4)
		if (access("onowa.mc"))
		    imdkern ("onowa.mc", fr=4)
	    } # end if access lastfile

	} # end if strlen

	# sleep for a longer interval
	sleep (delay)

    } # loop back to beginning

end







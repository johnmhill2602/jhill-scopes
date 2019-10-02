procedure mkgifc

# script to create some GIF images from oven metacode files, JMH 27SEP98

begin

if (!defpac ("mirror"))
    mirror
if (!defpac ("scopes"))
    scopes
if (!defpac ("furnace"))
    furnace

if ( strlen(ologfile) > 0 ) {
	print ("Starting new copy of mkgifc.cl", >> ologfile )
	print ("  version of 27SEP98", >> ologfile )
} # end if

    while (0<1) {

	if ( strlen(ologfile) > 0 ) {
		time ( >> ologfile)
	} # end if

	ovenw (offset=35)
	if ( access("ohalf.mc") ) {
	    gkimosaic ( "ohalf.mc", nx=1, ny=1, interact-, device="psidump" )
	    gflush
	    psi2gif ( "home$public_html/frame0.gif", clobber+, clean+, verb=2 )
	}

	ovenw (offset=35)
	if ( access("olong.mc") ) {
	    gkimosaic ( "olong.mc", nx=1, ny=1, interact-, device="psidump" )
	    gflush
	    psi2gif ( "home$public_html/frame3.gif", clobber+, clean+, verb=2 )
	}

	ovenw (offset=35)
	if ( access("oshort.mc") ) {
	    gkimosaic ( "oshort.mc", nx=1, ny=1, interact-, device="psidump" )
	    gflush
	    psi2gif ( "home$public_html/frame4.gif", clobber+, clean+, verb=2 )
	}

	ovenw (offset=35)
	if ( access("otres.mc") ) {
	    gkimosaic ( "otres.mc", nx=1, ny=1, interact-, device="psidump" )
	    gflush
	    psi2gif ( "home$public_html/frame1.gif", clobber+, clean+, verb=2 )
	}

	ovenw (offset=35)
	if ( access("owhole.mc") ) {
	    gkimosaic ( "owhole.mc", nx=1, ny=1, interact-, device="psidump" )
	    gflush
	    psi2gif ( "home$public_html/frame2.gif", clobber+, clean+, verb=2 )
	}

    # sleep for a longer interval
	sleep (delay)

    } # loop back to beginning
end







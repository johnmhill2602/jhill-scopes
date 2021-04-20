procedure mkpngc

## Issues for the implementation in IRAF 2.16 under Fedora
### updated "psidump" (didn't work) to "psdump" (BUT b&w and other issues)
### changed call from psi2gif to psi2png for Fedora
### editted furnace$graphcap to change stsdas$bin($arch) to stsdas$bin for psi_def
###   this makes "psidump" work - caused by a 64/32 bit issue of directories
### both psidump and psidumpp seem to give portrait output, or is problem is gs conversion?
### fetch commented out
### added call to headless google-chrome to retrieve rotation plot
### added ohigh processing


# Future Improvements:
#  -This procedure assumes that you will run it from /home/pilot/
#     It could be more generalized for different users and directories.
#  -It could pick the newest of the onowa,b,c plots.
#  -Allow turning off fetch.cgi call by parameter


begin

# check that needed packages are loaded
if (!defpac ("plot"))
    plot
if (!defpac ("mirror"))
    mirror
if (!defpac ("scopes"))
    scopes
if (!defpac ("furnace"))
    furnace

# the traditional default glbcolor string
#set glbcolor="pt=3,fr=9,al=3,tl=6,ax=5,tk=5"
# 0=black 1=white 2=red 3=green, 4=blue, 5=cyan 6=yellow
# 7=magenta 8=aux1(purple) 9=aux2(dark green)
# see lib$gim.h
# ax=axes, tl=tick labels, tk=ticks fr=frame al=axes labels pt=plot title
# do these have an effect on psidump?  on gkimosaic?
# They do have an effect on ograph plotted to xgterm.


# write to logfile
if ( strlen(ologfile) > 0 ) {
	print ("Starting new copy of mkpngc.cl", >> ologfile )
	print ("  version of 06MAR21", >> ologfile )
} # end if

# infinite loop (until script crashes or is killed)
    while (0<1) {

    	# write timestamp in logfile
	if ( strlen(ologfile) > 0 ) {
		time ( >> ologfile)
	} # end if

	ovenw (offset=35) # oven wait function until next minute
	!/home/pilot/fetch.cgi        # retrieve video images
	temp              # make text file of zone temps and scatter

	# NEW COMMAND 04-MAR-21 to retrieve rotation speed plot
	# This produces file rotation.png
	!timeout 60 google-chrome --headless --disable-gpu --window-size=1100,1800 --screenshot=/home/pilot/public_html/rotation.png --virtual-time-budget=2000  'http://192.168.1.80' 2> /dev/null
	!chmod 664 /home/pilot/public_html/rotation.png
	
	if ( access("ohalf.mc") ) {
	    gkimosaic ( "ohalf.mc", nx=1, ny=1, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame0.png", clobber+, clean+, verb=2 )
	}

	if ( access("olong.mc") ) {
	    gkimosaic ( "olong.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame3.png", clobber+, clean+, verb=2 )
	}

	if ( access("oshort.mc") ) {
	    gkimosaic ( "oshort.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame4.png", clobber+, clean+, verb=2 )
	}

	ovenw (offset=35) # oven wait function until next minute
	#!fetch.cgi
	temp
	
	if ( access("otres.mc") ) {
	    gkimosaic ( "otres.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame1.png", clobber+, clean+, verb=2 )
	}

	if ( access("onowc.mc") ) {
	    gkimosaic ( "onowc.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame6.png", clobber+, clean+, verb=2 )
	}

	if ( access("ohalf.mc") ) {
	    gkimosaic ( "ohalf.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame0.png", clobber+, clean+, verb=2 )
	}

	ovenw (offset=35) # oven wait function until next minute
	#!fetch.cgi
	temp
	
	if ( access("owhole.mc") ) {
	    gkimosaic ( "owhole.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame2.png", clobber+, clean+, verb=2 )
	}

	if ( access("ohigh.mc") ) {
	    gkimosaic ( "ohigh.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame7.png", clobber+, clean+, verb=2 )
	}

	if ( access("ospin.mc") ) {
	    gkimosaic ( "ospin.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame5.png", clobber+, clean+, verb=2 )
	}

	if ( access("onowa.mc") ) {
	    gkimosaic ( "onowa.mc", nx=1, ny=1, rotate=yes, interact-, device="psidump" )
	    gflush
	    psi2png ( "home$public_html/frame6.png", clobber+, clean+, verb=2 )
	}

    # sleep for a longer interval (used for annealing when thing change slowly)
	# sleep (delay)

    } # loop back to beginning
end

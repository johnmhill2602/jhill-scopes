procedure mkpngc

## Issues for the implementation in IRAF 2.16 under Fedora
### updated "psidump" (didn't work) to "psdump" (BUT b&w and other issues)
### changed call from psi2gif to psi2png for Fedora
### editted furnace$graphcap to change stsdas$bin($arch) to stsdas$bin for psi_def
###   this makes "psidump" work - caused by a 64/32 bit issue of directories
### both psidump and psidumpp seem to give portrait output, or is problem is gs conversion?
### fetch commented out
### added call to headless google-chrome to retrieve rotation plot 05MAR21 JMH
### added ohigh processing 06MAR21 JMH
### added metacode editting with sed 08MAR21 JMH
### put all processing into convpng 14MAR21 JMH
### use ls to determine newer file and avoid | cl 16MAR21 JMH


# Future Improvements:
#  -This procedure assumes that you will run it from /home/pilot/ as user=pilot.
#     It could be more generalized for different users and directories.
#  -Allow turning off fetch.cgi call by parameter
#  -Allow turning off high temp plot by parameter


begin

string	ls_str
file	newfile

# check that needed packages are loaded
if (!defpac ("plot"))
    plot
if (!defpac ("mirror"))
    mirror
if (!defpac ("scopes"))
    scopes
if (!defpac ("furnace"))
    furnace


# write to logfile
if ( strlen(ologfile) > 0 ) {
	print ("Starting new copy of mkpngc.cl", >> ologfile )
	print ("  version of 16MAR21", >> ologfile )
} # end if


# infinite loop (until script crashes or is killed)
    while (0<1) {

    	# write timestamp in logfile
	if ( strlen(ologfile) > 0 ) {
		time ( >> ologfile)
	} # end if


	ovenw (offset=48) # oven wait function until next minute
	!/home/pilot/fetch.cgi        # retrieve video images
	temp   # furnace$ script to make text file of zone temps and scatter



	# NEW COMMAND 04-MAR-21 to retrieve rotation speed plot
	# This produces file rotation.png
	!timeout 60 google-chrome --headless --disable-gpu --window-size=1100,1800 --screenshot=/home/pilot/public_html/rotation.png --virtual-time-budget=2000  'http://192.168.1.80' 2> /dev/null
	!chmod 664 /home/pilot/public_html/rotation.png



	# Process all the metacode files into png images
	#   clobber+ overwrites existing png file
	#   newer+ requires metacode file to be newer
	#   black+ converts yellow/green fonts to black
	
	if ( access("ohalf.mc") ) {
	    convpng ( "ohalf.mc", out="/home/pilot/public_html/frame0.png", clobber+, newer+, black+, verb=0 )
	}

	if ( access("olong.mc") ) {
	    convpng ( "olong.mc", out="/home/pilot/public_html/frame3.png", clobber+, newer+, black+, verb=0 )
	}

	if ( access("oshort.mc") ) {
	    convpng ( "oshort.mc", out="/home/pilot/public_html/frame4.png", clobber+, newer+, black+, verb=0 )
	}

	if ( access("otres.mc") ) {
	    convpng ( "otres.mc", out="/home/pilot/public_html/frame1.png", clobber+, newer+, black+, verb=0 )
	}

	
	# Need to figure out if onowa or onowb is newer......
	# These checks were disabled as piping to cl maybe causes the
	#   dictionary full error after about 3.5 hours. 20210314
	#if ( access("onowa.mc") ) { print ("!stat -c %Y onowa.mc") | cl | scan (atime) } else { atime=0 }
        #if ( access("onowb.mc") ) { print ("!stat -c %Y onowb.mc") | cl | scan (btime) } else { btime=0 }


	# Use ls to determine newer file without a pipe to cl
	#   This requires ls defined as foreign task in IRAF.
	ls_str = "-1t onowa.mc onowb.mc"
	ls (ls_str) | scan(newfile)
	
	if ( strlen(newfile) > 4 ) {
	    convpng ( newfile, out="/home/pilot/public_html/frame6.png", clobber+, newer+, black+, verb=0 )
	}


	# only need to do this one twice per hour
	if ( access("owhole.mc") ) {
	    convpng ( "owhole.mc", out="/home/pilot/public_html/frame2.png", clobber+, newer+, black+, verb=0 )
	}

	# Need to comment this out of ovenc during annealing
	if ( access("ohigh.mc") ) {
	    convpng ( "ohigh.mc", out="/home/pilot/public_html/frame7.png", clobber+, newer+, black+, verb=0 )
	}

	# flush IRAF process cache (15MAR21)
	#   experimenting to see if this influences the dictionary full error
	#   probably the error comes from repeated piping to IRAF cl.
	#   which we are now doing by checking the modification time.
	#   at least one message on iraf.net suggest that flpr can help.
	#   this flpr didn't seem to help at all.
	flpr


    # sleep for a longer interval (used for annealing when things change slowly)
	# sleep (delay)

    } # loop back to beginning

end

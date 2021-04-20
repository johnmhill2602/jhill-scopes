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


# Future Improvements:
#  -This procedure assumes that you will run it from /home/pilot/ as user=pilot.
#     It could be more generalized for different users and directories.
#  -It could pick the newest of the onowa,b plots.
#  -Allow turning off fetch.cgi call by parameter
#  -Allow turning off high temp plot by parameter

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
	print ("  version of 08MAR21", >> ologfile )
} # end if

# infinite loop (until script crashes or is killed)
    while (0<1) {

    	# write timestamp in logfile
	if ( strlen(ologfile) > 0 ) {
		time ( >> ologfile)
	} # end if

	# These calculations are spread across several minutes....(reduced to 2 minutes 08MAR21)
	ovenw (offset=50) # oven wait function until next minute
	!/home/pilot/fetch.cgi        # retrieve video images
	temp              # make text file of zone temps and scatter


	# NEW COMMAND 04-MAR-21 to retrieve rotation speed plot
	# This produces file rotation.png
	!timeout 60 google-chrome --headless --disable-gpu --window-size=1100,1800 --screenshot=/home/pilot/public_html/rotation.png --virtual-time-budget=2000  'http://192.168.1.80' 2> /dev/null
	!chmod 664 /home/pilot/public_html/rotation.png


	if ( access("ohalf.mc") ) {
	    #gkimosaic ( "ohalf.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # SECTION FOR SED EDIT OF METACODE FILES (to remove olive bkg, yellow text and green text) 08MAR21 JMH
	    #   This does not preserve the editted metacode after the next file is processed - only the output png file.
	    #   First sed replaces the full set_fillarea command at start - changing color from 9 to 0.
	    #   Next two seds replace green text (color=3) with black text (color=1) allowing for two positions relative to linebreak.
	    #   Last two seds replace yellow text (color=6) with black text (color=1) allowing for two positions relative to linebreak.
	    !xxd -p -c 256 ohalf.mc | sed 's/ffff1200050002000900/ffff1200050002000000/;s/00000300ffff/00000100ffff/g;s/0300ffff0b00/0100ffff0b00/g;s/00000600ffff/00000100ffff/g;s/0600ffff0b00/0100ffff0b00/g' | xxd -r -p > foobar_edit.mc
	    gkimosaic ( "foobar_edit.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # END METACODE EDIT
	    gflush
	    psi2png ( "home$public_html/frame0.png", clobber+, clean+, verb=2 )
	}

	if ( access("olong.mc") ) {
	    #gkimosaic ( "olong.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # SECTION FOR SED EDIT OF METACODE FILES (to remove olive bkg, yellow text and green text) 08MAR21 JMH
	    #   This does not preserve the editted metacode after the next file is processed - only the output png file.
	    #   First sed replaces the full set_fillarea command at start - changing color from 9 to 0.
	    #   Next two seds replace green text (color=3) with black text (color=1) allowing for two positions relative to linebreak.
	    #   Last two seds replace yellow text (color=6) with black text (color=1) allowing for two positions relative to linebreak.
	    !xxd -p -c 256 olong.mc | sed 's/ffff1200050002000900/ffff1200050002000000/;s/00000300ffff/00000100ffff/g;s/0300ffff0b00/0100ffff0b00/g;s/00000600ffff/00000100ffff/g;s/0600ffff0b00/0100ffff0b00/g' | xxd -r -p > foobar_edit.mc
	    gkimosaic ( "foobar_edit.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # END METACODE EDIT
	    gflush
	    psi2png ( "home$public_html/frame3.png", clobber+, clean+, verb=2 )
	}

	if ( access("oshort.mc") ) {
	    #gkimosaic ( "oshort.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # SECTION FOR SED EDIT OF METACODE FILES (to remove olive bkg, yellow text and green text) 08MAR21 JMH
	    #   This does not preserve the editted metacode after the next file is processed - only the output png file.
	    #   First sed replaces the full set_fillarea command at start - changing color from 9 to 0.
	    #   Next two seds replace green text (color=3) with black text (color=1) allowing for two positions relative to linebreak.
	    #   Last two seds replace yellow text (color=6) with black text (color=1) allowing for two positions relative to linebreak.
	    !xxd -p -c 256 oshort.mc | sed 's/ffff1200050002000900/ffff1200050002000000/;s/00000300ffff/00000100ffff/g;s/0300ffff0b00/0100ffff0b00/g;s/00000600ffff/00000100ffff/g;s/0600ffff0b00/0100ffff0b00/g' | xxd -r -p > foobar_edit.mc
	    gkimosaic ( "foobar_edit.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # END METACODE EDIT
	    gflush
	    psi2png ( "home$public_html/frame4.png", clobber+, clean+, verb=2 )
	}

	if ( access("otres.mc") ) {
	    #gkimosaic ( "otres.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # SECTION FOR SED EDIT OF METACODE FILES (to remove olive bkg, yellow text and green text) 08MAR21 JMH
	    #   This does not preserve the editted metacode after the next file is processed - only the output png file.
	    #   First sed replaces the full set_fillarea command at start - changing color from 9 to 0.
	    #   Next two seds replace green text (color=3) with black text (color=1) allowing for two positions relative to linebreak.
	    #   Last two seds replace yellow text (color=6) with black text (color=1) allowing for two positions relative to linebreak.
	    !xxd -p -c 256 otres.mc | sed 's/ffff1200050002000900/ffff1200050002000000/;s/00000300ffff/00000100ffff/g;s/0300ffff0b00/0100ffff0b00/g;s/00000600ffff/00000100ffff/g;s/0600ffff0b00/0100ffff0b00/g' | xxd -r -p > foobar_edit.mc
	    gkimosaic ( "foobar_edit.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # END METACODE EDIT
	    gflush
	    psi2png ( "home$public_html/frame1.png", clobber+, clean+, verb=2 )
	}

	ovenw (offset=35) # oven wait function until next minute
	#!fetch.cgi
	temp


	# Need to figure out if onowa or onowb is newer......
	if ( access("onowb.mc") ) {
	    #gkimosaic ( "onowb.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # SECTION FOR SED EDIT OF METACODE FILES (to remove olive bkg, yellow text and green text) 08MAR21 JMH
	    #   This does not preserve the editted metacode after the next file is processed - only the output png file.
	    #   First sed replaces the full set_fillarea command at start - changing color from 9 to 0.
	    #   Next two seds replace green text (color=3) with black text (color=1) allowing for two positions relative to linebreak.
	    #   Last two seds replace yellow text (color=6) with black text (color=1) allowing for two positions relative to linebreak.
	    !xxd -p -c 256 onowb.mc | sed 's/ffff1200050002000900/ffff1200050002000000/;s/00000300ffff/00000100ffff/g;s/0300ffff0b00/0100ffff0b00/g;s/00000600ffff/00000100ffff/g;s/0600ffff0b00/0100ffff0b00/g' | xxd -r -p > foobar_edit.mc
	    gkimosaic ( "foobar_edit.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # END METACODE EDIT
	    gflush
	    psi2png ( "home$public_html/frame6.png", clobber+, clean+, verb=2 )
	}

	# only need to do this one twice per hour
	if ( access("owhole.mc") ) {
	    #gkimosaic ( "owhole.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # SECTION FOR SED EDIT OF METACODE FILES (to remove olive bkg, yellow text and green text) 08MAR21 JMH
	    #   This does not preserve the editted metacode after the next file is processed - only the output png file.
	    #   First sed replaces the full set_fillarea command at start - changing color from 9 to 0.
	    #   Next two seds replace green text (color=3) with black text (color=1) allowing for two positions relative to linebreak.
	    #   Last two seds replace yellow text (color=6) with black text (color=1) allowing for two positions relative to linebreak.
	    !xxd -p -c 256 owhole.mc | sed 's/ffff1200050002000900/ffff1200050002000000/;s/00000300ffff/00000100ffff/g;s/0300ffff0b00/0100ffff0b00/g;s/00000600ffff/00000100ffff/g;s/0600ffff0b00/0100ffff0b00/g' | xxd -r -p > foobar_edit.mc
	    gkimosaic ( "foobar_edit.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
	    # END METACODE EDIT
	    gflush
	    psi2png ( "home$public_html/frame2.png", clobber+, clean+, verb=2 )
	}

	# Need to comment this out during annealing
#	if ( access("ohigh.mc") ) {
#	    #gkimosaic ( "ohigh.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
#	    # SECTION FOR SED EDIT OF METACODE FILES (to remove olive bkg, yellow text and green text) 08MAR21 JMH
	    #   This does not preserve the editted metacode after the next file is processed - only the output png file.
	    #   First sed replaces the full set_fillarea command at start - changing color from 9 to 0.
	    #   Next two seds replace green text (color=3) with black text (color=1) allowing for two positions relative to linebreak.
	    #   Last two seds replace yellow text (color=6) with black text (color=1) allowing for two positions relative to linebreak.
#	    !xxd -p -c 256 ohigh.mc | sed 's/ffff1200050002000900/ffff1200050002000000/;s/00000300ffff/00000100ffff/g;s/0300ffff0b00/0100ffff0b00/g;s/00000600ffff/00000100ffff/g;s/0600ffff0b00/0100ffff0b00/g' | xxd -r -p > foobar_edit.mc
#	    gkimosaic ( "foobar_edit.mc", nx=1, ny=1, rotate+, interact-, device="psidump" )
#	    # END METACODE EDIT
#	    gflush
#	    psi2png ( "home$public_html/frame7.png", clobber+, clean+, verb=2 )
#	}

    # sleep for a longer interval (used for annealing when thing change slowly)
	# sleep (delay)

    } # loop back to beginning
end

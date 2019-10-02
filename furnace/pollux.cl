procedure pollux
# Display oven stuff remotely on the pollux imtool
# by JMH 01APR92

# you must run this script in the foreground the first time you use it
#	in a window because IRAF networking will prompt you for the password.

# to define the task
#	task $pollux = home$pollux.cl

# setup the remote imtool with the first two displays zoomed by two
# first two displays color, third mono
# blink frames 1,2,3 at 32 second intervals

begin
	set (stdimage="imt1024")
	set (node="pollux")

	while (0<1) {
	    print ("Sending display to imt1024 on pollux.")

# odisp the lid ttmp map
	    odisp (info="ttmp",asp="l",frame=1)
	    ovenw
	    imdkern ("ltest.mc", fr=1, color=203)
#	    imdkern ("/u1d/pilot/angle.mc", fr=1, color=203)

# ograph the last 8 hours
	    ovenw
	    erase frame=2
	    if (access("/u1c/pilot/oshort.mc")) {
		delete ("oshort.mc")
		copy ("/u1c/pilot/oshort.mc", "oshort.mc")
	    }
	    imdkern ("oshort.mc", fr=2)

# display a video image
	    ovenw
		display ("/u1c/pilot/video/pollux1.imh", fr=3)

# odisp the wall ttmp map
	    ovenw
	    odisp (info="ttmp",asp="w",frame=1)
	    ovenw
	    imdkern ("wtest.mc", fr=1, color=203)
#	    imdkern ("/u1d/pilot/wangle.mc", fr=1, color=203)

# ograph the current graph
	    ovenw
	    erase frame=2
	    if (access("/u1c/pilot/onow.mc")) {
		delete ("onow.mc")
		copy ("/u1c/pilot/onow.mc", "onow.mc")
	    }
	    imdkern ("onow.mc", fr=2)

# display a video image
	    ovenw
		display ("/u1c/pilot/video/pollux2.imh", fr=3)

# odisp the base hpwr map
	    ovenw
	    odisp (info="hpwr",asp="b",frame=1) 

# ograph the last 1.5 days
	    ovenw
	    erase frame=2
	    if (access("/u1c/pilot/olong.mc")) {
		delete ("olong.mc")
		copy ("/u1c/pilot/olong.mc", "olong.mc")
	    }
	    imdkern ("olong.mc", fr=2)

# display a video image
	    ovenw
		display ("/u1c/pilot/video/pollux3.imh", fr=3)

# odisp the base ttmp map
	    ovenw
	    odisp (info="ttmp",asp="b",frame=1) 
	    ovenw
	    imdkern ("btest.mc", fr=1, color=203)
#	    imdkern ("/u1d/pilot/angle.mc", fr=1, color=203)

# ograph the aluminum zone
	    ovenw
	    erase frame=2
	    if (access("/u1c/pilot/oalum.mc")) {
		delete ("oalum.mc")
		copy ("/u1c/pilot/oalum.mc", "oalum.mc")
	    }
	    imdkern ("oalum.mc", fr=2)

# display a video image
	    ovenw
		display ("/u1c/pilot/video/pollux4.imh", fr=3)

# odisp the mold ttmp map
	    ovenw
	    odisp (info="ttmp",asp="m",frame=1)
	    ovenw
	    imdkern ("mtest.mc", fr=1, color=203)
#	    imdkern ("/u1d/pilot/angle.mc", fr=1, color=203)
	    ovenw

	}
end

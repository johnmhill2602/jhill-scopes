procedure remote
# Display oven stuff remotely on the remote imtool
# by JMH 01APR92, revised 01FEB94

# Changed so it is rum
# you must run this script in the foreground the first time you use it
#	in a window because IRAF networking will prompt you for the password.

# to define the task
#	task $remote = home$remote.cl

# setup the remote imtool with the first two displays zoomed by two
# (can't do that with saoimage)
# first two displays color, third mono
# (can't do that with saoimage)
# blink frames 1,2,3 at 32 second intervals
# (can't do that with saoimage)

# packages mirror, and tv must be loaded in advance.

begin
	print ("Setting display to imt1024.")
	set (stdimage="imt1024")
	# don't use this with ximtool.

	print ("Setting display magnification to x2.")
	display.xmag=2
	display.ymag=2

	display.erase=yes

	while (0<1) {

	    time

# odisp the lid ttmp map
	    odisp (info="ttmp",asp="l",frame=1)
#	    ovenw
#	    imdkern ("ltest.mc", fr=1, color=203)
#	    imdkern ("/u2/pilot/angle.mc", fr=1, color=203)

# ograph the last 8 hours
	    ovenw
	    if (access("oshort.mc"))
		delete ("oshort.mc")
	    copy ("crater!/u2/pilot/oshort.mc", "oshort.mc")
	    imdkern ("oshort.mc", fr=2)

# display a video image
	    ovenw
	    if (access("remote1.imh"))
		display ("remote1.imh", fr=3)

# odisp the wall ttmp map
	    ovenw
	    odisp (info="ttmp",asp="w",frame=1)
#	    ovenw
#	    imdkern ("wtest.mc", fr=1, color=203)
#	    imdkern ("/u2/pilot/wangle.mc", fr=1, color=203)

# ograph the current graph
	    ovenw
	    if (access("onow.mc"))
		delete ("onow.mc")
	    copy ("crater!/u2/pilot/onow.mc", "onow.mc")
	    imdkern ("onow.mc", fr=2)

# display a video image
	    ovenw
	    if (access("remote2.imh"))
		display ("remote2.imh", fr=3)

# odisp the base hpwr map
#	    ovenw
#	    odisp (info="hpwr",asp="b",frame=1) 

# ograph the last 1.5 days
	    ovenw
	    if (access("olong.mc"))
		delete ("olong.mc")
	    copy ("crater!/u2/pilot/olong.mc", "olong.mc")
	    imdkern ("olong.mc", fr=2)

# display a video image
	    ovenw
	    if (access("remote3.imh"))
		display ("remote3.imh", fr=3)

# odisp the base ttmp map
	    ovenw
	    odisp (info="ttmp",asp="b",frame=1) 
#	    ovenw
#	    imdkern ("btest.mc", fr=1, color=203)
#	    imdkern ("/u2/pilot/angle.mc", fr=1, color=203)

# ograph the aluminum zone
#	    ovenw
#	    if (access("oalum.mc"))
#		delete ("oalum.mc")
#	    copy ("crater!/u2/pilot/oalum.mc", "oalum.mc")
#	    imdkern ("oalum.mc", fr=2)

# display a video image
	    ovenw
	    if (access("remote4.imh"))
		display ("remote4.imh", fr=3)

# odisp the mold ttmp map
	    ovenw
	    odisp (info="ttmp",asp="m",frame=1)
#	    ovenw
#	    imdkern ("mtest.mc", fr=1, color=203)
#	    imdkern ("/u2/pilot/angle.mc", fr=1, color=203)

	}
end

procedure remote
#
# Display oven stuff remotely on the remote ximtool
#
# Created by J. M. Hill, Steward Observatory 01APR92, 
# Revised 01FEB94 JMH, 
# Revised 16JAN97 JMH

# normally the task is defined in furnace.cl, to execute say:
#	remote
# to define the task locally if you have modified it:
#	task $remote = home$remote.cl

# The normal usage is to run the script as "hill" or dorado so as
# not to put any significant load on crater.  dorado should have
# the oven0v2 daemons running to provide current data.

# There are sufficient ovenw commands in this script so as not to put a
# burden on crater's disk.  But ximtool blinking shows the user 4 screens
# in succession.

# ximtool setup
# 	first ximtool display in color, last two mono
# 	blink frames 1,2,3,4 at 32 second intervals

# packages mirror, tv and iis must be loaded in advance.

begin
	display.erase=yes

	display ("dev$pix[*,*]", frame=1)
	display ("dev$pix[-*,*]", frame=2)
	display ("dev$pix[*,-*]", frame=3)
	display ("dev$pix[-*,-*]", frame=4)

	while (0<1) {

	    time

# odisp the lid ttmp map
	    odisp (info="ttmp",asp="l",frame=1)
#	    imdkern ("ltest.mc", fr=1, color=203)

# ograph the last 8 hours
	    ovenw
	    if (access("oshort.mc"))
		delete ("oshort.mc")
	    copy ("crater!/home/pilot/oshort.mc", "oshort.mc")
	    erase (fr=2)
	    if (access("oshort.mc"))
		imdkern ("oshort.mc", fr=2)

# display a video image
	    ovenw
	    if (access("remote1.imh"))
		display ("remote1.imh", fr=3)

# odisp the wall ttmp map
	    ovenw
	    odisp (info="ttmp",asp="w",frame=1)
#	    imdkern ("wtest.mc", fr=1, color=203)

# ograph the current graph
	    ovenw
	    if (access("onowa.mc"))
		delete ("onowa.mc")
	    copy ("crater!/home/pilot/onowa.mc", "onowa.mc")
	    erase (fr=2)
	    if (access("onowa.mc"))
		imdkern ("onowa.mc", fr=2)

# display a video image
	    ovenw
	    if (access("remote2.imh"))
		display ("remote2.imh", fr=4)

# odisp the base hpwr map
#	    ovenw
#	    odisp (info="hpwr",asp="b",frame=1) 

# ograph the last 1.5 days
	    ovenw
	    if (access("olong.mc"))
		delete ("olong.mc")
	    copy ("crater!/home/pilot/olong.mc", "olong.mc")
	    erase (fr=2)
	    if (access("olong.mc"))
		imdkern ("olong.mc", fr=2)

# display a video image
	    ovenw
	    if (access("remote3.imh"))
		display ("remote3.imh", fr=3)

# odisp the base ttmp map
	    ovenw
	    odisp (info="ttmp",asp="b",frame=1) 
#	    imdkern ("btest.mc", fr=1, color=203)

# display a video image
	    ovenw
	    if (access("remote4.imh"))
		display ("remote4.imh", fr=4)

# odisp the mold ttmp map
#	    ovenw
#	    odisp (info="ttmp",asp="m",frame=1)
#	    imdkern ("mtest.mc", fr=1, color=203)

	} # end while
end

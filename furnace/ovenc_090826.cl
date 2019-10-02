procedure ovenc

# script to plot a number of the current oven datasets
#
# uncommented some ographs, added logfile parameter,  JMH 15NOV96
# changed all stdgraph calls to gkimosaic,  JMH 21NOV96
# revised for zone changes, JMH 01MAY97
# alum odisps commented out, JMH 20SEP98
# added whole firing plot, JMH 25SEP98
# updated whole firing parameters for LBT2 prefire, JMH 24FEB00
# updated whole firing parameters for LBT2 casting, JMH 15MAY00
# updated whole firing parameters for LOTIS casting, JMH 29MAR02
# updated whole firing parameters for GMT1 casting, JMH 21JUL05
# updated whole firing parameters for LSST casting, RDL 24March08
# updated whole firing parameters for SPM casting, JMH 23AUG09
# added rotation speed plot for SPM casting, JMH 25AUG09

begin

reset stdimage="imt512"
display.erase=yes

if (!defpac ("mirror"))
    mirror


if ( strlen(ologfile) > 0 ) {
	print ("Starting new copy of ovenc.cl", >> ologfile )
	print ("  version of 25AUG09", >> ologfile )
} # end if

    while (0<1) {

	if ( strlen(ologfile) > 0 ) {
		time ( >> ologfile)
	} # end if

# ograph the pilot default settings
	ovenw;ograph (device="stdvdm")
	delete ( "onowa.mc", verify=no )
	rename ( "uparm$vdm", "onowa.mc" )
	gkimosaic ( "onowa.mc", nx=1, ny=1, interactive- )

# odisp the base ttmp map
	odisp (info="ttmp",asp="b",frame=3) 
	imdkern ("b.mc", fr=3, color=203)
	imdkern ("angle.mc", fr=3, color=203)


# ograph the last 0.5 days
	ovenw;ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-1200,timeroff=20,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z0",factor1=1,
		info2="ztmp",zone2="z0",factor2=1,
		info3="ztmp",zone3="z1",factor3=1,
		info4="ztmp",zone4="z2",factor4=1,
		append=no,subsample=1,device="stdvdm")
	ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-1200,timeroff=20,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z3",factor1=1,
		info2="ztmp",zone2="z4",factor2=1,
		info3="ztmp",zone3="z5",factor3=1,
		info4="",zone4="",factor4=1,
		append=yes,subsample=1,device="stdvdm")
	delete ( "ohalf.mc", verify=no )
	rename ( "uparm$vdm", "ohalf.mc" )
	gkimosaic ( "ohalf.mc", nx=1, ny=1, interactive- )


# odisp the lid ttmp map
	    odisp (info="ttmp",asp="l",frame=1)
	    imdkern ("l.mc", fr=1, color=203)
	    imdkern ("angle.mc", fr=1, color=203)


# ograph the pilot default settings
	ovenw;ograph (device="stdvdm")
	delete ( "onowb.mc", verify=no )
	rename ( "uparm$vdm", "onowb.mc" )
	gkimosaic ( "onowb.mc", nx=1, ny=1, interactive- )


# odisp the wall ttmp map
	odisp (info="ttmp",asp="w",frame=2)
	imdkern ("w.mc", fr=2, color=203)
	imdkern ("wangle.mc", fr=2, color=203)


# ograph the last 1.5 days
	ovenw;ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-3600,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z0",factor1=1,
		info2="ztmp",zone2="z0",factor2=1,
		info3="ztmp",zone3="z1",factor3=1,
		info4="ztmp",zone4="z2",factor4=1,
		append=no,subsample=3,device="stdvdm")
	ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-3600,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z3",factor1=1,
		info2="ztmp",zone2="z4",factor2=1,
		info3="ztmp",zone3="z5",factor3=1,
		info4="",zone4="",factor4=1,
		append=yes,subsample=3,device="stdvdm")
	delete ( "olong.mc", verify=no )
	rename ( "uparm$vdm", "olong.mc" )
	gkimosaic ( "olong.mc", nx=1, ny=1, interactive- )


# odisp the mold ttmp map
	odisp (info="ttmp",asp="m",frame=4) 
	imdkern ("m.mc", fr=4, color=203)
	imdkern ("angle.mc", fr=4, color=203)


# ograph the pilot default settings
	ovenw;ograph (device="stdvdm")
	delete ( "onowc.mc", verify=no )
	rename ( "uparm$vdm", "onowc.mc" )
	gkimosaic ( "onowc.mc", nx=1, ny=1, interactive- )

# odisp the lid hpwr map
	odisp (info="hpwr",asp="l",frame=1) 
	imdkern ("l.mc", fr=1, color=203)
	imdkern ("angle.mc", fr=1, color=203)


# ograph the last 8 hours
	ovenw;ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-800,timeroff=20,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z0",factor1=1,
		info2="ztmp",zone2="z0",factor2=1,
		info3="ztmp",zone3="z1",factor3=1,
		info4="ztmp",zone4="z2",factor4=1,
		append=no,device="stdvdm")
	ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-800,timeroff=20,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z3",factor1=1,
		info2="ztmp",zone2="z4",factor2=1,
		info3="ztmp",zone3="z5",factor3=1,
		info4="",zone4="",factor4=1,
		append=yes,device="stdvdm")
	delete ( "oshort.mc", verify=no )
	rename ( "uparm$vdm", "oshort.mc" )
	gkimosaic ( "oshort.mc", nx=1, ny=1, interactive- )


# odisp the wall hpwr map
	odisp (info="hpwr",asp="w",frame=2) 
	imdkern ("w.mc", fr=2, color=203)
	imdkern ("wangle.mc", fr=2, color=203)


# ograph the pilot default settings, but save as metacode
	ovenw;ograph (device="stdvdm")
	delete ( "onowd.mc", verify=no )
	rename ( "uparm$vdm", "onowd.mc" )
	gkimosaic ( "onowd.mc", nx=1, ny=1, interactive- )

# odisp the base hpwr map
	odisp (info="hpwr",asp="b",frame=3) 
	imdkern ("b.mc", fr=3, color=203)
	imdkern ("angle.mc", fr=3, color=203)


# ograph the last 3 days
	ovenw;ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=60,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z0",factor1=1,
		info2="ztmp",zone2="z0",factor2=1,
		info3="ztmp",zone3="z1",factor3=1,
		info4="ztmp",zone4="z2",factor4=1,
		append=no,subsample=6,device="stdvdm")
	ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=60,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z3",factor1=1,
		info2="ztmp",zone2="z4",factor2=1,
		info3="ztmp",zone3="z5",factor3=1,
		info4="",zone4="",factor4=1,
		append=yes,subsample=6,device="stdvdm")
	delete ( "otres.mc", verify=no )
	rename ( "uparm$vdm", "otres.mc" )
	gkimosaic ( "otres.mc", nx=1, ny=1, interactive- )


# odisp the alum ttmp map
#	    odisp (info="ttmp",asp="a",frame=4) 
#	    imdkern ("a.mc", fr=4, color=203)
#	    imdkern ("angle.mc", fr=4, color=203)

# ograph the aluminum zone
	ovenw;ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-2400,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=10,ylooff=-10,
		info1="etmp",zone1="z5",factor1=.1728,
		info2="ztmp",zone2="z5",factor2=.1728,
		info3="etmp",zone3="z6",factor3=1,
		info4="ztmp",zone4="z6",factor4=1,
		append=no,subsample=2,device="stdvdm")
	delete ( "oalum.mc", verify=no )
	rename ( "uparm$vdm", "oalum.mc" )
	gkimosaic ( "oalum.mc", nx=1, ny=1, interactive- )

# odisp the alum hpwr map
#	    odisp (info="hpwr",asp="a",frame=4) 
#	    imdkern ("a.mc", fr=4, color=203)


# ograph the whole SPM Casting
	ovenw;ograph (dateleft=090821,dateright=INDEF,
		timelori="",timerori="now",timeloff=0400,timeroff=60,
		yhiori="zero",yloori="zero",yhioff=1200,ylooff=0,
		info1="etmp",zone1="z0",factor1=1,
		info2="ztmp",zone2="z0",factor2=1,
		info3="ztmp",zone3="z1",factor3=1,
		info4="ztmp",zone4="z2",factor4=1,
		timeunit="days",
		append=no,subsample=24,device="stdvdm")
	ograph (dateleft=090821,dateright=INDEF,
		timelori="",timerori="now",timeloff=0400,timeroff=60,
		yhiori="zero",yloori="zero",yhioff=1200,ylooff=0,
		info1="etmp",zone1="z3",factor1=1,
		info2="ztmp",zone2="z4",factor2=1,
		info3="ztmp",zone3="z5",factor3=1,
		info4="etmp",zone4="r",factor4=10,
		timeunit="days",
		append=yes,subsample=24,device="stdvdm")
	delete ( "owhole.mc", verify=no )
	rename ( "uparm$vdm", "owhole.mc" )
	gkimosaic ( "owhole.mc", nx=1, ny=1, interactive- )


# odisp the lid htmp map
#	    odisp (info="htmp",asp="l",frame=1) 
#	    imdkern ("l.mc", fr=1, color=203)

# odisp the wall htmp map
#	    odisp (info="htmp",asp="w",frame=2) 
#	    imdkern ("w.mc", fr=2, color=203)

# odisp the base htmp map
#	    odisp (info="htmp",asp="b",frame=3) 
#           imdkern ("b.mc", fr=3, color=203) 

# odisp the alum htmp map
#	    odisp (info="htmp",asp="a",frame=2) 
#           imdkern ("a.mc", fr=2, color=203) 

# graph the rotation speed
	ovenw
	spinplot (rfile="/home/pilot/rspeed.oven0v0", izero="",
		istart=-2500,istop=INDEF,iincr=2500,rmin=7000,rmax=7500,
		append=no,device="stdvdm")
	spinplot (rfile="/home/pilot/rspeed.oven0v2", izero="",
		istart=-2500,istop=INDEF,iincr=2500,rmin=7000,rmax=7500,
		append=yes,device="stdvdm")
	delete ( "ospin.mc", verify=no )
	rename ( "uparm$vdm", "ospin.mc" )
	gkimosaic ( "ospin.mc", nx=1, ny=1, interactive- )


    } # loop back to beginning
end







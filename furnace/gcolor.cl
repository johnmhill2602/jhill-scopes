procedure gcolor

# script to plot a number of the current oven datasets
#
# created 18SEP98

begin

reset stdimage="imt512"
display.erase=yes

# ograph the last 1.5 days
	    ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z0",factor1=1,
		info2="",info3="",info4="",
		append=no,subsample=6,device="stdvdm")
	    delete ( "color3.mc", verify=no )
	    rename ( "uparm$vdm", "color3.mc" )
	    imdkern ( "color3.mc", fr=1, color=203 )

	    ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="ztmp",zone1="z0",factor1=1,
		info2="",info3="",info4="",
		append=yes,subsample=6,device="stdvdm")
	    delete ( "color4.mc", verify=no )
	    rename ( "uparm$vdm", "color4.mc" )
	    imdkern ( "color4.mc", fr=1, color=204 )

	    ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="ztmp",zone1="z1",factor1=1,
		info2="",info3="",info4="",
		append=yes,subsample=6,device="stdvdm")
	    delete ( "color5.mc", verify=no )
	    rename ( "uparm$vdm", "color5.mc" )
	    imdkern ( "color5.mc", fr=1, color=205 )

	    ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="ztmp",zone1="z3",factor1=1,
		info2="",info3="",info4="",
		append=yes,subsample=6,device="stdvdm")
	    delete ( "color6.mc", verify=no )
	    rename ( "uparm$vdm", "color6.mc" )
	    imdkern ( "color6.mc", fr=1, color=206 )

	    ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="ztmp",zone1="z4",factor1=1,
		info2="",info3="",info4="",
		append=yes,subsample=6,device="stdvdm")
	    delete ( "color7.mc", verify=no )
	    rename ( "uparm$vdm", "color7.mc" )
	    imdkern ( "color7.mc", fr=1, color=207 )

	    ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="ztmp",zone1="z5",factor1=1,
		info2="",info3="",info4="",
		append=yes,subsample=6,device="stdvdm")
	    delete ( "color8.mc", verify=no )
	    rename ( "uparm$vdm", "color8.mc" )
	    imdkern ( "color8.mc", fr=1, color=208 )

	    ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-7200,timeroff=40,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="ztmp",zone1="z6",factor1=1,
		info2="",info3="",info4="",
		append=yes,subsample=6,device="stdvdm")
	    delete ( "color3.mc", verify=no )
	    rename ( "uparm$vdm", "color3.mc" )
	    imdkern ( "color3.mc", fr=1, color=203 )

end

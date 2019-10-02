procedure ovenc9
# ograph enhancements by JMH 26MAR92
# making odisp mosaic by JMH 11AUG93

# to define this script for the cl:
#	task $ovenc9 = home$ovenc9.cl

begin
# alloc a larger than usual image buffer
reset stdimage="imt1600"	# 3x3 mosaic of 512x512 odisp images

# using a mosaic like this requires special metacode files for overlays.
# these are made to have the correct scale using graph.vx1,vx2,vy1,vy2.
# saoimage always redisplays at the frame center (a feature?) after odisp.

	    display.erase = yes		# erase before first display

	while (0<1) {

# ograph the pilot default settings with no tricks
#	    ovenw;ograph

# odisp the lid ttmp map
display.xcenter=0.5
display.ycenter=0.84
	    odisp (info="ttmp",asp="l",frame=1,showtc=no)
	    display.erase = no		# don't erase before display

# odisp the lid htmp map
#	    odisp (info="htmp",asp="l",frame=1,showtc=no) 

# odisp the lid hpwr map
display.xcenter=0.16
display.ycenter=0.84
	    odisp (info="hpwr",asp="l",frame=1,showtc=no) 

# ograph the last 8 hours
#	    ovenw;ograph (dateleft=INDEF,dateright=INDEF,
#		timelori="now",timerori="now",timeloff=-800,timeroff=20,
#		yhiori="maxdata",yloori="mindata",yhioff=10,ylooff=-10,
#		info1="etmp",zone1="z0",factor1=1,
#		info2="ztmp",zone2="z0",factor2=1,
#		info3="ztmp",zone3="z4",factor3=1,
#		info4="ztmp",zone4="z5",factor4=1,
#		append=no,device="stdvdm")
#	    delete oshort.mc;rename stdvdm$,oshort.mc;stdgraph oshort.mc

# odisp the wall ttmp map
display.xcenter=0.5
display.ycenter=0.5
	    odisp (info="ttmp",asp="w",frame=2,showtc=no)

# odisp the wall htmp map
#	    odisp (info="htmp",asp="w",frame=2,showtc=no) 

# odisp the wall hpwr map
display.xcenter=0.16
display.ycenter=0.5
	    odisp (info="hpwr",asp="w",frame=2,showtc=no) 

# ograph the pilot default settings, but save as metacode
#	    ovenw;ograph (device="stdvdm")
#	    delete onow.mc;rename stdvdm$,onow.mc;stdgraph onow.mc

# odisp the base ttmp map
display.xcenter=0.5
display.ycenter=0.16
	    odisp (info="ttmp",asp="b",frame=3,showtc=no) 

# odisp the base htmp map
#	    odisp (info="htmp",asp="b",frame=3,showtc=no) 

# odisp the base hpwr map
display.xcenter=0.16
display.ycenter=0.16
	    odisp (info="hpwr",asp="b",frame=3,showtc=no) 

# ograph the last 1.5 days
#	    ovenw;ograph (dateleft=INDEF,dateright=INDEF,
#		timelori="now",timerori="now",timeloff=-3600,timeroff=40,
#		yhiori="maxdata",yloori="mindata",yhioff=10,ylooff=-10,
#		info1="etmp",zone1="z0",factor1=1,
#		info2="ztmp",zone2="z0",factor2=1,
#		info3="ztmp",zone3="z4",factor3=1,
#		info4="ztmp",zone4="z5",factor4=1,
#		append=no,subsample=3,device="stdvdm")
#	    delete olong.mc;rename stdvdm$,olong.mc;stdgraph olong.mc

# odisp the mold ttmp map
display.xcenter=0.84
display.ycenter=0.84
	    odisp (info="ttmp",asp="m",frame=4,showtc=no) 

# ograph the aluminum zone
#	    ovenw;ograph (dateleft=INDEF,dateright=INDEF,
#		timelori="now",timerori="now",timeloff=-2400,timeroff=40,
#		yhiori="maxdata",yloori="mindata",yhioff=10,ylooff=-10,
#		info1="etmp",zone1="z3",factor1=.1728,
#		info2="ztmp",zone2="z3",factor2=.1728,
#		info3="etmp",zone3="z6",factor3=1,
#		info4="ztmp",zone4="z6",factor4=1,
#		append=no,subsample=2,device="stdvdm")
#	    delete oalum.mc;rename stdvdm$,oalum.mc;stdgraph oalum.mc

# odisp the aluminum ttmp map
display.xcenter=0.84
display.ycenter=0.50
	    odisp (info="ttmp",asp="a",frame=4,showtc=no) 

# imdkern the tc labels on the whole mosaic in the saoimage window
#     This file is generated with tcmark, graph and furnace.gkimerge.
#     See the scopes.furnace.new_tcmark help file.
	    imdkern ("big3x3.mc", fr=4, color=203)

	    ovenw	# temporary wait
	} # never end infinite while loop

# an alternate scheme is to:
# 	leave stdimage=imt512
# 	odisp display-
#	display tbnow with xmag=4 ymag=4
# This works better and uses less memory than the above script,
# except that the imdkern overlays have limited resolution.
end

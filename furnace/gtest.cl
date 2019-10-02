procedure gtest

# script to plot a number of the current oven datasets
#   and turn them into a gif image
#
# created 23SEP98 by J. M. Hill, Steward Observatory
# revised 24SEP98

begin

# ograph the last 0.5 days
	ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-1200,timeroff=20,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z0",factor1=1,
		info2="ztmp",zone2="z0",factor2=1,
		info3="ztmp",zone3="z1",factor3=1,
		info4="ztmp",zone4="z6",factor4=1,
		append=no,subsample=1,device="psidump")
	ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-1200,timeroff=20,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z3",factor1=1,
		info2="ztmp",zone2="z4",factor2=1,
		info3="ztmp",zone3="z5",factor3=1,
		info4="",zone4="",factor4=1,
		append=yes,subsample=1,device="psidump")

# flush graphics buffer
	gflush

# convert the postscript to a GIF image
	psi2gif ( "home$public_html/frame0.gif", clobber=yes, clean=yes )

	sleep (20)

# ograph the last 2 days
	ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-4800,timeroff=60,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z0",factor1=1,
		info2="ztmp",zone2="z0",factor2=1,
		info3="ztmp",zone3="z1",factor3=1,
		info4="ztmp",zone4="z6",factor4=1,
		append=no,subsample=6,device="psidump")
	ograph (dateleft=INDEF,dateright=INDEF,
		timelori="now",timerori="now",timeloff=-4800,timeroff=60,
		yhiori="maxdata",yloori="mindata",yhioff=2,ylooff=-2,
		info1="etmp",zone1="z3",factor1=1,
		info2="ztmp",zone2="z4",factor2=1,
		info3="ztmp",zone3="z5",factor3=1,
		info4="",zone4="",factor4=1,
		append=yes,subsample=6,device="psidump")

# flush graphics buffer
	gflush

# convert the postscript to a GIF image
	psi2gif ( "home$public_html/frame1.gif", clobber=yes, clean=yes )


	sleep (20)

# ograph the whole Magellan II Casting
	ograph (dateleft=980909,dateright=INDEF,
		timelori="",timerori="now",timeloff=1400,timeroff=60,
		yhiori="zero",yloori="zero",yhioff=1200,ylooff=0,
		info1="etmp",zone1="z0",factor1=1,
		info2="ztmp",zone2="z0",factor2=1,
		info3="ztmp",zone3="z1",factor3=1,
		info4="ztmp",zone4="z6",factor4=1,
		append=no,subsample=24,device="psidump")
	ograph (dateleft=980909,dateright=INDEF,
		timelori="",timerori="now",timeloff=1400,timeroff=60,
		yhiori="zero",yloori="zero",yhioff=1200,ylooff=0,
		info1="etmp",zone1="z3",factor1=1,
		info2="ztmp",zone2="z4",factor2=1,
		info3="ztmp",zone3="z5",factor3=1,
		info4="etmp",zone4="r",factor4=10,
		append=yes,subsample=24,device="psidump")

# flush graphics buffer
	gflush

# convert the postscript to a GIF image
	psi2gif ( "home$public_html/frame2.gif", clobber=yes, clean=yes )
	
end

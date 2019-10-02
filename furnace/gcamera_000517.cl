# GCAMERA.CL --- script to overplot cameras temperatures.
#
# ograph version created from gband.cl by JMH 13SEP98
# coordinates updated for LBT2 casting 19MAY00

# all the parameters in gcamera.par work like ograph except append

procedure gcamera ()

begin

	# Camera Temperatures A, B, C, D
        # dntx 2310 2020 1133 0200
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="ttmp", r1=165, th1=340, z1=099,
		info2="ttmp", r2=165, th2=070, z2=099,
		info3="ttmp", r3=165, th3=100, z3=099,
		info4="ttmp", r4=165, th4=213, z4=099,
		subsample=subsample, append=no, 
		datadir=datadir, device=device )

	# Camera Temperatures E, F, G
        # dntx 3302 3014 2021
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="ttmp", r1=188, th1=233, z1=099,
		info2="ttmp", r2=188, th2=353, z2=099,
		info3="ttmp", r3=188, th3=113, z3=099,
		info4="", 
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

end

# GBAND.CL --- script to overplot expansion of Inconel bands from LVDTs
#
# ograph version created by JMH 19AUG93
# modified 21AUG93 to not modify any ograph parameters during use.
# added LVDTs 12-15, 10SEP98

# all the parameters in gband.par work like ograph except append

procedure gband ()

begin
	# Plot oven temperatures
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="ztmp", zone1="z4", info2="etmp", zone2="z4",
		info3="ztmp", zone3="z5", info4="ztmp", zone4="z1",
		subsample=subsample, append=no, 
		datadir=datadir, device=device )

	# LVDT readings scaled to oven temperatures.
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="", info2="r0lvdt8", info3="r0lvdt9", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="", info2="r0lvdt10", info3="r0lvdt11", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="", info2="r0lvdt12", info3="r0lvdt15", info4="",
		factor2=38, factor3=38,
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="", info2="r0lvdt13", info3="r0lvdt14", info4="",
		factor2=38, factor3=38,
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

end

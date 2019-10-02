# file to overplot expansion of hearth from LVDTs
# ograph version by JMH 22AUG93

# this should not alter existing epar parameters

procedure glvdt ()

begin

	# Plot aluminum and scaled oven temperatures
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="ztmp", zone1="z7", info2="etmp", zone2="z7",
		info3="ztmp", zone3="z4", factor3=0.1728, info4="",
		subsample=subsample, append=no, 
		datadir=datadir, device=device )

	# LVDT readings scaled to aluminum temperatures.

	# Hearth and Aluminum radius at 350 degrees
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="", info2="r0lvdt0", info3="r0lvdt1", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	# Hearth and Aluminum radius at 160 degrees
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="", info2="r0lvdt2", info3="r0lvdt3", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	# Hearth and Aluminum radius at 340 degrees
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="", info2="r0lvdt4", info3="r0lvdt5", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	# Hearth and Aluminum radius at 170 degrees
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="", info2="r0lvdt6", info3="r0lvdt7", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )
end

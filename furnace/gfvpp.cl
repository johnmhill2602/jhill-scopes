# ograph power panel fase voltages
# J. M. Hill 16APR92, 25AUG93

procedure gfvpp ()

begin
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv000", info2="fv010", info3="fv020", info4="",
		subsample=subsample, append=no, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv100", info2="fv110", info3="fv120", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv200", info2="fv210", info3="fv220", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv300", info2="fv310", info3="fv320", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv400", info2="fv410", info3="fv420", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv500", info2="fv510", info3="fv520", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv600", info2="fv610", info3="fv620", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv700", info2="fv710", info3="fv720", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fv800", info2="fv810", info3="fv820", info4="",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

end

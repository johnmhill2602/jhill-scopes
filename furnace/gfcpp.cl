# ograph power panel fase currents
# J. M. Hill 15FEB94
# Note that fase currents are only sampled once per minute, so they may not
# adequately reflect the total power draw on that circuit.

procedure gfcpp ()

begin
	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc000", info2="fc010", info3="fc020", info4="pc000",
		subsample=subsample, append=no, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc100", info2="fc110", info3="fc120", info4="pc100",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc200", info2="fc210", info3="fc220", info4="pc200",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc300", info2="fc310", info3="fc320", info4="pc300",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc400", info2="fc410", info3="fc420", info4="pc400",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc500", info2="fc510", info3="fc520", info4="pc500",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc600", info2="fc610", info3="fc620", info4="pc600",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc700", info2="fc710", info3="fc720", info4="pc700",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

	ograph (dateleft=dateleft, dateright=dateright,
		timelorigin=timelorigin, timerorigin=timerorigin,
		timeloffset=timeloffset, timeroffset=timeroffset,
		yhiorig=yhiorig, yloorig=yloorig,
		yhioffs=yhioffs, ylooffs=ylooffs,
		info1="fc800", info2="fc810", info3="fc820", info4="pc800",
		subsample=subsample, append=append, 
		datadir=datadir, device=device )

end

procedure mygraph (fname)

# Created by Imelda Kirby, Steward Observatory
# Revised 19JAN97  JMH

string	fname		{ prompt="filename to use: " }

begin
	string tmpfile, tmpout, tmptime, tmpplot, tmpfname

	
	tmpfile = mktemp ('tmp$mg')
	tmpout  = mktemp ('tmp$mg')
	tmptime = mktemp ('tmp$mg')
	tmpplot = mktemp ('tmp$mg')
	tmpfname = fname

	level ('@'//tmpfname, >> tmpfile)
	match ('peak ccf', tmpfile, > tmpout)
	print (tmpout)
	hselect ('@'//tmpfname, '$I,TIME', yes, > tmptime)
	print (tmptime)

	column (tmpout, 10)
	rename ('col.10', 'peak')
	delete ('col.*', ver-)
	print (tmpout)
	column (tmptime, 2)
	rename ('col.2', 'time')
	delete ('col.*', ver-)
	print (tmptime)

	join ('time', 'peak', > tmpplot)
	print (tmpplot)
	type (tmpplot)
	del ('time, peak')

	graph (tmpplot, xlabel='Time', ylabel='Level', pointmode=yes, title='MyGraph')

#	del ('/tmp/mg*')
end


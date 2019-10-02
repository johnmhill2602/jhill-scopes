procedure temp.cl

# script to export oven temperature

# This script looks at the present time and then generates a
# wtextimage command that prints the latest zone temperatures from
# the previous minute.

# Warning: This script accesses the oven data on crater!
#
# Created by J. M. Hill, 09JUN97 
# Revised 09SEP98

string outfile="/net/medusa/d0/ftp/pub/oven/temperature"
int verb=3
struct* list1

begin

	string wday, month, junk, year
	int jj, iday, minutes
	real hours
	string yy, mm, dd

	date | scan(wday, month, iday, hours, junk, year)

	minutes = (hours * 60) - 1

	yy = substr( year, 3, 4 )
	
	if ( month == "Jan" )
		mm = "01"
	else if ( month == "Feb" )
		mm = "02"
	else if ( month == "Mar" )
		mm = "03"
	else if ( month == "Apr" )
		mm = "04"
	else if ( month == "May" )
		mm = "05"
	else if ( month == "Jun" )
		mm = "06"
	else if ( month == "Jul" )
		mm = "07"
	else if ( month == "Aug" )
		mm = "08"
	else if ( month == "Sep" )
		mm = "09"
	else if ( month == "Oct" )
		mm = "10"
	else if ( month == "Nov" )
		mm = "11"
	else if ( month == "Dec" )
		mm = "12"
	else
		mm = "00"

	# delete the old file
	if ( access(outfile) )
		delete ( outfile, verify=no )

	# make an unformatted wtext to trick a parameter bug.
	print ( 'wtext dev$pix[1,1] STDOUT header=no' ) | cl

	if ( iday < 10 ) {
		print ( 'wtext /home/pilot/ztmp', yy, mm, '0',
			str(iday), '.imh[1:2,', str(minutes),
			'] ', outfile, ' header=no format="8.1f"' )
		print ( 'wtext /home/pilot/ztmp', yy, mm, '0',
			str(iday), '.imh[1:2,', str(minutes),
			'] ', outfile, ' header=no format="8.1f"' ) | cl
	}
	else {
		print ( 'wtext /home/pilot/ztmp', yy, mm,
			str(iday), '.imh[1:2,', str(minutes),
			'] ', outfile, ' header=no format="8.1f"' )
		print ( 'wtext /home/pilot/ztmp', yy, mm,
			str(iday), '.imh[1:2,', str(minutes),
			'] ', outfile, ' header=no format="8.1f"' ) | cl
	}

end







procedure temp()

# script to export oven temperature to a file

# This script looks at the present time and then generates a
# wtextimage command that prints the latest zone temperatures from
# the previous minute into a text file.

# Warning: This script accesses the oven data on crater!
#     (It could be more general than that by changing outfile.)
#
# Created by J. M. Hill, 09JUN97 
# Revised 09SEP98
# Removed struct* list1 23JAN12 JMH
# Converted to direct wtextimage call 24JAN12 JMH
# Ignore zone parameters in favor of 1:7 17SEP15 JMH
# Add scatter output file 18SEP15 JMH


# script parameters
string outfile1="/home/pilot/public_html/temperature"
int zone1=0   # zone 0 for lid temperature
string outfile2="/home/pilot/public_html/rotation"
int zone2=20  # zoneR=20 for rotation speed
string outfile3="/home/pilot/public_html/scatter"
int zone3=0   # zone 0 for lid temperature
int verb=3    # verbosity (not used)

begin

# repeated calls (~300) to this script seems to make the error
#      INTERNAL ERROR on line 27: dictionary full
# It seems to be in piping the wtext command to the cl
# how can we stop that?  23JAN12 JMH
# Apparently fixed by making the wtext command directly in program mode.
# 24JAN12 JMH

# declarations
	string datafile1, datafile2, datafile3
	string wday, month, junk, year
	int iday, minutes, index1, index2, index3
	real hours
	string yy, mm, dd

# convert the zone number to a 1-based index for the data file
	index1 = zone1+1
	index2 = zone2+1
	index3 = zone3+1

# get the date
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

# process the first zone if zone number was >=0
    if ( index1 > 0 ) {
	# delete the old file
	if ( access(outfile1) )
		delete ( outfile1, verify=no )

	# make an unformatted wtext to trick a parameter bug.
	# print ( 'wtext dev$pix[1,1] STDOUT header=no pixels=yes' ) | cl
	# This prints "38" on a single line?


	if ( iday < 10 ) {
		datafile1 = '/home/pilot/ztmp'//yy//mm//'0'//str(iday)//'.imh[1:7,'//str(minutes)//']'
		# print (datafile1)
		wtextimage (datafile1, outfile1, header=no, pixels=yes, format="8.1f")
	}
	else {
		datafile1 = '/home/pilot/ztmp'//yy//mm//str(iday)//'.imh[1:7,'//str(minutes)//']'
		# print (datafile1)
		wtextimage (datafile1, outfile1, header=no, pixels=yes, format="8.1f")
	}
    } # end if index1

# process the second zone if zone number was >= 0
    if ( index2 > 0 ) {
	# delete the old file
	if ( access(outfile2) )
		delete ( outfile2, verify=no )

	# make an unformatted wtext to trick a parameter bug.
	# print ( 'wtext dev$pix[1,1] STDOUT header=no pixels=yes' ) | cl
	# This prints "38" on a single line?

	if ( iday < 10 ) {
		datafile2 = '/home/pilot/ztmp'//yy//mm//'0'//str(iday)//'.imh['//str(index2)//','//str(minutes)//']'
		# print (datafile2)
		wtextimage (datafile2, outfile2, header=no, pixels=yes, format="8.3f")
	}
	else {
		datafile2 = '/home/pilot/ztmp'//yy//mm//str(iday)//'.imh['//str(index2)//','//str(minutes)//']'
		# print (datafile2)
		wtextimage (datafile2, outfile2, header=no, pixels=yes, format="8.3f")
	}
    } # end if index2

# process the third zone if zone number was >=0
    if ( index3 > 0 ) {
	# delete the old file
	if ( access(outfile3) )
		delete ( outfile3, verify=no )

	if ( iday < 10 ) {
		datafile3 = '/home/pilot/zsct'//yy//mm//'0'//str(iday)//'.imh[1:7,'//str(minutes)//']'
		# print (datafile3)
		wtextimage (datafile3, outfile3, header=no, pixels=yes, format="8.1f")
	}
	else {
		datafile3 = '/home/pilot/zsct'//yy//mm//str(iday)//'.imh[1:7,'//str(minutes)//']'
		# print (datafile3)
		wtextimage (datafile3, outfile3, header=no, pixels=yes, format="8.1f")
	}
    } # end if index3

end





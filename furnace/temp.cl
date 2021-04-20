procedure temp()

# script to export oven temperature (scatter, power) to a file(s)

# This script looks at the present time and then generates a
# wtextimage command that prints the latest zone temperatures from
# the previous minute into a text file.

# Warning: This script accesses the oven data on crater!
# Warning: It also assumes that you are user pilot with write permission.
#     (It could be more general than that by changing outfile.)
#
#
# Created by J. M. Hill, 09JUN97 
# Revised 09SEP98
# Removed struct* list1 23JAN12 JMH
# Converted to direct wtextimage call 24JAN12 JMH
# Ignore zone parameters in favor of 1:7 17SEP15 JMH
# Add scatter output file 18SEP15 JMH
# Modifed for Linux use 20JAN21 JMH
## new date format for Fedora (date -R)
## use .fits file instead of .imh
# Add hpwr stats 05MAR21 JMH
# Change format 8.3f to 10.3f 08MAR21 JMH
# Use "date +%g%m%d" to simplify this code 12APR21 JMH (from TomT)


# script parameters
string outfile1="/home/pilot/public_html/temperature"
int zone1=0   # zone 0 for lid temperature+
string outfile2="/home/pilot/public_html/rotation"
int zone2=20  # zoneR=20 for rotation speed
string outfile3="/home/pilot/public_html/scatter"
int zone3=0   # zone 0 for lid temperature+
string outfile4="/home/pilot/public_html/power"
int zone4=0   # zone 0 for lid temperature+
int verb=3    # verbosity (not used)


begin

# repeated calls (~300) to this script seems to make the error
#      INTERNAL ERROR on line 27: dictionary full
# It seems to be in piping the wtext command to the cl
# how can we stop that?  23JAN12 JMH
# Apparently fixed by making the wtext command directly in program mode.
# 24JAN12 JMH


# declarations
	string datafile1, datafile2, datafile3, datafile4
	int index1, index2, index3, index4
	string fulldate
	int minutes
	real hours

# convert the oven zone number to a 1-based index for the data file
	index1 = zone1+1
	index2 = zone2+1
	index3 = zone3+1
	index4 = zone4+1
	
# get the date and time
	date "+%g%m%d" | scan(fulldate)  #Fedora - scan to a string
	date "+%k:%M" | scan(hours)  #Fedora - scan to a real
	minutes = (hours * 60) - 1 # fulltime was sexagesimal
	
# process the first zone if zone number was >=0
    if ( index1 > 0 ) {
	# delete the old file
	if ( access(outfile1) )
		delete ( outfile1, verify=no )

	datafile1 = '/home/pilot/ztmp'//fulldate//'.fits[1:7,'//str(minutes)//']'
	#print (datafile1)
	wtextimage (datafile1, outfile1, header=no, pixels=yes, format="10.1f")
    } # end if index1

# process the second zone if zone number was >= 0
    if ( index2 > 0 ) {
	# delete the old file
	if ( access(outfile2) )
		delete ( outfile2, verify=no )

	datafile2 = '/home/pilot/ztmp'//fulldate//'.fits['//str(index2)//','//str(minutes)//']'
	#print (datafile2)
	wtextimage (datafile2, outfile2, header=no, pixels=yes, format="10.3f")
    } # end if index2

# process the third zone if zone number was >=0
    if ( index3 > 0 ) {
	# delete the old file
	if ( access(outfile3) )
		delete ( outfile3, verify=no )

	datafile3 = '/home/pilot/zsct'//fulldate//'.fits[1:7,'//str(minutes)//']'
	#print (datafile3)
	wtextimage (datafile3, outfile3, header=no, pixels=yes, format="10.1f")
    } # end if index3


# process the fourth zone if zone number was >=0
    if ( index4 > 0 ) {
	# delete the old file
	if ( access(outfile4) )
		delete ( outfile4, verify=no )

	datafile4 = '/home/pilot/hpwr'//fulldate//'.fits[1:270,'//str(minutes)//']'
	#print (datafile4)
	imstat (datafile4, fields="mean,stddev,min,max,npix", format=no, > outfile4)
    } # end if index4

end



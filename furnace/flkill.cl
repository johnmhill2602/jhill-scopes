procedure flkill ()

# cl script to deselect (and discharge) flash units with the new video system.
# Created 15JUN97 by J. M. Hill, Steward Observatory

int	verb=4  		{prompt="verbosity"}
string	version="15 June 1997" {prompt="Version date of this routine"}

#.help
# How to deselect the flashed
#	fu> flkill test a cd
#
# -----  More details of how this script works  -----
#
# The unix command to deselect the flashes os:
#    /opt/vxworks/local/tcs oven0v1 flkill
# The appropriate vxworks software must be loaded in oven0v1 using:
	# iam "vwuser"
	# routeAdd "0.0.0.0", "128.196.32.253"
	# < /home/skip/misc/vxworks/video/startup.cmd
#
# For this script to work, the 'tcs' task from unix must be previously 
# defined as a foreign task to IRAF.  (handled in furnace.cl)
#    task $tcs = "$/opt/vxworks/local/tcs oven0v1"
#
# The syntax used to call tcs from IRAF in this cl script is:
#    tcs flkill
#
# flkill deselects and discharges any flash which was selected by
# a previous usage of takepic.
#.endhelp

begin
	# define variables
	string command, part1, part1h, part2, part3

	# create the full command string
	command = "tcs flkill"

	# execute the command (send it to oven0v1)
	tcs ( "flkill" )

	if (verb > 3)
	    print ("FLKILL>   ",command)

	if (verb > 4)
	    print ("FLKILL is complete.")
end

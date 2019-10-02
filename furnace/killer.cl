procedure killer

# cl script to perform widespread Unix killing
# Created 09FEB93 by J. M. Hill, Steward Observatory
# Added Solaris branches 08SEP94  JMH
# Added double keyword option 07NOV96

string  matc_a1	{"N" ,prompt="first key for Match A"}
string  matc_a2	{"" ,prompt="second key for Match A"}
string  matc_b1	{"N" ,prompt="first key for Match B"}
string  matc_b2	{"" ,prompt="second key for Match B"}
string  uname	{"hill" ,prompt="username for all Kills"}
int	verb=4  {prompt="verbosity"}
string	version="07 November 1996" {prompt="Version date of this routine"}
struct	*list1

begin
	# define variables
	file	temp1, temp2, temp3
	int	ipid
	string	junk

	temp1 = ".killer_temp1"
	temp2 = ".killer_temp2"
	temp3 = ".killer_temp3"
	if ( access(temp1) )
	    delete (temp1, verify=no)
	if ( access(temp2) )
	    delete (temp2, verify=no)
	if ( access(temp3) )
	    delete (temp3, verify=no)

	print ("KILLER preparing the hit list.")
	time
	print (" ")

	# Get the all the PID numbers and other info for all tasks
	# 	How could we do this without invoking the csh?
	# Branch for SunOS or Solaris version of "ps"
	if ( envget("arch") == ".ssun" )
	    !ps -efc > .killer_temp1
	else if ( envget("arch") == ".sparc" )
	    !ps -aux > .killer_temp1
	else
	    print ("Unix architecture is unknown. ", envget("arch"))

	# Get the PIDs you want to kill in Kill A
	if ( strlen(matc_a1) > 0 || strlen(matc_a2) > 0 )
	  match (matc_a1, temp1) |match (matc_a2) |match (uname, > temp2)

	# Get the PIDs you want to kill in Kill B
	if ( strlen(matc_b1) > 0 || strlen(matc_b2) > 0 )
	  match (matc_b1, temp1) |match (matc_b2) |match (uname, >> temp2)

	if ( access(temp2) ) {
  	  #killing in reverse PID order is need to free the IRAF job slot.
	  sort (temp2, col=2, reverse=yes, > temp3)

	  type (temp3)
	  print ("Hit ^C now if you do not want to kill these tasks!!!!!!")
	  sleep (6)

	  list1 = temp3
	  # loop over the list of jobs to kill
	  while (fscan(list1, junk, ipid) != EOF) {
	    print (" Killing PID ", ipid)
	    print ("!kill -9 ", ipid) | cl
	  } # end while

	  print ("KILLER is complete.")
	} # end if
	else {
	  print ("KILLER could not find any jobs that matched your specifications.")
	} # end else

	delete (temp1, verify=no)
	if ( access(temp2) )
		delete (temp2, verify=no)
	if ( access(temp3) )
		delete (temp3, verify=no)

end

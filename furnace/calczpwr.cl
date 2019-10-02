# CALCZPWR.CL --- calculate average zone powers
#
# This script calculates the total hpwr applied by the heaters in the
#	specified zone of the oven.  A sum of the hpwr data for all
#	heaters in the specified zone is generated with units of
#	1/4 second power units.  To convert from P.U. to kilowatts,
#	divide by 240 and multiply by 7.5.

# As of June 1997, this script runs imreplace on the hpwr images before 
#	adding them in order to prevent imarith from choking on INDEF data 
#	values from the future or data dropouts.

# Limitations: The script only does one zone at a time.
#              ograph can't graph the result

procedure  calczpwr (datatxt, hpwrimages)

string  datatxt      {prompt="databasc text file of oven database"}
string  hpwrimages   {prompt="List of hpwr images to process"}
string	zone	     {prompt="Zone number (i.e. Z3)"}
string  zpwrimages   {prompt="List of output images"}
string	version="10 June 1997"	{prompt="Version date of this routine"}

struct *list1
struct *list2
struct *list3

begin
	# define variables
	int  i, j
	int	pfe		# heater address
	int	hindex		# heater index
	struct  name
	string	str, zn
	file  image, temp1, temp2, temp3, temp4

	# expand the input image list into a file
	temp1=mktemp("tmp$temp")
	sections(hpwrimages, option="root", >temp1)
	list1 = temp1

	zn = zone//" "

	print ("Extracting Zone: ", zn)

	# match the zone id in the database file
	temp2=mktemp("tmp$temp")
	match (pattern=zn, files=datatxt, stop=no) |
	match (pattern="he0", files="", stop=no, > temp2)

	# expand the output file list into a file
	temp3=mktemp("tmp$temp")
	sections(zpwrimages, option="root", >temp3)
	list3 = temp3

	# temporary image name
	temp4=mktemp("tmp$temp") // ".imh"

	cache ("imarith")

	# do each hpwr image in the list
	while (fscan(list1, image) !=EOF) {

	    print ("Processing hpwr: ", image )

	    # copy the data to a temporary image
	    imcopy (image, temp4, verbose=yes)

	    # strip the INDEF values from the image
	    imreplace ( temp4, value=0, lower=241, upper=INDEF )

	    # get output image name
	    if (fscan(list3, name) !=EOF) {

		j = 0
		list2 = temp2

		# loop over heaters in the zone
		while (fscan(list2, str, pfe) !=EOF) { 

		    hindex = pfe - int(pfe/100)*70 + 1
		    print (str,"  PFE ",pfe,"  INDEX ",hindex)
		    j = j + 1

		    # add in the hpwr data for that heater
		    if (j == 1)
			imcopy (temp4//"["//hindex//",*]", name, verbose=yes)
		    else 
			imarith (name, "+", temp4//"["//hindex//",*]", name, verbose=yes)


		} # end while loop over databae

		print ("Added ",j," images for zone ",zn)

		# put a title on the output image
		hedit (name, "i_title",
			"Total power in "//j//" heaters for zone "//zn,
			update=yes, verify=no)

	    }	# end if for zpwr images

	    # imdelete the temporary image
	    imdelete ( temp4, go_ahead=yes, verify=no )

	}	# end of loop over hpwr images

	delete (temp1, verify=no)
	delete (temp2, verify=no)
	delete (temp3, verify=no)
	list1 = ""
	list2 = ""
	list3 = ""
end


procedure fhselect (fname)

# cl script to convert a FITS image to IRAF format and hselect it.
# Created 02FEB94 by J. M. Hill, Steward Observatory
# Version 07JAN97 -- Temporary files in tmp$.
# Version 14SEP98 -- fits file "*"

string  fname			{prompt="list of FITS image to read"}
file	iname=""		{prompt="temporary IRAF image name"}
string	ifields="$I,CAMERA,STROBES,SHUTTER,GAIN,OFFSET,TIME,CARD" {prompt="fields for extraction"}
bool	isave=no		{prompt="save IRAF image"}
int	verb=4  		{prompt="verbosity"}
string	version="14 September 1998" {prompt="Version date of this routine"}
struct	*list1

begin
	# define variables
	file rname, jname, gname, temp1

	# expand 'fname' into a list 
	temp1=mktemp("tmp$temp")
	files(fname, >temp1)
	list1 = temp1

	# loop over list of files
	while ( fscan(list1, gname) != EOF) {	

	    # check for .fts extension
	    if ( substr(gname, strlen(gname)-3, strlen(gname) ) == ".fts" )
		rname = gname
	    else
		rname = gname // ".fts"

	    # generate default IRAF image name
	    # warning: old files with this name will be clobbered
	    if ( strlen(iname) == 0 ) {
		jname = substr(rname, 1, strlen(rname)-4) // ".imh"
		while (stridx("/", jname) > 0) {
		# strip leading directory paths
		    jname = substr(jname,stridx("/",jname)+1,strlen(jname))
		} #end while
		while (stridx("$", jname) > 0) {
		# strip leading indirect path
		    jname = substr(jname,stridx("$",jname)+1,strlen(jname))
		} #end while
	    } # end if
	    else {
		# use specified default name and path
		jname = iname
	    } # end else

	    # does the temporary IRAF image already exist?
	    if ( access(jname) )
		# delete the temporary IRAF image
		imdelete (jname, verify=no)

	    # read the FITS image with task rfits
	    rfits (rname, file_list="*", iraf_file=jname, make_image=yes,
		long_header=no, short_header=no, datatype="",
		scale=no, oldirafname=no, offset=0)

	    # hselect the image using the preset hselect parameters
	    hselect (image=jname, fields=ifields, expr=yes)

	    if ( !isave )
		# delete the temporary IRAF image
		imdelete (jname, verify=no)

	} # end while

	delete(temp1,verify=no)
        list1=""

	print ("FHSELECT is complete.")
end

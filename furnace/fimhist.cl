procedure fimhist (fname)

# cl script to convert a FITS image to IRAF format and imhist it.
# Created 31JAN94 by J. M. Hill, Steward Observatory
# Version 07JAN97 -- Temporary files in tmp$.

string  fname			{prompt="list of FITS image to read"}
string  iname=""		{prompt="temporary IRAF image name"}
string	isect=""		{prompt="image section for histogram"}
bool	isave=no		{prompt="save IRAF image"}
int	verb=4  		{prompt="verbosity"}
string	version="07 January 1997" {prompt="Version date of this routine"}
struct	*list1

begin
	# define variables
	string rname, sname, jname, gname, temp1

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
	    rfits (rname, file_list=1, iraf_file=jname, make_image=yes,
		long_header=no, short_header=no, datatype="",
		scale=no, oldirafname=no, offset=0)

	    # add on image section if any
	    sname = jname // isect

	    # imhist the image using the preset imhist parameters
	    imhist (sname)

	    if ( !isave )
		# delete the temporary IRAF image
		imdelete (jname, verify=no)

	} # end while

	delete(temp1,verify=no)
        list1=""

	print ("FIMHIST is complete.")
end

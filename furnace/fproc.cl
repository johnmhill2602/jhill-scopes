procedure fproc (fname,dname)

# cl script to convert a FITS image to IRAF format 
#	subtract a dark frame, copy the banner and export to GIF format
# Created 23JAN97 by J. M. Hill, Steward Observatory

string  fname			{prompt="list of FITS image to read"}
string  dname			{prompt="list of FITS darks to read"}
string  iname=""		{prompt="temporary IRAF image name"}
string  jname=""		{prompt="temporary IRAF dark name"}
string	format="gif"		{prompt="image format for export"}
bool    rotate=no		{prompt="rotate image"}
bool	isave=no		{prompt="save IRAF image"}
int	verb=4  		{prompt="verbosity"}
string	version="23 January 1997" {prompt="Version date of this routine"}
struct	*list1
struct  *list2

begin
	# define variables
	string rname, sname, pname, pname2, qname, gname, hname
	string temp1, temp2, zname, zname2, zname3, ename

	# expand 'fname' into a list 
	temp1=mktemp("tmp$temp")
	files(fname, >temp1)
	list1 = temp1

	# expand 'dname' into a list 
	temp2=mktemp("tmp$temp")
	files(dname, >temp2)
	list2 = temp2

	# loop over list of input images
	while ( fscan(list1, gname) != EOF) {	

	# get the input file

	    # check for .fts extension
	    if ( substr(gname, strlen(gname)-3, strlen(gname) ) == ".fts" )
		rname = gname
	    else
		rname = gname // ".fts"

		    # generate default IRAF image name
	    # warning: old files with this name will be clobbered
	    if ( strlen(iname) == 0 ) {
		pname = substr(rname, 1, strlen(rname)-4) // ".imh"
		while (stridx("/", pname) > 0) {
		# strip leading directory paths
		    pname = substr(pname,stridx("/",pname)+1,strlen(pname))
		} #end while
		while (stridx("$", pname) > 0) {
		# strip leading indirect path
		    pname = substr(pname,stridx("$",pname)+1,strlen(pname))
		} #end while
	    } # end if
	    else {
		# use specified default name and path
		pname = iname
	    } # end else

	    # does the temporary IRAF image already exist?
	    if ( access(pname) )
		# delete the temporary IRAF image
		imdelete (pname, verify=no)

	    # read the FITS image with task rfits
	    rfits (rname, file_list=1, iraf_file=pname, make_image=yes,
		long_header=no, short_header=yes, datatype="",
		scale=no, oldirafname=no, offset=0)

	# get the dark file
	if ( fscan(list2, hname) != EOF) {	

	    # check for .fts extension
	    if ( substr(hname, strlen(hname)-3, strlen(hname) ) == ".fts" )
		sname = hname
	    else
		sname = hname // ".fts"

		    # generate default IRAF image name
	    # warning: old files with this name will be clobbered
	    if ( strlen(iname) == 0 ) {
		qname = substr(sname, 1, strlen(sname)-4) // ".imh"
		while (stridx("/", qname) > 0) {
		# strip leading directory paths
		    qname = substr(qname,stridx("/",qname)+1,strlen(qname))
		} #end while
		while (stridx("$", qname) > 0) {
		# strip leading indirect path
		    qname = substr(qname,stridx("$",qname)+1,strlen(qname))
		} #end while
	    } # end if
	    else {
		# use specified default name and path
		qname = jname
	    } # end else

	    # does the temporary IRAF image already exist?
	    if ( access(qname) )
		# delete the temporary IRAF image
		imdelete (qname, verify=no)

	    # read the FITS image with task rfits
	    rfits (sname, file_list=1, iraf_file=qname, make_image=yes,
		long_header=no, short_header=yes, datatype="",
		scale=no, oldirafname=no, offset=0)

	} # end if

	# subtract the two images and fix the banner
	    zname = substr(pname, 1, strlen(pname)-4) // "_dif.imh"

	    # does the temporary IRAF image already exist?
	    if ( access(zname) )
		# delete the temporary IRAF image
		imdelete (zname, verify=no)

	    imarith ( pname, "-", qname, zname, verbose=no )

	    pname2 = substr(pname, 1, strlen(pname)-4) // "[1:495,33:51]"
	    zname2 = zname // "[1:495,33:51]"
	    imcopy ( pname2, zname2, verbose=no )

	    if ( rotate ) {
		zname3 = zname // "[*,-*]"
		imtranspose ( zname3, zname )
	    } # end if rotate

	# save the IRAF image if no format specified.
	    if ( strlen(format) == 0 ) {
		if ( !isave ) {
		# delete the temporary IRAF images
		    imdelete (pname, verify=no)
		    imdelete (qname, verify=no)
		} # end if
	    }
	    else {
		# create the name of the export image
		ename = substr(pname, 1, strlen(pname)-4) // "." // format

		# export is from package imcnv which must be loaded
		# export the image using the selected format
		export (zname, ename, format=format, header=no, bswap=no)

		if ( !isave ) {
		# delete the temporary IRAF images
		    imdelete (pname, verify=no)
		    imdelete (qname, verify=no)
		    imdelete (zname, verify=no)
		} # end if
	    } # end else

	} # end while

	delete(temp1,verify=no)
        list1=""
	delete(temp2,verify=no)
        list2=""

	print ("FPROC is complete.")
end

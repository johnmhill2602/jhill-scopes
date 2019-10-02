# AUTOS -- automatic generator of ograph scripts

include	<time.h>
include	<ctype.h>

procedure t_autos()

.help
#  Description
	AUTOS is a text-processor to automatically generate an ograph
script from a section of an oven databasc file.  You may use match or a text
editor to process the databasc file down to the info you want to plot.
Or you may use the parameters of autos itself to limit the selection of
heaters or thermocouples.

#  Sample output script:

# dntx 3203 3204 3210 3211
ograph noven=0 \\
info1="ttmp" r1=188 th1=240 z1=036 \\
info2="ttmp" r2=188 th2=278 z2=036 \\
info3="ttmp" r3=110 th3=064 z3=000 \\
info4="ttmp" r4=117 th4=078 z4=000 

#  Oven Limits
The official definitions of the various oven aspects are found in
 "mirror$src/odisp/tc_he_bounds.h" --- a header file for thermocouple
 and heater boundarys.

define HBMIN 	 -1.			# base minimum and maximum z values
define HBMAX 	  6.
define HLMIN 	 52.			# lid minimum and maximum z values
define HLMAX 	 95.
define HWMIN 	191.			# wall minimum and maximum radii
define HWMAX 	193.
define HMMIN     19.			# mold minimum and maximum z values
define HMMAX     21.
define HAMIN     -11.			# alum minimum and maximum z values
define HAMAX     -9.

define TBMIN 	 -1.			# base minimum and maximum z values
define TBMAX 	  6.
define TLMIN 	 52.			# lid minimum and maximum z values
define TLMAX 	 95.
define TWMIN 	187.			# wall minimum and maximum radii
define TWMAX 	193.
define TMMIN     19.			# mold minimum and maximum z values
define TMMAX     21.
define TAMIN     -11.			# alum minimum and maximum z values
define TAMAX     -9.

#  History
	27MAR92 - Created by J. M. Hill, Steward Observatory
	30MAR92 - How to printf a \\ to continue a script line.
	15FEB94 - Extend to hpwr capability
	06JAN97 - entities selectable via RTZ limits
	
#  Future Work
	Sort the entries
	Implement output file
.endhelp

#  Parameter declarations
pointer	datafile                # Input files
pointer outfile	  		# output file name (optional)
bool	clobout			# clobber existing output file?
pointer gtype                   # type of data to graph
int     ract, rmin, rmax
int     thact, thmin, thmax
int     zact, zmin, zmax
int     iinfo                   # first info param to specify (still buggy)
int     finfo                   # last info param to specify
int	verbosity		# controls amount of output text

#  Variable Declarations
char	time[SZ_TIME]
string  version	"26-MAR-97"		# version date of code

int     jj, kk, stat, ii, mm
char    rad[3,4], theta[3,4], zzz[3,4], hzone[3,4], id[4,4], nnn[4,4]
bool    out
pointer	fd, od
pointer	sp			# stack pointer
pointer	linebuf, junk, rtza, rtzb, dntx, type  # pointer for text storage
pointer zone, beam, tlck

# declare functions
int	clgeti()
bool	clgetb()
int     ctoi()
int	open ()
int	access()
int	getline()
long	clktime()
int	strlen()
bool    streq()

begin
   # Get output verbosity parameter
        verbosity = clgeti ("verbosity")

   # Introduce program
	if (verbosity >= 5) {
	   call printf ("#AUTOS, ograph script generator --- SPP Version of %s\n")
		call pargstr (version)

	   # Get Date and Time
	   call cnvtime (clktime(0), time, SZ_TIME)
	   call printf ("#       Executed on: %s\n\n")
	       call pargstr (time)
	   call flush (STDOUT)
	} # end if

	call smark (sp)

  # allocate memory
	call salloc (linebuf, SZ_LINE, TY_CHAR)
	call salloc (junk, SZ_LINE, TY_CHAR)
	call salloc (dntx, SZ_LINE, TY_CHAR)
	call salloc (rtza, SZ_LINE, TY_CHAR)
	call salloc (rtzb, SZ_LINE, TY_CHAR)
	call salloc (type, SZ_LINE, TY_CHAR)
	call salloc (zone, SZ_LINE, TY_CHAR)
	call salloc (beam, SZ_LINE, TY_CHAR)
	call salloc (tlck, SZ_LINE, TY_CHAR)
	call salloc (gtype, SZ_LINE, TY_CHAR)
	call salloc (datafile, SZ_FNAME, TY_CHAR)
	call salloc (outfile, SZ_FNAME, TY_CHAR)

   # get parameters from cl
	call clgstr ("datafile", Memc[datafile], SZ_FNAME)
	call clgstr ("outfile", Memc[outfile], SZ_FNAME)
	call clgstr ("gtype", Memc[gtype], SZ_FNAME)
	clobout = clgetb ("clobout")
	rmin = clgeti ("rmin")
	rmax = clgeti ("rmax")
	thmin = clgeti ("thmin")
	thmax = clgeti ("thmax")
	zmin = clgeti ("zmin")
        zmax = clgeti ("zmax")
        finfo = clgeti ("finfo")
   	iinfo = clgeti ("iinfo")

   # read data output file  (could be a procedure)
	if (verbosity >= 6) {
	    call printf ("#AUTOS:  Reading data file  %s\n")
		call pargstr (Memc[datafile])
	    call flush (STDOUT)
	}

	fd = open(Memc[datafile], READ_ONLY, TEXT_FILE)

	jj=0	# index for number of accepted entries
        kk=iinfo-1    # index for infos in current cluster
        mm=0    # index for total possible entries
   
   #  Loop to read the file
	while (getline (fd, Memc[linebuf]) != EOF) {
	    # skip comment lines
	    if (Memc[linebuf] == '#') next

.help
       tc     0000 E D N      0     0.0 080280100
       he0    300 E D E E E E Z2       0     24 192023012 192192 015030 000024
.endhelp

            mm = mm  + 1

	    # scan the summary lines
            call sscan (Memc[linebuf])
	            call gargwrd (Memc[type],SZ_LINE-1)         # data type
                    call gargwrd (Memc[dntx],SZ_LINE-1)		# dntx / pfe
	            call gargwrd (Memc[junk],SZ_LINE-1)
                    call gargwrd (Memc[junk],SZ_LINE-1)
                    call gargwrd (Memc[junk],SZ_LINE-1)
                    call gargwrd (Memc[junk],SZ_LINE-1)
                    call gargwrd (Memc[junk],SZ_LINE-1)
	            call gargwrd (Memc[rtza],SZ_LINE-1)         # rtz tc
	            call gargwrd (Memc[zone],SZ_LINE-1)         # zone he
                    call gargwrd (Memc[beam],SZ_LINE-1)         # beam he
                    call gargwrd (Memc[tlck],SZ_LINE-1)         # twistlock he
	            call gargwrd (Memc[rtzb],SZ_LINE-1)         # rtz he

	   # print as requested
	   if (verbosity >= 8) {
	      call printf ("%4s %4s %9s %9s\n")
		call pargstr (Memc[type])
		call pargstr (Memc[dntx])
		call pargstr (Memc[rtza])
		call pargstr (Memc[rtzb])
	      call flush (STDOUT)
	   }

	   # is this the right data type to process?
	   if ( streq(Memc[type],Memc[gtype]) ) {

	      kk = kk +1
	      jj = jj +1	# increment the entry counter

	      # copy the strings
	      call strcpy (Memc[type],nnn[1,kk],4)
	      call strcpy (Memc[dntx],id[1,kk],4)
	      if ( streq(Memc[type], "tc") ) {
		 call strcpy (Memc[rtza],rad[1,kk],3)
		 call strcpy (Memc[rtza+3],theta[1,kk],3)
		 call strcpy (Memc[rtza+6],zzz[1,kk],3)
	      }
	      else if ( streq(Memc[type], "he0") ) {
		 call strcpy (Memc[rtzb],rad[1,kk],3)
		 call strcpy (Memc[rtzb+3],theta[1,kk],3)
		 call strcpy (Memc[rtzb+6],zzz[1,kk],3)
		 call strcpy (Memc[zone],hzone[1,kk],3)
	      }
	      
	      # decode the coordinates
	      ii = 1
	      stat = ctoi(rad[1,kk],ii,ract)
	      ii = 1
	      stat = ctoi(theta[1,kk],ii,thact)
	      ii = 1
	      stat = ctoi(zzz[1,kk],ii,zact)

	      if (verbosity >= 6) {
		 call printf ("# %4s %4s %3u %3u %3d\n")
		     call pargstr (Memc[type])
		     call pargstr (Memc[dntx])
		     call pargi (ract)
		     call pargi (thact)
		     call pargi (zact)
		 call flush (STDOUT)
	      }
	      
	      # check coordinate ranges
	      if ( ract < rmin && rmin != INDEFI ) {
		 jj = jj - 1
		 kk = kk - 1
	      }
	      else if ( ract > rmax && rmax != INDEFI ) {
		 jj = jj - 1
		 kk = kk - 1
	      }
	      else if ( thact < thmin && thmin != INDEFI ) {
		 jj = jj - 1
		 kk = kk - 1
	      }
	      else if ( thact > thmax && thmax != INDEFI ) {
		 jj = jj - 1
		 kk = kk - 1
	      }
	      else if ( zact < zmin && zmin != INDEFI ) {
		 jj = jj - 1
		 kk = kk - 1
	      }
	      else if ( zact > zmax && zmax != INDEFI ) {
		 jj = jj - 1
		 kk = kk - 1
	      }
		 
	      # write the graphics commands as needed, when you get 4 entries
	      else if (kk >= finfo) {
		 if ( streq(nnn[1,1], "tc") ) {
		    call write_ogr_t (kk, rad[1,1], theta[1,1], zzz[1,1],
				      id[1,1])
		 }
		 else if ( streq(nnn[1,1], "he0") ) {
		    call write_ogr_h (kk, rad[1,1], theta[1,1], zzz[1,1],
				      id[1,1], hzone[1,1])
		 }
		 kk = iinfo - 1
	      } # end if kk >= finfo
	      
	   } # end if gtype
	   
	} # end of while loop

   # print the last few entries, if kk didn't make it to finfo again
        if (kk > iinfo - 1) {
	   if ( streq(nnn[1,1], "tc") ) {
	      call write_ogr_t (kk, rad[1,1], theta[1,1], zzz[1,1], id[1,1])
	   }
	   else if ( streq(nnn[1,1], "he0") ) {
	      call write_ogr_h (kk, rad[1,1], theta[1,1], zzz[1,1],
				id[1,1], hzone[1,1])
	   }
	   kk = iinfo - 1
	} # end if
   
	call close (fd)		# close the datafile

	if (verbosity >= 5) {
	   call printf ("#AUTOS:  Read %5u points from data file for %4u entries; (%u).\n")
	       call pargi (mm)
	       call pargi (jj)
	       call pargi (kk)
	   call flush (STDOUT)
	}


   # Open the output file
	if (strlen(Memc[outfile]) > 0) {
	    out = true
	    if (access(Memc[outfile], WRITE_ONLY, TEXT_FILE) == YES) {
		if (clobout) {
		    call delete (Memc[outfile])
		    od = open (Memc[outfile], NEW_FILE, TEXT_FILE)
		}
		else {
		    od = open (Memc[outfile], APPEND, TEXT_FILE)
		}
	    }
	    else {
		od = open (Memc[outfile], NEW_FILE, TEXT_FILE)
	    }
	}
	else {
		out = false
	}


	call close (fd)
	if (out)
	    call close (od)

	call sfree (sp)
end

procedure write_ogr_t (kk, rad, theta, zzz, id)

int     kk, jj
char    rad[3,4], theta[3,4], zzz[3,4], id[4,4]

begin
   # write the comment line with dntx addresses
   call printf ("# dntx %4s %4s %4s %4s\n")
   for (jj=1; jj<=4; jj=jj+1) {
      if (jj <= kk)
	 call pargstr (id[1,jj])
      else
	 call pargstr ("....")
   }
   
   # write the ograph command
   # all those slashes make two backslashes and a carriage return
   call printf ("ograph noven=0 \\\\\\\\\n")

   # write the info parameters
   for (jj=1; jj<=3; jj=jj+1) {
      if (jj > kk) {
	 call printf ("info%1u=\"\" \\\\\\\\\n")
		     call pargi (jj)
      }
      else {
	 call printf ("info%1u=\"ttmp\" r%1u=%3s th%1u=%3s z%1u=%3s \\\\\\\\\n")
		     call pargi (jj)
		     call pargi (jj)
		     call pargstr (rad[1,jj])
		     call pargi (jj)
		     call pargstr (theta[1,jj])
		     call pargi (jj)
		     call pargstr (zzz[1,jj])
      }
   }
   for (jj=4; jj<=4; jj=jj+1) {
      if (jj > kk) {
	 call printf ("info%1u=\"\" \n\n")
		     call pargi (jj)
      }
      else {
	 call printf ("info%1u=\"ttmp\" r%1u=%3s th%1u=%3s z%1u=%3s \n\n")
		     call pargi (jj)
		     call pargi (jj)
		     call pargstr (rad[1,jj])
		     call pargi (jj)
		     call pargstr (theta[1,jj])
		     call pargi (jj)
	             call pargstr (zzz[1,jj])
      }
   }

   # flush the output buffer
   call flush (STDOUT)


end

procedure write_ogr_h (kk, rad, theta, zzz, id, hzone)

int     kk, jj
char    rad[3,4], theta[3,4], zzz[3,4], hzone[3,4], id[4,4]

begin
   # write the comment line with pfe addresses
   call printf ("# pfe %3s %3s %3s %3s       %3s %3s %3s %3s\n")
   for (jj=1; jj<=4; jj=jj+1) {
      if (jj <= kk)
	 call pargstr (id[1,jj])
      else
	 call pargstr ("...")
   }
   for (jj=1; jj<=4; jj=jj+1) {
      if (jj <= kk)
	 call pargstr (hzone[1,jj])
      else
	 call pargstr ("...")
   }
   
   # write the ograph command
   # all those slashes make two backslashes and a carriage return
   call printf ("ograph noven=0 \\\\\\\\\n")

   # write the info parameters
   for (jj=1; jj<=3; jj=jj+1) {
      if (jj > kk) {
	 call printf ("info%1u=\"\" \\\\\\\\\n")
		     call pargi (jj)
      }
      else {
	 call printf ("info%1u=\"hpwr\" r%1u=%3s th%1u=%3s z%1u=%3s \\\\\\\\\n")
		     call pargi (jj)
		     call pargi (jj)
		     call pargstr (rad[1,jj])
		     call pargi (jj)
		     call pargstr (theta[1,jj])
		     call pargi (jj)
		     call pargstr (zzz[1,jj])
      }
   }
   for (jj=4; jj<=4; jj=jj+1) {
      if (jj > kk) {
	 call printf ("info%1u=\"\" \n\n")
		     call pargi (jj)
      }
      else {
	 call printf ("info%1u=\"hpwr\" r%1u=%3s th%1u=%3s z%1u=%3s \n\n")
		     call pargi (jj)
		     call pargi (jj)
		     call pargstr (rad[1,jj])
		     call pargi (jj)
		     call pargstr (theta[1,jj])
		     call pargi (jj)
	             call pargstr (zzz[1,jj])
      }
   }

   # flush the output buffer
   call flush (STDOUT)


end

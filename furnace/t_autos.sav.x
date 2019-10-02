# AUTOS -- automatic generator of ograph scripts

include	<time.h>
include	<ctype.h>

procedure t_autos()

.help
#  Description
	AUTOS is a text-processor to automatically generate an ograph
script from a section of an oven databasc file.

#  History
#	27MAR92 - Created by J. M. Hill, Steward Observatory
#       30MAR92 - How to printf a \\ to continue a script line.

#  Future Work
	# Implement output file
	# Extend to hpwr capability
.endhelp

#  Parameter declarations
#	Input files
pointer	datafile
#	Output files
pointer outfile	  		# output file name (optional)
bool	clobout			# clobber existing output file?
#	Program parameters
int	verbosity			# controls amount of output text

#  Variable Declarations
char	time[SZ_TIME]
string	version	"30-MAR-92"		# version date of code

int     jj, kk, ll
char    rad[3,4], theta[3,4], zzz[3,4], id[4,4]
bool    out
pointer	fd, od
pointer	sp			# stack pointer
pointer	linebuf, junk, rtz, dntx	# pointer for text storage

#declare functions
int	clgeti()
bool	clgetb()
int	open ()
int	access()
int	getline()
long	clktime()
int	strlen()

begin
#  Get output verbosity parameter
	verbosity = clgeti ("verbosity")

#  Introduce program
	if (verbosity >= 5) {
	    call printf ("#AUTOS, ograph script generator --- SPP Version of %s\n")
		call pargstr (version)

	# Get Date and Time
	    call cnvtime (clktime(0), time, SZ_TIME)
	    call printf ("#       Executed on: %s\n")
		call pargstr (time)
	    call flush (STDOUT)
	}

	call smark (sp)

  # allocate memory
	call salloc (linebuf, SZ_LINE, TY_CHAR)
	call salloc (junk, SZ_LINE, TY_CHAR)
	call salloc (dntx, SZ_LINE, TY_CHAR)
	call salloc (rtz, SZ_LINE, TY_CHAR)
	call salloc (datafile, SZ_FNAME, TY_CHAR)
	call salloc (outfile, SZ_FNAME, TY_CHAR)

   # get parameters from cl
	call clgstr ("datafile", Memc[datafile], SZ_FNAME)
	call clgstr ("outfile", Memc[outfile], SZ_FNAME)
	clobout = clgetb ("clobout")

   # read data output file  (could be a procedure)
	if (verbosity >= 6) {
	    call printf ("#AUTOS:  Reading data file  %s\n")
		call pargstr (Memc[datafile])
	    call flush (STDOUT)
	}

	fd = open(Memc[datafile], READ_ONLY, TEXT_FILE)

	jj=0	# index for number of entries
        kk=0    # index for infos
   
   #  Loop to read the file
	while (getline (fd, Memc[linebuf]) != EOF) {
	    # skip comment lines
	    if (Memc[linebuf] == '#') next

.help
tc     0000 E D N      0     0.0 080280100
.endhelp

	    # scan the summary lines
            call sscan (Memc[linebuf])
                    call gargwrd (Memc[junk],SZ_LINE)
                    call gargwrd (Memc[dntx],SZ_LINE)		# dntx
	            call gargwrd (Memc[junk],SZ_LINE)
                    call gargwrd (Memc[junk],SZ_LINE)
                    call gargwrd (Memc[junk],SZ_LINE)
                    call gargwrd (Memc[junk],SZ_LINE)
                    call gargwrd (Memc[junk],SZ_LINE)
	            call gargwrd (Memc[rtz],SZ_LINE)            # rtx

	    if (verbosity >= 7) {
		call printf ("%4s %9s\n")
		    call pargstr (Memc[dntx])
		    call pargstr (Memc[rtz])
		call flush (STDOUT)
	    }

	   kk = kk +1
	   jj = jj +1	# increment the entry counter

	   call strcpy (Memc[dntx],id[1,kk],4)
	   call strcpy (Memc[rtz],rad[1,kk],3)
	   call strcpy (Memc[rtz+3],theta[1,kk],3)
	   call strcpy (Memc[rtz+6],zzz[1,kk],3)
	   
	   if (kk >= 4) {
	      call printf ("# dntx %4s %4s %4s %4s\n")
		     call pargstr (id[1,1])
		     call pargstr (id[1,2])
		     call pargstr (id[1,3])
		     call pargstr (id[1,4])
	      call printf ("ograph noven=0 \134")
	      call printf ("\134\n")
	      for (ll=1; ll<=3; ll=ll+1) {
		 call printf ("info%1u=\"ttmp\" r%1u=%3s th%1u=%3s z%1u=%3s \134")
		     call pargi (ll)
		     call pargi (ll)
		     call pargstr (rad[1,ll])
		     call pargi (ll)
		     call pargstr (theta[1,ll])
		     call pargi (ll)
		     call pargstr (zzz[1,ll])
		    call printf ("\134\n")
	      }
	      for (ll=4; ll<=4; ll=ll+1) {
		 call printf ("info%1u=\"ttmp\" r%1u=%3s th%1u=%3s z%1u=%3s \n\n")
		     call pargi (ll)
		     call pargi (ll)
		     call pargstr (rad[1,ll])
		     call pargi (ll)
		     call pargstr (theta[1,ll])
		     call pargi (ll)
		     call pargstr (zzz[1,ll])
	      }
	      call flush (STDOUT)
	      kk = 0
	   } # end if
	   
	} # end of while loop

   # print the last few entries
   if (kk > 0) {
      call printf ("# dntx %4s %4s %4s %4s\n")
		     call pargstr (id[1,1])
		     call pargstr (id[1,2])
		     call pargstr (id[1,3])
		     call pargstr (id[1,4])
	      call printf ("ograph noven=0 \\")
	      call printf ("\134\n")
	      for (ll=1; ll<=4; ll=ll+1) {
		 if (ll > kk) {
		    call printf ("info%1u=\"\" \\")
		     call pargi (ll)
		    call printf ("\134\n")
		 }
		 else {
		    call printf ("info%1u=\"ttmp\" r%1u=%3s th%1u=%3s z%1u=%3s \\")
		     call pargi (ll)
		     call pargi (ll)
		     call pargstr (rad[1,ll])
		     call pargi (ll)
		     call pargstr (theta[1,ll])
		     call pargi (ll)
		     call pargstr (zzz[1,ll])
	      call printf ("\134\n")
		 }
	      }
	      call flush (STDOUT)
	      kk = 0
   } # end if
   
	call close (fd)		# close datafile

	if (verbosity >= 6) {
	    call printf ("#AUTOS:  Read %5u points from data file.\n")
	       call pargi (jj)
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

.help
   call printf ("Start\n")
   call printf ("This is the first test \\\\\n");
   call printf ("This is the second test \\ \\ \n");
   call printf ("This is the third test \134\134\n");
   call printf("Done\n");
   call flush (STDOUT)
.endhelp
   
end

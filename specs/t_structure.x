# STRUCTURE -- Task to calculate structure function of a list of points

include <time.h>
include <error.h>

procedure t_structure()

# See the corresponding task in SCOPES.ALUMINIZE for s.f. of an image
.help

#  History
#	29APR92 - Created in SPP by J. M. Hill, Steward Observatory
.endhelp

#  Include memory allocation and parameters

#  Local Variables
pointer	infile, fd		# input file name, descriptor
double  radius, rmaski, rmasko
int	kran			# number of random points to sample
int     numxyz                  # maximum number of xyz points
int     nxy                     # actual number of xyz points
int     nbin                    # number of structure function bins
int     idec                    # number of bins per dex
int	verbosity		# quantity of info to print

long	jran, im, ia, ic	# random number generator variables
int     ik, kkx

string	version	"01-MAY-92"	# version Date of Code
char	time[SZ_TIME]

pointer  xp, yp, zp, xj, yj, zj, rms, sss, nns

pointer  sp

errchk	salloc, open

#  Function Declarations

long	clktime()
int	clgeti()
double	clgetd()
int	open()
int	nscan()
int     fscan()

begin

#  Introduce Program
   call printf ("STRUCTURE Function Program, SPP Version of %s\n")
       call pargstr (version)

#  Get Date and Time
   call cnvtime (clktime(0), time, SZ_TIME)
   call printf ("       Executed on: %s\n")
       call pargstr (time)

   call flush (STDOUT)

#  Allocate Memory
   call smark (sp)
   call salloc (infile, SZ_FNAME, TY_CHAR)

#  Get Task Parameters
   call clgstr ("infile", Memc[infile], SZ_FNAME)

   rmasko = clgetd ("rmasko")
   rmaski = clgetd ("rmaski")
   numxyz = clgeti ("numxyz")    # maximum number of xyz points
   kran = clgeti ("kran")    # maximum number of points to process
   nbin = clgeti ("nbin")
   idec = clgeti ("idec")
   verbosity = clgeti ("verbosity")


   # allocate dynamic memory for xyz points
   call salloc ( xp, numxyz, TY_DOUBLE )
   call salloc ( yp, numxyz, TY_DOUBLE )
   call salloc ( zp, numxyz, TY_DOUBLE )
   

   call printf ("STRUCTURE:  Reading list file %s\n")
       call pargstr (Memc[infile])
   call flush (STDOUT)
   
#  Read in the input list
   iferr ( fd = open(Memc[infile],READ_ONLY,TEXT_FILE) ) {
      call eprintf("cannot open input file\n")
      call erract ( EA_FATAL )
   }

   # read the text file with xyz points
   nxy = 0   # point counter
   
   while ( fscan(fd) != EOF ) {
      if ( nxy >= NUMXYZ )
	 call eprintf("too much data - discarding\n")
      else {
	 nxy = nxy + 1
	 call gargd (Memd[xp+nxy-1])
	 call gargd (Memd[yp+nxy-1])
	 call gargd (Memd[zp+nxy-1])
	 if ( nscan() < 3 ) {
	    call eprintf("less than 3 numbers on a line - discarding\n")
	    nxy = nxy - 1
	 } else if (verbosity >= 4) {
	    call printf ("xyz:  %.2f %.2f %.6f\n")
	        call pargd (Memd[xp+nxy-1])
	        call pargd (Memd[yp+nxy-1])
	        call pargd (Memd[zp+nxy-1])
	    call flush (STDOUT)
	 }
      }
   }
   call close ( fd )

   call printf ("STRUCTURE:  Read %6u good xyz points.\n")
       call pargi (nxy)
   call printf ("STRUCTURE:  Masking inside %6.2f and outside %6.2f radius.\n")
       call pargd (rmaski)
       call pargd (rmasko)
   call flush (STDOUT)


   # allocate dynamic memory for xyz points
   call salloc ( xj, kran, TY_DOUBLE )
   call salloc ( yj, kran, TY_DOUBLE )
   call salloc ( zj, kran, TY_DOUBLE )

   if (nxy > kran){
      # select xyz positions from the list randomly
      call printf ("Generating the %5u random x,y positions.\n")
          call pargl (kran)
      call flush (STDOUT)
   
      jran = 137              # initialize random number generator
      im = 86436              # see Numerical Recipes ch 7, page 196-198
      ia = 1093
      ic = 18257

      ik = 0

      while (ik < kran) {

	 # select X,Y position pair at random between 1 and NXY inclusive.
	 jran = mod( jran*ia+ic, im )
	 kkx = 1 + (nxy * jran) / im

	 # there is no check for repeated points
	 
	 # check to see if point should be masked
	 radius = (Memd[xp+kkx-1])**2 + (Memd[yp+kkx-1])**2
	 radius = sqrt(radius)
	 if (rmasko != INDEFD && radius >= rmasko)
	    next
	 else if (rmaski != INDEFD && radius <= rmaski)
	    next

	 ik = ik + 1  # pair counter

	 Memd[xj+ik-1] = Memd[xp+kkx-1]
	 Memd[yj+ik-1] = Memd[yp+kkx-1]
	 Memd[zj+ik-1] = Memd[zp+kkx-1]

	 if (verbosity >= 4) {
	    call printf ("pair %4u, index %5u, X= %6.1f  Y=%6.1f  Z=%10.5f\n")
	        call pargi (ik)
	        call pargi (kkx)
	        call pargd (Memd[xj+ik-1])
	        call pargd (Memd[yj+ik-1])
	        call pargd (Memd[zj+ik-1])
	    call flush (STDOUT)
	 } # end if

      } # end while

   } # end if
   else {
      # copy the list of xyz positions directly
      call printf ("Using the %5u x,y positions.\n")
          call pargl (nxy)
      call flush (STDOUT)
      
      ik = 0
      kkx = 0

      while (kkx < nxy) {

	 kkx = kkx + 1
	 
	 # check to see if point should be masked
	 radius = (Memd[xp+kkx-1])**2 + (Memd[yp+kkx-1])**2
	 radius = sqrt(radius)
	 if (rmasko != INDEFD && radius >= rmasko)
	    next
	 else if (rmaski != INDEFD && radius <= rmaski)
	    next

	 ik = ik + 1

	 Memd[xj+ik-1] = Memd[xp+ik-1]
	 Memd[yj+ik-1] = Memd[yp+ik-1]
	 Memd[zj+ik-1] = Memd[zp+ik-1]

	 if (verbosity >= 4) {
	    call printf ("pair %4u, index %5u, X= %6.1f  Y=%6.1f  Z=%10.5f\n")
	        call pargi (ik)
	        call pargi (ik)
	        call pargd (Memd[xj+ik-1])
	        call pargd (Memd[yj+ik-1])
	        call pargd (Memd[zj+ik-1])
	    call flush (STDOUT)
	 } # end if

      } # end while

      kran = ik
      
   } # end else


# ==> Call JMH's structure function...
   call printf ("Calculating the Structure Function with %4u points.\n")
       call pargi (kran)
   call flush (STDOUT)

   # allocate dynamic memory for structure function
   call salloc ( rms, nbin+1, TY_DOUBLE )
   call salloc ( sss, nbin+1, TY_DOUBLE )
   call salloc ( nns, nbin+1, TY_DOUBLE )
   

   call struct (kran, Memd[xj], Memd[yj], Memd[zj],
		  nbin, idec, Memd[rms], Memd[sss], Memd[nns])

   for (ik=1; ik<=nbin+1; ik=ik+1) {
      call printf ("Scale= %6.2f,  RMS= %9.5f,  N= %5.0f\n")
          call pargd (Memd[sss+ik-1])
          call pargd (Memd[rms+ik-1])
          call pargd (Memd[nns+ik-1])
      call flush (STDOUT)
   }


#  Say Goodbye
	call printf ("STRUCTURE is complete.\n")

	call sfree (sp)

end

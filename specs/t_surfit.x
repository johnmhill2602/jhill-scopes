# SURFIT -- Fit a polynomial surface to a list of points

include <time.h>
include <error.h>
include <math/gsurfit.h>

procedure t_surfit()

.help
This program reads a list of X, Y, Z points and uses the IRAF
gsurfit package to fit a polynomial surface to the list.
The resulting residuals are printed.

#  History
#       06MAY92 - Created in SPP by J. M. Hill, Steward Observatory
#       16MAY92 - Calculate fit rms
.endhelp

#  Include memory allocation and parameters

#  Local Variables
pointer	infile, fd		# input file name, descriptor
double  radius, rmaski, rmasko
double  xmin, xmax, ymin, ymax
double  chisqr, rms, sigmam, sigmap
int     xorder, yorder
bool    xterms
int     numxyz                  # maximum number of xyz points
int     nxy                     # actual number of xyz points
int	verbosity		# quantity of info to print
int     nsave                   # number of coefficients
int     ik, ier, jj, kkx, irej

string	version	"16-MAY-92"	# version Date of Code
char	time[SZ_TIME]

pointer  xp, yp, zp
pointer  xj, yj, zj, fj, dj, wj
pointer  ej, cj

pointer  sp, sf

errchk	salloc, open

#  Function Declarations

long	clktime()
int	clgeti()
double	clgetd()
int	open()
int	nscan()
int     fscan()
int     dgsgeti()

begin

#  Introduce Program
   call printf ("SURFIT Fitting Program, SPP Version of %s\n")
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
   xorder = clgeti ("xorder")
   yorder = clgeti ("yorder")
   sigmam = clgetd ("sigmam")
   sigmap = clgetd ("sigmap")
   verbosity = clgeti ("verbosity")


   # allocate dynamic memory for xyz points
   call salloc ( xp, numxyz, TY_DOUBLE )
   call salloc ( yp, numxyz, TY_DOUBLE )
   call salloc ( zp, numxyz, TY_DOUBLE )
   

   call printf ("SURFIT:  Reading list file %s\n")
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
      if ( nxy >= numxyz )
	 call eprintf("too much data - discarding\n")
      else {
	 nxy = nxy + 1
	 call gargd (Memd[xp+nxy-1])
	 call gargd (Memd[yp+nxy-1])
	 call gargd (Memd[zp+nxy-1])
	 if ( nscan() < 3 ) {
	    call eprintf("less than 3 numbers on a line - discarding\n")
	    nxy = nxy - 1
	 }
	 else if (verbosity >= 7) {
	    call printf ("xyz:  %.2f %.2f %.6f\n")
	        call pargd (Memd[xp+nxy-1])
	        call pargd (Memd[yp+nxy-1])
	        call pargd (Memd[zp+nxy-1])
	    call flush (STDOUT)
	 }
      }
   }    # end while loop
   
   call close ( fd )

   call printf ("SURFIT:  Read %6u good xyz points.\n")
       call pargi (nxy)
   call flush (STDOUT)

   # physical limits of the image
   xmin = clgetd ("xmin")
   xmax = clgetd ("xmax")

   # autoscale if any limits are indef
   if (xmin == INDEFD || xmax == INDEFD) {
      call alimd (Memd[xp], nxy, xmin, xmax)
   }
   
   ymin = clgetd ("ymin")
   ymax = clgetd ("ymax")

   # autoscale if any limits are indef
   if (ymin == INDEFD || ymax == INDEFD) {
      call alimd (Memd[yp], nxy, ymin, ymax)
   }

   call printf ("SURFIT:  Using points from X= %.2f to %.2f\n")
       call pargd (xmin)
       call pargd (xmax)
   call printf ("SURFIT:  Using points from Y= %.2f to %.2f\n")
       call pargd (ymin)
       call pargd (ymax)
   call flush (STDOUT)


   call printf ("SURFIT:  Masking inside %6.2f and outside %6.2f radius.\n")
       call pargd (rmaski)
       call pargd (rmasko)
   call flush (STDOUT)


   # allocate dynamic memory for xyz points
   call salloc ( xj, nxy, TY_DOUBLE )
   call salloc ( yj, nxy, TY_DOUBLE )
   call salloc ( zj, nxy, TY_DOUBLE )
   call salloc ( fj, nxy, TY_DOUBLE )
   call salloc ( dj, nxy, TY_DOUBLE )
   call salloc ( wj, nxy, TY_DOUBLE )

   # copy the list of xyz positions directly
   call printf ("Using the %5u x,y positions.\n")
       call pargi (nxy)
   call flush (STDOUT)
      
   ik = 0
   kkx  = 0
   
   while (kkx < nxy) {

      kkx = kkx + 1    # index for next point in the list
	 
      # check to see if point should be masked
      radius = (Memd[xp+kkx-1])**2 + (Memd[yp+kkx-1])**2
      radius = sqrt(radius)
      if (rmasko != INDEFD && radius >= rmasko) {
	 next
      }
      else if (rmaski != INDEFD && radius <= rmaski) {
	 next
      }

      ik = ik + 1     # index for next point in the output list

      Memd[xj+ik-1] = Memd[xp+kkx-1]
      Memd[yj+ik-1] = Memd[yp+kkx-1]
      Memd[zj+ik-1] = Memd[zp+kkx-1]

      if (verbosity >= 6) {
	 call printf ("pair %4u, index %5u, X= %6.1f  Y=%6.1f  Z=%10.5f\n")
	     call pargi (ik)
	     call pargi (kkx)
	     call pargd (Memd[xj+ik-1])
	     call pargd (Memd[yj+ik-1])
	     call pargd (Memd[zj+ik-1])
	 call flush (STDOUT)
      } # end if

   } # end while

   if (verbosity >= 6) {
      call printf ("SURFIT:  Initializing the surface fit.\n")
      call flush (STDOUT)
   }

   # cross terms don't matter for orders 1=constant, 2=line
   if (xterms) {
      call dgsinit (sf, GS_CHEBYSHEV, xorder, yorder, YES, xmin, xmax, ymin, ymax )
   }
   else {
      call dgsinit (sf, GS_LEGENDRE, xorder, yorder, NO, xmin, xmax, ymin, ymax )
   }


   if (verbosity >= 4) {
      call printf ("SURFIT:  Fitting the surface with %4u points, xorder=%u yorder=%u.\n")
          call pargi (ik)
          call pargi (xorder)
          call pargi (yorder)
      call flush (STDOUT)
   }
   
   call dgsfit (sf, Memd[xj], Memd[yj], Memd[zj], Memd[wj], ik, WTS_UNIFORM, ier)

      if (verbosity >= 5) {
	 call printf ("SURFIT:  Evaluating the fit. ier=%d\n")
	     call pargi (ier)
	 call flush (STDOUT)
      }

   # Number of coefficents to save (N+8)
   nsave = dgsgeti (sf, GSNSAVE)
   call salloc (cj, nsave, TY_DOUBLE)
   call salloc (ej, nsave, TY_DOUBLE)

   if (verbosity >= 8) {
      call printf ("SURFIT:  NSAVE = %u\n")
      call flush (STDOUT)
   }
   
   # Get the fit values
   call dgsvector (sf, Memd[xj], Memd[yj], Memd[fj], ik)

   # Calculate the residuals for the fitted points
   for (jj=1; jj<=ik; jj=jj+1) {
      Memd[dj+jj-1] = Memd[zj+jj-1] - Memd[fj+jj-1]  # residual
      if (verbosity >= 5) {
	 call printf ("%10.2f  %10.2f  %12.4f\n")
             call pargd (Memd[xj+jj-1])
             call pargd (Memd[yj+jj-1])
#            call pargd (Memd[zj+jj-1])    # data
#            call pargd (Memd[fj+jj-1])    # fit
	     call pargd (Memd[dj+jj-1])    # residual
	 call flush (STDOUT)
      }
   }

   # Get the fit coefficients and errors
   call dgssave (sf, Memd[cj])

   if (verbosity >= 6) {
      call printf ("SURFIT:  Coefficients saved (%u).\n")
          call pargi (nsave)
      for (jj=1; jj<=nsave; jj=jj+1) {
	 call printf ("      %2u   %f\n")
	     call pargi (jj)
	     call pargd (Memd[cj+jj-1])
      } 
     call flush (STDOUT)
   }

   call dgserrors (sf, Memd[zj], Memd[wj], Memd[fj], chisqr, Memd[ej])
   rms = sqrt (chisqr)

   if (verbosity >= 4) {
      call printf ("SURFIT:  reduced chisquare is %.6f\n")
          call pargd (chisqr)
      call printf ("SURFIT:  rms is               %.6f\n")
      call pargd (rms)
      for (jj=9; jj<=nsave; jj=jj+1) {
	 call printf ("      %2u   %15.6f +/- %13.6f\n")
	     call pargi (jj-8)
	     call pargd (Memd[cj+jj-1])
	     call pargd (Memd[ej+jj-9])
      }
      call flush (STDOUT)
   }

   
   if (verbosity >= 4) {
      call printf ("SURFIT:  Rejecting points beyond %.2f and %.2f sigma.\n")
          call pargd (sigmam)
          call pargd (sigmap)
      call flush (STDOUT)
   }

   irej = 0

   # loop over all the data points
   for (jj=1; jj<=ik; jj=jj+1) {
      if (Memd[dj+jj-1] > (rms*sigmap) && sigmap != INDEF) {
	 next
      }
      else if (Memd[dj+jj-1] < (rms*sigmam) && sigmam != INDEF) {
	 next
      }
      else {
	 irej = irej + 1
	 Memd[xj+irej-1] = Memd[xj+jj-1]
	 Memd[yj+irej-1] = Memd[yj+jj-1]
	 Memd[zj+irej-1] = Memd[zj+jj-1]
      }
   } # end loop over points

   if (verbosity >= 4) {
      call printf ("SURFIT:  Re-Fitting the surface with %4u points, %4u rejected.\n")
          call pargi (irej)
          call pargi (ik-irej)
      call flush (STDOUT)
   }
   
   call dgsfit (sf, Memd[xj], Memd[yj], Memd[zj], Memd[wj], irej, WTS_UNIFORM, ier)

   if (verbosity >= 6) {
      call printf ("SURFIT:  Evaluating the fit. ier=%d\n")
          call pargi (ier)
      call flush (STDOUT)
   }

   # Get the fit values not including rejected points
   call dgsvector (sf, Memd[xj], Memd[yj], Memd[fj], irej)

   # Calculate the residuals for the fitted points
   for (jj=1; jj<=irej; jj=jj+1) {
      Memd[dj+jj-1] = Memd[zj+jj-1] - Memd[fj+jj-1]  # residual
      if (verbosity >= 5) {
	 call printf ("%10.2f  %10.2f  %12.4f\n")
             call pargd (Memd[xj+jj-1])
             call pargd (Memd[yj+jj-1])
#            call pargd (Memd[zj+jj-1])    # data
#            call pargd (Memd[fj+jj-1])    # fit
	     call pargd (Memd[dj+jj-1])    # residual
	 call flush (STDOUT)
      }
   }

   # Get the fit coefficients and errors
   call dgssave (sf, Memd[cj])

   if (verbosity >= 6) {
      call printf ("SURFIT:  Coefficients saved (%u).\n")
          call pargi (nsave)
      for (jj=1; jj<=nsave; jj=jj+1) {
	 call printf ("      %2u   %f\n")
	     call pargi (jj)
	     call pargd (Memd[cj+jj-1])
      } 
     call flush (STDOUT)
   }

   call dgserrors (sf, Memd[zj], Memd[wj], Memd[fj], chisqr, Memd[ej])
   rms = sqrt (chisqr)

   if (verbosity >= 4) {
      call printf ("SURFIT:  reduced chisquare is %.6f\n")
          call pargd (chisqr)
      call printf ("SURFIT:  rms is               %.6f\n")
      call pargd (rms)
      for (jj=9; jj<=nsave; jj=jj+1) {
	 call printf ("      %2u   %15.6f +/- %13.6f\n")
	     call pargi (jj-8)
	     call pargd (Memd[cj+jj-1])
	     call pargd (Memd[ej+jj-9])
      }
      call flush (STDOUT)
   }

   
   call dgsfree (sf)
   
   #  Say Goodbye
	call printf ("SURFIT is complete.\n")

	call sfree (sp)

end

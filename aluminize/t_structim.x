# STRUCTIM -- Task to calculate structure function of an image

include <time.h>
include <error.h>
include <imhdr.h>

procedure t_structim()

# See the corresponding task in SCOPES.SPECS for s.f. of a list

.help

#  History
#	17JAN91 - Created in SPP by J. M. Hill, Steward Observatory
#	22JAN91 - Translated from CHAMBER.F77.  JMH
#       29APR92 - Completed SPP implementation.  JMH
#  Future Improvements
#       Allow non-square images, with arbitrary origin
.endhelp

#  Local Variables
pointer	image			# image file name
double  rmaski, rmasko          # inner and outer radii to mask off
double  scale                   # scale of the image (i.e. cm/pixel)
int	kran			# number of random points to sample
int     nbin                    # number of structure function bins
int     idec                    # number of bins per dex
int	verbosity		# quantity of info to print

long	jran, im, ia, ic	# random number generator variables
int     ik, kkx, kky, kki

string	version	"29-APR-92"	# version Date of Code
char	time[SZ_TIME]

pointer xj, yj, zj, rms, sss, nns
pointer sp
pointer	id
pointer imsp
int	npixx, npixy		# image (imsp) size in pixels
double	zmin, zmax		# min and max input values
double  radius

errchk	salloc, imgs2d, immap

#  Function Declarations

long	clktime()
int	clgeti()
double	clgetd()
int	imaccess()
pointer immap(), imgs2d()


begin

#  Introduce Program
   call printf ("STRUCTIM Structure Function Program, SPP Version of %s\n")
       call pargstr (version)

#  Get Date and Time
   call cnvtime (clktime(0), time, SZ_TIME)
   call printf ("       Executed on: %s\n")
       call pargstr (time)

   call flush (STDOUT)

#  Allocate Memory
   call smark (sp)
   call salloc (image, SZ_FNAME, TY_CHAR)

#  Get Task Parameters
   call clgstr ("image", Memc[image], SZ_FNAME)

   rmasko = clgetd ("rmasko")
   rmaski = clgetd ("rmaski")
   scale = clgetd ("scale")
   kran = clgeti ("kran")    # maximum number of points to process
   nbin = clgeti ("nbin")
   idec = clgeti ("idec")
   verbosity = clgeti ("verbosity")


#  Read in the image grid

   # Check for existence of image
   if (imaccess (Memc[image], READ_ONLY) == YES) {
      call printf ("STRUCTIM:  Reading image file: %s\n")
          call pargstr (Memc[image])
      call flush (STDOUT)
   }
   else {
      call printf ("STRUCTIM:  Cannot find image file: %s\n")
          call pargstr (Memc[image])
      call flush (STDOUT)
   }
	
   id = immap (Memc[image], READ_ONLY, 0)

   npixx = IM_LEN(id,1)
   npixy = IM_LEN(id,2)

   call printf ("  %4u by %4u pixels.\n")
       call pargi (npixx)
       call pargi (npixy)

   call printf ("  title = '%s'\n")
	  call pargstr (IM_TITLE (id))

   call flush (STDOUT)
   
   # allocate dynamic memory for the image
   call salloc ( imsp, npixx*npixy, TY_DOUBLE )

   # Read in the image
   call amovd (Memd[imgs2d(id, 1, npixx, 1, npixy)], Memd[imsp], npixx * npixy)
	
   call imunmap (id)


   # Find minimum and maximum input values in z dimension.
   call alimd (Memd[imsp], npixx*npixy, zmin, zmax)

   call printf ("STRUCTIM:  Z-values range from %.2f to %.2f\n")
       call pargd (zmin)
       call pargd (zmax)
   call printf ("STRUCTIM:  Image scale is %.4f units/pixel.\n")
       call pargd (scale)
   call printf ("STRUCTIM:  X-range is %.2f,  Y-range is %.2f\n")
       call pargd (scale*npixx)
       call pargd (scale*npixy)
   call printf ("STRUCTIM:  Masking R > %.3f, and R < %.3f\n")
       call pargd (rmasko)
       call pargd (rmaski)
   call flush (STDOUT)
   
   
   # allocate dynamic memory for xyz points
   call salloc ( xj, kran, TY_DOUBLE )
   call salloc ( yj, kran, TY_DOUBLE )
   call salloc ( zj, kran, TY_DOUBLE )

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

        # select X,Y position pair at random between 1 and II inclusive.
        jran = mod( jran*ia+ic, im )
        kkx = 1 + (npixx * jran) / im
        jran = mod( jran*ia+ic, im )
        kky = 1 + (npixy * jran) / im

	 kki = (kky-1)*npixx + kkx

	 # there is no check for repeated points
	 
	 # check to see if point should be masked
	 radius = (kkx-npixx/2-0.5)**2 + (kky-npixy/2-0.5)**2
	 radius = sqrt(radius) * scale
	 if (rmasko != INDEFD && radius >= rmasko)
	    next
	 else if (rmaski != INDEFD && radius <= rmaski)
	    next

	 ik = ik + 1  # pair counter

	 Memd[xj+ik-1] = kkx * scale
	 Memd[yj+ik-1] = kky * scale
	 Memd[zj+ik-1] = Memd[imsp+kki-1]

	 if (verbosity >= 4) {
	    call printf ("pair %4u, (%4u,%4u) X= %6.1f  Y=%6.1f  Z=%10.5f\n")
	        call pargi (ik)
	        call pargi (kkx)
	        call pargi (kky)
	        call pargd (Memd[xj+ik-1])
	        call pargd (Memd[yj+ik-1])
	        call pargd (Memd[zj+ik-1])
	    call flush (STDOUT)
	 } # end if

      } # end while


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
	call printf ("STRUCTIM is complete.\n")

	call sfree (sp)

end

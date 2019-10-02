# SYNTHIM -- Task to synthesize images of specific wavefront errors.

include <mach.h>
include <time.h>
include <imhdr.h>

procedure t_synthim()

.help
This task generates IRAF images of a selected set of low order aberrations.
These include:
	piston			constant
	cone			R
	focus			R**2
	spherical aberration	R**4
	astigmatism		R**2 COS(T)**2
	coma			R**3 COS(T), R**3 SIN(T)
	trefoil, etc
which are functions of R, R**n, COS(T), COS(T)**n, COS(nT), SIN(T), etc.

Pixel(1,1) is in lower left when image is displayed on imtool.
Coordinate (0,0,0) is the vertex of the mirror.

#  History
#       Created by J. M. Hill at Steward Observatory
#       23AUG94 - Derived from scopes.aluminize.chamber

Future work:

.endhelp

# Include memory allocation and parameters
# Image row storage; $1 is the pointer, $2 is the column number
define	ZR	Memr[($1 + ($2-1))]

#  Local Variables
pointer	outimg			# output image file
int	gridrows, gridcols	# output image dimensions (was IGRIDxIGRID)
double	dmirror			# mirror diameter (was SDIA)
double	ampl			# function amplitude
double	rexp			# radial exponent
double	cexp			# cosine theta exponent
double	sexp			# sine theta exponent
double	cfac			# cosine theta factor
double	sfac			# sine theta factor
int	verbosity		# quantity of info to print

double	sum1, sum2, rms
double	tmin, tmax, tmean, tdep
double	r1, r2, yedge, xedge
double  rnorm, costh, sinth, theta
double	xmin, xmax, ymin, ymax
double  xm, ym		        # coordinates on the mirror surface
long	nn			# number of active pixels
int	irow, icol

string	version	"23-AUG-94"	# version Date of Code
char	time[SZ_TIME]

pointer  sp, im, zq

errchk	salloc, immap, impl2r, imgl2r

#  Function Declarations

long	clktime()
int	clgeti()
double	clgetd()
pointer	immap()
pointer	impl2r()
#pointer imgl2r()

begin

   # Introduce Program
   call printf ("SYNTHIM Image Calculation Program, SPP Version of %s\n")
       call pargstr (version)

   # Get Date and Time
   call cnvtime (clktime(0), time, SZ_TIME)
   call printf ("       Executed on: %s\n")
       call pargstr (time)

   call flush (STDOUT)

   # Allocate Memory
   call smark (sp)

   call salloc (outimg, SZ_FNAME+1, TY_CHAR)

   # Get Task Parameters
   call clgstr ("outimg", Memc[outimg], SZ_FNAME)
   gridcols = clgeti ("gridcols")
   gridrows = clgeti ("gridrows")
   dmirror = clgetd ("dmirror")
   ampl = clgetd ("ampl")
   rexp = clgetd ("rexp")
   cexp = clgetd ("cexp")
   sexp = clgetd ("sexp")
   cfac = clgetd ("cfac")
   sfac = clgetd ("sfac")
   verbosity = clgeti ("verbosity")

   # Map the output image file.
   im = immap (Memc[outimg], NEW_IMAGE, 0)
   IM_NDIM(im) = 2
   IM_LEN(im,1) = gridcols
   IM_LEN(im,2) = gridrows
   IM_PIXTYPE(im) = TY_REAL
   # call strcpy (Memc[fifile], IM_TITLE(im), SZ_IMTITLE)

   # Allocate Image Memory (enough for a row)
   call salloc (zq, gridcols, TY_REAL)

   # Loop through Grid Points
   nn = 0
   tmin = MAX_REAL
   tmax = 0.d0
   sum1 = 0.d0
   sum2 = 0.d0

   # Note that dmirror is a completely useless parameter at this point.
   # It just serves to make the calculation more complicated.
   # But, it may allow for more complex operations in the future.
   # Such as: making the mirror be smaller than the image array.
   
   xedge = dmirror/2.d0
   yedge = dmirror/2.d0

   if (verbosity >= 4) {
      call printf ("SYNTHIM:  diameter: %8.2f  A= %7.3f  R= %7.3f  C= %7.3f\n")
          call pargd (dmirror)
	  call pargd (ampl)
	  call pargd (rexp)
	  call pargd (cfac)
      call flush (STDOUT)
   }

   call printf ("Calculating the Values at the Grid Points..\n")
   call printf ("     %5u rows by %5u columns.\n")
       call pargi (gridrows)
	call pargi (gridcols)
   call flush (STDOUT)

   for (irow=1; irow<=gridrows; irow=irow+1 ) {

      if (verbosity >= 6) {
	 call printf ("SYNTHIM:  Working on image row %4u.\n")
	     call pargi (irow)
	 call flush (STDOUT)
      }

      # Y coordinate on mirror
      ym = -yedge + dmirror/double(gridrows)*(double(irow)-0.5d0)    
      # center of row 1 is 0.5 pixel inside mirror edge

      for (icol=1; icol<=gridcols; icol=icol+1 ) {

.help
	 if (verbosity >= 8) {
	    call printf ("SYNTHIM:  Working on image column %4u.\n")
	        call pargi (icol)
	    call flush (STDOUT)
	 }
.endhelp

	 # X coordinate on mirror
	 xm = -xedge + dmirror/double(gridcols)*(double(icol)-0.5d0) 
	 # center of row 1 is 0.5 pixel inside mirror edge

	 r2 = xm*xm + ym*ym		# radius squared
	 r1 = sqrt (r2)			# radius on mirror
	 if (r1 > dmirror/2.d0) {
	    tdep = 0.0d0            # Off edge of mirror
	 } # end if r1
	 else {
	    # cosine theta and sine theta
	    theta = atan2 ( xm, ym )
	    costh = cos ( cfac * theta )
	    sinth = sin ( sfac * theta )
	    # normalize the radius
	    rnorm = r1 / dmirror * 2.d0
	    # Calculate the real value here
	    tdep = ampl * rnorm**rexp * costh**cexp * sinth**sexp

	    # Increment Statistics Counters
	    sum1 = tdep + sum1
	    sum2 = tdep*tdep + sum2
	    nn = nn + 1

	    # Save maxima and minima
	    if (tdep < tmin) {
	       tmin = tdep
	       xmin = xm
	       ymin = ym
	    }
	    else if (tdep > tmax) {
	       tmax = tdep
	       xmax = xm
	       ymax = ym
	    }

	 } # end of pixel inside mirror section

.help
	 if (verbosity >= 8) {
	    call printf ("SYNTHIM:  Value is %14.7e at pixel %8u\n")
	        call pargd (tdep)
		call pargl (nn)
	    call flush (STDOUT)
	 }
.endhelp

	 # Store result in the row array.
	 ZR(zq,icol) = real(tdep)

      }	# end of loop over columns

      if (verbosity >= 6) {
	 call printf ("SYNTHIM:  Writing row %4u to the image.\n")
	     call pargi (irow)
	 call flush (STDOUT)
      }

      # Write the row to the image
      call amovr (Memr[zq], Memr[impl2r(im,irow)], gridcols)

   } # end of loop over rows

   # Calculate statistics

   call printf ("There were %8u active grid points.\n")
       call pargl (nn)
   call flush (STDOUT)

   if (nn > 0) {
      tmean = sum1 / double(nn)
      rms = sum2 / double(nn) - tmean * tmean
      if (rms < 0.0d0)
	 rms = 0.0d0
      else
	 rms = sqrt (rms*2.d0)

      call printf ("SYNTHIM:  mean: %10.3f (nm)  rms: %10.3f (nm)\n")
          call pargd (tmean)
          call pargd (rms)
      call flush (STDOUT)
      call printf ("SYNTHIM:  tmin: %10.3f (nm)  xmin=%8.2f  ymin=%8.2f\n")
          call pargd (tmin)
	  call pargd (xmin)
	  call pargd (ymin)
      call flush (STDOUT)
      call printf ("SYNTHIM:  tmax: %10.3f (nm)  xmax=%8.2f  ymax=%8.2f\n")
	  call pargd (tmax)
	  call pargd (xmax)
	  call pargd (ymax)
      call flush (STDOUT)
	} # end of statistics section

   # Write minimum and maximum of deposition to image header
   #   A slight corruption of their actual meaning.
   IM_MIN(im) = tmin
   IM_MAX(im) = tmax
   IM_LIMTIME(im) = clktime(0)

#  Unmap the image.
	call imunmap (im)

#  Say Goodbye
	call printf ("SYNTHIM is complete for %s.\n")
		call pargstr (Memc[outimg])

	call sfree (sp)

end

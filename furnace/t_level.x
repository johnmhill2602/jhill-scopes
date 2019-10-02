# LEVEL -- Task to measure faceplate glass level (find a step) on an image

include <time.h>
include <error.h>
include <imhdr.h>

procedure t_level()

.help

#  History
#	12FEB94 - Created in SPP by J. M. Hill, Steward Observatory
#       19JAN97 - Added search box for correlation edge.
#       16OCT97 - changed INDEF to INDEFR for V2.11

#  Future Improvements

.endhelp

#  Local Variables
pointer	image			# image file name
int     ymin, ymax
int     xmin, xmax
int     width                   # halfwidth of the step template
real    scale                   # pixel scale (units/pixel)
real    pzero                   # zero point in pixels
real    cwidth, cradius         # centering parameters
int	verbosity		# quantity of info to print

string	version	"19-JAN-97"	# version Date of Code
char	time[SZ_TIME]

pointer template, average, column, ccf, result
pointer listin
pointer sp, sq
pointer	id
pointer imsp
int	npixx, npixy		# image (imsp) size in pixels
real	zmin, zmax		# min and max input values
real    cmax
real  height, value, center
int     jj, kk, ll, vv

errchk	salloc, imgs2d, immap

#  Function Declarations

long	clktime()
int	clgeti()
real	clgetr()
real    asumr()
real    center1d()
int	imaccess()
int	imtgetim()
pointer	imtopenp()
pointer immap(), imgs2r()


begin

#  Introduce Program
   call printf ("LEVEL of the glass Program, SPP Version of %s\n")
       call pargstr (version)

#  Get Date and Time
   call cnvtime (clktime(0), time, SZ_TIME)
   call printf ("       Executed on: %s\n")
       call pargstr (time)

   call flush (STDOUT)

#  Allocate Memory
   call smark (sp)
   call salloc (image, SZ_FNAME, TY_CHAR)

   # Open the image templates
   listin = imtopenp ("image")

   #  Get Task Parameters
   # call clgstr ("image", Memc[image], SZ_FNAME)
   ymin = clgeti ("ymin")
   ymax = clgeti ("ymax")
   xmin = clgeti ("xmin")
   xmax = clgeti ("xmax")
   width = clgeti ("width")
   scale = clgetr ("scale")
   pzero = clgetr ("pzero")
   cwidth = clgetr ("cwidth")
   cradius = clgetr ("cradius")
   verbosity = clgeti ("verbosity")

   # allocate dynamic memory for the template
   call salloc ( template, 2*width, TY_REAL )
   call salloc ( result, 2*width, TY_REAL )

   # Loop over all the images in the template
   while (imtgetim (listin, Memc[image], SZ_FNAME) != EOF) {

      # save stack pointer
      call smark (sq)
      
      # Check for existence of image
      if (imaccess (Memc[image], READ_ONLY) == YES) {
	 if (verbosity >= 4) {
	    call printf ("LEVEL:  Reading image file: %s\n")
	        call pargstr (Memc[image])
	    call flush (STDOUT)
	 }
      } # end if
      else {
	 call printf ("LEVEL:  Cannot find image file: %s\n")
	     call pargstr (Memc[image])
	 call flush (STDOUT)
      } # end else
	
      id = immap (Memc[image], READ_ONLY, 0)

      npixx = IM_LEN(id,1)
      npixy = IM_LEN(id,2)

      if (verbosity >= 4) {
	 call printf ("  %4u by %4u pixels.\n")
          call pargi (npixx)
          call pargi (npixy)
	 call printf ("  title = '%s'\n")
	  call pargstr (IM_TITLE (id))
	 call flush (STDOUT)
      }

      if ( ymin == INDEFI || ymin <= 0 )
	 ymin = 1
      if ( ymax == INDEFI || ymax > npixy)
	 ymax = npixy
      if ( xmin == INDEFI || xmin <= 0 )
	 xmin = 1
      if ( xmax == INDEFI || xmax > npixx)
	 xmax = npixx
      
      if (verbosity >= 4) {
	 call printf ("LEVEL:  Averaging columns %u to %u\n")
             call pargi (xmin)
             call pargi (xmax)
	 call printf ("LEVEL:  Searching lines %u to %u\n")
             call pargi (ymin)
             call pargi (ymax)
	 call flush (STDOUT)
      }

      # This 2d manipulation is not really needed.
      # allocate dynamic memory for the image
      call salloc ( imsp, npixx*npixy, TY_REAL )

      # Read in the image
      call amovr (Memr[imgs2r(id, 1, npixx, 1, npixy)], Memr[imsp], npixx*npixy)

      # Find minimum and maximum input values in z dimension.
      call alimr (Memr[imsp], npixx*npixy, zmin, zmax)

      if (verbosity >= 4) {
	 call printf ("LEVEL:  Z-values range from %.2f to %.2f\n")
          call pargr (zmin)
          call pargr (zmax)
	 call printf ("LEVEL:  Image scale is %.4f units/pixel.\n")
          call pargr (scale)
	 call printf ("LEVEL:  Image zeropoint is %.4f pixels.\n")
          call pargr (scale)
	 call printf ("LEVEL:  X-range is %.2f,  Y-range is %.2f\n")
          call pargr (scale*npixx)
          call pargr (scale*npixy)
	 call flush (STDOUT)
      }
      
      # allocate dynamic memory for the columns
      call salloc ( average, npixy, TY_REAL )
      call salloc ( column, npixy, TY_REAL )
      call salloc ( ccf, npixy, TY_REAL )

      # Read in the first image column
      call amovr (Memr[imgs2r(id, xmin, xmin, 1, npixy)], Memr[average], npixy)

      # Extract/combine columns from the region
      for (ll=xmin+1; ll<=xmax; ll=ll+1) {
	 # Read in the next image column
	 call amovr (Memr[imgs2r(id, ll, ll, 1, npixy)], Memr[column], npixy)
	 # Add to the average (sum) column
	 call aaddr (Memr[average], Memr[column], Memr[average], npixy)
      } # end for

      # unmap the image descriptor
      call imunmap (id)


      # Generate the template
      for (jj=1; jj<=width; jj=jj+1) {
	 Memr[template+jj-1] = - real(jj) / real(width)
	 Memr[template+2*width-jj] = real(jj) / real(width)
      } # end for

      if (verbosity >= 6) {
	 for (jj=1; jj<=2*width; jj=jj+1) {
	    call printf ("LEVEL:  Template value %u is %.4f\n")
	        call pargi (jj)
	        call pargr (Memr[template+jj-1])
	 }
	 call flush (STDOUT)
      }

      # Is npixy > 2 * width?

      
      # clear the ccf vector
      call aclrr (Memr[ccf], npixy)
   
      # Correlate the template
      for (kk=1; kk<=npixy-2*width; kk=kk+1) {
	 call amulr (Memr[average+kk-1], Memr[template], Memr[result], 2*width)
	 Memr[ccf+kk+width-1] = asumr (Memr[result], 2*width)
      } # end for

      if (verbosity >= 7) {
	 for (kk=1; kk<=npixy-2*width; kk=kk+1) {
	    call printf ("LEVEL:  ccf value %u is %.4f\n")
	        call pargi (kk)
	        call pargr (Memr[ccf+kk-1])
	 }
	 call flush (STDOUT)
      }
   
      # Find minimum and maximum input values in z dimension.
      call alimr (Memr[ccf], npixy, zmin, zmax)

      if (verbosity >= 4) {
	 call printf ("LEVEL:  ccf values range from %.2f to %.2f\n")
	     call pargr (zmin)
	     call pargr (zmax)
	 call flush (STDOUT)
      }

      # Find the edge
      cmax = 0.0
      for (kk=ymin; kk<=ymax; kk=kk+1) {
	 if ( Memr[ccf+kk-1] > cmax ) {
	    value = kk
	    vv = kk
	    cmax = Memr[ccf+kk-1]
	    height = scale * (value - pzero)
	 } # end if
      } # end for

      # Fit the peak
      center = center1d (value, Memr[ccf], npixy, cwidth, 1, cradius, 1.0)
      if (center != INDEFR)
	 height = scale * (center - pzero)
      else
	 height = scale * (value - pzero)
      
      call printf ("LEVEL:  %s peak ccf at %u >> %.2f = %.4f is %.2f\n")
          call pargstr (Memc[image])
          call pargi (vv)
          call pargr (center)
          call pargr (height)
          call pargr (Memr[ccf+vv-1])
      call flush (STDOUT)
         
      call sfree (sq)
      
   } # end while

   call imtclose (listin)

#  Say Goodbye
   if (verbosity >= 4)
      call printf ("LEVEL is complete.\n")

   call sfree (sp)

end

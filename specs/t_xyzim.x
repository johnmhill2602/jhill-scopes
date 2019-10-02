# T_XYZIM.X - Code for the xyz to image interpolator.

include <error.h>
include <imhdr.h>
include <time.h>

define MINSMOOTH	4

# History
# T. Trebisky  8/7/89 - much of the code ripped-off rom
# A. Koski's "odisp" used to display oven temperatures
# R Meeks modified various hardwired dimensions 11/30/90
# Parametrized numxyz, outpix, xmin, ymin, xmax, ymax  - J. M. Hill 4/27/92
# Integrated into scopes.specs package JMH 4/28/92
# Optional imtitle parameter.  JMH  14JAN93
# Search for image dimension bug. JMH 21APR04

# uncomment for stand-alone code 
# task	xyzim = t_xyzim

procedure t_xyzim ()

string	version	"21-APR-04"	# version Date of Code
bool debug
char infile[SZ_PATHNAME]
char image[SZ_PATHNAME]
char title[SZ_PATHNAME]
char    time[SZ_TIME]    # time string
int nxy, numxyz, outpix
int fd
pointer imsp, sp, xp, yp, zp

int	ier, ix, iy		# error code from smooth routine
int	npixx, npixy		# image (imsp) size in pixels
double	xmin, xmax, ymin, ymax	# x, y image limit values
double	zmin, zmax		# min and max input values
double  xinc, yinc
double  radius, rmaski, rmasko, maskf
double  xscale, yscale
pointer	im
pointer xi, yi, wk, iwk

bool	clgetb()
int     clgeti()
double  clgetd()
int	imaccess()
int     strlen()
pointer immap(), imps2d()
int	nscan(), fscan(), open()
long    clktime()

errchk	open, salloc, imps2d

begin

   #  Introduce Program
   call printf ("XYZIM image interpolator, SPP Version of %s\n")
       call pargstr (version)

#  Get Date and Time
   call cnvtime (clktime(0), time, SZ_TIME)
   call printf ("       Executed on: %s\n")
       call pargstr (time)
   call flush (STDOUT)


   # save the stack pointer
   call smark (sp)
   
   # Get parameters from the cl.
   debug = clgetb ("debug")

   numxyz = clgeti ("numxyz")    # maximum number of xyz points
   outpix = clgeti ("outpix")    # dimension of output image

   # allocate dynamic memory for xyz points
   call salloc ( xp, numxyz, TY_DOUBLE )
   call salloc ( yp, numxyz, TY_DOUBLE )
   call salloc ( zp, numxyz, TY_DOUBLE )
   
   call clgstr ("input",infile,SZ_PATHNAME)
   call clgstr ("image",image,SZ_PATHNAME)
   call clgstr ("title",title,SZ_PATHNAME)
   if (debug) {
      call eprintf ("input file name = '%s'\n")
          call pargstr (infile)
      call eprintf ("image name = '%s'\n")
          call pargstr (image)
      call eprintf ("title = '%s'\n")
          call pargstr (title)
      call flush (STDOUT)
   }

   iferr ( fd = open(infile,READ_ONLY,TEXT_FILE) ) {
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
	 } else {
	    call printf ("xyz:  %.2f %.2f %.6f\n")
	        call pargd (Memd[xp+nxy-1])
	        call pargd (Memd[yp+nxy-1])
	        call pargd (Memd[zp+nxy-1])
	    call flush (STDOUT)
	 }
      }
   }
   call close ( fd )

   call printf ("XYZIM:  Read %6u good xyz points.\n")
       call pargi (nxy)
   call flush (STDOUT)

   # allocate dynamic memory for the image
   call salloc ( imsp, outpix*outpix, TY_DOUBLE )


   # image dimensions, for the moment square
   npixx = outpix
   npixy = outpix

   # physical limits of the image
   # how do we force image to be a square?
   
   xmin = clgetd ("xmin")
   xmax = clgetd ("xmax")

   # autoscale if any limits are indef
   if (xmin == INDEFD || xmax == INDEFD) {
      call alimd (Memd[xp], nxy, xmin, xmax)
      call printf ("XYZIM:  Autoscaling the X-coordinate\n")
   }
   
   call printf ("XYZIM:  Using points from X= %.4f to %.4f\n")
       call pargd (xmin)
       call pargd (xmax)

   ymin = clgetd ("ymin")
   ymax = clgetd ("ymax")

   # autoscale if any limits are indef
   if (ymin == INDEFD || ymax == INDEFD) {
      call alimd (Memd[yp], nxy, ymin, ymax)
      call printf ("XYZIM:  Autoscaling the Y-coordinate\n")
   }

   call printf ("XYZIM:  Using points from Y= %.4f to %.4f\n")
       call pargd (ymin)
       call pargd (ymax)

   xscale = (xmax - xmin)/npixx
   yscale = (ymax - ymin)/npixy

   call printf ("XYZIM:  xscale= %9.4f,  yscale=%9.4f\n")
       call pargd (xscale)
       call pargd (yscale)


   # Find minimum and maximum input values in z dimension.
   call alimd (Memd[zp], nxy, zmin, zmax)

   call printf ("XYZIM:  Z-values range from %.4f to %.4f\n")
       call pargd (zmin)
       call pargd (zmax)
   call flush (STDOUT)
   
   # There must be at least so many points for the smooth routine.
   if (nxy < MINSMOOTH) {
      call eprintf ("Number of data points = %d ( < %d )\n")
	    call pargi (nxy)
	    call pargi (MINSMOOTH)
      call error (15, "Too few data points to smooth")
   }
    
   call printf ("XYZIM:  Smoothing into %u by %u pixels.\n")
       call pargi (npixx)
       call pargi (npixy)
   call flush (STDOUT)

   # allocate dynamic memory for smoothing
   call salloc (xi, npixx, TY_DOUBLE)
   call salloc (yi, npixy, TY_DOUBLE)
   call salloc (iwk, 31*nxy+npixx*npixy, TY_INT)
   call salloc (wk, 6*nxy, TY_DOUBLE)

   # calculate pixel scale (location)
   xinc= (xmax-xmin)/double(npixx-1)
   yinc= (ymax-ymin)/double(npixy-1)

   # location of the first pixel
   Memd[xi] = xmin
   Memd[yi] = ymin

   # Generate x and y locations for the interpolation
   do ix=2,npixx {
      Memd[xi+ix-1] = Memd[xi+ix-2] + xinc
   }

   do iy=2,npixy {
      Memd[yi+iy-1] = Memd[yi+iy-2] + yinc
   }

   # call the interpolation routine
   call iqhscv(Memd[xp], Memd[yp], Memd[zp], nxy,
	Memd[xi], npixx, Memd[yi], npixy, Memd[imsp], npixx,
	Memi[iwk], Memd[wk], ier)

   if (ier != 0) {
      call eprintf ("Smooth routine error return = %d\n")
	  call pargi (ier)
      call error (18, "Smooth routine failed")
   }

   # get parameters for masking the output image
   rmasko = clgetd ("rmasko")
   rmaski = clgetd ("rmaski")
   maskf = clgetd ("maskf")
   
   call printf ("Masking circle outside radius %.2f and inside radius %.2f.\n")
       call pargd (rmasko)
       call pargd (rmaski)
   call flush (STDOUT)

   # convert masking parameters to pixel space
   if (rmasko != INDEFD )
      rmasko = rmasko / xinc
   if (rmaski != INDEFD )
      rmaski = rmaski / xinc
      
   # This section truncates to a circular image --  added by jmh
   do ix=1,npixx {
      do iy=1,npixy {
	 radius = (ix-npixx/2-0.5)**2 + (iy-npixy/2-0.5)**2
	 radius = sqrt(radius)
	 if (rmasko != INDEFD && radius >= rmasko)
	    Memd[imsp+(ix-1)*npixy+(iy-1)] = maskf
	 else if (rmaski != INDEFD && radius <= rmaski)
	    Memd[imsp+(ix-1)*npixy+(iy-1)] = maskf
      }
   }
	

   call printf ("XYZIM:  writing image file: %s\n")
       call pargstr (image)
   call flush (STDOUT)
   
   # delete any old image file
   if (imaccess (image, READ_ONLY) == YES)
      call imdelete (image)
	
   im = immap (image, NEW_IMAGE, 0)

   IM_NDIM(im) = 2
   IM_LEN(im, 1) = npixx
   IM_LEN(im, 2) = npixy
   IM_PIXTYPE(im) = TY_REAL

   if (strlen(title) > 0) {
      call sprintf (IM_TITLE(im), SZ_IMTITLE, "%s")
	call pargstr (title)
   }
   else {
      call sprintf (IM_TITLE(im), SZ_IMTITLE, "%s %s")
	call pargstr ("Mirror Deflections from file:")
        call pargstr (infile)
   }
   if (debug) {
      call eprintf ("  title = '%s'\n")
	  call pargstr (IM_TITLE (im))
   }

   # Set keywords for minimum and maximum input values.
   call imaddr (im, "DATAMIN", real (zmin))
   call imaddr (im, "DATAMAX", real (zmax))
   if (debug) {
      call printf ("data min/max = %.2f, %.2f\n")
	    call pargr (real (zmin))
	    call pargr (real (zmax))
   }

#	if (debug) {
#	    call eprintf ("background value = %.2f")
#		call pargr (real (bgval))
#	    call eprintf ("\n")
#	}

   # Write out image.
   call amovd (Memd[imsp], Memd[imps2d(im, 1, npixx, 1, npixy)], npixx * npixy)
	
   call imunmap (im)

   call printf ("XYZIM complete.\n")
   
   call sfree (sp)

end

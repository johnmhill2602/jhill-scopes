# T_XYZMOM.X - Code for the xyz to moment computation

include <error.h>
include <imhdr.h>
include <time.h>

# History
# Created 31AUG94 from t_xyzim.x by J. M. Hill, Steward Observatory

# To Do
#	make a scheme that works for unbalanced moment distributions

# uncomment for stand-alone code 
# task	xyzmom = t_xyzmom

procedure t_xyzmom ()

string	version	"26-SEP-94"	# version Date of Code
bool debug
char infile[SZ_PATHNAME]
char image[SZ_PATHNAME]
char title[SZ_PATHNAME]
char    time[SZ_TIME]    # time string
int nxy, numxyz, outpix
int fd
pointer imsx, imsy, imsm, sp, xp, yp, zp

int	ix, iy, ip		# pixel indices
int	npixx, npixy		# image (imsx) size in pixels
double	xmin, xmax, ymin, ymax	# x, y image limit values
double	zmin, zmax		# min and max input values
double  xinc, yinc
double  xdiff, ydiff
double  xposn, yposn
double	xmom, ymom
double	zsum, mmom, area, yval
double  radius, rmaski, rmasko, maskf
pointer	im

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

   # Introduce Program
   call printf ("XYZMOM image moments, SPP Version of %s\n")
       call pargstr (version)

   # Get Date and Time
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
   zsum = 0.0  # sum of forces
   xmom = 0.0
   ymom = 0.0   
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
	    zsum = zsum + Memd[zp+nxy-1]
	    xmom = xmom + Memd[xp+nxy-1]*Memd[zp+nxy-1]
	    ymom = ymom + Memd[yp+nxy-1]*Memd[zp+nxy-1]
	 } # end else
      } # end else
   } # end while

   call close ( fd )

   call printf ("XYZMOM:  Read %6u good xyz points with sum of %.2f .\n")
       call pargi (nxy)
       call pargd (zsum)
   call printf ("XYZMOM:  Net x-moment %.2f  y-moment %.2f \n")
       call pargd (xmom)
       call pargd (ymom)
   call flush (STDOUT)

   # allocate dynamic memory for the images
   call salloc ( imsx, outpix*outpix, TY_DOUBLE )
   call salloc ( imsy, outpix*outpix, TY_DOUBLE )
   call salloc ( imsm, outpix, TY_DOUBLE )

   # image dimensions, for the meantime square
   npixx = outpix
   npixy = outpix

   # physical limits of the image
   # how do we force image to be a square?
   
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

   call printf ("XYZMOM:  Using points from X= %.2f to %.2f\n")
       call pargd (xmin)
       call pargd (xmax)
   call printf ("XYZMOM:  Using points from Y= %.2f to %.2f\n")
       call pargd (ymin)
       call pargd (ymax)


   # calculate pixel scale (location)
   xinc= (xmax-xmin)/double(npixx-1)
   yinc= (ymax-ymin)/double(npixy-1)

   call printf ("XYZMOM:  xscale= %8.3f,  yscale=%8.3f\n")
       call pargd (xinc)
       call pargd (yinc)

   # Find minimum and maximum input values in z dimension.
   call alimd (Memd[zp], nxy, zmin, zmax)

   call printf ("XYZMOM:  Z-values range from %.2f to %.2f\n")
       call pargd (zmin)
       call pargd (zmax)
   call flush (STDOUT)
   
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

   # area of the mirror in square pixels
   if (rmasko != INDEFD && rmaski != INDEFD )
	area = acos(-1.0) * (rmasko**2 - rmaski**2)
   else if (rmasko == INDEFD && rmaski != INDEFD )
	area = npixx * npixy - acos(-1.0) * rmaski**2
   else if (rmasko != INDEFD && rmaski == INDEFD )
	area = acos(-1.0) * rmasko**2
   else
	area = npixx * npixy

   # calculate the x-moment of a mirror which is uniform thickness.
	# this code was just slapped together to make a 1-d vector.
	# thus we later assume that the mass distribution is the same in X,Y.
   # loop over all the columns
   do ix=1,npixx {
      # sum over all columns up to the current one
      mmom = 0.0
      do iy=1,ix {
	  xposn = iy-npixx/2-0.5     # pixel units with zero at the center
	  if (rmasko == INDEFD) {
	     yval = npixy
	  }
	  else if ( abs(xposn) < rmasko )  {
	     yval = 2.0 * sqrt(rmasko**2 - xposn**2)
	  }
	  else {
	     yval = 0.0
	  }
	  if (rmaski != INDEFD  &&  abs(xposn) < rmaski ) {
	     yval = yval - 2.0 * sqrt(rmaski**2 - xposn**2)
	  }
	  # assume mass is uniformly distributed in y direction
	  # sum the moment around the present column (ix)
	  mmom = mmom + (yval * zsum / area) * (ix - iy)

          Memd[imsm+ix-1] = mmom
	} # end do
#   call printf ("pixel %d   xposn %.2f   yval %.2f   mmom %.2f\n")
#       call pargi (ix)
#       call pargd (xposn)
#       call pargd (yval)
#       call pargd (mmom)
#   call flush (STDOUT)
    } # end do ix

   # This section truncates to a circular image while calculating moments
   do ix=1,npixx {
      do iy=1,npixy {
	 xposn = ix-npixx/2-0.5     # pixel units with zero at the center
	 yposn = iy-npixy/2-0.5
	 radius = xposn**2 + yposn**2
	 radius = sqrt(radius)
	 # mask off points which are inside or outside the mirror
	 if (rmasko != INDEFD && radius >= rmasko) {
	    Memd[imsx+(ix-1)*npixy+(iy-1)] = maskf
	    Memd[imsy+(ix-1)*npixy+(iy-1)] = maskf
	 }
	 else if (rmaski != INDEFD && radius <= rmaski) {
	    Memd[imsx+(ix-1)*npixy+(iy-1)] = maskf
	    Memd[imsy+(ix-1)*npixy+(iy-1)] = maskf
	 }
	 else {
	   xmom = 0.0
	   ymom = 0.0
	   # sum the local bending moments from the list of force vectors.
	   # use only those with a larger x or y position than this point.
	   do ip=1,nxy {
		# position difference in pixel units
		xdiff = Memd[xp+ip-1]/xinc - xposn
		ydiff = Memd[yp+ip-1]/yinc - yposn
		if ( xdiff < 0 )
		    xmom = xmom + Memd[zp+ip-1] * xdiff
		if ( ydiff < 0 )
		    ymom = ymom + Memd[zp+ip-1] * ydiff
	   } # end do ip
#	   Memd[imsx+(ix-1)*npixy+(iy-1)] = xmom
#	   Memd[imsy+(ix-1)*npixy+(iy-1)] = ymom
	   # subtract off the counter moment from the mirror mass distribution
	   Memd[imsx+(ix-1)*npixy+(iy-1)] = xmom + Memd[imsm+ix-1]
	   Memd[imsy+(ix-1)*npixy+(iy-1)] = ymom + Memd[imsm+iy-1]
	 } # end else
      } # end do iy
   } # end do ix

   call printf ("XYZMOM:  writing image file: %s\n")
       call pargstr (image)
   call flush (STDOUT)
   
   # delete any old image file
   if (imaccess (image, READ_ONLY) == YES)
      call imdelete (image)
	
   im = immap (image, NEW_IMAGE, 0)

   IM_NDIM(im) = 2
   IM_LEN(im, 1) = npixx
   IM_LEN(im, 2) = npixy*2
   IM_PIXTYPE(im) = TY_REAL

   if (strlen(title) > 0) {
      call sprintf (IM_TITLE(im), SZ_IMTITLE, "%s")
	call pargstr (title)
   }
   else {
      call sprintf (IM_TITLE(im), SZ_IMTITLE, "%s %s")
	call pargstr ("Bending Moments from file:")
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

   # Write out image.
   call amovd (Memd[imsx], Memd[imps2d(im, 1, npixx, 1, npixy)], npixx * npixy)
   call amovd (Memd[imsy], Memd[imps2d(im, 1, npixx, npixy+1, npixy*2)],
		 npixx * npixy)
	
   call imunmap (im)

   call printf ("XYZMOM complete.\n")
   
   call sfree (sp)

end

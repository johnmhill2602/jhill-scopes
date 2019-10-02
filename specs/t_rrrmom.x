# T_RRRMOM.X - Code for the xyz to wierd radial moment computation

include <error.h>
include <time.h>

# History
# Created 23SEP94 from t_xyzmom.x by J. M. Hill, Steward Observatory

# uncomment for stand-alone code 
# task	rrrmom = t_rrrmom

procedure t_rrrmom ()

string	version	"27-SEP-94"	# version Date of Code
bool debug
char infile[SZ_PATHNAME]
char time[SZ_TIME]    # time string
int nxy, numxyz, outpix
int fd
pointer sp, xp, yp, zp

int	ix, ip		# pixel indices
int	npixx, npixy		# image (imsx) size in pixels
double	xmin, xmax, ymin, ymax	# x, y image limit values
double	zmin, zmax		# min and max input values
double  xinc, yinc
double  xdiff, ydiff
double  xposn
double	xmom, ymom
double	zsum, radius

bool	clgetb()
int     clgeti()
double  clgetd()
int	nscan(), fscan(), open()
long    clktime()

errchk	open, salloc

begin

   # Introduce Program
   call printf ("RRRMOM radial moments?, SPP Version of %s\n")
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

   if (debug) {
      call eprintf ("input file name = '%s'\n")
          call pargstr (infile)
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

   call printf ("RRRMOM:  Read %6u good xyz points with sum of %.2f .\n")
       call pargi (nxy)
       call pargd (zsum)
   call printf ("RRRMOM:  Net x-moment %.2f  y-moment %.2f \n")
       call pargd (xmom)
       call pargd (ymom)
   call flush (STDOUT)

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

   call printf ("RRRMOM:  Using points from X= %.2f to %.2f\n")
       call pargd (xmin)
       call pargd (xmax)
   call printf ("RRRMOM:  Using points from Y= %.2f to %.2f\n")
       call pargd (ymin)
       call pargd (ymax)


   # calculate pixel scale (location)
   xinc= (xmax-xmin)/double(npixx-1)
   yinc= (ymax-ymin)/double(npixy-1)

   call printf ("RRRMOM:  xscale= %8.3f,  yscale=%8.3f\n")
       call pargd (xinc)
       call pargd (yinc)

   # Find minimum and maximum input values in z dimension.
   call alimd (Memd[zp], nxy, zmin, zmax)

   call printf ("RRRMOM:  Z-values range from %.2f to %.2f\n")
       call pargd (zmin)
       call pargd (zmax)
   call flush (STDOUT)
   
 
   do ix=1,npixx {
      xmom = 0.0
      xposn = ix-npixx/2-0.5     # pixel units with zero at the center
      radius = sqrt(xposn**2)
      do ip=1,nxy {
	 # radial difference in pixel units
	 xdiff = (Memd[xp+ip-1]/xinc)**2
	 ydiff = (Memd[yp+ip-1]/yinc)**2
	 xdiff = sqrt(xdiff+ydiff) - radius
	 xmom = xmom + Memd[zp+ip-1] * xdiff
      } # end do ip

      call printf ("RRRMOM:  radius= %8.3f  %8.3f,  net moment=%8.3f\n")
       call pargd (xposn)
       call pargd (radius*xinc)
       call pargd (xmom)
} # end do ix

   call printf ("RRRMOM complete.\n")
   
   call sfree (sp)

end

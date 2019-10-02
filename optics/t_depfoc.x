#  DEPFOC -- Program to Calculate Depth of Focus and Field

include <time.h>

procedure t_depfoc()

.help


This program was written by J. M. Hill at Steward Observatory.
Compute depth-of-focus parameters for telescope focal planes.

.endhelp
#--End of Documentation

#  History
#       13JAN93 - Created by J. M. Hill, Steward Observatory
#       12MAY93 - Converted to SPP from depfoc.cl

#  Parameter Declarations
double	sag1           # focal plane sag at R=1 arcminute (m)
double	ftel	       # telescope focal ratio
double	dpri           # primary mirror diameter (m)
double	lambda         # wavelength (m)
double	ppixel         # physical pixel size (m)
double	sample         # pixel sampling of image (2)
double	seeing         # seeing FWHM at 0.5 micron (arcsec)
double	isovis         # isoplanatic patch at 0.5 micron (arcmin)

#  Variable Declarations

string	version  "12-MAY-93"	# Version Date of Code
char	time[SZ_TIME]

double spixel, dpixel, scam, dcam
double srad, drad, sfocus, dfocus, sagabs
double ipatch, iseeing
int snum, dnum, iverb

#  Function Declarations

#bool	clgetb()
int     clgeti()
double	clgetd()
long	clktime()
#int     strlen()

begin

#  Get parameters from the CL
   iverb = clgeti ("verbosity")

#  Introduce Program
   if ( iverb > 3 ) {
       call printf ("DEPFOC - Focal Plane Design Program, SPP Version of %s\n")
           call pargstr (version)

#  Get Date and Time
      call cnvtime (clktime(0), time, SZ_TIME)
      call printf ("       Executed on: %s\n")
          call pargstr (time)
      call flush (STDOUT)
   }

#  Get parameters from the CL
   sag1 = clgetd ("sag1")
   ftel = clgetd ("ftel")
   dpri = clgetd ("dpri")
   lambda = clgetd ("lambda")
   ppixel = clgetd ("ppixel")
   sample = clgetd ("sample")
   seeing = clgetd ("seeing")
   isovis = clgetd ("isovis")
   

   # This calculation takes curvature of telescope focal plane as input.
   # This is expressed as the sag of the focal plane at 1 arcmin radius.
   # Then a perfect collimator/camera is assumed to magnify the telescope
   #	focal plane to a different f/ratio with no intrinsic curvature.

   # Print inputs
   if ( iverb > 5 ) {
      call printf ("%5.3f meter F/%4.1f\n")
          call pargd (dpri)
          call pargd (ftel)
      call printf ("Wavelength (m):                             %10f\n")
          call pargd (lambda)
      call printf ("Physical pixel size (m):                    %10f\n")
          call pargd (ppixel)
   }

   # Sign of focal plane curvature doesn't count
   sagabs = abs(sag1)

   # Calculate size of the isoplanatic patch
   # Scale input according to wavelength
   ipatch = isovis * (lambda / 0.5e-6)**1.2
   if ( iverb > 5 )
      call printf ("Isoplanatic Patch (arcmin):                 %10f\n")
          call pargd (ipatch)

   # Calculate size of seeing limited pixel in arcsec
   # Scale input according to wavelength
   iseeing = seeing * (lambda / 0.5e-6)**-0.2
   spixel = iseeing / sample
   if ( iverb > 5 )
      call printf ("Seeing limited pixel size (arcsec):         %10f\n")
          call pargd (spixel)

   # Calculate camera focal ratio for seeing limited pixels
   scam = 206264.8 / dpri * ppixel / spixel
   if ( iverb > 5 )
      call printf ("Seeing limited camera focal ratio:          %10f\n")
          call pargd (scam)

   # Depth of focus -- seeing limited (20% degradation)
   sfocus = 0.2 * scam * ppixel
   if ( iverb > 5 )
      call printf ("Seeing limited depth of focus +-(m):        %10f\n")
          call pargd (sfocus)

   # Calculate maximum field radius within seeing depth of focus
   # What radius is the focal plane sag twice the depth of focus?
   srad = ( 0.4 * ftel * ftel * ppixel / scam / sagabs )**0.5
   if ( iverb > 5 )
      call printf ("Seeing limited maximum radius (arcmin):     %10f\n")
          call pargd (srad)	

   # Calculate number of pixels across this field
   snum = srad * 60.0 / spixel
   if ( iverb > 5 )
      call printf ("Seeing limited field radius (pixels):       %6u\n")
	  call pargi (snum)

   # Calculate size of diffraction limited pixel in arcsec
   dpixel = 2.4 * lambda / dpri / sample * 206264.8
   if ( iverb > 5 )
      call printf ("Diffraction limited pixel (arcsec):         %10f\n")
          call pargd (dpixel)

   # Calculate camera focal ratio for diffraction limited pixels
   dcam = 206264.8 / dpri * ppixel / dpixel
   if ( iverb > 5 )
      call printf ("Diffraction limited camera focal ratio:     %10f\n")
          call pargd (dcam)

   # Depth of focus -- diffraction limited  (80% Strehl)
   dfocus = 2.0 * dcam * dcam * lambda
   if ( iverb > 5 )
      call printf ("Diffraction limited depth of focus +-(m):   %10f\n")
          call pargd (dfocus)

   # Calculate maximum radius within diffraction depth of focus
   # What radius is the focal plane sag twice the depth of focus?
   drad = 2.0 * ftel * ( lambda / sagabs )**0.5
   if ( iverb > 5 )
      call printf ("Diffracton limited maximum radius (arcmin): %10f\n")
          call pargd (drad)	

   # Calculate number of pixels across this field
   dnum = drad * 60.0 / dpixel
   if ( iverb > 5 )
      call printf ("Diffraction limited field radius (pixels):  %6u\n")
          call pargi (dnum)

   call printf ("%4.2f &%4.0f &%6.2f &%6.3f &%6.2f &%6.2f &%5u &%6.3f &%6.2f &%6.2f &%5u \n")
   call pargd (lambda*1d6)
       call pargd (ppixel*1d6)
       call pargd (ipatch)
       call pargd (spixel)
       call pargd (scam)
       call pargd (srad)
       call pargi (snum)
       call pargd (dpixel)
       call pargd (dcam)
       call pargd (drad)
       call pargi (dnum)
   call flush (STDOUT)
   
end

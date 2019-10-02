#  CASS -- Program to Calculate Parameters of a Cassegrain Focus

include <time.h>

procedure t_cass()

.help

This program calculates the first order parameters of a simple
telescope.  Given the primary diameter and the primary focal ratio,
the program will calculate the first order telescope parameters given
any two of the following design inputs: system focal ratio,
vertex--focus distance or secondary focal length.  The program will
calculate the parameters for a prime focus, a Newtonian focus, a
classical Cassegrain focus or a Gregorian focus.  Specified aspheres
may be used or the program will attempt an aplanatic design to produce
a Ritchey-Chretien focus or an aplanatic Gregorian.

These first order parameters are used in third order aberration
calculations.  The third order aberration coefficients are used to
calculate a field focus curve and secondary alignment tolerances.
Additional parameters have been added to allow design of the combined
focus for a Two-Shooter.  For systems with more than three mirrors,
system focal ratio and vertex plane--focus distance must be used for
the inputs. Someday, this may be generalized to an N-Shooter.

Note: This program calculates third order (Seidel) aberrations for
on-axis reflecting elements.  Higher order aberrations are ignored.
It does not trace rays or perform diffraction calculations.  Specified
Spotsize is RMS radius from image centroid or the 63 percent encircled
energy radius.  Be careful what you compare it to!

This program was written by J. M. Hill at Steward Observatory.

.endhelp
#--End of Documentation

#  Warning: Beware of Typos until software has been certified.
#  Two-mirror telescopes have been cross-checked carefully.

#  History
#       25OCT86 - Created by J. M. Hill, Steward Observatory
#       26OCT86 - Add more aberration Calculations.  JMH
#       05NOV86 - Add options for Prime Focus.  JMH
#       06NOV86 - Add Combined Focus Parameters.  JMH
#       08NOV86 - More Combined Focus Calculations.  JMH
#       10NOV86 - Add Obscuration and Forced M2 Asphere.  JMH
#       12NOV86 - Add RAYTRC Output File.  JMH
#       14NOV86 - Added Focal Plane Curvature.  JMH
#       17NOV86 - Flat Focal Plane Parameters and other stuff.  JMH
#       07DEC86 - Start Adding Gregorian Option.  JMH
#       14JAN87 - Calculate Size of Hole in Primary.  JMH
#       15JAN87 - Revise Gregorian Calculation.  JMH
#       09MAR87 - Start Adding Alignment Tolerances.  JMH
#               - Calculate Zero-Coma Pivot Position.
#       10MAR87 - Calculate Tilt Sensitivities.  JMH
#       13MAR87 - Scale Change from Axial Motion.  JMH
#       15MAR87 - Update .RAY file for Folding Flats.  JMH
#       16MAR87 - .RAY file gets zero coma pivot.  JMH
#       19MAR87 - Rearrange output format.  New CONFIG Call.  JMH
#       22MAR87 - Latest version of RAYTRC.INC File.  JMH
#       27MAR87 - Added ZC chop induced astigmatism estimate.  JMH
#       20JAN88 - Improve Combined Beam Optics, New Rev of CONFIG.OB  JMH
#       20FEB88 - Angles for Offset Combined Beam Optics
#       23FEB88 - Diameter of Beam at Tertiary and BC.  JMH
#       24JUN88 - Major Axis Diameter of Tertiary,
#               - Trap <nul> string for new revision of F77.  JMH
#       28JUN88 - More Offset combined optics.  JMH
#       29JUN88 - Flats for combined coude optics.  JMH
#       18APR89 - Add a RAYTRC translation before the primary mirror.  JMH
#       15NOV89 - Better Detail on Internal Obscuration of Tertiary.  JMH
#               - Calculate Net Collecting Area
#       16NOV89 - Separate Cass Hole and Specified Obscuration.
#       20DEC89 - Modify Secondary Diameter to Account for Secondary Curvature.
#       02JAN90 - Calculate Wavefront Error from Secondary Focus Motion.  JMH
#	16JUN90 - Begin Conversion of F77 version to SPP.  JMH
#	17JUN90 - Removed File I/O and RAYTRC code.  JMH
#	23JUN90 - Begin breakup into smaller procedures.  JMH
#	24JUN90 - Add global common file.  JMH
#	29JUN90 - Fix problem with common declaration!
#	30JUN90 - cass.x cass_sub1.x cass_sub2.x
#	04JUL90 - read l2 as a parameter, improve Newtonian calcs.  JMH
#		- allow secondary diameter as a design parameter.
#	05JUL90 - split out the first order design routines to cass_sub0.x
#	14JUL90 - calculate diameter of hole in secondary.  JMH
#	17JAN91 - installed in scopes.optics package.  JMH
#	06FEB91 - missing code in two_mirror when solving from fs,l2. JMH
#	03APR91 - diameter of secondary for IR aperture stop.  JMH
#	30JUL91 - calculate alpha1 when alpha2 fixed for cass.  JMH
#	24OCT91 - calculate full field distortion.  JMH
#       31JUL92 - corrected beam combiner height vs field.  JMH
#       01AUG92 - added OSLO output file.  JMH
#       03AUG92 - 5 mirror reimaging beam combination
#       04AUG92 - Changed sign for Gregorian at fs rather than magn.  JMH
#       30DEC92 - Additional 4-mirror parameters added.  JMH
#       15FEB93 - Pupil parameters.  JMH
#       26APR93 - More infrared calculations.  JMH
#       10MAY93 - flags for generating the lens file.  JMH
#       20OCT93 - Afocal systems added, fs=0  JMH
#       11JAN94 - More afocal calculations.  JMH
#       03NOV94 - Working on infrared pupil dimensions.  JMH
#       07NOV94 - added CODEV output file.  JMH
#       08NOV94 - t_cass.x is right at the SPP limit for number of strings.
#       22NOV94 - more rigorous definition of f/number = 1/2NA
#       23NOV94 - use refractive index of air for numerical aperture
#       30OCT96 - adding lens file format for OSLOPRO.  JMH
#       02SEP97 - use rigorous f/number for combined beams and primary
#               - parametrize refractive index
#       16OCT97 - changed INDEF to INDEFD for V2.11
#       19APR99 - calculated ellipse offset for tertiary mirror.  JMH
#       28AUG07 - multiply scale tolerances by 4*magn per Rakich.  JMH

#  Possible Improvements
#       Check beam combination with new f/number definitions.
#       Consider wave aberration variance tolerances
#       Finish Alignment Tolerances
#	Asphere on flat secondary
#       Include effects of Central Obstruction on Coefficients
#       Optics Graphics >> ZEMAX as well as OSLO, CODEV
#       Finish the CODEV .SEQ files
#       Field Focus Graphics >> IGI
#       How to Deal With Corrector Elements
#       How to Deal with powered tertiaries
#       How to Deal with off axis elements
#       Baffle Parameters and Vignetting Boundaries
#       How to Deal with N-Shooter Designs
#       Size, Location, and Obstruction of Baffles

#  Variable Declarations

include	"cass_common.h"

char 	title[SZ_LINE]
char    rayfile[SZ_FNAME]
char    rayprog[SZ_FNAME]

string	version  "28-AUG-07"	# Version Date of Code

char	time[SZ_TIME]

# raytrace program options
define  PROGS "|oslo|oslopro|codev|zemax|all|"
define  OSLO  1
define  OSLOPRO  2
define  CODEV 3
define  ZEMAX 4
define  ALL   5
long    iprog

#  Function Declarations

long    clgwrd()
bool	clgetb()
double	clgetd()
long	clktime()
int     strlen()

begin

#  Introduce Program
	call printf ("CASS - Telescope Design Program, SPP Version of %s\n")
		call pargstr (version)

#  Get Date and Time
	call cnvtime (clktime(0), time, SZ_TIME)
	call printf ("       Executed on: %s\n       Parameters based on third order aberration calculations.\n\n")
	    call pargstr (time)
	call flush (STDOUT)

#  Get New Parameters from the CL and show the data
	# telescope title
	call clgstr ("title", title, SZ_LINE)
	call printf ("%s\n" )
	    call pargstr ( title )

        call printf ( "telescope input parameters\n" )

	rnum = clgetd ("rnum")
        call wout ( rnum, "number of mirrors in optical train" )

	styp = clgetd ("styp")
        if( styp == 0.0d0 )
          call wout ( styp, "prime focus configuration" )
        else if( styp == 1.0d0 )
          call wout ( styp, "newtonian configuration" )
        else if( styp == 2.0d0 )
          call wout ( styp, "cassegrain configuration" )
        else if( styp == 3.0d0 )
          call wout ( styp, "gregorian configuration" )
        else
          call wout ( styp, "unknown configuration" )
	# need an error exit here ?


	d1 = clgetd ("d1")
        call wout ( d1, "primary mirror diameter (m)" )

	d1i = d1	# initial value for effective infrared aperture

	f1 = clgetd ("f1")
        call wout ( f1, "primary focal ratio" )

	#  check for a prime focus system
        if ( styp == 0.0d0 ) {
            fs = f1
	    verd = - ( d1 * f1 )
	    eve = verd	# will be recalculated if rnum > 2
	} # end if

	#  check for a newtonian system
	else if ( styp == 1.0d0 ) {
            fs = f1
	    verd = clgetd ("verd")
	    eve = verd	# will be recalculated if rnum > 2
	} # end else if

	#  two powered mirror system
	else {
	   fs = clgetd ("fs")
	   if ( styp == 3.0d0 && fs != INDEFD )  # negative fs for Gregorian
	      fs = - fs
	   if ( fs == 0.0d0 ) {
	      afbeam = clgetd ("afbeam")   # afocal beam diameter
	      if ( styp == 3.0d0 && afbeam != INDEFD )  # negative for Gregorian
		 afbeam = -afbeam
	      call wout ( afbeam, "afocal beam diameter (m)" )
	   } # end if
	   
	   verd = clgetd ("verd")
	   l2 = clgetd ("l2")
	   if ( styp == 2.0d0 && l2 >= 0.0d0 && l2 != INDEFD )
	      call printf ("Warning: convex Cassegrain secondary has negative focal length.\n")
	   if ( styp == 3.0d0 && l2 <= 0.0d0 && l2 != INDEFD )
	      call printf ("Warning: concave Gregorian secondary has positive focal length.\n")
	   eve = verd	# will be recalculated if rnum > 2
	} # end else

	if ( rnum >= 2.0d0 )
	    call wout ( fs, "system focal ratio" )
        
        if ( rnum >= 4.0d0 )
            call wout ( verd, "vertex plane -- focus distance (m)" )
        else if ( rnum == 3.0d0 || styp == 1.0d0 )
            call wout ( verd, "axis -- focus distance (m)" )
	else if ( rnum == 2.0d0 )
            call wout ( verd, "vertex -- focus distance (m)" )

	if ( rnum >= 2.0d0 )
	    call wout ( l2, "secondary focal length (m)" )

	field = clgetd ("field")
        call wout ( field, "field diameter (arcmin)" )

	pbaffle = clgetd ("pbaffle")
        call wout ( pbaffle, "primary obstruction (m)" )

	alpha1 = clgetd ("alpha1")
	if ( rnum > 1.0d0 )
	    alpha2 = clgetd ("alpha2")

	spotsize = clgetd ("spotsize")

	if ( rnum >= 2.0d0 ) {
	    irm2 = clgetb ("irm2")	# Calculate Infrared Secondary?
	    if (irm2) {
		lmax = clgetd ("lmax")
		call wout ( lmax, "maximum infrared wavelength (microns)" )

		xdif = clgetd ("xdif")
		call wout ( xdif, "tolerable diffraction radius" )

		cent = clgetd ("cent")
		call wout ( cent, "infrared centration allowance (m)" )
	    }
	}

   if ( rnum > 2.0d0 ) {
      vt = clgetd ("vt")
      call wout ( vt, "height of tertiary above vertex (m)" )
   }

   if ( rnum > 3.0d0 ) {
      pspace = clgetd ("pspace")
      call wout ( pspace,"separation of primaries (m, center-to-center)" )

      vh = clgetd ("vh")
      call wout ( vh, "height of beam combiner above vertex plane (m)" )

      yocomb = clgetd ("yocomb")
      # lateral offset of combined focus along symmetry plane (sign ?)
      call wout ( yocomb, "lateral offset of combined focus (m)" )
   }

   if ( rnum == 5.0d0 ) {
      fscomb = clgetd ("fscomb")
      if ( fscomb == INDEFD )
	 fscomb = fs
      if ( styp == 3.0d0 && fs != 0.0d0 )
	 # negative fscomb for Gregorian reimaging, except afocal reimaging
                fscomb = - fscomb
      else if ( styp == 2.0d0 && fs == 0.0d0 )
	 # negative fscomb for Cassegrain afocal reimaging
                fscomb = - fscomb
      call wout ( fscomb, "reimaged focal ratio" )

      vdcomb = clgetd ("vdcomb")
      if ( vdcomb == INDEFD && vh == INDEFD )
	 vdcomb = verd - vt
      call wout ( vdcomb, "reimaged vertex distance (m)" )

      vf = clgetd ("vf")
      call wout ( vf, "height of fold flat above vertex plane (m)" )

      xf = clgetd ("xf")
      call wout ( xf, "horizontal offset of fold flat from center plane (m)" )
   }
      
   if ( rnum == 6.0d0 ) {
      zelax = clgetd ("zelax")
      call wout ( zelax, "height of elevation axis above vertex plane (m)" )

      yelax = clgetd ("yelax")
      call wout ( yelax, "lateral offset of elevation axis (m)" )
   }

   # Refractive Index
   # 1.00029 is the refractive index of air: 0 deg C, 760 mm Hg @ D line
   index = clgetd ("index")
   call wout ( index, "refractive index of air" )
   
#  get name of raytrace output file and program type
   call clgstr ("rayfile", rayfile, SZ_FNAME)
   IPROG = clgwrd ("rayprog", rayprog, SZ_FNAME, PROGS)
   if ( strlen(rayfile) > 0 ) {
      rayrl = clgetb ("rayrl")	# Rays from the left or the right
      # default, rays enter telescope from the left
      rayud = clgetb ("rayud")	# Tertiary bends up or down
      rayobs = clgetb ("rayobs") # Put in obstruction surfaces
      raypup = clgetb ("raypup") # Put in entrance/exit pupil surface
      # raypup is modified by irm2 which puts exit pupil at secondary and
      #    entrance pupil ahead of primary
   }
   #   call printf ("Output filename: %s\n")
   #       call pargstr ( rayfile )

#  calculate first order parameters

   call printf ( "other telescope parameters\n" )

   call first_order


   #  system power
   if ( ls != 0.0d0 )
      power = 1.0d0 / ls    # normal
   else
      power = 0.0d0         # afocal system

#  platescale
        plate = abs ( ls * 1000.0d0 / ARCSEC_RAD )

#  field radius angle = field diameter / 2 * rad/arcmin
        ubar1 = field / 2.0d0 / DEG_RAD / 60.0d0

#  linear diameter of focal plane
        fpdia = field * 0.060d0 * plate

#  marginal ray height at primary (m) = primary radius
        y1 = d1 / 2.0d0

#  lagrange invariant or a relative thereof = ubar1 * y1 + ybar * u
        mlg = ubar1 * y1
        call wout ( mlg, "throughput (ubar1*y1)" )

   # numerical aperture of telescope light cone
   na = 0.5d0 / fs
   call wout ( na, "telescope numerical aperture" )

   #  half angle of the final beam
   # old recipe,  as = atan ( 0.5d0 / fs )
   if ( fs != 0.0d0 )
      # 1.00029 is the refractive index of air: 0 deg C, 760 mm Hg @ D line
      as = asin ( na / index )
   else
      as = 0.0d0 # afocal system
   call wout ( as, "half angle of telescope light cone (in air, rad)" )

   # initialize
   bcfd = 0.0d0
   tfd = 0.0d0
   bfd = 0.0d0
   pfd = 0.0d0

#  Calculate the distance and angles to the focal plane
   if( rnum == 1.0d0 ) {    # prime focus
      call one_mirror
   }
   else {
      # mirrors after the secondary
      if( rnum == 6.0d0 ) {         # coude combination
	 call four_mirror
      }
      else if( rnum == 5.0d0 && fs != 0.0d0 ) {    # reimaged combination
	 call five_mirror
      }
      else if( rnum == 5.0d0 && fs == 0.0d0 ) {    # type1 combination
	 call five_afocal
      }
      else if( rnum == 4.0d0 ) {    # straight combination
	 call four_mirror
      }
      else if( rnum == 3.0d0 ) {    # bent cassegrain or gregorian
	 call three_mirror
      }

      # secondary parameters
      call two_mirror
      
   } # end else

   #  size of central obstruction
        if ( pbaffle != INDEFD ) {
	   obss = ( pbaffle / d1 )**2
	   call wout ( obss, "specified central obstruction (fractional area)" )
	}
	else {
	   pbaffle = 0.0d0	# no primary obstruction specified
	   obss = 0.0d0
	}

        if( (rnum > 2.0d0) && (vt >= 0.0d0) ) {
	   # tertiary folds above primary
	   d1h = 0.0d0
	   obsh = 0.0d0
	}
        else if( (rnum == 2.0d0) && (eve < 0.0d0) ) {
	   # cassegrain focus above vertex
	   d1h = 0.0d0
	   obsh = 0.0d0
	}
        else if( rnum < 2.0d0 ) {
	   # prime focus
	   d1h = 0.0d0
	   obsh = 0.0d0
	}
        else if( fs == 0.0d0 ) {
	   # afocal system, haven't worked out the correct equation yet
	   d1h = abs( afbeam )   # true only for zero field
	   obsh = ( d1h / d1 )**2
	}
        else {
	   # primary must have a hole, derived from w&r (16)
	   # W&R (16) is more complex to account for tilted chief rays.
	   # the simple equation was d1h = fpdia + 2.0d0 * ubar1 * eve
	   d1h = d1 * eta / abs( fs ) +
		 fpdia / magn / fs * ( fs**2 - eta**2 ) / ( f1 + eta )
	   call wout ( d1h, "diameter of unused hole in primary (m)" )

	   # area of central obstruction
	   obsh = ( d1h / d1 )**2
	   call wout ( obsh, "obscuration by cassegrain hole (fractional area)" )
	}

   # is there power on the secondary?
   if( ls == 0.0d0 )
      call afocal_m2    # afocal system
   else if( ( l1 / ls )  ==  1.0d0 )
      call flat_m2	# prime or newtonian focus
   else
      call curved_m2	# curved secondary


#  sagitta, diameter and asphere of primary mirror
   call m1_size

#  sagitta, diameter, asphere of secondary mirror
   if( rnum >= 2.0d0)      # is there a secondary?
      call m2_size

   magx = ls / l1
	   call wout ( magx, "??magnification by focal length" )
   magx = bfd / ( l1 - sep )
	   call wout ( magx, "??magnification by image distance" )
   magx = a1 / as
	   call wout ( magx, "??magnification by angle U" )
   magx = tan( a1 ) / tan( as )
	   call wout ( magx, "??magnification by tangent U" )
   magx = na1 / na
	   call wout ( magx, "??magnification by numerical aperture" )
   
#  size of tertiary and other flat mirrors
   if( rnum >= 3.0d0 )
      call m3_size

   if( rnum == 4.0d0 )
      call m4_size
   else if( rnum == 5.0d0 && fs != 0.0d0 )
      call m5_size
   else if( rnum == 5.0d0 && fs == 0.0d0 )
      call m5_asize
   else if( rnum == 6.0d0 ) {
      call m4_size
      call m6_size
   }


#  calculate net obstruction of the telescope and collecting area

        # select maximum obscuration between primary, secondary, tertiary
        obsn = max ( obss, obsh )	# specified or hole
	obsn = max ( obsn, obs2 )	# previous or secondary
	obsn = max ( obsn, obs3 )	# previous or tertiary
#	call wout ( obss,"obss" )
#	call wout ( obsh,"obsh" )
#	call wout ( obs2,"obs2" )
#	call wout ( obs3,"obs3" )
        call wout ( obsn,"fractional area of telescope obscuration" )

        # calculate primary collecting area
        carea = PI2 / 2.0d0 * d1**2
        carea = carea * ( (d1i/d1)**2 - obsn )
        call wout ( carea,"net telescope collecting area (m**2)" )


   if ( fs != 0.0d0 ) {   # skip if afocal system
      
      #  calculate third order aberrations in microns

      call printf ( "wavefront aberration coefficients\n" )

      w040 = y1**4 / 32.d0 * power**3 * sigma1 * 1.0d6
      call wout ( w040,"w040  (microns)  spherical aberration" )

      w131 = mlg / 4.d0 * y1**2 * power**2 * sigma2 * 1.0d6
      call wout ( w131,"w131  (microns)  coma" )

      w222 = 0.5d0 * mlg**2 * power * sigma3 * 1.0d6
      call wout ( w222,"w222  (microns)  astigmatism" )

      w220p = 0.25d0 * mlg**2 * power * sigma4 * 1.0d6
      call wout ( w220p,"w220p (microns)  field curvature" )

      w311 = mlg**3 / y1**2 * sigma5 * 1.0d6
      call wout ( w311,"w311  (microns)  distortion" )

      if ( !irm2 && rnum >= 2 ) {
	 call printf ( "exit pupil aberration coefficients\n" )

	 # sigma1 = Y**2 + alpha2
	 x040 = dbeam2**4 / 512.d0 / l2**3 * ( xbigy2**2 + alpha2 ) * 1.0d6
	 call wout ( x040,"x040  (microns)  pupil spherical aberration" )

	 # sigma2 = -Y
	 x131 = mlg2 / 16.0d0 * dbeam2**2 / l2**2 * xbigy2 * -1.0d6
	 call wout ( x131,"x131  (microns)  pupil coma" )

	 # sigmaiii = 1
	 x222 = 0.5d0 * mlg2**2 / l2 * 1.0d6
	 call wout ( x222,"x222  (microns)  pupil astigmatism" )

	 # sigmaiv = -1
	 x220p = 0.25d0 * mlg2**2 / l2 * -1.0d6
	 call wout ( x220p,"x220p (microns)  pupil curvature" )

	 # sigmav = 0
	 x311 = 0
	 call wout ( x311,"x311  (microns)  pupil distortion" )
      } # end if

      #  image plane params

      call printf ( "focal plane parameters\n" )

      call wout ( plate,"platescale (mm/arcsec)" )

      call wout ( ubar1,"field radius angle (ubar1), (rad)" )

      call wout ( fpdia,"linear diameter of focal plane (m)" )


      #  calculate allowed image size tolerance

      call wout ( spotsize,"rms angular image radius tolerance (arcsec)" )

      ebar = spotsize * plate * 1.0d3
      call wout ( ebar,"rms physical image radius tolerance (microns)" )

      if ( fs != 0.0d0 )
	 w2e2 = ( ebar / 2.d0 / fs )**2
      else
	 w2e2 = 0.0d0 # afocal ?
      # call wout ( w2e2,"w2e2" )


      #  calculate fractional field angle with largest acceptable images
      call focal_plane

      #  calculate field-focus curve
      call field_focus


      #  calculate secondary alignment tolerances
      if ( rnum >= 2.0d0 ) {
	 if ( styp == 1.0d0 )
	    call newt_tolerances
	 else
	    call m2_tolerances
      }

      #  calculate tertiary alignment tolerances
      if ( rnum >= 3.0d0 )
	 call tert_tolerances

   } # end if -- no afocal tolerances yet

# raytrace input file
   if ( strlen(rayfile) > 0 ) {
      switch (iprog) {
	 case OSLO:
	    call oslo_rays (rayfile, title)
	 case OSLOPRO:
	    call oslopro_rays (rayfile, title, time)
	 case CODEV:
	    call codev_rays (rayfile, title)
	 case ZEMAX:
	    call zemax_rays (rayfile, title)
	 case ALL:
	    # not implemented yet
	 default:
	    # no action
      } # end switch
   } # end if rayfile

end

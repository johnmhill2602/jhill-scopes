# sub-procedures for cass,
# Version 05JUL90
# Version 06FEB91 -- flush STDOUT in wout.
# Version 30JUL91 -- Calculate alpha1 for zero spherical when alpha2 fixed.
# Version 31JUL92 -- Calculate interior angle of combined light cone.
# Version 03AUG92 -- Copied five_mirror from four_mirror
# Version 05AUG92 -- Split five_mirror into m5_size
# Version 09OCT92 -- Offset beam combiners
# Version 30DEC92 -- Fixed aap in four_mirror.
# Version 15JAN93 -- Symmetry options for beam combination in four_mirror.
# Version 15FEB93 -- Pupil dimensions
# Version 10MAY93 -- Conjugate entrance pupil for infrared
# Version 20OCT93 -- Added afocal_m2
# Version 30OCT93 -- Added five_afocal
# Version 25OCT94 -- working on pupil sizes


# Reimaging beam combiner from bent cass focus

procedure five_mirror

include	"cass_common.h"

begin
# needs: d1, fscomb, vdcomb, vt, pspace, yocomb

   call printf ( "  calculations of reimaging beam combiner, pass 1\n")
   vy = 0.0d0

   # half angle of the final beam (the reimaged beam)
   # beams from Gregorian telescopes must cross centerplane
   # unless they are reimaged!
   ascomb = atan( 0.5d0 / fscomb )
   call wout ( ascomb, "half angle of reimaged telescope light cone (rad)" )
   
   # axis-plane half angle of combined beams for proper phasing
   aa = abs(pspace) / d1 * ascomb
   call wout ( aa, "half angle of combined chief rays, axis plane (rad)" )
   # print the chief ray focal ratio ?

   # in-plane half angle of combined beams for proper phasing
   aap = sqrt( pspace**2 + 4.0d0 * yocomb**2 ) / d1 * ascomb
   call wout ( aap, "half angle of combined chief rays, in-plane (rad)" )

   # half angle of combined light cone
   ac = ( abs(pspace) + d1 ) / d1 * ascomb
   call wout ( ac, "half angle of combined light cone, axis plane (rad)" )

   # half angle of interior empty cone
   ai = ( abs(pspace) - d1 ) / d1 * ascomb
   call wout ( ai, "half angle of interior light cone, axis plane (rad)" )

   # out of plane angle of chief rays for offset combined focus
   al = 2.0d0 * yocomb / d1 * ascomb
   call wout ( al, "angle of chief ray for lateral offset, center plane (rad)" )

   # combined beam f/ratio, the long way.
   fc = 0.5d0 / tan( ac )
   call wout ( fc, "apparent combined beam focal ratio" )

   # Using the bent cass tertiary parameters
   # let verd be the distance from the axis
   if ( verd == INDEF )
      tfd = eve + vt
   else
      tfd = abs( verd )
   call wout ( tfd, "pathlength from tertiary to focus (m)" )

   # effective vertex distance, ignoring folding flats
   eve = tfd - vt
   call wout ( eve, "effective vertex distance (m)" )

   call printf ( "  end of reimaging beam combiner pass 1\n")

end

# afocal beam combiner

procedure five_afocal

include	"cass_common.h"

begin
   call printf ( "  calculations of afocal beam combiner, pass 1\n")
   vy = 0.0d0

   # half angle of the final beam (the reimaged beam)
   # beams from Gregorian telescopes must cross centerplane
   # unless they are reimaged!
   ascomb = atan( 0.5d0 / fscomb )
   call wout ( ascomb, "half angle of reimaged telescope light cone (rad)" )
   
   # axis-plane half angle of combined beams for proper phasing
   aa = abs(pspace) / d1 * ascomb
   call wout ( aa, "half angle of combined chief rays, axis plane (rad)" )
   # print the chief ray focal ratio ?

   # in-plane half angle of combined beams for proper phasing
   aap = sqrt( pspace**2 + 4.0d0 * yocomb**2 ) / d1 * ascomb
   call wout ( aap, "half angle of combined chief rays, in-plane (rad)" )

   # half angle of combined light cone
   ac = ( abs(pspace) + d1 ) / d1 * ascomb
   call wout ( ac, "half angle of combined light cone, axis plane (rad)" )

   # half angle of interior empty cone
   ai = ( abs(pspace) - d1 ) / d1 * ascomb
   call wout ( ai, "half angle of interior light cone, axis plane (rad)" )

   # out of plane angle of chief rays for offset combined focus
   al = 2.0d0 * yocomb / d1 * ascomb
   call wout ( al, "angle of chief ray for lateral offset, center plane (rad)" )

   # combined beam f/ratio, the long way.
   fc = 0.5d0 / tan( ac )
   call wout ( fc, "apparent combined beam focal ratio" )

   # Using the bent cass tertiary parameters
   # let verd be the distance from the axis
   if ( verd == INDEF )
      tfd = eve + vt
   else
      tfd = abs( verd )
   call wout ( tfd, "bogus pathlength from tertiary to focus (m)" )

   # effective vertex distance, ignoring folding flats
   eve = tfd - vt
   call wout ( eve, "bogus effective vertex distance (m)" )

   call printf ( "  end of afocal beam combiner pass 1\n")

end


# Straight four mirror beam combination with or w/o coude flats
#     Use mirror image of optics if negative value of pspace.

procedure four_mirror

include	"cass_common.h"

begin
# needs: d1, as, verd, vt, pspace, yocomb

        # adjustment of vertex distance for combined coude focus
	if ( rnum == 6.0d0 )
	    vy = abs( yocomb - yelax )
	else
	    vy = 0.0d0


   # axis-plane half angle of combined beams for proper phasing
   aa = pspace / d1 * as
   call wout ( aa, "half angle of combined chief rays, axis plane (rad)" )
   # print the chief ray focal ratio ?

   # in-plane half angle of combined beams for proper phasing
   aap = sqrt( pspace**2 + 4.0d0 * yocomb**2 ) / d1 * as
   if ( pspace < 0.0d0 )
      aap = -aap
   call wout ( aap, "half angle of combined chief rays, in-plane (rad)" )

   # half angle of combined light cone
   if ( pspace > 0.0d0 )
      ac = ( pspace + d1 ) / d1 * as
   else
      ac = ( pspace - d1 ) / d1 * as
   call wout ( ac, "half angle of combined light cone, axis plane (rad)" )

   # half angle of interior empty cone
   if ( pspace > 0.0d0 )
      ai = ( pspace - d1 ) / d1 * as
   else
      ai = ( pspace + d1 ) / d1 * as
   call wout ( ai, "half angle of interior light cone, axis plane (rad)" )

   # out of plane angle of chief rays for offset combined focus
   al = 2.0d0 * yocomb / d1 * as
   call wout ( al, "angle of chief ray for lateral offset, center plane (rad)" )

   # combined beam f/ratio, the long way.
   fc = 0.5d0 / tan( ac )
   call wout ( fc, "apparent combined beam focal ratio" )

   # impact point of chief rays w/ respect to combined axis, axis-plane
   # beams from Gregorian telescopes must cross centerplane
   bcx = ( verd + vh + vy ) * sin( aa )
   call wout ( bcx, "impact parameter on beam combiner, axis-plane (m)" )

   # impact point of chief rays w/ respect to combined axis, lateral
   bcy = ( verd + vh + vy ) * sin( al )
   call wout ( bcy, "impact parameter on beam combiner,lateral (m)" )

   # angle of ray from tertiary to beam combiner
   # this is the angle in the plane containing the optical axes.
   ag = atan2 ( ( vh - vt ) , ( pspace / 2.d0 - bcx ) )
   call wout ( ag, "axis-plane projected angle from tertiary to bc (rad)" )

   # rotation azimuth of ray from teritary to beam combiner
   # this is also the wedge angle of the offset beam combiner +-.
   # this is also the rotation azimuth of the tertiary mirror
   az = atan2 ( ( yocomb - bcy ) , ( pspace / 2.0d0 - bcx ) )
   call wout ( az, "azimuth angle from tertiary to beam combiner (rad)" )

   # distance in horizontal plane from tertiary to beam combiner
   ldbc = sqrt( ( yocomb - bcy )**2 + ( pspace / 2.0d0 - bcx )**2 )

   # net ray angle from tertiary to beam combiner (in that plane)
   aw = atan( ( vh - vt ) / ldbc )
   if ( pspace < 0.0d0 )
      aw = 2.0d0 * PI2 - aw
   call wout ( aw, "ray angle from tertiary to beam combiner (rad)" )

   # tilt of tertiary mirror
   at = 0.5d0 * ( PI2 - aw )
   call wout ( at, "tertiary tilt angle from optical axis (rad)" )

   # ray angle from beam combiner to focus, in-plane
   #    abr = aap - PI2 if we don't care about it being positive
   abr = aap + 3.0d0 * PI2
   call wout ( abr, "ray angle from beam combiner to focus (rad)")

   # tilt angle of the beam combiner mirror (down-looking)
   abp = 0.5d0 * ( - abr - aw )
   call wout ( abp, "tilt angle of the beam combiner mirror (rad)" )
   
   # half angle of beam combiner apex, axis-plane --- convention problem?
   # complement of the tilt angle
   if ( pspace > 0.0d0 )
      ab = 0.5d0 * ( PI2 + aw + aa )
   else
      ab = 0.5d0 * ( -3.0d0 * PI2 + aw + aa )
   call wout ( ab, "half angle of beam combiner apex (rad)" )

   # pathlength from beam combiner to focus
   bcfd = ( vh + verd + vy ) / cos( aa ) / cos( al )
   call wout ( bcfd, "pathlength from beam combiner to focus (m)" )

   # rotation azimuth of ray from beam combiner to focus
   ar = atan2( bcy, bcx )
   call wout ( ar, "azimuth angle from beam combiner to focus (rad)" )

   # effective height of beam combiner apex above the focal plane
   bch = vh + verd + vy - bcx / tan( ab )
   call wout ( bch, "height of beam combiner apex above focal plane (m)" )

   # pathlength from tertiary to focus
   tfd = ldbc / abs( cos( aw ) ) + bcfd
   call wout ( tfd, "pathlength from tertiary to focus (m)" )

   # effective vertex distance, ignoring folding flats
   eve = tfd - vt
   call wout ( eve, "effective vertex distance (m)" )


   # folding flats for combined coude focus,  still experimental
   if ( rnum == 6.0d0 ) {

      # effective vertex distance from m5 folding flat to focus
      #    assumes m5 nominally 45 deg at elevation axis
      zjunk = ( vh - zelax + bcy ) / ( 1.0d0 + sin( al ) )
      m5fd = bcfd - zjunk / cos ( aa ) / cos( al )
      call wout ( m5fd, "pathlength from m5 to focus (m)" )

      # effective vertex distance from m6 folding flat to focus
      # ???? is this equation using the right strategy???
      # actual pathlength is a function of zenith angle
      zjunk = abs( yocomb - yelax + m5fd * sin( al ) ) / ( 1.0d0 + sin( al ) )
      m6fd = m5fd - zjunk / cos( aa ) / cos( al )
      call wout ( m6fd, "?pathlength from m6 to focus (m)" )
   } # end if

end


# Calculate Tertiary Parameters for a Nasmyth or Bent Cass Telescope

procedure three_mirror

include	"cass_common.h"

begin
# needs: verd or eve, vt

   # let the tertiary mirror be at 45 degrees
   at = 0.5d0 * PI2
   call wout ( at, "tertiary tilt angle from optical axis (rad)" )

   # let verd be the distance from the axis
   if ( verd == INDEF )
      tfd = eve + vt
   else
      tfd = abs ( verd )
   call wout ( tfd, "pathlength from tertiary to focus (m)" )
end


procedure	two_mirror

include	"cass_common.h"

begin
   #  separation of primary and secondary
   if( ls != 0.0d0 )
      # conventional cassegrain (convex)
      # gregorian (concave) uses negative ls
      # see also w&r (6)
      sep = l1 * ( ls - eve ) / ( ls + l1 )
   else
      # afocal system
      sep = l1 - afbeam * l1 / d1

   if ( styp == 1.0d0 )
      sep = l1 - eve		# newtonian flat

   call wout ( sep, "separation of m1 and m2 (m)" )

   #  back focal distance from secondary
   bfd = sep + eve
   if ( styp == 1.0d0 )
      bfd = eve
   # what happens for the afocal system? (use fake value of bfd)
   if ( ls != 0.0d0 )
      call wout ( bfd, "pathlength from secondary to focus (m)" )
   else
      call wout ( bfd, "bogus pathlength from secondary to focus (m)" )

   #  parameter "l" = separation / back focal distance
   if ( ls != 0.0d0 )
      l = sep / bfd   # normal definition of "l"
   else
      l = 0           # afocal system
   call wout ( l, "l = separation / back focal distance" )

   #  parameter beta from w&r (3)
   #      beta = vertex distance / focal length of m1
   if ( ls != 0.0d0 ) {
      beta = ( bfd - sep ) / l1
      call wout ( beta, "beta = vertex distance / focal length of m1" )
   }
   # what happens for the afocal system ?
   else {
      beta = INDEF
      call wout ( beta, "beta is undefined for afocal system" )
   }

   #  parameter eta from w&r (2), normalized vertex back focus
   if ( ls != 0.0d0 ) {
      eta = ( bfd - sep ) / d1
      call wout ( eta, "eta = normalized vertex back focus" )
   }
   # what happens for the afocal system ?
   else {
      eta = INDEF
      call wout ( eta, "eta is undefined for afocal system" )
   }
   
end


# Procedure to calculate distances for prime focus 

procedure one_mirror

include	"cass_common.h"

begin
   # separation of primary and secondary, prime focus has no secondary
   sep = 0.0d0

   # back focal distance from primary
   bfd = sep + eve

   # parameter "l" = separation / back focal distance
   l = sep / bfd
   call wout ( l, "l = separation / back focal distance" )

   # parameter beta from w&r (3)
   beta = ( bfd - sep ) / l1
   call wout ( beta, "beta = vertex distance / focal length of m1" )

   # parameter eta from w&r (2)
   eta = ( bfd - sep ) / d1
   call wout ( eta, "eta = normalized vertex back focus" )
end


# Procedure to calculate parameters for a newtonian or prime focus

procedure flat_m2

include	"cass_common.h"

begin
   # newtonian or prime focus, secondary fl = infinity
   if( rnum >= 2.0 ) { # Newtonian focus
      l2 = 0.0d0
      call wout ( l2, "focal length of secondary (m)" )
   }
   else { # prime focus
      l2 = 0.0d0
   }
   
   #  back focal distance from pupil
   pfd = bfd + sep

   # angle of off-axis (field) chief ray for a single telescope
   ax = asin( fpdia / 2.0d0 / pfd )
   call wout ( ax, "angle of off-axis/field chief ray (rad)" )

   #  secondary diameter = beam spread + field allowance
   if( rnum >= 2.0 ) {
      d2v = bfd / abs( fs ) + 2.0d0 * ubar1 * sep
      call wout ( d2v, "vertex diameter of secondary (m)" )

      #  obscuration caused by secondary (fractional area)
      obs2 = ( d2v / d1 )**2
      call wout ( obs2, "obscuration by secondary (fractional area)" )

      #  diameter of beam at secondary
      dbeam2 = bfd / fs
      call wout ( dbeam2, "diameter of beam at secondary (m)" )

   }
   else {
      d2v = 0.0d0
      obs2 = 0.0d0
      dbeam2 = bfd / fs
   }
   
   # calculate the primary asphere if not specified
   if( alpha1 == INDEF ) {
      alpha1 = -1.0d0         # parabolic
      call wout ( alpha1, "primary asphere parabolic" )
   }
   else
      call wout ( alpha1, "primary asphere fixed" )

   # calculate the primary eccentricity
   if( alpha1 < 0.0d0 )
      ecc1 = sqrt ( - alpha1 )        # normal
   else
      ecc1 = - sqrt ( alpha1 )        # oblate spheroid
   call wout ( ecc1, "primary eccentricity" )

   # calculate structural aberration coefficients for a single mirror
   #       assume the stop is at the mirror,  these terms add to the 
   #       two mirror terms, but it was hard to trap 1-m in the code.

   call printf( "normalized structural aberration coefficients\n" )

   sigma1 = 1.0d0 + alpha1
   call wout ( sigma1, "sigmai" )

   sigma2 = -1.0d0
   call wout ( sigma2, "sigmaii" )

   sigma3 = 1.0d0
   call wout ( sigma3, "sigmaiii" )

   sigma4 = -1.0d0
   call wout ( sigma4, "sigmaiv" )

   sigma5 = 0.0d0
   call wout ( sigma5, "sigmav" )
end

procedure curved_m2

include	"cass_common.h"

begin
   #  secondary focal length
   l2 = 1.0d0 / ( 1.0d0 / ( sep - l1) + 1.0d0 / bfd )
   call wout ( l2, "focal length of secondary (m)" )

   if ( irm2 ) {
      # Assume exit pupil at infrared secondary, calculate entrance pupil
      # calculations are corrected later for sag of secondary
      
      # entrance pupil position relative to primary
      #    separation is not corrected for sagitta of secondary
      spupil = 1.0d0 / ( 1.0d0 / l1 - 1.0d0 / sep )
      call wout ( spupil, "entrance pupil position relative to primary (m)" )

      # pupil magnification, assume Gregorian pupil magnification is negative
      mpupil = - spupil / sep
      call wout ( mpupil, "entrance pupil magnification, paraxial" )

      # chief ray angles,
      ubar2 = atan2( d1/2.0d0, sep )
      #call wout ( ubar2, "ubar2 from pupil (rad)" )

      # entrance pupil diameter
      dpupil = d2v * abs( mpupil )   # but d2v not calculated yet!
      #call wout ( dpupil, "entrance pupil diameter (m)" )

      # back focal distance from exit pupil (secondary)
      # This is used in the secondary diameter calculation below.
      pfd = bfd
   }
   else {
      # Assume entrance pupil at primary, calculate exit pupil
      
      # exit pupil position relative to secondary
      spupil = 1.0d0 / ( 1.0d0 / l2 - 1.0d0 / sep )
      call wout ( spupil, "exit pupil position relative to secondary (m)" )

      # pupil magnification, assume Gregorian pupil magnification is negative
      mpupil = - spupil / sep
      call wout ( mpupil, "exit pupil magnification" )

      # exit pupil diameter
      dpupil = - d1 * mpupil
      call wout ( dpupil, "exit pupil diameter (m)" )

      # chief ray angles, ubar2 = atan2( d1/2.0d0, sep )
      ubar2 = atan2( dpupil/2.0d0, spupil )
      #call wout ( ubar2, "ubar2 from pupil (rad)" )

      # back focal distance from exit pupil (possibly virtual)
      pfd = bfd - spupil
   }

   # angle of off-axis (field) chief ray for a single telescope
   ax = asin( fpdia / 2.0d0 / pfd )

   #  secondary diameter = beam spread + field allowance
   d2v = bfd / abs( fs )  +  2.0d0 * ubar1 * sep
   call wout ( d2v, "vertex diameter of secondary (m)" )

   #  obscuration caused by secondary (fractional area)
   obs2 = ( d2v / d1 )**2		# should be d2e for accuracy
   call wout ( obs2, "obscuration by secondary (fractional area)" )

   #  diameter of beam at secondary
   dbeam2 = bfd / abs( fs )
   call wout ( dbeam2, "vertex diameter of beam at secondary (m)" )

   #  secondary throughput for pupil (experimental)
   mlg2 = ubar2 * dbeam2 / 2.0d0
   call wout ( mlg2, "?exit pupil throughput (ubar*y) for secondary" )
   
   #  normalized marginal ray height at secondary
   y2 = 1.0d0 / ( 1.0d0 + magn * l )

   # calculate the aspheres here

   # Y for telescope
   bigy2 = ( 1.0d0 + magn ) / ( 1.0d0 - magn )
   
   # Y for pupil (experimental)
   xbigy2 = ( 1.0d0 + mpupil ) / ( 1.0d0 - mpupil )

   k = ( 1.0d0 - magn )**3 / ( 1.0d0 + magn * l )


   # if alpha1, alpha2 have not been defined, calculate rc parameters
   if (alpha1 == INDEF && alpha2 == INDEF) {
      #  ritchey-chretien conic constants, alpha1 used to set sigma1=0
      alpha1 = -1.0d0 - 2.0d0 / l / magn **3
      call wout ( alpha1, "primary asphere for rc" )

      #  alpha2 used to set sigma2=0
      alpha2 = 2.0d0 / l / k - bigy2 **2
      call wout ( alpha2, "secondary asphere for rc" )
   }
   # if alpha1 has not been defined, calculate for zero spherical
   else if (alpha1 == INDEF) {
      #  alpha1 used to set sigma1=0
      alpha1 = -1.0d0 - k * ( bigy2 **2 + alpha2 ) / magn **3
      call wout ( alpha1, "primary asphere for cass" )
      call wout ( alpha2, "secondary asphere fixed" )
   }
   # if alpha1 is fixed, calculate the relevant alpha2 for the best focus
   else if (alpha2 == INDEF) {
      call wout ( alpha1, "primary asphere fixed" )
      # alpha2 used to set sigma1=0
      alpha2 = - bigy2 **2 - magn **3 * ( 1.d0 + alpha1 ) / k
      call wout ( alpha2, "secondary asphere for cass" )
   }
   # both primary and secondary aspheres fixed
   else {
      call wout ( alpha1, "primary asphere fixed" )
      call wout ( alpha2, "secondary asphere fixed" )
   }

   #  there are lots of ways to specify the asphere.
   #       w&r (20) use k = kappa - 1
   #       kappa = alpha + 1 = epsilon (from Wynne 1968)
   #       alpha = k
   #       eccentricity = sqrt( -alpha )

   if( alpha1 < 0.0d0 )
      ecc1 = sqrt( - alpha1 )        # normal
   else
      ecc1 = - sqrt( alpha1 )        # oblate spheroid
   call wout ( ecc1, "primary eccentricity" )

   if( alpha2 < 0.0d0 )
      ecc2 = sqrt( - alpha2 )        # normal
   else
      ecc2 = - sqrt( alpha2 )        # oblate spheroid
   call wout ( ecc2, "secondary eccentricity" )


   #  calculate structural aberration coefficients for 2 mirror system
   call printf ( "normalized structural aberration coefficients\n" )

   by2a = bigy2 **2 + alpha2

   sigma1 = magn **3 * ( 1.d0 + alpha1 ) + k * by2a
   call wout ( sigma1, "sigmai" )

   sigma2 = -1.0d0 + l * k / 2.d0 * by2a
   call wout ( sigma2, "sigmaii" )

   sigma3 = 1.0d0 - ( 1.d0 - magn ) * l + l **2 * k / 4.d0 * by2a
   call wout ( sigma3, "sigmaiii" )

   sigma4 = -1.0d0 - magn * l * ( 1.d0 - magn )
   call wout ( sigma4, "sigmaiv" )

   sigma5 = l * ( 1.d0 - magn ) -
	    l **2 / 4.d0 * ( 1.d0 - magn ) * ( 3.d0 - magn ) +
	    l **3 / 8.d0 * k * by2a
   call wout ( sigma5, "sigmav" )

end

procedure afocal_m2

include	"cass_common.h"

begin
   #  secondary focal length
   l2 = -afbeam * l1 / d1
   call wout ( l2, "focal length of secondary (m)" )

   if ( irm2 ) {  # Assume exit pupil at secondary, calculate entrance pupil
      # entrance pupil position relative to primary
      spupil = 1.0d0 / ( 1.0d0 / l1 - 1.0d0 / sep )
      call wout ( spupil, "entrance pupil position relative to primary (m)" )

      # pupil magnification, assume Gregorian pupil magnification is negative
      mpupil = - spupil / sep
      call wout ( mpupil, "entrance pupil magnification" )

      # chief ray angles,
      ubar2 = atan2( d1/2.0d0, sep )
      #call wout ( ubar2, "ubar2 from pupil (rad)" )

      # entrance pupil diameter
      #dpupil = - d2v * mpupil
      #call wout ( dpupil, "entrance pupil diameter (m)" )

      # back focal distance from exit pupil (secondary)
      # This is used in the secondary diameter calculation below.
      pfd = bfd
   }
   else {  # Assume entrance pupil at primary, calculate exit pupil
      # exit pupil position relative to secondary
      spupil = 1.0d0 / ( 1.0d0 / l2 - 1.0d0 / sep )
      call wout ( spupil, "exit pupil position relative to secondary (m)" )

      # pupil magnification, assume Gregorian pupil magnification is negative
      mpupil = - spupil / sep
      call wout ( mpupil, "exit pupil magnification" )

      # exit pupil diameter
      dpupil = - d1 * mpupil
      call wout ( dpupil, "exit pupil diameter (m)" )

      # chief ray angles, ubar2 = atan2( d1/2.0d0, sep )
      ubar2 = atan2( dpupil/2.0d0, spupil )
      #call wout ( ubar2, "ubar2 from pupil (rad)" )

      # back focal distance from exit pupil (possibly virtual)
      pfd = bfd - spupil
   }

.help
   # angle of off-axis (field) chief ray for a single telescope
   ax = asin( fpdia / 2.0d0 / pfd )
.endhelp

   #  secondary diameter = beam spread + field allowance
   d2v = abs( afbeam )  +  2.0d0 * ubar1 * sep
   call wout ( d2v, "vertex diameter of secondary (m)" )

   #  obscuration caused by secondary (fractional area)
   obs2 = ( d2v / d1 )**2		# should be d2e for accuracy
   call wout ( obs2, "obscuration by secondary (fractional area)" )

   #  diameter of beam at secondary
   dbeam2 = abs( afbeam )
   call wout ( dbeam2, "vertex diameter of beam at secondary (m)" )

   #  secondary throughput for pupil (experimental)
   mlg2 = ubar2 * dbeam2 / 2.0d0
   call wout ( mlg2, "?exit pupil throughput (ubar*y) for secondary" )

.help   
   #  normalized marginal ray height at secondary
   y2 = 1.0d0 / ( 1.0d0 + magn * l )
.endhelp

   # calculate the aspheres here

   # Y for telescope
   bigy2 = ( 1.0d0 + magn ) / ( 1.0d0 - magn )
   
   # Y for pupil (experimental)
   xbigy2 = ( 1.0d0 + mpupil ) / ( 1.0d0 - mpupil )

   k = ( 1.0d0 - magn )**3 / ( 1.0d0 + magn * l )


   # if alpha1, alpha2 have not been defined, calculate rc parameters
   if (alpha1 == INDEF && alpha2 == INDEF) {
      #  ritchey-chretien conic constants, alpha1 used to set sigma1=0
      alpha1 = -1.0d0 - 2.0d0 / l / magn **3
      call wout ( alpha1, "primary asphere for rc" )

      #  alpha2 used to set sigma2=0
      alpha2 = 2.0d0 / l / k - bigy2 **2
      call wout ( alpha2, "secondary asphere for rc" )
   }
   # if alpha1 has not been defined, calculate for zero spherical
   else if (alpha1 == INDEF) {
      #  alpha1 used to set sigma1=0
      alpha1 = -1.0d0 - k * ( bigy2 **2 + alpha2 ) / magn **3
      call wout ( alpha1, "primary asphere for cass" )
      call wout ( alpha2, "secondary asphere fixed" )
   }
   # if alpha1 is fixed, calculate the relevant alpha2 for the best focus
   else if (alpha2 == INDEF) {
      call wout ( alpha1, "primary asphere fixed" )
      # alpha2 used to set sigma1=0
      alpha2 = alpha1   # true for non-parabola?
      call wout ( alpha2, "?secondary asphere for afocal" )
   }
   # both primary and secondary aspheres fixed
   else {
      call wout ( alpha1, "primary asphere fixed" )
      call wout ( alpha2, "secondary asphere fixed" )
   }

   #  there are lots of ways to specify the asphere.
   #       w&r (20) use k = kappa - 1
   #       kappa = alpha + 1 = epsilon (from Wynne 1968)
   #       alpha = k
   #       eccentricity = sqrt( -alpha )

   if( alpha1 < 0.0d0 )
      ecc1 = sqrt( - alpha1 )        # normal
   else
      ecc1 = - sqrt( alpha1 )        # oblate spheroid
   call wout ( ecc1, "primary eccentricity" )

   if( alpha2 < 0.0d0 )
      ecc2 = sqrt( - alpha2 )        # normal
   else
      ecc2 = - sqrt( alpha2 )        # oblate spheroid
   call wout ( ecc2, "secondary eccentricity" )


   #  calculate structural aberration coefficients for 2 mirror system
   call printf ( "normalized structural aberration coefficients\n" )

   by2a = bigy2 **2 + alpha2

   sigma1 = magn **3 * ( 1.d0 + alpha1 ) + k * by2a
   call wout ( sigma1, "sigmai" )

   sigma2 = -1.0d0 + l * k / 2.d0 * by2a
   call wout ( sigma2, "sigmaii" )

   sigma3 = 1.0d0 - ( 1.d0 - magn ) * l + l **2 * k / 4.d0 * by2a
   call wout ( sigma3, "sigmaiii" )

   sigma4 = -1.0d0 - magn * l * ( 1.d0 - magn )
   call wout ( sigma4, "sigmaiv" )

   sigma5 = l * ( 1.d0 - magn ) -
	    l **2 / 4.d0 * ( 1.d0 - magn ) * ( 3.d0 - magn ) +
	    l **3 / 8.d0 * k * by2a
   call wout ( sigma5, "sigmav" )

end

#  Subroutine to find the real roots of a quadratic equation
procedure quadratic_solr ( coefa, coefb, coefc, xxx, yyy )

double	coefa
double  coefb
double	coefc
double	xxx
double	yyy
double	radcl

begin
   # coefa * x**2 + coefa * x + coefc = 0

   # b**2 - 4ac
   radcl = coefb **2 - 4.0d0 * coefa * coefc

   # make sure there are real roots
   if( radcl >= 0.0d0 ) {
      # ( - b - sqrt ) / 2a
      xxx = ( - coefb - sqrt( radcl ) ) / 2.0d0 / coefa

      # ( -b + sqrt ) / 2a
      yyy = ( - coefb + sqrt ( radcl ) ) / 2.0d0 / coefa
   }
   else {
      xxx = INDEF
      yyy = INDEF
   }

end

#  Subroutine to Write Parameter Output and Keep Code Cleaner
procedure wout ( dvalue, text )

double	dvalue          # Parameter Value
char	text[ARB]   # Label

begin
   call printf ("   %15.7g     %s\n")
	call pargd (dvalue)
	call pargstr (text)
   call flush (STDOUT)
end

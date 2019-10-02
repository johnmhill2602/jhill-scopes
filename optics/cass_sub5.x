# cass_sub5.x version 10OCT92
# Version 30OCT93 Added m5_asize for afocal
# 16OCT97 -- changed INDEF to INDEFD for V2.11

# Reimaging beam combiner dimensions for two-shooter (experimental)

procedure m5_size

include	"cass_common.h"

# Scratch variables
double   zfd, dzmin, zh, dex, dey, dez, aae, bbe, cce, sse, spe


.help
The sign convention for mirror tilts is supposed to be that zero angle
  is upward looking parallel to the optical axis.

The sign convention for rays is that zero is horizontal (inward)
  and +pi/2 is upward.

See also procedure five_mirror.

Specified parameters (beware of overconstraint)
	fs      first focal ratio
	vt      tertiary height above vertex
	verd    first focus distance from axis
	pspace  primary spacing
	fscomb  reimaged focal ratio
	yocomb  lateral offset of combiner
Available parameters (for solution or specified at cl)
	vdcomb  reimaged vertex distance
	vh      beam combiner height  (must be greater than vdcomb)
	vf      fold flat height
	xf      fold flat offset  (limited by obstruction)
Derived parameters (always calculated)
	at      tertiary tilt  (limited by primary/secondary edge)
	af      fold flat tilt
	aell    beam combiner axis angle
	l5      beam combiner focal length

Almost standard definitions:
  Axis Plane --- plane containing optical axes of the two primaries.
  Vertex Plane --- plane perpendicular to optical axes at primary vertices.
  Center Plane --- mid-plane between two telescopes
  In-Plane --- plane containing the relevant rays (parallel to axis)
.endhelp

begin
   call printf ( "  calculations of reimaging beam combiner, pass 2\n")

   if ( vdcomb == INDEFD ) {
      # if vh vf, xf are specified
      # calculate the required vertex distance
   }
   
   if ( vh == INDEFD ) {
      # Estimate height of beam combiner based on unvignetted field
      #  or based on required relay distance.
      # But where is the reimaged exit pupil?
      # OR
      # if vdcomb, vf, xf are specified
      # calculate the required height
   }

   else {
      # Assume both vh and vdcomb are fixed.
   
      # Use specified beam combiner height.

      # Impact point of chief rays w/ respect to combined axis, axis-plane
      #   positive bcx is on original side of center plane
      bcx = ( vdcomb + vh + vy ) * sin( aa )
      call wout ( bcx, "impact parameter on beam combiner, axis-plane (m)" )

      # Impact point of chief rays w/ respect to combined axis, lateral
      #  positive bcy is closer to axis plane; doesn't reverse with yocomb
      bcy = ( vdcomb + vh + vy ) * sin( al )
      call wout ( bcy, "impact parameter on beam combiner, lateral (m)" )

      # angle of ray from tertiary to beam combiner w/o any fold flat
      # this is the angle in the plane containing the optical axes.
      # ag = atan2( ( vh - vt ) , ( pspace / 2.0d0 - bcx ) )
      # call wout ( ag, "axis-plane projected angle from tertiary to bc (rad)" )

      # rotation azimuth of ray from teritary to beam combiner
      # this is also the rotation azimuth of the tertiary mirror
      az = atan( ( yocomb - bcy ) / ( pspace / 2.0d0 - bcx ) )
      call wout ( az, "*azimuth angle from tertiary to beam combiner (rad)" )

      # rotation azimuth of ray from teritary to focus
      # this is also the rotation azimuth of the tertiary mirror
      az = atan( ( yocomb ) / ( pspace / 2.0d0 ) )
      call wout ( az, "*azimuth angle from tertiary to focus (rad)" )
      # recalculated below as az, aq, ar
      
      # pathlength from beam combiner to focus
      # bcfd = ( vh + vdcomb + vy ) / cos( aa ) / cos( al )
      bcfd = ( vh + vdcomb + vy ) / cos( aap )
      call wout ( bcfd, "pathlength from beam combiner to focus (m)" )


      if ( xf == INDEFD ) {
	 # Calculate xf based on minimum reimaging angle or flat focal planes
	 # But that's hard.  So use bcx as crude estimate for now.
	 xf = bcx
	 yf = bcy
	 # change this if yf becomes a parameter
      }
      else {
.help
	 # Use specified xf, but adjust sign to match bcx
	 if ( bcx < 0.0d0 && xf > 0.0d0 )
	    xf = -xf
	 else if ( bcx > 0.0d0 && xf < 0.0d0 )
	    xf = -xf
	 # Not absolutely a requirement, just keeps folded beams clear
.endhelp
	 # Calculate yoffset of fold flat
	 #  assume z-projected chief ray is a straight line
	 yf = yocomb  / ( pspace / 2.0d0 ) * ( pspace / 2.0d0 - xf )
      }
      call wout ( xf, "horizontal offset of fold flat from center plane (m)" )
      call wout ( yf, "lateral offset of fold flat from axis plane (m)" )

      # azimuth rotation of tertiary mirror
      # or ray angle in plane of primaries from tertiary to fold flat
      az = atan2( yf , ( pspace / 2.0d0 - xf ) )
      call wout ( az, "azimuth rotation angle of tertiary (rad)" )

      # ray angle in plane of primaries from fold flat to beam combiner
      aq = atan2( ( yf + bcy - yocomb ), ( xf - bcx ) )
      call wout ( aq, "azimuth angle from fold flat to beam combiner (rad)" )

      # rotation azimuth of ray from beam combiner to focus
      ar = atan2( bcy, bcx )
      call wout ( ar, "azimuth angle from beam combiner to focus (rad)" )
   } # end else


   if ( vf == INDEFD ) {
      # Try to calculate the lowest beam from tertiary that won't hit primary.
      # This iteration leaves 0.25 m clearance at mirror edge!
      # Estimate of vf depends only on the telescope parameters M1--M3
      
      # diameter of the light cone at edge of primary (initial guess)
      dzmin = fpdia

      # Iterate a couple times
      zfd = tfd - sqrt( d1**2 /4.0d0 + ( vt - sag1 - 0.25 - dzmin /2.0d0 )**2 )
      dzmin = abs( zfd ) * 2.0d0 * tan( as ) + fpdia - zfd * 2.0d0 * tan( ax )
      zfd = tfd - sqrt( d1**2 /4.0d0 + ( vt - sag1 - 0.25 - dzmin /2.0d0 )**2 )
      dzmin = abs( zfd ) * 2.0d0 * tan( as ) + fpdia - zfd * 2.0d0 * tan( ax )

      # distance from edge of primary to first focal plane
      zfd = tfd - sqrt( d1**2 /4.0d0 + ( vt - sag1 - 0.25 - dzmin /2.0d0 )**2 )
      call wout ( zfd, "  distance from edge of primary to focal plane (m)" )
   
      # size of the light cone (from size of tertiary calculation)
      dzmin = abs( zfd ) * 2.0d0 * tan( as ) + fpdia - zfd * 2.0d0 * tan( ax )
      call wout ( dzmin, "  diameter of light at primary edge (m)" )

      # height of chief ray above mirror edge (useless)
      zh = 0.25 + dzmin / 2.0d0
      call wout ( zh, "  height of chief ray above primary edge (m)" )
   
      # net ray angle from tertiary to fold flat (in that plane)
      aw = atan2( ( sag1 + dzmin / 2.0d0 - vt ) , ( d1 / 2.0d0 ) )
      call wout ( aw, "ray angle from tertiary to fold flat (rad)" )

      # estimate fold flat position ( very crude )
      # doesn't account for xf or yf
      vf = vt + sin( aw ) * ( pspace / 2.0d0 )
      call wout ( vf, "height of fold flat - m4 - above vertex plane (m)" )

      # This is a practical minimum value of vf.
   }
   else {
      # Use the specified vf

      # net ray angle from tertiary to fold flat (in that plane)
      # aw = atan2( ( vf - vt ) , ( pspace / 2.0d0 - xf ) )
      aw = atan2( ( vf - vt ) , sqrt( ( pspace / 2.0d0 - xf )**2 + yf**2 ) )
      call wout ( aw, "ray angle from tertiary to fold flat (rad)" )
      # xf must have had the correct sign for this to work == Gregorian
      
      # height of chief ray above mirror edge (useless)
      zh = ( d1 / 2.0d0 ) * tan( aw ) + vt - sag1
      call wout ( zh, "  height of chief ray above primary edge (m)" )
   
      call wout ( vf, "height of fold flat - m4 - above vertex plane (m)" )
      
   }

.help
   Mirror tilt angle with respect to telescope optical axis is computed
      as minus one-half the sum of the old and new ray angles.
   For the tertiary mirror, the old ray angle is -pi/2 and the first
      quadrant of new angles is up and to the left.
   That may be a backwards defintion, but it is what this code has evolved to.
.endhelp

   # tilt of tertiary mirror
   at = 0.5d0 * ( PI2 - aw )
   call wout ( at, "tertiary tilt angle from optical axis (rad)" )

   # distance from first focus to m4
   ffa = sqrt( ( vt - vf )**2 + ( pspace / 2.0d0 - xf )**2 + ( yf )**2 )
   ffa = ffa - tfd
   call wout ( ffa, "pathlength from focus to fold flat (m)" )
      

   # angle from fold flat to beam combiner (in-plane)
   #   depends on beam combiner location
   #   needs other branches for negative yocomb
   if ( xf > 0.0d0 ) {
      ay = atan2( ( vh - vf ) ,
		  sqrt( ( xf - bcx )**2 + ( yf + bcy - yocomb )**2 ) )
   }
   else {
      ay = atan2( ( vh - vf ) ,
		  -sqrt( ( xf - bcx )**2 + ( yf + bcy - yocomb )**2 ) )
   }
   call wout ( ay, "ray angle from fold flat to beam combiner, in-plane (rad)" )
      
   # angle of 4th mirror, fold flat
   af = 0.5d0 * ( - aw - ay )
   call wout ( af, "fold flat tilt angle from optical axis (rad)" )
   
.help
Off-axis ellipsoid beam combiner.
   If vh and vdcomb are fixed,
     hold ay fixed and slide vf, aw, xf to get correct fscomb.
.endhelp


   # focal length of beam combiner relay, given beam combiner height.
   #   use lens equation and ratio of the focal ratios
   #   paraxial focal length at the off-axis segment
   l5 = 1.0d0 / ( ( fscomb / fs / ( vh + vdcomb ) ) +
		  ( 1.0d0 / ( vh + vdcomb ) ) )
   call wout ( l5, "  *paraxial focal length of the beam combiner (m)" )

   # ray angle from beam combiner to focus (in-plane)
   # axis-plane angle is aa - PI2
   abr = aap - PI2
   call wout ( abr, "ray angle from beam combiner to focus, in-plane (rad)")
   

.help
   These calculations require a self-consistent geometry.
   So we must iterate to find solution.
   Assume bcfd, vh, vdcomb, fs, ay are known.
.endhelp
   
   # desired distance from first focus to beam combiner
   ffb = bcfd * fs / fscomb
   call wout ( ffb, "  ?pathlength from focus to beam combiner (m)" )

   # measured distance from fold flat to beam combiner
   ffc = sqrt( ( vh - vf )**2 + ( bcx - xf )**2 +
	       ( - bcy + yocomb - yf )**2 ) + ffa
   call wout ( ffc, "  *pathlength from focus to beam combiner (m)" )

   if ( ffc > ffb ) {
      call printf ("  need to raise fold flat %12f\n")
          call pargd ( ffc - ffb )
   }
   else {
      call printf ("  need to lower fold flat% 12f\n")
          call pargd ( ffc - ffb )
   }
   call flush (STDOUT)

   # Iterate fold flat parameters here: vf, aw, at, xf, ffa, ffc
   #   Loop for 1 micron match.
   while ( abs( ffc - ffb ) > 1.0d-6 ) {
      # Correction to height of fold flat, vf
      vf = vf + ffc - ffb
	 
      # Correction to xf
      xf = xf - cos( ay ) * ( ffc - ffb )

      # Recalculation of yf
      yf = yocomb  / ( pspace / 2.0d0 ) * ( pspace / 2.0d0 - xf )
	 
      # distance from first focus to m4
      ffa = sqrt( ( vt - vf )**2 + ( pspace / 2.0d0 - xf )**2 + ( yf )**2 )
      ffa = ffa - tfd

      # New ffc
      ffc = sqrt( ( vh - vf )**2 + ( bcx - xf )**2 +
		  ( - bcy + yocomb - yf )**2 ) + ffa

      # Check for out of bounds
      if ( vf > vh ) {
	 call printf ("  fold flat has reached beam combiner height.\n")
	 call flush (STDOUT)
	 break
      }
      else if ( vf < - vdcomb ) {
	 call printf ("  fold flat has reached focal plane height.\n")
	 call flush (STDOUT)
	 break
      }
   } # end while

   # Print the adjusted values from the iteration
   call wout ( vf, "height of fold flat - m4, adjusted (m)" )
   call wout ( xf, "horizontal offset of fold flat, adjusted (m)" )
   call wout ( yf, "lateral offset of fold flat, adjusted (m)" )
   call wout ( ffa, "pathlength from focus to fold flat (m)" )
   call wout ( ffc, "pathlength from focus to beam combiner (m)" )

   # Recalculate  ay, az, aq (should be the same angle)
   # angle from fold flat to beam combiner (in-plane)
   #   depends on beam combiner location
   #   needs other branches for negative yocomb
   if ( xf > 0.0d0 ) {
      ay = atan2( ( vh - vf ) ,
		  sqrt( ( xf - bcx )**2 + ( yf + bcy - yocomb )**2 ) )
   }
   else {
      ay = atan2( ( vh - vf ) ,
		  -sqrt( ( xf - bcx )**2 + ( yf + bcy - yocomb )**2 ) )
   }
   call wout ( ay, "ray angle from fold flat to beam combiner, in-plane (rad)" )
      
   # azimuth rotation of tertiary mirror
   #   or ray angle in plane of primaries from tertiary to fold flat
   az = atan2( yf , ( pspace / 2.0d0 - xf ) )
   call wout ( az, "azimuth rotation angle of tertiary (rad)" )

   # ray angle in plane of primaries from fold flat to beam combiner
   aq = atan2( ( yf + bcy - yocomb ), ( xf - bcx ) )
   call wout ( aq, "azimuth angle from fold flat to beam combiner (rad)" )
      
   # Recalculate angles aw, at, af
   # net ray angle from tertiary to fold flat (in that plane)
   aw = atan2( ( vf - vt ) , sqrt( ( pspace / 2.0d0 - xf )**2 + yf**2 ) )
   call wout ( aw, "ray angle from tertiary to fold flat (rad)" )

   # tilt of tertiary mirror
   at = 0.5d0 * ( PI2 - aw )
   call wout ( at, "tertiary tilt angle from optical axis (rad)" )

   # angle of 4th mirror, fold flat
   af = 0.5d0 * ( - aw - ay )
   call wout ( af, "fold flat tilt angle from optical axis (rad)" )

   # distance from first focus to second focus
   fff = ffb + bcfd
   call wout ( fff, "pathlength from focus to focus (m)" )

   # horizontal offset from first focal plane to reimaged focal plane
   #   positive value means first focus is closer to primary axis
   #   offset in-plane
   dex = bcfd * cos( abr ) + ffb * cos( ay )
   call wout ( dex, "  horizontal offset from focus to focus, in-plane (m)" )

   # vertical offset from first focal plane to reimaged focal plane
   #   positive value means first focus is above reimaged focal plane
   #   offset in-plane
   dey = - bcfd * sin( abr ) - ffb * sin( ay )
   call wout ( dey, "  vertical offset from focus to focus, in-plane (m)" )

   # out-of-plane offset from first focal plane to reimaged focal plane
   # dez = bcfd * sin( al ) - ffb * sin( aq )
   dez = 0.0d0
   # call wout ( dez, "  Z offset from focus to focus (m)" )
      
   # solve for the ellipse parameters
   aae = 0.5d0 * fff
   call wout ( aae, "  A = semi-major axis (m)" )

   cce = 0.5d0 * sqrt ( dex**2 + dey**2 + dez**2 )
   call wout ( cce, "  C = half distance between foci (m)" )
   
   bbe = sqrt ( aae**2 - cce**2 )
   call wout ( bbe, "  B = semi-minor axis (m)" )

   sse = aae - cce
   call wout ( sse, "  S (m)" )
   spe = 2.0d0 * aae - sse
   call wout ( spe, "  S' (m)" )
   
   # Asphere on beam combiner, oblate ellipsoid
   #   See Schroeder page 35-38, K = -c**2/a**2
   alpha5 = - cce**2 / aae**2
   call wout ( alpha5, "asphere for beam combiner" )
   ecc5 = sqrt ( - alpha5 )
   call wout ( ecc5, "eccentricity for beam combiner" )

   # focal length of parent ellipse
   l5 = bbe**2 / aae / 2.0d0
   call wout ( l5, "focal length of the beam combiner parent ellipse (m)" )

   # tilt angle for the off-axis ellipse
   #   ray from reimaged focus to first focus
   #   the line containing the virtual locations of the foci
   #   let ray trace calculate which part of ellipse is used
   aell = atan2( dey, -dex )
   #   above, only correct for in-plane combination
   call wout ( aell, "angle of beam combiner parent ellipse axis (rad)" )
      
   # Angles between rays and ellipse axis
   aea = abr + PI2 + PI2 - aell   # reverse downward ray (temp)
   call wout ( aea, "  angle AEA (rad)" )
   aeb = ay - aell
   call wout ( aeb, "  angle AEB (rad)" )

   # Calculate y-offset to the ellipse axis from the chief ray
   #   do it two ways as a check
   #   if chief ray is going up vertical,
   #   positive Y moves away from primary axis (for this case)
   eoy = bcfd * sin( aea )
   eoy = ffb * sin( aeb )
   call wout ( eoy, "  ellipse offset EOY (m)" )

   # Calculate z-offset to the ellipse axis from the chief ray
   eoz = spe - bcfd * cos( aea )
   eoz = sse - ffb * cos( aeb )
   call wout ( eoz, "  ellipse offset EOZ (m)" )

   # Assume that x-offset (out of plane) is zero for now.
   eox = 0.0d0
   # call wout ( eox, "  EOX (m)" )
      

   call printf ( "  end of reimaging beam combiner pass 2\n")
   call printf ( "  analysis refers to the first focal plane\n")
end

# Afocal beam combiner dimensions for two-shooter (experimental)

procedure m5_asize

include	"cass_common.h"

# Scratch variables
double   zfd, dzmin, zh


.help
The sign convention for mirror tilts is supposed to be that zero angle
  is upward looking parallel to the optical axis.

The sign convention for rays is that zero is horizontal (inward)
  and +pi/2 is upward.

See also procedure five_afocal.

Specified parameters (beware of overconstraint)
	fs      first focal ratio
	vt      tertiary height above vertex
	pspace  primary spacing
	fscomb  reimaged focal ratio
	yocomb  lateral offset of combiner
Available parameters (for solution or specified at cl)
	afbeam  afocal beam diameter
	vdcomb  reimaged vertex distance
	vh      beam combiner height  (must be greater than vdcomb)
	vf      fold flat height
Derived parameters (always calculated)
	at      tertiary tilt  (limited by primary/secondary edge)
	af      fold flat tilt
	aell    beam combiner axis angle
	l5      beam combiner focal length

Almost standard definitions:
  Axis Plane --- plane containing optical axes of the two primaries.
  Vertex Plane --- plane perpendicular to optical axes at primary vertices.
  Center Plane --- mid-plane between two telescopes
  In-Plane --- plane containing the relevant rays (parallel to axis)
.endhelp

begin
   call printf ( "  calculations of afocal beam combiner, pass 2\n")

   if ( vdcomb == INDEFD && afbeam != INDEFD && vh != INDEFD && fscomb != INDEFD ) {
      # Is there a small angle approximation error here?
      vdcomb = abs( afbeam * fscomb ) - vh
      call wout ( vdcomb, "reimaged vertex distance (m)" )
   }
   
   if ( vh == INDEFD ) {
      # Estimate height of beam combiner based on unvignetted field
      # OR
      # if vdcomb, vf, xf are specified
      # calculate the required height
   }

   else {
      # Assume both vh and vdcomb are fixed.
      # Use specified beam combiner height.

      # This may be inconsistent with the specified combined focal ratio
      # and afocal beam diameter.
      
      # Impact point of chief rays w/ respect to combined axis, axis-plane
      #   positive bcx is on original side of center plane
      bcx = ( vdcomb + vh + vy ) * sin( aa )
      call wout ( bcx, "impact parameter on beam combiner, axis-plane (m)" )

      # Impact point of chief rays w/ respect to combined axis, lateral
      #  positive bcy is closer to axis plane; doesn't reverse with yocomb
      bcy = ( vdcomb + vh + vy ) * sin( al )
      call wout ( bcy, "impact parameter on beam combiner, lateral (m)" )

      # angle of ray from tertiary to beam combiner w/o any fold flat
      # this is the angle in the plane containing the optical axes.
      # ag = atan2( ( vh - vt ) , ( pspace / 2.0d0 - bcx ) )
      # call wout ( ag, "axis-plane projected angle from tertiary to bc (rad)" )

      # rotation azimuth of ray from teritary to beam combiner
      # this is also the rotation azimuth of the tertiary mirror
      az = atan( ( yocomb - bcy ) / ( pspace / 2.0d0 - bcx ) )
      call wout ( az, "*azimuth angle from tertiary to beam combiner (rad)" )

      # rotation azimuth of ray from teritary to focus
      # this is also the rotation azimuth of the tertiary mirror
      az = atan( ( yocomb ) / ( pspace / 2.0d0 ) )
      call wout ( az, "*azimuth angle from tertiary to focus (rad)" )
      # recalculated below as az, aq, ar
      
      # pathlength from beam combiner to focus
      # bcfd = ( vh + vdcomb + vy ) / cos( aa ) / cos( al )
      bcfd = ( vh + vdcomb + vy ) / cos( aap )
      call wout ( bcfd, "pathlength from beam combiner to focus (m)" )

      # Calculate xf, yf for vertical input to beam combiner
      xf = bcx
      yf = bcy
      call wout ( xf, "horizontal offset of fold flat from center plane (m)" )
      call wout ( yf, "lateral offset of fold flat from combined focus (m)" )

      # azimuth rotation of tertiary mirror
      # or ray angle in plane of primaries from tertiary to fold flat
      az = atan2( yf , ( pspace / 2.0d0 - xf ) )
      call wout ( az, "azimuth rotation angle of tertiary (rad)" )

      # rotation azimuth of ray from beam combiner to focus
      ar = atan2( bcy, bcx )
      call wout ( ar, "azimuth angle from beam combiner to focus (rad)" )
   } # end else


   if ( vf == INDEFD ) {
      # Try to calculate the lowest beam from tertiary that won't hit primary.
      # This iteration leaves 0.25 m clearance at mirror edge!
      # Estimate of vf depends only on the telescope parameters M1--M3
      
      # diameter of the light cone at edge of primary (initial guess)
      dzmin = afbeam

      
      # size of the light cone (from size of tertiary calculation)
      dzmin = abs( zfd ) * 2.0d0 * tan( as ) + fpdia - zfd * 2.0d0 * tan( ax )
      call wout ( dzmin, "  diameter of light at primary edge (m)" )

      # height of chief ray above mirror edge (useless)
      zh = 0.25 + dzmin / 2.0d0
      call wout ( zh, "  height of chief ray above primary edge (m)" )
   
      # net ray angle from tertiary to fold flat (in that plane)
      aw = atan2( ( sag1 + dzmin / 2.0d0 - vt ) , ( d1 / 2.0d0 ) )
      call wout ( aw, "ray angle from tertiary to fold flat (rad)" )

      # estimate fold flat position ( very crude )
      # doesn't account for xf or yf
      vf = vt + sin( aw ) * ( pspace / 2.0d0 )
      call wout ( vf, "height of fold flat - m4 - above vertex plane (m)" )

      # This is a practical minimum value of vf.
   }
   else {
      # Use the specified vf

      # net ray angle from tertiary to fold flat (in that plane)
      # aw = atan2( ( vf - vt ) , ( pspace / 2.0d0 - xf ) )
      aw = atan2( ( vf - vt ) , sqrt( ( pspace / 2.0d0 - xf )**2 + yf**2 ) )
      call wout ( aw, "ray angle from tertiary to fold flat (rad)" )
      # xf must have had the correct sign for this to work == Gregorian
      
      # height of chief ray above mirror edge (useless)
      zh = ( d1 / 2.0d0 ) * tan( aw ) + vt - sag1
      call wout ( zh, "  height of chief ray above primary edge (m)" )
   
      call wout ( vf, "height of fold flat - m4 - above vertex plane (m)" )
      
   }

.help
   Mirror tilt angle with respect to telescope optical axis is computed
      as minus one-half the sum of the old and new ray angles.
   For the tertiary mirror, the old ray angle is -pi/2 and the first
      quadrant of new angles is up and to the left.
   That may be a backwards defintion, but it is what this code has evolved to.
.endhelp

   # tilt of tertiary mirror
   at = 0.5d0 * ( PI2 - aw )
   call wout ( at, "tertiary tilt angle from optical axis (rad)" )

   # distance from tertiary to m4
   ffa = sqrt( ( vt - vf )**2 + ( pspace / 2.0d0 - xf )**2 + ( yocomb - yf )**2 )
   call wout ( ffa, "pathlength from tertiary to fold flat (m)" )


   # angle from fold flat to beam combiner (in-plane)
   ay = atan2( ( vh - vf ) , sqrt( ( xf - bcx )**2 + ( yf - bcy )**2 ) )
   call wout ( ay, "ray angle from fold flat to beam combiner (rad)" )
      
   # angle of 4th mirror, fold flat
   af = 0.5d0 * ( - aw - ay )
   call wout ( af, "fold flat tilt angle from optical axis (rad)" )

   # distance from fold flat to beam combiner (vh - vf)
   ffb = sqrt( ( vh - vf )**2 + ( xf - bcx )**2 + ( yf - bcy )**2 )
   call wout ( ffb, "pathlength from fold flat to beam combiner (m)" )
   
   dbeam4 = abs( afbeam )  # afocal
   call wout ( dbeam4, "diameter of beam at fold flat (m)" )

   f4if = ( bfd - tfd + ffa ) * ubar1 / magn # distance times magnified angle
   call wout ( f4if, "  field correction to m4 diameter (m)" )

   # size of the fold flat (minor axis diameter)
   d4 = f4if + dbeam4 # afocal
   call wout ( d4, "minor axis diameter of fold flat (m)" )

   #Parabolic beam combiner.

   # focal length of beam combiner relay, given beam combiner height.
   #   paraxial focal length at the off-axis segment
   if ( vh != INDEFD && vdcomb != INDEFD ) {
      l5 = vh + vdcomb
   }
   else {
      l5 = afbeam * fscomb
   }
   call wout ( l5, "focal length of the beam combiner (m)" )

   dbeam5 = abs( afbeam )  # afocal
   call wout ( dbeam5, "diameter of beam at beam combiner (m)" )

   f5if = ( bfd - tfd + ffa + ffb ) * ubar1 / magn # distance times mag. angle
   call wout ( f5if, "  field correction to m5 diameter (m)" )

   # size of the combiner facet
   d5 = f5if + dbeam5 # afocal
   call wout ( d5, "diameter of beam combiner facet (m)" )
   # overwritten by next operation

   # calculate unvignetted field at beam combiner (and fold flat)
   
   # diameter of beam combiner mirror
   d5 = f5if + afbeam * ( pspace + d1 ) / d1
   call wout ( d5, "diameter of the beam combiner (m)" )

   # ray angle from beam combiner to focus (in-plane)
   # axis-plane angle is aa - PI2
   abr = aap - PI2
   call wout ( abr, "ray angle from beam combiner to focus, in-plane (rad)")
   
      
   # Asphere on beam combiner, paraboloid
   alpha5 = -1.0d0
   call wout ( alpha5, "asphere defined for beam combiner" )
   ecc5 = sqrt ( - alpha5 )
   call wout ( ecc5, "eccentricity for beam combiner" )

   call printf ( "  end of afocal beam combiner pass 2\n")
end

# calculate dimensions of coude fold mirrors

procedure m6_size

include "cass_common.h"

begin
   if( rnum >= 5.0d0 ) {

      # size of the point beam at the beam combiner
      dbeam5 = m5fd / abs( fs )
      call wout ( dbeam5,"diameter of beam at folding flat 5 (m)" )

      # size of the flat for one telescope
      d5 = m5fd * 2.0d0 * tan( abs( as ) ) +
	   fpdia - m5fd * 2.0d0 * tan ( ax )
      call wout ( d5,"minor axis diameter of folding flat 5 (m)" )

      # size of the flat for both beams
      dlong5 = d5 + m5fd * sin( aa ) * 2.0d0
      call wout ( dlong5,"combined length of folding flat 5 (m)" )

      # note: the actual shape of this mirror is 
      #         dlong5  wide  by  d5 / cos( tilt ) high

   } # end if 5

   if( rnum >= 6.0d0 ) {

      # size of the point beam at the beam combiner
      dbeam6 = m6fd / abs( fs )
      call wout ( dbeam6,"diameter of beam at folding flat 6 (m)" )

      # size of the flat for one telescope
      d6 = m6fd * 2.0d0 * tan( abs( as ) ) + fpdia - m6fd * 2.0d0 * tan( ax )
      call wout ( d6,"minor axis diameter of folding flat 6 (m)" )

      # size of the flat for both beams
      dlong6 = d6 + m6fd * sin( aa ) * 2.0d0
      call wout ( dlong6,"combined length of folding flat 6 (m)" )

      # note: the actual shape of this mirror is 
      #         dlong6  wide  by  d6 / cos( tilt ) high

   } # end if 6

end

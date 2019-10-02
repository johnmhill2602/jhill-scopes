# cass_sub3.x version 03APR91
#    added secondary conjugate position  19JUN92
#    added minimum height of beam combiner  31JUL92
#    split m3_size into m4_size,m6_size  03AUG92
#    added m5_size 05AUG92
#    working on beam combiner reimaging for m5  17AUG92
#    added beam combiner asphere 21SEP92
#    moved m5_size to cass_sub5.x 22SEP92
#    correction to field wrt/bc  24DEC92
#    some abs() calls for negative pspace  15JAN93
#    infrared additions to tertiary size  22APR93
#    envelope on infrared primary  25OCT94, 04NOV94, 08NOV94, 14NOV94
#    convert to more rigorous definition of f/number 1/2NA  22NOV94
#    use refractive index of air for numerical aperture  23NOV94
#    divide by zero checks for hole in tertiary beam  04NOV96
#    calculate offset correction for tertiary mirror  19APR99

# calculate dimensions of primary mirror

procedure m1_size

include "cass_common.h"

begin
   call printf ( "primary mirror parameters\n" )

#  sagitta of primary mirror
#       sag1 = d1**2 / 16.0d0 / l1 / sqrt (1.0d0 - (alpha1+1)*(d1/2.0d0/l1)**2)
#	(this was the old way, seems to work only for parabola)
#	sag1 = d1 / f1 / 8.0d0 /
#		 ( 1.0d0 + sqrt (1.0d0 - (alpha1+1.0d0)/16.0d0/f1**2 ) )
	sag1 = d1**2 / l1 / 8.0d0 /
	    ( 1.0d0 + sqrt (1.0d0 - (alpha1+1.0d0)*d1**2/16.0d0/l1**2 ) )
        call wout ( sag1, "sagitta of primary mirror (m)" )

#  aspheric amplitude on primary mirror
#	sphere1 = d1 / f1 / 8.0d0 /
#		 ( 1.0d0 + sqrt (1.0d0 - 1.0d0/16.0d0/f1**2 ) )
	sphere1 = d1**2 / l1 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - d1**2/16.0d0/l1**2 ) )
	asphere1 = ( sag1 - sphere1 ) * 1.0d6
	call wout ( asphere1, "primary aspheric amplitude (microns)" )

   #  half angle of primary light cone (geometrical definition)
   a1 = atan ( 0.5d0 * d1 / ( l1 - sag1 ) )
   call wout ( a1, "half angle of primary light cone (rad)" )

   # primary numerical aperture, corrected for refractive index of air
   na1 = sin ( a1 ) * index
   call wout ( na1, "primary numerical aperture" )

   # primary focal ratio (rigorous definition)
   fjunk = 0.5d0 / na1
   call wout ( fjunk, "??primary focal ratio apparently" )
   
end

# calculate dimensions of secondary mirror

procedure m2_size

include "cass_common.h"

int   jj

begin

   call printf ( "secondary mirror parameters\n" )

   if( l1 != ls ) {           # does secondary have power?

      # calculate sagitta from vertex diameter and asphere
      f2 = l2 / d2v
      sag2 = d2v / f2 / 8.0d0 /
	     ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )

      # calculate new edge diameter of the secondary adjusting beam spread
      #     field correction to diameter assumes field is small enough that
      #     focal plane curvature and distortion are negligible.
      # iteration loop
      for ( jj=1; jj<=8; jj=jj+1 ) {
	 if ( fs != 0.0d0 )
	    d2e = (bfd - sag2) * 2.0d0 * abs( tan( as ) )  +  2.0d0 * ubar1 * ( sep - sag2 )
	 else
	    d2e = abs( afbeam ) + 2.0d0 * ubar1 * ( sep - sag2 ) # afocal

	 # iterate sagitta from edge diameter and asphere
	 f2 = l2 / d2e
	 sag2 = d2e / f2 / 8.0d0 /
		( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )
      } # end for
      
      call wout ( d2e, "edge diameter of secondary mirror (m)" )
      call wout ( f2, "secondary focal ratio" )
      call wout ( sag2, "sagitta of secondary mirror (m)" )


      if ( irm2 ) {	# parameters for infrared secondary mirror

	 cdif = -2.0d0 * cent	# centration correction

	 # iteration loop for vertex diameter
	 for ( jj=1; jj<=8; jj=jj+1 ) {
	    # calculate secondary focal ratio (using vertex diameter)
	    f2 = l2 / d2v

	    # iterate sagitta from edge diameter and asphere
	    sag2 = d2v / f2 / 8.0d0 /
		   ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )

	    # iterate the corrections
	    adif = asin (lmax * 1.0d-6 * xdif / d2v)
	    ddif = -2.0d0*adif * sqrt((sep-sag1)**2+((d1-d2v)/2.0d0)**2)
	    fdif = -2.0d0 * ubar1 * sep

	    # calculate new vertex diameter of the secondary for infrared
	    if ( fs != 0.0d0 )
	       d2v = bfd * 2.0d0 * abs( tan( as ) )  + ddif + cdif + fdif
	    else
	       d2v = abs( afbeam )  + ddif + cdif + fdif  # afocal
	 } # end iteration

#	 call wout ( adif, "*infrared diffraction angle (radians)" )
#	 call wout ( ddif, "*  diffraction correction to m2 diameter (m)" )
#	 call wout ( fdif, "*  field correction to m2 diameter (m)" )
#	 call wout ( cdif, "*  centration correction to m2 diameter (m)" )

	 call wout ( d2v, "*infrared vertex diameter of secondary mirror (m)" )
#	 call wout ( f2, "*infrared secondary focal ratio" )
#	 call wout ( sag2, "*sagitta of secondary mirror (m)" )

	 # entrance pupil diameter
	 #     scaling the infrared vertex diameter
	 dpupil =  d2v * abs( mpupil )
	 call wout ( dpupil, "*entrance pupil diameter, paraxial (m)" )


	 # This section assumes that all chief rays point at the center
	 #     of the circle defined by the edge of the secondary.
#	 fdif = -2.0d0 * ubar1 * ( sep - sag2 )
#	 call printf ( "                       (using chief rays through center of edge)\n" )
	 # That is different than assuming that all chief rays point at
	 #     the secondary vertex.
	 fdif = -2.0d0 * ubar1 * sep
	 call printf ( "                       (using chief rays through secondary vertex)\n" )

	 call wout ( fdif, "  field correction to m2 diameter (m)" )
	 call wout ( cdif, "  centration correction to m2 diameter (m)" )
	 
	 # iteration loop for edge diameter
	 for ( jj=1; jj<=8; jj=jj+1 ) {
	    # calculate secondary focal ratio (using edge diameter)
	    f2 = l2 / d2e

	    # iterate sagitta from edge diameter and asphere
	    sag2 = d2e / f2 / 8.0d0 /
		   ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )

	    # iterate the corrections
	    adif = asin (lmax * 1.0d-6 * xdif / d2e)
	    ddif = -2.0d0*adif * sqrt((sep-sag1-sag2)**2+((d1-d2e)/2.0d0)**2)

	    # calculate new edge diameter of the secondary for infrared
	    #    pupil stop is at height of secondary edge, not vertex.
	    if ( fs != 0.0d0 )
	       d2e = (bfd - sag2) * 2.0d0 * abs( tan( as ) )  + ddif + cdif + fdif
	    else
	       d2e = abs( afbeam )  + ddif + cdif + fdif  # afocal
	 } # end iteration

	 call wout ( adif, "infrared diffraction angle (radians)" )
	 call wout ( ddif, "  diffraction correction to m2 diameter (m)" )

	 # results of the iteration above
	 call wout ( d2e, "infrared edge diameter of secondary mirror (m)" )
	 call wout ( f2, "infrared secondary focal ratio" )
	 call wout ( sag2, "sagitta of secondary mirror (m)" )

	 # calculate the effective aperture of the telescope
	 # 	based on ratio of nominal beam diameter
	 #        to infrared secondary diameter
	 # Should this be corrected for field angle?  OK at zero field.
	 if ( fs != 0.0d0 )
	    d1i = d1 / ( (bfd - sag2) * 2.0d0 * abs( tan( as ) ) ) * d2e
	 else
	    d1i = d1 / abs( afbeam ) * d2e  # afocal
	 call wout ( d1i, "effective primary aperture (m)" )

	 # calculate effective numerical aperture
	 if ( fs != 0.0d0 )
	    # 1.00029 is the refractive index of air: 0 deg C, 760 mm Hg @ D
	    nai = 1.00029d0 * sin( atan( d2e / (bfd - sag2) / 2.0d0 ) )
	 else
	    nai = 0.0d0
	 
	 # calculate the effective cassegrain focal ratio
	 # old calculation,  fsi = ls / d1i
	 fsi = 0.5d0 / nai
	 call wout ( fsi, "effective system focal ratio" )

	 # entrance pupil diameter
	 #     why is this number too large?
	 #     wrong magnification?
	 #     should we scale the infrared vertex diameter??? (above)
	 dpupil =  d2e * abs( mpupil )
#	 call wout ( dpupil, "?entrance pupil diameter, from edge (m)" )

	 # calculate the diameter of the primary that is actually
	 #      used by light from anywhere in the field.
	 # this is the combined beam envelope from the whole field.
	 # compute beam diameter plus field spread since entrance pupil.
	 # should we compute a new value for sag1?
	 d1f = d1i + abs( (spupil - sag1) * ubar1 * 2.0d0 )
	 call wout ( d1f, "effective primary envelope (m)" )

	 # Pupil positions and magnifications were calculated
	 #     paraxially earlier in the program.
	 # On 25 October / 03 November 1994, I tried
	 #     recomputing them here using (sep-sag2) instead of just (sep).
	 # That produced funny results so I've gone back to the paraxial case.

	 # entrance pupil position relative to primary vertex
	 #     separation now corrected for sagitta of secondary
	 spupil = 1.0d0 / ( 1.0d0 / l1 - 1.0d0 / ( sep - sag2 ) )
	 call wout ( spupil, "??entrance pupil position relative to primary (m)" )
	 # pupil magnification,
	 #    assume Gregorian pupil magnification is negative
	 mpupil = - spupil / ( sep - sag2 )
	 call wout ( mpupil, "??entrance pupil magnification" )

	 # entrance pupil diameter
	 dpupil =  d2e * abs( mpupil )
	 call wout ( dpupil, "??entrance pupil diameter, from edge (m)" )
	 # as of 08NOV94, the rayfile still uses "d1i" for entrance pupil
	 
.help
	 # compute beam diameter plus field spread since entrance pupil.
	 d1f = d1i + abs( (spupil - sag1) * ubar1 * 2.0d0 )
	 call wout ( d1f, "??effective primary envelope (m)" )
.endhelp

      }	# end of infrared secondary diameter

      # aspheric amplitude on secondary mirror
      sphere2 = d2e / f2 / 8.0d0 /
		( 1.0d0 + sqrt (1.0d0 - 1.0d0/16.0d0/f2**2 ) )
      asphere2 = ( sag2 - sphere2 ) * 1.0d6
      call wout ( asphere2, "secondary aspheric amplitude (microns)" )
      # divide aspheric amplitude by 4 to get p-v departure from
      #	    best fit sphere.

   } # end if secondary has power
   else {
      sag2 = 0.0d0          # flat secondary
      # this calculation fails when we have a flat secondary with asphere
      d2e = d2v
      f2 = 0.0d0		# flat secondary
   } # end else flat secondary

   # Is there an unused hole at the center of the secondary?
   # Calculate focal ratio of hole in beam, equivalent to fs
   if ( fs != 0.0d0 )
      f2h = bfd * 2.0d0 * abs ( tan( as ) ) / d1 * max ( pbaffle, d2e )
   else
      f2h = abs ( afbeam ) / d1 * max ( pbaffle, d2e )  # afocal
   if ( !irm2 ) { # Unused hole in secondary for optical
      # Calculate hole in secondary for beam expansion and field spread
      #	Note that field spread is subtracted rather than added.
	 d2h = f2h - 2.0d0 * ubar1 * sep
      # field spread must be less than beam expansion for a hole
      if ( d2h < 0.0d0 )
	 d2h = 0.0d0
      call wout ( d2h, "diameter of unused hole in secondary (m)" )
   } # end if
   else { # Unused hole in secondary for infrared
      ddif = -2.0d0* adif * sep
      fdif = -2.0d0 * ubar1 * sep
      d2h = f2h - fdif - cdif - ddif
      # field spread must be less than beam expansion for a hole
      if ( d2h < 0.0d0 )
	 d2h = 0.0d0
      call wout ( d2h, "infrared unused hole in secondary (m)" )
   } # end else

   # Location of conjugate image of secondary vertex in primary
   if (sep != l1)
      con2 = 1.0d0 / (1.0d0 / l1 - 1.0d0 / sep)  # lens equation
   else
      con2 = 0.0d0  # infinite conjugate
   if (!irm2)  # Only print if entrance pupil is primary.
      call wout ( con2, "conjugate to secondary vertex (m)" )
   
end

# calculate dimensions of tertiary mirror

procedure m3_size

include "cass_common.h"

int   jj

begin

   call printf ( "tertiary mirror parameters\n" )
   
   # size of the point beam at the tertiary
   if( fs != 0.0d0 ) {
      dbeam3 = tfd * 2.0d0 * abs( tan( as ) )
      call wout ( dbeam3, "diameter of beam at tertiary (m)" )

      ftif = fpdia - tfd * 2.0d0 * tan ( ax )
      call wout ( ftif, "  field correction to tertiary diameter (m)" )

      # size of the tertiary (minor axis diameter)
      d3min = tfd * 2.0d0 * tan( abs( as ) ) + ftif
      call wout ( d3min, "minor axis diameter of tertiary (m)" )

      d3minup = d3min
      d3mindn = d3min
      
      # iteration loop for tertiary diameter corrections
      # due to the divergence of the beam
      for ( jj=1; jj<=8; jj=jj+1 ) {
	 d3minup = ( tfd + d3minup * sin( at ) / 2.0d0 ) *
		   2.0d0 * tan( abs( as ) ) +
		   fpdia - (tfd + d3minup * sin( at ) / 2.0d0 ) *
		   2.0d0 * tan ( ax )
	 d3mindn = ( tfd - d3mindn * sin( at ) / 2.0d0 ) *
		   2.0d0 * tan( abs( as ) ) +
		   fpdia - (tfd - d3mindn * sin( at ) / 2.0d0 ) *
		   2.0d0 * tan ( ax )
      } # end for 
      call wout ( d3minup, "  upper tertiary minor axis diameter (m)" )
      call wout ( d3mindn, "  lower tertiary minor axis diameter (m)" )

      # offset of the tertiary ellipse based on the corrections
      # this is the offset in the plane of the tertiary mirror.
      # offset by half the difference of the major axis radii
      # approx = tfd / 4 / fs**2 + fpdia / 4 / fs ( 1 - (2 * tfd / bfd ) )
      d3off = ( d3minup - d3mindn ) / cos ( at ) / 4.0d0
      call wout ( d3off, "offset of the tertiary ellipse (m)" )

      d3min = ( d3minup + d3mindn ) / 2.0d0
      call wout ( d3min, "corrected minor axis diameter of tertiary (m)" )
      
      # major axis diameter of tertiary (m)
      d3maj = d3min / cos( at )
      call wout ( d3maj, "major axis diameter of tertiary (m)" )

      if (irm2){
	 # IR corrections to tertiary size (increase rather than decrease)
	 # diffraction angle times secondary to tertiary angle ??
	 dtif = adif * (bfd - tfd)
	 call wout ( dtif, "  diffraction correction to m3 diameter (m)" )
	 # specified centration allowance (same as secondary with opposite sign)
	 ctif = - cdif
	 call wout ( ctif, "  centration correction to m3 diameter (m)" )

	 d3min = d3min + dtif + ctif
	 call wout ( d3min, "infrared minor axis diameter of tertiary (m)" )

	 # major axis diameter of tertiary (m)
	 d3maj = d3min / cos( at )
	 call wout ( d3maj, "infrared major axis diameter of tertiary (m)" )
      } # end if irm2

   } # end if
   else {  # afocal

      dbeam3 = abs( afbeam )  # afocal
      call wout ( dbeam3, "diameter of beam at tertiary (m)" )

      ftif = ( bfd - tfd ) * ubar1 / magn # distance times magnified angle
      call wout ( ftif, "  field correction to m3 diameter (m)" )

      # size of the tertiary (minor axis diameter)
      d3min = dbeam3 + ftif  # afocal
      call wout ( d3min, "minor axis diameter of tertiary (m)" )
   
      # major axis diameter of tertiary (m)
      d3maj = d3min / cos( at )
      call wout ( d3maj, "major axis diameter of tertiary (m)" )

   } # end else afocal

   # obscuration by the tertiary in the converging beam
   if( vt > 0.0d0 ) {

      if ( max ( d2e, pbaffle ) .eq. 0.0d0 ) {
	 fh = 0.0d0
      }
      else {
	 # focal ratio of the hole in the converging beam from a central
	 # obstruction other than the tertiary.  does not account for
	 # an off-axis shadow from the secondary mirror.
	 fh = l1 / max ( d2e, pbaffle )
      }

      # highest point on the tertiary.  this does not account for
      # decentering the tertiary to minimize the obscuration.
      vtext = vt + d3min * abs( tan( at ) ) / 2.0d0

      if ( fh .eq. 0.0d0 ) {
	 dbeam3h = 0.0d0
	 ash = 0.0d0
      }
      else {
	 # diameter of the hole in the point converging beam at tertiary.
	 dbeam3h = ( l1 - vtext ) / fh

      # half angle of the hole in the converging beam (equivalent as)
	 ash = atan ( 0.5d0 / fh )
      }

      # angle of off-axis (field) chief ray from prime focus.
      # primary focal length is the distance from focus to exit pupil
      # diameter of focal plane at prime is fpdia / magn
      axp = asin ( fpdia / magn / 2.0d0 / l1 )

      # diameter of the clear hole in the converging beam at the
      # maximum height of tertiary including the field
      dclear3 = ( l1 - vtext ) * 2.0d0 * tan( ash ) - fpdia / magn +
		( l1 - vtext ) * 2.0d0 * tan( axp )
      call wout ( dclear3, "hole in converging light above tertiary (m)" )

      # is the tertiary smaller than the clear hole?
      if( d3min  >  dclear3 ) {

	 # this assumes a circular tertiary, lower estimate.
	 obs3 = ( d3min / d1  *  l1 / ( l1 - vt )  ) ** 2
	 call wout ( obs3, "minimum obscuration by tertiary (fractional area)" )
	 # this assumes top edge of elliptical tertiary, upper estimate.
	 obs3 = (  d3min / d1  *  l1 / ( l1 - vtext )  ) ** 2
	 call wout ( obs3, "maximum obscuration by tertiary (fractional area)" )
      }
      else
	 obs3 = 0.0d0
   }
   else
      obs3 = 0.0d0

end

# calculate dimensions of beam combiner mirrors

procedure m4_size

include "cass_common.h"

begin
   # size of the point beam at the beam combiner
   dbeam4 = bcfd * 2.0d0 * abs( tan( as ) )
   call wout ( dbeam4, "diameter of beam at beam combiner (m)" )

   # size of the beam combiner facet, minor axis diameter
   d4 = bcfd * 2.0d0 * tan( abs( as ) ) + fpdia - bcfd * 2.0d0 * tan( ax )
   call wout ( d4, "minor axis diameter of beam combiner facet (m)" )
   # these numbers do not take beam combiner wedge for lateral offset
   # into account.  assume wedge angle << apex angle.

   # maximum unvignetted field (corrected 31JUL92/24DEC92)
   # criterion for vignetting is that the interior ray from the opposite
   #  telescope at the edge of the field must cross the center plane
   #  before reaching the beam combiner apex (bch).
   # this calculation is done by similar triangles meeting at the apex.
   # this is an approximation that neglects focal plane tilt wrt/bch.
   # this calculation may not account for lateral offset.
   uvrad = pfd * cos( aa ) * abs( tan( ai ) ) * bch / ( pfd * cos( aa ) - bch )
   call wout ( uvrad, "unvignetted field radius wrt/bc (m)" )

   uvfld = uvrad * 2.0d3 / 6.0d1 / plate
   call wout ( uvfld, "unvignetted field diameter wrt/bc (arcmin)" )

   # angle of center ray to pupil at edge of field
   # this had better be consistent with above calculation!
   # this is an approximation that neglects focal plane tilt wrt/bch.
   # this calculation assumes the apex is at bch.
   ap = asin ( fpdia / 2.0d0 / pfd / cos( aa ) )
   call wout ( ap, "angle of center ray at edge of field (rad)")

   # Vertical separation of tilted focal planes at edge of field.
   # Each focal plane is half this distance above the midplane.
   fpcsep = fpdia * abs( aa )
   call wout ( fpcsep, "distance between tilted focal planes at full field (m)" )

   # Image separation because center ray is tilted at edge of field.
   fpccim = fpcsep * ap / plate * 1.0d3
   call wout ( fpccim, "image split from center ray tilt at full field (arcsec)" )

   # minimum height of beam combiner apex above focal plane for requested field
   # (a small angle approximation ??)
   # abs used for negative pspace -- untested
   vhmin = fpdia / 2.0d0 / tan( ap + abs( ai ) )
   call wout ( vhmin, "minimum possible height of bc apex wrt/focus (m)")
   # minimum height of beam combiner above vertex for requested field
   vhmin = vhmin + vh - bch
   call wout ( vhmin, "minimum possible height of beam combiner (m)")

   # This section could potentially solve for beam combiner height
   # or field, but the recursion through other code is messy.
   
end

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
#    envelope on infrared primary  25OCT94

# calculate dimensions of primary mirror

procedure m1_size

include "cass_common.h"

begin
#  sagitta of primary mirror
#       sag1 = d1**2 / 16.0d0 / l1 / sqrt (1.0d0 - (alpha1+1)*(d1/2.0d0/l1)**2)
#	(this was the old way, seems to work only for parabola)
	sag1 = d1 / f1 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - (alpha1+1.0d0)/16.0d0/f1**2 ) )
        call wout ( sag1, "sagitta of primary mirror (m)" )

#  aspheric amplitude on primary mirror
	sphere1 = d1 / f1 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - 1.0d0/16.0d0/f1**2 ) )
	asphere1 = ( sag1 - sphere1 ) * 1.0d6
	call wout ( asphere1, "primary aspheric amplitude (microns)" )

end

# calculate dimensions of secondary mirror

procedure m2_size

include "cass_common.h"

begin

	if( l1 != ls ) {           # does secondary have power?

          # calculate sagitta from vertex diameter and asphere
	    f2 = l2 / d2v
	    sag2 = d2v / f2 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )

	   # calculate new edge diameter of the secondary adjusting beam spread
	   if ( fs != 0.0d0 )
	      d2e = (bfd - sag2) / abs( fs )  +  2.0d0 * ubar1 * ( sep - sag2 )
	   else
	      d2e = abs( afbeam ) + 2.0d0 * ubar1 * ( sep - sag2 ) # afocal

          # iterate sagitta from edge diameter and asphere
	    f2 = l2 / d2e
	    sag2 = d2e / f2 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )

          # iterate edge diameter of the secondary adjusting beam spread
	   if ( fs != 0.0d0 )
	      d2e = (bfd - sag2) / abs( fs )  +  2.0d0 * ubar1 * ( sep - sag2 )
	   else
	      d2e = abs( afbeam ) + 2.0d0 * ubar1 * ( sep - sag2 )  # afocal
	   call wout ( d2e, "edge diameter of secondary mirror (m)" )

	  # calculate secondary focal ratio (using edge diameter)
	    f2 = l2 / d2e
	    call wout ( f2, "secondary focal ratio" )

          # calculate sagitta from edge diameter and asphere
	    sag2 = d2e / f2 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )
            call wout ( sag2, "sagitta of secondary mirror (m)" )


	    if ( irm2 ) {	# parameters for infrared secondary mirror

	      cdif = -2.0d0 * cent	# centration correction

            # estimate secondary sagitta from vertex diameter and asphere
	      f2 = l2 / d2v
	      sag2 = d2v / f2 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )

	    # estimate corrections for the infrared diameter
	      adif = asin (lmax * 1.0d-6 * xdif / d2v)
	      ddif = -2.0d0*adif * sqrt((sep-sag1-sag2)**2+((d1-d2v)/2.0d0)**2)
	      fdif = -2.0d0 * ubar1 * ( sep - sag2 )

	    # calculate new edge diameter of the secondary for infrared
	    #	beam spread - field correction - centration - diffraction
	       if ( fs != 0.0d0 )
		  d2e = (bfd - sag2) / abs( fs )  + ddif + cdif + fdif
	       else
		  d2e = abs( afbeam )  + ddif + cdif + fdif  # afocal
	       
	    # iterate sagitta from edge diameter and asphere
	      f2 = l2 / d2e
	      sag2 = d2e / f2 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )

	    # iterate the corrections
	      adif = asin (lmax * 1.0d-6 * xdif / d2e)
	      call wout ( adif, "infrared diffraction angle (radians)" )

	      ddif = -2.0d0*adif * sqrt((sep-sag1-sag2)**2+((d1-d2e)/2.0d0)**2)
	      call wout ( ddif, "  diffraction correction to m2 diameter (m)" )

	      fdif = -2.0d0 * ubar1 * ( sep - sag2 )
	      call wout ( fdif, "  field correction to m2 diameter (m)" )

	      call wout ( cdif, "  centration correction to m2 diameter (m)" )

            # calculate new edge diameter of the secondary for infrared
	       if ( fs != 0.0d0 )
		  d2e = (bfd - sag2) / abs( fs )  + ddif + cdif + fdif
	       else
		  d2e = abs( afbeam )  + ddif + cdif + fdif  # afocal
	       call wout ( d2e, "infrared diameter of secondary mirror (m)" )

	    # calculate secondary focal ratio (using edge diameter)
	      f2 = l2 / d2e
	      call wout ( f2, "secondary focal ratio" )

            # calculate sagitta from edge diameter and asphere
	      sag2 = d2e / f2 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - (alpha2+1.0d0)/16.0d0/f2**2 ) )
              call wout ( sag2, "sagitta of secondary mirror (m)" )

	       # calculate the effective aperture of the telescope
	       # 	based on ratio of nominal beam diameter
	       #        to infrared secondary diameter
	       # Should this be corrected for field angle?
	       if ( fs != 0.0d0 )
		  d1i = d1 / (bfd - sag2) * abs( fs ) * d2e
	       else
		  d1i = d1 / abs( afbeam ) * d2e  # afocal
	       call wout ( d1i, "effective primary aperture (m)" )
	       
	       # calculate the effective cassegrain focal ratio
	       fsi = ls / d1i
	       call wout ( fsi, "effective system focal ratio" )

	       # Pupil positions and magnifications were calculated
	       #     earlier in the program.  On 25 October 1994, I
	       #     tried recomputing them here using (sep-sag2) instead
	       #     of just (sep).  That produced funny results so
	       #     I've gone back to the paraxial case.

	       # entrance pupil position relative to primary
	       #     separation now corrected for sagitta of secondary
	       #spupil = 1.0d0 / ( 1.0d0 / l1 - 1.0d0 / ( sep - sag2 ) )

	       # entrance pupil diameter
	       #     why is this number too large?
	       #     should we scale the infrared vertex diameter???
	       dpupil =  d2e * abs( mpupil )
	       call wout ( dpupil, "?entrance pupil diameter (m)" )

	       # calculate the diameter of the primary that is actually
	       #      used by light from anywhere in the field.
	       #      The combined beam envelope from the whole field.
	       # compute beam diameter plus field spread since pupil.
	       # This is a vertex diameter sort of calculation?
	       d1f = d1i + abs( spupil * ubar1 * 2.0d0 )
	       call wout ( d1f, "?effective primary envelope (m)" )

	    }	# end of infrared secondary diameter

	  # aspheric amplitude on secondary mirror
	    sphere2 = d2e / f2 / 8.0d0 /
		 ( 1.0d0 + sqrt (1.0d0 - 1.0d0/16.0d0/f2**2 ) )
	    asphere2 = ( sag2 - sphere2 ) * 1.0d6
	    call wout ( asphere2, "secondary aspheric amplitude (microns)" )
	  # divide aspheric amplitude by 4 to get p-v departure from
	  #	best fit sphere.

	  }
          else {
            sag2 = 0.0d0          # flat secondary
	  # this calculation fails when we have a flat secondary with asphere
	    d2e = d2v
	    f2 = 0.0d0		# flat secondary
	  }

   # Is there an unused hole at the center of the secondary?
   # Calculate focal ratio of hole in beam, equivalent to fs
   if ( fs != 0.0d0 )
      f2h = bfd / abs ( fs ) / d1 * max ( pbaffle, d2e )
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

begin
   # size of the point beam at the tertiary
   if( fs != 0.0d0 ) {
      dbeam3 = tfd / abs( fs )
      call wout ( dbeam3, "diameter of beam at tertiary (m)" )

      ftif = fpdia - tfd * 2.0d0 * tan ( ax )
      call wout ( ftif, "  field correction to m3 diameter (m)" )

      # size of the tertiary (minor axis diameter)
      d3min = tfd * 2.0d0 * tan( abs( as ) ) + ftif
      call wout ( d3min, "minor axis diameter of tertiary (m)" )
   
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

      # focal ratio of the hole in the converging beam from a central
      # obstruction other than the tertiary.  does not account for
      # an off-axis shadow from the secondary mirror.
      fh = l1 / max ( d2e, pbaffle )

      # highest point on the tertiary.  this does not account for
      # decentering the tertiary to minimize the obscuration.
      vtext = vt + d3min * abs( tan( at ) ) / 2.0d0

      # diameter of the hole in the point converging beam at tertiary.
      dbeam3h = ( l1 - vtext ) / fh

      # half angle of the hole in the converging beam (equivalent as)
      ash = atan ( 0.5d0 / fh )

      # angle of off-axis (field) chief ray from prime focus.
      # primary focal length is the distance from focus to exit pupil
      # diameter of focal plane at prime is fpdia / magn
      axp = asin ( fpdia / magn / 2.0d0 / l1 )

      # diameter of the clear hole in the converging beam at the
      # maximum height of tertiary including the field
      dclear3 = ( l1 - vtext ) * 2.0d0 * tan( ash ) - fpdia / magn +
		( l1 - vtext ) * 2.0d0 * tan( axp )
      call wout ( dclear3, "hole inconverging light above tertiary (m)" )

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
   dbeam4 = bcfd / abs( fs )
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

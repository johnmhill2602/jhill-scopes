# cass_subs2.x version 14JUL90
# added full field distortion 24OCT91
# added spherical vs. focal plane motion 31OCT91
# corrected primary coma rotation 25AUG92
# added image motion from M2 decenter 05NOV92
# added conic tolerances 12NOV92
# 16OCT97 -- changed INDEF to INDEFD for V2.11
# 19APR99 -- print format for spherical aberration tolerances
# 28AUG07 -- corrected W&R equations 51 and 53.

# calculate fractional field diameter available in focal plane

procedure focal_plane

include "cass_common.h"

double	junkvar

begin

#  assume a curved focal plane so dw20 is set at height of best images

#  this doesn't work if the field is zero diameter (divides by zero)
	if ( field <= 0.0d0 )
	    return

        # find the roots of the rw20 equation in height squared

        # acoef * h**4 + bcoef * h**2 + ccoef = 0
        acoef = -0.5d0 * w222**2
        bcoef = -2.0d0/3.0d0 * w131**2
        ccoef = w2e2 - 4.0d0/9.0d0 * w040**2

	call quadratic_solr ( acoef, bcoef, ccoef, hmax, junkvar )

	if ( hmax == INDEFD )
            hmax = 0.0d0
	else if ( hmax < 0.0d0 )
	    hmax = 0.0d0
	else
        # convert height squared to height
	    hmax = sqrt ( hmax )
        call wout ( hmax,"fractional curved field radius" )

        fmax = hmax * field
        call wout ( fmax,"maximum curved field diameter (arcmin)" )

#  assume focal plane is a parabola, see also depth of focus calculations below
#       positive roc turns out to be concave up in a regular cass telescope.
#       this sign convention may be reverse from W&R (30)
        fproc = fpdia**2 / 64.0d-6 / fs**2 / w220p
        call wout ( fproc,"?petzval radius of curvature (m)" )
        fproc = fpdia**2 / 64.0d-6 / fs**2 / ( w220p + w222 )
        call wout ( fproc,"focal plane radius of curvature (m)" )

#  assume a flat focal plane
#       this may mean shifting away from the best axial focus

        # calculate range of focus on the axis ( h = 0 )
        rw20 = w2e2  -  4.0d0/9.0d0 * w040**2
        if( rw20 < 0.0d0 )
            rw20 = 0.0d0
        else
            rw20 =  sqrt ( 0.5d0 * rw20 )
	# range of focus is +-rw20

        # offset the flat plane toward the curvature
	if ( fproc > 0.0d0 )
	    rw20 = - rw20

	# calculate plane of best on-axis focus
	dw20a = - 4.0d0/3.0d0 * w040

        # calculate best focus height at maximum field calculated above
        dw20h = -4.0d0/3.0d0 * w040 - ( w220p + w222 ) * hmax**2

        # is maximum flat field set by curvature or aberrations?
        if( abs (rw20) < abs (dw20h - dw20a) )
	    # maximum focus plane passes thru extreme focus on-axis
	    dw20 = dw20a + rw20
	else
	    # maximum focus plane passes thru edge of useful field
	    dw20 = dw20h

        # find the roots of the rw20 equation in height squared
        #       equation now includes the dw20 terms

        # acoef * h**4 + bcoef * h**2 + ccoef = 0
        acoef = -0.5d0 * w222**2 - 2.0d0 * ( w220p + 0.5d0 * w222 )**2
        bcoef = -2.0d0/3.0d0 * w131**2 - 4.0d0 * (dw20 + 4.0d0/3.0d0*w040) * ( w220p + 0.5d0 * w222 )
        ccoef = w2e2 - 4.0d0/9.0d0 * w040**2 - 2.0d0 * (dw20 + 4.0d0/3.0d0*w040)**2

	call quadratic_solr ( acoef, bcoef, ccoef, hlax, junkvar )

	if ( hlax == INDEFD )
            hlax = 0.0d0
	else if ( hlax < 0.0d0 )
	    hlax = 0.0d0
	else
        # convert height squared to height
            hlax = sqrt ( hlax )
        call wout ( hlax,"fractional flat field radius" )

        flax = hlax * field
        call wout ( flax,"maximum flat field diameter (arcmin)" )

        # calculate focus position of best flat field (mm)
        dw20m = dw20 * 8.0d0 * fs**2 / 1.0d3
        call wout ( dw20m,"height of largest flat field (mm)" )

	# calculate amplitude of full field distortion (DS3)
	# negative w311 moves chief ray to larger radius on flat focal plane
        # is sign correct for Gregorian?
	rspot = -2.0d0 * fs * w311 
	call wout ( rspot,"full field distortion (microns)" )
end

#  Calculate Field-Focus Curve
procedure field_focus

include "cass_common.h"

double	ffh	# fractional field height

begin

#  print the table header
	call printf ("field focus curve for aligned system\n")
	call printf ("     radius        focal plane height     image size         wave aberration\n")
	call printf (" (mm)   (arcmin)    (mm)     (+/-mm)   (micron)  (arcsec)      (micron rms)\n")

#  loop from center to edge of field
	for ( ffh = 0.0d0; ffh <= 1.00001d0; ffh = ffh + 0.05d0 ) {

        # calculate best focus location
            dw20 = -4.0d0/3.0d0 * w040 - ( w220p + w222 ) * ffh**2

        # calculate range of focus
            rw20 = w2e2  -  4.0d0/9.0d0 * w040**2 -  
		2.0d0/3.0d0 * w131**2 * ffh**2 - 0.5d0 * w222**2 * ffh**4
            if( rw20 < 0.0d0 )
                rw20 = 0.0d0
            else
                rw20 = sqrt ( 0.5d0 * rw20 )

        # calculate the rms image radius
            rmsis = 2.0d0/3.0d0 * w131**2 * ffh**2 +
		    4.0d0/9.0d0 * w040**2 + 0.5d0 * w222**2 * ffh**4
        #       in microns
            rmsis = sqrt ( rmsis ) * 2.0d0 * abs( fs )
        #       in arcsec
            rmsia = rmsis / 1.0d3 / plate

        # calculate field angle in arcminutes
            ha = ffh * field / 2.0d0

        # calculate field position in mm
            hm = ha * 60.0d0 * plate

        # convert depth of focus to millimeters
            dw20m = dw20 * 8.0d0 * fs**2 / 1.0d3
            rw20m = rw20 * 8.0d0 * fs**2 / 1.0d3
            if(ffh == 0.0d0)
		xrw20m = rw20m  # save the center depth of focus

        # calculate the wave aberration variance
        #   this is not the surface of minimum wavefront error.
            waveab = ( dw20 + w040 + (w220p+w222/2.d0) * ffh**2 )**2 / 12.d0 +
	    w040**2 / 180.d0 + (w222*ffh**2)**2 / 24.d0 + (w131*ffh)**2 / 72.d0
            waveab = sqrt ( waveab )

	call printf ("%7.2f %6.2f %10.4g %9.3g  %9.3g %9.3g       %9.3g\n")
		call pargd (hm)
		call pargd (ha)
		call pargd (dw20m)
		call pargd (rw20m)
		call pargd (rmsis)
		call pargd (rmsia)
		call pargd (waveab)

	}	# end for loop

end

#  calculate secondary alignment tolerances for curved secondaries
procedure m2_tolerances

include "cass_common.h"

double afudge

begin

	call printf ( "secondary alignment tolerances based on rms image radius\n" )
	call flush (STDOUT)

#  calculate paraxial focus shift based on corrected W&R (48)
	# added this calculation 22-JAN-2010 based on W&R Errata
        pshift = - (magn**2 +1)
	call wout ( pshift, "paraxial focus shift -- axial motion (micron/micron)" )

#  calculate focus wavefront error caused by secondary axial motion
        # ignore the sign and assume other aberrations are small
        sw020 = magn**2 / 8.0d0 / fs**2
        call wout ( sw020,"wavefront focus -- axial motion (micron/micron)" )

#  calculate secondary focus = axial motion tolerance
        #       this gives it all the remaining spot size by using the whole 
        #       focus range.
        srw20m = xrw20m / magn**2 * 1.0d3
        call wout ( srw20m,"m2 focus tolerance (on-axis) -- axial motion (micron)" )
        srw20m = rw20m / magn**2 * 1.0d3
        call wout ( srw20m,"m2 focus tolerance (field) -- axial motion (micron)" )

        #  change in scale with axial motion without refocus 1/micron
	#	from W&R (51,52) multiplied by 4*magn (Rakich 2007 PC)
        xdya = 4.0d-6/ls * ( magn**2 * (2.d0+beta) + beta ) / (1.0d0+beta)
        call wout ( xdya,"scale change without refocus (fraction/micron)" )

        #  change in scale with axial motion with refocus 1/micron
	#	from W&R (52,53) multiplied by 4*magn (Rakich 2007 PC)
        xdyra = 1.0d-6*magn/ls * (1.0d0 - magn**2) / (1.0d0+beta)
        call wout ( xdyra,"scale change with refocus (fraction/micron)" )

        #  spherical aberration induced by axial motion of m2 from W&R (54)
        sw040 = (magn+1.0d0) * ( 2.d0 * magn * (magn-1.0d0) *
		 (fs-eta) +1.0d0) /256.d0 / fs**3 / f1 / (fs-eta)
        call wout ( sw040,"wavefront spherical ab'n -- axial motion (micron/micron)" )
        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 4/9 w040**2 )
        rspot = 1.333333d0 * abs( fs ) * sw040
        call wout ( rspot,"  induced image radius (micron/micron)" )
        #  in arcsec
        rspot = rspot / 1.0d3 / plate
        call wout ( rspot,"  induced image radius (arcsec/micron)" )
        #  how much motion is tolerable?
        rspot = spotsize / rspot
        call wout ( rspot,"  tolerable secondary motion (micron)" )
	sw040 = sw040 / magn**2 * 1.0d6
	# spherical aberration induced by axial motion, in terms of focal plane
        call wout ( sw040,"wavefront spherical ab'n -- focal motion (micron/meter)" )
        #  how much does this secondary motion move the focal plane?
        fspot = - rspot * magn**2 / 1.0d6
        call wout ( fspot,"  tolerable focal plane motion (m)" )

# spherical aberration sensitivity to primary conic constant errors
   # This is error produced by changing asphere from -1.200000 to -1.200001.
   # Also given by w040 = d1 / 512 / f1**3 * deltaALPHA (Burge)
   sw040 = magn**3 * y1**4 / 32.0d0 * power**3
   call wout ( sw040, "wavefront spherical ab'n -- primary asphere (micron/ppm)" )
        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 4/9 w040**2 )
        rspot = 1.333333d0 * abs( fs ) * sw040
        call wout ( rspot,"  induced image radius (micron/ppm)" )
        #  in arcsec
        rspot = rspot / 1.0d3 / plate
        call wout ( rspot,"  induced image radius (arcsec/ppm)" )
        #  how much motion is tolerable?
        rspot = spotsize / rspot * 1.0d-6
        call wout ( rspot,"  tolerable primary asphere error" )

# spherical aberration sensitivity to secondary conic constant errors
   sw040 = k * y1**4 / 32.0d0 * power**3
   call wout ( sw040, "wavefront spherical ab'n -- secondary asphere (micron/ppm)" )
        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 4/9 w040**2 )
        rspot = 1.333333d0 * abs( fs ) * sw040
        call wout ( rspot,"  induced image radius (micron/ppm)" )
        #  in arcsec
        rspot = rspot / 1.0d3 / plate
        call wout ( rspot,"  induced image radius (arcsec/ppm)" )
        #  how much motion is tolerable?
        rspot = spotsize / rspot * 1.0d-6
        call wout ( rspot,"  tolerable secondary asphere error" )

.help
# added this unimplemented code 23JUN93   
# spherical aberration sensitivity to primary radius errors, fixed fs
   sw040 = y1**4 / 32.0d-6 * power**3 * (delta_sigma1)
   # But we still need to derive how sigma1 changes with the magnification
   call wout ( sw040, "wavefront spherical ab'n -- primary f.l. (micron/m)" )
        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 4/9 w040**2 )
        rspot = 1.333333d0 * abs( fs ) * sw040
        call wout ( rspot,"  induced image radius (micron/m)" )
        #  in arcsec
        rspot = rspot / 1.0d3 / plate
        call wout ( rspot,"  induced image radius (arcsec/m)" )
        #  how much motion is tolerable?
        rspot = spotsize / rspot * 1.0d-6
        call wout ( rspot,"  tolerable primary radius error (m)" )
.endhelp

#  calculate the location of the zero-coma pivot point, W&R (60)
        zcp = 2.d0 * l2 * (magn+1.0d0) / ( (magn+1.0d0) -alpha2*(magn-1.0d0) )
        call wout ( zcp,"distance from m2 to zero-coma pivot (m)" )
   
#  calculate the location of zero-coma point relative to prime focus
        zcppf = l1 - sep + zcp
        call wout ( zcppf,"distance from prime focus to zero-coma pivot (m)" )

#  calculate image motion from zero-coma rotation
        azcr = ( 2.d0 * l2 - zcp ) * ( 1.0d0 - magn ) / ls
        call wout ( azcr,"image motion from zero-coma rotation (arcsec/arcsec)" )

#  calculate image motion from vertex rotation
        avtr = 2.d0 * l2 * ( 1.0d0 - magn ) / ls
        call wout ( avtr,"image motion from m2 vertex rotation (arcsec/arcsec)" )

#  calculate image motion from lateral displacement, W&R (A7)
   amld = ( 1.0d0 - magn )
   call wout ( amld, "image motion from lateral displacement (micron/micron)" )
   amld = amld / 1.0d3 / plate
   call wout ( amld, "image motion from lateral displacement (arcsec/micron)" )

#  calculate induced coma from lateral displacement
        #       this is displacement from the zero-coma pivot
        wcd = ( 1.0d0 + ( f1 + eta ) / magn**2 / ( fs - eta ) ) / 32.d0 / f1**3
        call wout ( wcd,"wavefront coma -- lateral motion (micron/micron)" )
        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 2/3 * w131**2 )
         rspot = 1.632993d0 * abs( fs ) * wcd
         call wout ( rspot,"  induced image radius (micron/micron)" )
        #  in arcsec
         rspot = rspot / 1.0d3 / plate
         call wout ( rspot,"  induced image radius (arcsec/micron)" )
        #  how much motion is tolerable?
         rspot = spotsize / rspot
         call wout ( rspot,"  tolerable motion (micron)" )

#  calculate induced coma from m2 vertex rotation
         wvr = zcp * wcd * 1.0d6 / ARCSEC_RAD
         call wout ( wvr,"wavefront coma -- vertex rotation (micron/arcsec)" )

        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 2/3 * w131**2 )
	rspot = 1.632993d0 * abs( fs ) * wvr
        call wout ( rspot,"  induced image radius (micron/arcsec)" )
        #  in arcsec
        rspot = rspot / 1.0d3 / plate
        call wout ( rspot,"  induced image radius (arcsec/arcsec)" )
        #  how much motion is tolerable?
        rspot = spotsize / rspot
        call wout ( rspot,"  tolerable rotation (arcsec)" )

#  calculate induced coma from m2 vertex chop in focal plane units
        wcv = wvr / avtr
        call wout ( wcv,"wavefront coma -- vertex chop angle (micron/arcsec)" )

        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 2/3 * w131**2 )
        rspot = 1.632993d0 * abs( fs ) * wcv
        call wout ( rspot,"  induced image radius (micron/arcsec)" )
        #  in arcsec
        rspot = rspot / 1.0d3 / plate
        call wout ( rspot,"  induced image radius (arcsec/arcsec)" )
        #  how much motion is tolerable?
        rspot = spotsize / rspot
        call wout ( rspot,"  tolerable vertex chop throw (arcsec)" )

        #  what is permissible zero coma chop before astigmatism gets you?
        afudge = 9.54d-07            # constant for chop in arcsec
        wzca = 0
#        call wout ( wzca,"wavefront astigmatism -- zero coma chop (micron/arcsec)" )
        #  in microns
        #  in arcsec
#           rspot = afudge * l * abs( fs ) / f1 **2
#          call wout ( rspot,"  induced image radius at field center (arcsec/arcsec)" )
        #  how much motion is tolerable
           achop = abs( spotsize * f1 **2 / afudge / l / abs( fs ) )
           achop = sqrt ( achop )
           call wout ( achop,"  tolerable zero coma chop throw (arcsec), astig only")

#  calculate induced coma from m1 vertex rotation
   # ( sep - zcp ) is approximately equal to ( l1 )
         wvp = ( sep - zcp ) * wcd * 1.0d6 / ARCSEC_RAD
         call wout ( wvp,"wavefront coma -- primary rotation (micron/arcsec)" )

        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 2/3 * w131**2 )
	rspot = 1.632993d0 * abs( fs ) * wvp
        call wout ( rspot,"  induced image radius (micron/arcsec)" )
        #  in arcsec
        rspot = rspot / 1.0d3 / plate
        call wout ( rspot,"  induced image radius (arcsec/arcsec)" )
        #  how much motion is tolerable?
        rspot = spotsize / rspot
        call wout ( rspot,"  tolerable rotation (arcsec)" )

end

#  calculate secondary alignment tolerances for newtonian secondaries
procedure newt_tolerances

include "cass_common.h"

begin

	call printf ( "secondary alignment tolerances based on rms image radius\n" )
	call flush (STDOUT)


#  calculate focus wavefront error caused by secondary axial motion
        # ignore the sign and assume other aberrations are small
	# corrected to be half as much as a cass secondary
        sw020 = magn**2 / 4.0d0 / fs**2
        call wout ( sw020,"wavefront focus -- axial motion (micron/micron)" )

#  calculate secondary focus = axial motion tolerance
        #       this gives it all the remaining spot size by using the whole 
        #       focus range.
        srw20m = xrw20m / magn**2 * 1.0d3
        call wout ( srw20m,"m2 focus tolerance (on-axis) -- axial motion (micron)" )
        srw20m = rw20m / magn**2 * 1.0d3
        call wout ( srw20m,"m2 focus tolerance (field) -- axial motion (micron)" )

        #  change in scale with axial motion without refocus 1/micron
	#	from W&R (51,52) multiplied by 4*magn (Rakich 2007 PC)
        xdya = 4.0d-6/ls * ( magn**2 * (2.d0+beta) + beta ) / (1.0d0+beta)
        call wout ( xdya,"scale change without refocus (fraction/micron)" )

        #  change in scale with axial motion with refocus 1/micron
	#	from W&R (52,53) multiplied by 4*magn (Rakich 2007 PC)
        xdyra = 1.0d-6*magn/ls * (1.0d0 - magn**2) / (1.0d0+beta)
        call wout ( xdyra,"scale change with refocus (fraction/micron)" )

# spherical aberration sensitivity to primary conic constant errors
   # This is error produced by changing asphere from -1.200000 to -1.200001.
   sw040 = y1**4 / 32.0d0 * power**3
   call wout ( sw040, "wavefront spherical ab'n -- primary asphere (micron/ppm)" )
        #  what image radius does this produce? 
        #  in microns = 2 * fs * sqrt( 4/9 w040**2 )
        rspot = 1.333333d0 * abs( fs ) * sw040
        call wout ( rspot,"  induced image radius (micron/ppm)" )
        #  in arcsec
        rspot = rspot / 1.0d3 / plate
        call wout ( rspot,"  induced image radius (arcsec/ppm)" )
        #  how much motion is tolerable?
        rspot = spotsize / rspot * 1.0d-6
        call wout ( rspot,"  tolerable primary asphere error" )

#  calculate image motion from vertex rotation
        avtr = 2.0d3 * bfd / plate / ARCSEC_RAD
        call wout ( avtr,"image motion from m2 vertex rotation (arcsec/arcsec)" )

#  calculate induced coma from lateral displacement

#  calculate induced coma from m2 vertex rotation

end

#  calculate tertiary alignment tolerances
procedure tert_tolerances

include "cass_common.h"

begin

	call printf ( "tertiary alignment tolerances\n" )
	call flush (STDOUT)

#  calculate image motion from vertex rotation
        tvtr = 2.0d3 * tfd / plate / ARCSEC_RAD
        call wout ( tvtr,"image motion from tertiary rotation (arcsec/arcsec)" )

end

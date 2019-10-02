# CHAMBER -- Task to calculate aluminum thickness distribution.

include <mach.h>
include <time.h>
include <imhdr.h>

procedure t_chamber()

.help
This task calculates the distribution of aluminum desposited on a
mirror surface from a grid of evaporating filaments in a vacuum
chamber.  It accounts for filament location, distance, and substrate
angle.  (This early version does not yet include baffles or the
possibility of extended filaments.)  Each filament contributes to the
coating based on its distance from the surface element and the angle
between the surface normal and the filament.

Pixel(1,1) is in lower left when image is displayed on imtool.
Coordinate (0,0,0) is the vertex of the mirror.

#  History
#       26JUL88 - Code stolen from Michael P. Lesser, Steward Observatory
#       27JUL88 - JMH Continues destroying code.  Units >> mm.
#       29JUL88 - Install rigorous correction for surface-source angle
#	17JAN91 - Created in SPP by J. M. Hill, Steward Observatory
#	22JAN91 - Translated from CHAMBER.F77.  JMH
#	24JAN91 - Added IMHDR calls.  JMH
#	29JAN91 - decode centers string.  JMH
#	30JAN91 - filenames in dynamic memory.  JMH
#	05FEB91 - Added baffle angle from point source.  JMH
#	11FEB91 - put name of filament file in im_title.
#		- added tmin,tmax to header.  JMH
#	12FEB91 - implemented finite filament loads.  JMH
#	14FEB91 - added spherical approximation to surface normal
#       16OCT97 - changed INDEF to INDEFD for V2.11

Future work:
	Calculate rigorous normal to conic surfaces
	Implement filament baffles physically
	Allow for extended filament geometry
.endhelp

#  Include memory allocation and parameters
include	"filament.h"

#  Local Variables
pointer	fifile			# filament location file
pointer	outimg			# output image file
int	gridrows, gridcols	# output image dimensions (was IGRIDxIGRID)
double	dmirror			# mirror diameter (was SDIA)
double	fnum			# mirror focal ratio
double	asphere			# mirror asphere (-1 = parabola)
double	thick			# desired coating thickness
				# INDEF = 1 filament load
double	load			# filament load normalization
double	density			# specific gravity of aluminum coating
double	bangle			# baffle angle (degrees)
bool	baffles			# use filament baffles?
int	verbosity		# quantity of info to print

double	fl			# focal length of mirror (calculated)
double	curv			# curvature of mirror
int	jfils			# number of filaments
int	jj
double	dcx, dcy, dcz		# direction cosines
double	fcx, fcy, fcz
double	sbang			# cosine of baffle angle
double	sum, sum1, sum2
double	tmin, tmax, tmean
double	dist, tdep, costh
double	rms, scale
double	r1, r2, yedge, xedge
double	xmin, xmax, ymin, ymax
double  xm, ym, zm		# coordinates on the mirror surface
long	nn			# number of active pixels
int	irow, icol
real	rscale, rzero

string	version	"14-FEB-91"	# version Date of Code
char	time[SZ_TIME]

pointer  sp, im, zq, ff

errchk	salloc, immap, impl2r, imgl2r

#  Function Declarations

long	clktime()
int	clgeti()
double	clgetd()
bool	clgetb()
int	read_fils()
pointer	immap()
pointer	impl2r()
pointer imgl2r()

begin

#  Introduce Program
	call printf ("CHAMBER Aluminizing Program, SPP Version of %s\n")
		call pargstr (version)

#  Get Date and Time
	call cnvtime (clktime(0), time, SZ_TIME)
	call printf ("       Executed on: %s\n")
		call pargstr (time)

	call flush (STDOUT)

#  Allocate Memory
	call smark (sp)

	call salloc (fifile, SZ_FNAME+1, TY_CHAR)
	call salloc (outimg, SZ_FNAME+1, TY_CHAR)

#  Get Task Parameters
	call clgstr ("fifile", Memc[fifile], SZ_FNAME)
	call clgstr ("outimg", Memc[outimg], SZ_FNAME)
	gridcols = clgeti ("gridcols")
	gridrows = clgeti ("gridrows")
	dmirror = clgetd ("dmirror")
	fnum = clgetd ("fnum")
	asphere = clgetd ("asphere")
	thick = clgetd ("thick")
	load = clgetd ("load")
	density = clgetd ("density")
	bangle = clgetd ("bangle")
	baffles = clgetb ("baffles")
	verbosity = clgeti ("verbosity")



#  Allocate memory for filaments.
	call salloc (ff, LEN_FILARRAY, TY_STRUCT)

#  Read the filament location file.
	jfils =  read_fils (Memc[fifile], ff, verbosity)

	if (verbosity >= 4) {
	    call printf ("CHAMBER:  Read %5u filaments from: %s.\n")
		call pargi (jfils)
		call pargstr (Memc[fifile])
	    call flush (STDOUT)
	}

	if (verbosity >= 5) {
	    for (jj=1; jj<=jfils; jj=jj+1) {
		call printf ("CHAMBER:  filament %4u X=%6.2f Y=%6.2f Z=%6.2f\n")
		    call pargl (KF(ff,jj))
		    call pargr (XA(ff,jj))
		    call pargr (YA(ff,jj))
		    call pargr (ZA(ff,jj))
	    }
	    call flush (STDOUT)
	}

#  Map the image file.
	im = immap (Memc[outimg], NEW_IMAGE, 0)
	IM_NDIM(im) = 2
	IM_LEN(im,1) = gridcols
	IM_LEN(im,2) = gridrows
	IM_PIXTYPE(im) = TY_REAL
	call strcpy (Memc[fifile], IM_TITLE(im), SZ_IMTITLE)

#  Allocate Image Memory (enough for a row)
	call salloc (zq, gridcols, TY_REAL)

#  Loop through Grid Points

        nn = 0
        tmin = MAX_REAL
        tmax = 0.d0
        sum1 = 0.d0
        sum2 = 0.d0

	if (fnum == 0.0d0) {
	    fl = 0.d0			# flat mirror
	    curv = 0.0d0
	}
	else {
	    fl = dmirror * fnum		# focal length of mirror
	    curv =  0.5d0 / fl		# curvature of the mirror, 1/R
	}

        xedge = dmirror/2.d0
        yedge = dmirror/2.d0

	if (verbosity >= 4) {
	    call printf ("CHAMBER:  diameter: %8.2f  F/%-7.3f  f.l.: %8.2f  k: %7.4f\n")
		call pargd (dmirror)
		call pargd (fnum)
		call pargd (fl)
		call pargd (asphere)
	    call flush (STDOUT)
	}

	if (baffles) {
	# bangle of 0 means no baffle, bangle of 90 degrees stops everything
	# sine of baffle angle, after converting to radians
	    sbang = sin (bangle * acos(-1.0d0) / 180.0d0)
	    call printf ("CHAMBER:  Using baffles at %4.1f degrees, %5.3f\n")
		call pargd (bangle)
		call pargd (sbang)
	}
	else {
	    sbang = 0.0d0		# no baffle
	    call printf ("CHAMBER:  Using no baffles, %5.3f\n")
		call pargd (sbang)
	}

	call printf ("Calculating the Deposition at the Grid Points..\n")
	call printf ("     %5u rows by %5u columns.\n")
		call pargi (gridrows)
		call pargi (gridcols)
	call flush (STDOUT)

	for (irow=1; irow<=gridrows; irow=irow+1 ) {

	    if (verbosity >= 6) {
		call printf ("CHAMBER:  Working on image row %4u.\n")
		    call pargi (irow)
		call flush (STDOUT)
	    }

	# Y coordinate on mirror
	    ym = -yedge + dmirror/double(gridrows)*(double(irow)-0.5d0)    
		# center of row 1 is 0.5 pixel inside mirror edge

	    for (icol=1; icol<=gridcols; icol=icol+1 ) {

.help
	    if (verbosity >= 8) {
		call printf ("CHAMBER:  Working on image column %4u.\n")
		    call pargi (icol)
		call flush (STDOUT)
	    }
.endhelp

	# X coordinate on mirror
                xm = -xedge + dmirror/double(gridcols)*(double(icol)-0.5d0) 
		# center of row 1 is 0.5 pixel inside mirror edge

		r2 = xm*xm + ym*ym		# radius squared
		r1 = sqrt (r2)			# radius on mirror
		if (r1 > dmirror/2.d0) {
		    tdep = 0.0d0            # Off edge of mirror
	        }
	 	else {
		    if ( fl == 0.0d0 )
			zm = 0.0d0               # flat mirror
		    else
		    # curved mirror (rigorous for conics)
			zm = r2 * curv /
			 (1.d0 + sqrt (1.d0 - (asphere+1.d0) * curv**2 * r2))

		# Calculate direction cosines of vector normal to mirror surface
		#	 Could the sign be wrong?
		    if (fl == 0.0) {
		    # flat mirror
			dcx = 0.0d0
			dcy = 0.0d0
			dcz = 1.0d0
		    }
		    else if (asphere < -0.5d0) {
		    # curved mirror (parabolic approximation)
			dcx = cos ( atan2 ( 2.0d0*fl, -xm ) )
			dcy = cos ( atan2 ( 2.0d0*fl, -ym ) )
			dcz = sqrt ( 1.0d0 - dcx**2 - dcy**2 )
		    }
		    else {
		    # curved mirror (spherical approximation)
			dcx = -xm / (2.0d0*fl)
			dcy = -ym / (2.0d0*fl)
			dcz = sqrt ( 1.0d0 - dcx**2 - dcy**2 )
		    }

	    if (verbosity >= 8) {
		call printf ("CHAMBER:  radius=%8.3f z=%8.3f dcx=%8.5f dcy=%8.5f dcz=%8.5f\n")
		    call pargd (r1)
		    call pargd (zm)
		    call pargd (dcx)
		    call pargd (dcy)
		    call pargd (dcz)
		call flush (STDOUT)
	    }

		# Calculate the relative deposition at this point.
		    sum = 0.d0

		# Loop over all filaments
		    for (jj=1; jj<=jfils; jj=jj+1) {

		    # Calculate the distance from filament to surface.
			dist = (YA(ff,jj)-ym)**2 + (XA(ff,jj)-xm)**2 + (ZA(ff,jj)-zm)**2
		    # Deposition goes as inverse square of distance.
			tdep = 1.0d0 / dist
			dist = sqrt (dist)

		    # Direction cosines of aluminum trajectory
			fcx = ( XA(ff,jj) - xm ) / dist
			fcy = ( YA(ff,jj) - ym ) / dist
			fcz = ( ZA(ff,jj) - zm ) / dist


		    # Does this aluminum get baffled?
			# fcz must always be positive!
			if (sbang >= fcz)
			# No deposition
			    costh = 0.0d0
			else
		    	# Combine with the surface normal.
			    costh = dcx*fcx + dcy*fcy + dcz*fcz

		    # Does this aluminum get intercepted by the mirror?
		    #	Don't put filaments below the mirror edge!

		    # Skip angles from behind the mirror surface.
		    #	These act as "negative" deposition.
			if (costh > 0.0d0)
			    tdep = tdep * costh
			else
			    tdep = 0.0d0

# Lesser's old equation  T = (ZA(I)-Z) / SQRT(DIST) / DIST 
#	now becomes   tdep = (ZA(ff,jj)-zm) / sqrt (dist) / dist 

		    # Add to deposition from other filaments
			sum = sum + tdep

.help
	if (verbosity >= 10) {
		call printf ("CHAMBER:  fil %4u  dist=%10.4e  tdep=%10.4e sum=%10.4e\n")
			call pargi (jj)
			call pargd (dist)
			call pargd (tdep)
			call pargd (sum)
	}
.endhelp

		    }	# end of loop over filaments

		# Increment Statistics Counters
		    tdep = sum
		    sum1 = tdep + sum1
		    sum2 = tdep*tdep + sum2
		    nn = nn + 1

		# Save maxima and minima
		    if (tdep < tmin) {
			tmin = tdep
			xmin = xm
			ymin = ym
		    }
		    else if (tdep > tmax) {
			tmax = tdep
			xmax = xm
			ymax = ym
		    }

		}	# end of pixel inside mirror section

.help
	    if (verbosity >= 8) {
		call printf ("CHAMBER:  Deposition is %14.7e at pixel %8u\n")
		    call pargd (tdep)
		    call pargl (nn)
		call flush (STDOUT)
	    }
.endhelp

	    # Store result in the row array.
		ZR(zq,icol) = real(tdep)


	    }	# end of loop over columns

	    if (verbosity >= 6) {
		call printf ("CHAMBER:  Writing row %4u to the image.\n")
		    call pargi (irow)
		call flush (STDOUT)
	    }

	# Write the row to the image
	    call amovr (Memr[zq], Memr[impl2r(im,irow)], gridcols)

	}	# end of loop over rows

# Calculate statistics

	call printf ("There were %8u active grid points.\n")
		call pargl (nn)
	call flush (STDOUT)

        if (nn > 0) {
	    tmean = sum1 / double(nn)

	    if (thick != INDEFD) {
	    # scale to desired coating thickness
		scale = thick / tmean
	    # calculate required load
		load = scale * density * acos(-1.d0) / 2.5d8
		call printf ("CHAMBER:  scale: %10.4e  load: %10.6f g  density: %5.2f\n")
			call pargd (scale)
			call pargd (load)
			call pargd (density)
	    }
	    else if (load != INDEFD) {
	    # calculate scale from filament load
	    #	factor is 1e9 /4pi
		scale = load / density * 2.5d8 / acos(-1.d0)
		call printf ("CHAMBER:  load: %10.6f g  scale: %10.4e  density: %5.2f\n")
			call pargd (load)
			call pargd (scale)
			call pargd (density)
	    }
	    else {
	    # unable to scale
		scale = 1.0d0
		load = 1.0d0
		call printf ("CHAMBER:  Unable to scale thickness.\n")
	    }

	    tmean = tmean*scale
	    sum2 = sum2*scale*scale
	    tmin = tmin*scale
	    tmax = tmax*scale
	    rms = sum2/double(nn) - tmean*tmean
	    if (rms < 0.0d0)
		rms = 0.0d0
	    else
		rms = sqrt (rms*2.d0)

	    call printf ("CHAMBER:  mean: %10.3f (nm)  rms: %10.3f (nm)  rms: %9.4f (%%)\n")
		call pargd (tmean)
		call pargd (rms)
		call pargd (rms/tmean*100.d0)
	    call flush (STDOUT)
	    call printf ("CHAMBER:  tmin: %10.3f (nm)  xmin=%8.2f  ymin=%8.2f\n")
		call pargd (tmin)
		call pargd (xmin)
		call pargd (ymin)
	    call flush (STDOUT)
	    call printf ("CHAMBER:  tmax: %10.3f (nm)  xmax=%8.2f  ymax=%8.2f\n")
		call pargd (tmax)
		call pargd (xmax)
		call pargd (ymax)
	    call flush (STDOUT)

	}	# end of statistics section


#  Apply scale to the image or the header
		rscale = scale
		rzero = 0.0
	for (irow=1; irow<=gridrows; irow=irow+1 ) {
	    call altmr (Memr[imgl2r(im,irow)], Memr[impl2r(im,irow)], gridcols,
		 rscale, rzero)
	}

#  Write minimum and maximum of deposition to image header
#	A slight corruption of their actual meaning.
	IM_MIN(im) = tmin
	IM_MAX(im) = tmax
	IM_LIMTIME(im) = clktime(0)

#  Unmap the image.
	call imunmap (im)

#  Say Goodbye
	call printf ("CHAMBER is complete for %s.\n")
		call pargstr (Memc[outimg])

	call sfree (sp)

end

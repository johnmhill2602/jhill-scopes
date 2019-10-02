# SPECS -- Compute the structure functions for various telescope
#		wavefront specifications

# Written by J. M. Hill,  Steward Observatory

# Original Version in AOS F77 14JAN88
# Converted to Sun F77 20JUL89
# Converted to SPP from the F77 version 22DEC89
# Added scaling for secondary 17SEP90
# Removed task statement, renamed t_newspecs   31JAN91
# Expand to six cases,  20APR92

procedure t_newspecs()

# loop variables
int	lr, jl, i
real	rr, tr, col[7]

# number of curves to generate
int	ncurves

# r0 for the atmosphere and mirror specification at 0.5 microns (meters)
real r05[6]

# internal variable for r0 as a function of wavelength
real r0l

# tiltyn=yes means consider specification with mean tilt removed
bool tiltyn[6]

# diameter of the primary mirror (meters)
real diameter[6]

# wavefront scale factor for secondary mirror (1.0 for primary)
real scale[6]

# scattering loss from small scale roughness
real scatter[6], sigma

# structure function values
real delta, deltatel

# structure function ceiling for wavefront rms, (nm) 0 if none
real maxrms[6]

# minimum and maximum spacing (in centimeters), number of points
int minsep, maxsep, npoints
real xx

# wavelengths (meters)
real wave[6], wlambda

# functions
real clgetr()
int clgeti()
bool clgetb()
real log10()
real real()


begin
	ncurves = clgeti ("ncurves")
	minsep = clgeti ("minsep")
	maxsep = clgeti ("maxsep")
	npoints = clgeti ("npoints")

	if ( ncurves >= 1 ) {
	    diameter[1]= clgetr ("diameter_1")
	    r05[1] = clgetr ("r05_1")
	    wave[1] = clgetr ("wave_1")
	    scale[1] = clgetr ("scale_1")
	    scatter[1] = clgetr ("scatter_1")
	    maxrms[1] = clgetr ("maxrms_1")
	    tiltyn[1] = clgetb ("tiltyn_1")
	}
	if ( ncurves >= 2 ) {
	    diameter[2]= clgetr ("diameter_2")
	    r05[2] = clgetr ("r05_2")
	    wave[2] = clgetr ("wave_2")
	    scale[2] = clgetr ("scale_2")
	    scatter[2] = clgetr ("scatter_2")
	    maxrms[2] = clgetr ("maxrms_2")
	    tiltyn[2] = clgetb ("tiltyn_2")
	}
	if ( ncurves >= 3 ) {
	    diameter[3]= clgetr ("diameter_3")
	    r05[3] = clgetr ("r05_3")
	    wave[3] = clgetr ("wave_3")
	    scale[3] = clgetr ("scale_3")
	    scatter[3] = clgetr ("scatter_3")
	    maxrms[3] = clgetr ("maxrms_3")
	    tiltyn[3] = clgetb ("tiltyn_3")
	}
	if ( ncurves >= 4 ) {
	    diameter[4]= clgetr ("diameter_4")
	    r05[4] = clgetr ("r05_4")
	    wave[4] = clgetr ("wave_4")
	    scale[4] = clgetr ("scale_4")
	    scatter[4] = clgetr ("scatter_4")
	    maxrms[4] = clgetr ("maxrms_4")
	    tiltyn[4] = clgetb ("tiltyn_4")
	}
	if ( ncurves >= 5 ) {
	    diameter[5]= clgetr ("diameter_5")
	    r05[5] = clgetr ("r05_5")
	    wave[5] = clgetr ("wave_5")
	    scale[5] = clgetr ("scale_5")
	    scatter[5] = clgetr ("scatter_5")
	    maxrms[5] = clgetr ("maxrms_5")
	    tiltyn[5] = clgetb ("tiltyn_5")
	}
	if ( ncurves >= 6 ) {
	    diameter[6]= clgetr ("diameter_6")
	    r05[6] = clgetr ("r05_6")
	    wave[6] = clgetr ("wave_6")
	    scale[6] = clgetr ("scale_6")
	    scatter[6] = clgetr ("scatter_6")
	    maxrms[6] = clgetr ("maxrms_6")
	    tiltyn[6] = clgetb ("tiltyn_6")
	}


# calculate logarithmic interval
	xx = ( log10(real(maxsep)) - log10(real(minsep)) ) / npoints

# loop over spacings by logarithmic interval
	for (lr=0; lr<=npoints; lr=lr+1) {

	    rr = 10**( xx*lr + log10(real(minsep)) - 2.0 )
	    col[1] = rr * 100.0

# loop over columns
	    for (jl=1; jl<=ncurves; jl=jl+1) {

# rescale the wavefront
		tr = rr * scale[jl]

# convert microns to meters
                wlambda = wave[jl] * 1.0e-06

# ro as a function of wavelength
                r0l = r05[jl] * ( wlambda / 5e-07 )**1.2

# small scale roughness allowance
                sigma = ( scatter[jl] )**0.5 / 6.283185 * wlambda

# mirror wavefront specification
		if ( tr >= diameter[jl] ) {
		    delta = 0.0
		}
		else {
                    delta = 2.0 * sigma**2    # mirror wavefront spec for space

		    if ( r0l > 0.0 ) {	# include atmosphere

			if (tiltyn[jl]) 	# without mean tilt
                	    delta = delta + 0.17427 * wlambda**2 * 
				( tr  / r0l )**1.66666666666667 *
				(1.0 - 0.975 *
				( tr / diameter[jl] )**0.3333333333)
			# Note: tilt correction is questionable if scale >1.0

			else		# including tilt
			    delta = delta + 0.17427 * wlambda**2 * 
				( tr / r0l )**1.66666666666667
		    
		    }
		}

                deltatel = 1.0e9 * ( delta )**0.5		# convert to nm

		if ( (maxrms[jl] > 0.0) && (deltatel > maxrms[jl]) )
		    deltatel = maxrms[jl]	# rms wavefront ceiling

                col[jl+1] = deltatel

	    }

# fill unused columns
	    for (jl=ncurves+1; jl<=6; jl=jl+1) {
		col[jl+1] = 0.0
	    }

# print the results
	call printf (" %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f\n")
		for (i=1; i<=7; i=i+1) {
            	    call pargr (col[i])
		}

        }

end

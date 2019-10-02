# SPECS -- Compute the structure functions for various telescope
#		wavefront specifications

# Written by J. M. Hill,  Steward Observatory

# Original Version in AOS F77 14JAN88
# Converted to Sun F77 20JUL89
# Converted to SPP from the F77 version 22DEC89
# Added scaling for secondary 17SEP90

task	specs

procedure specs()

# loop variables
int	lr, jl, i
real	rr, col[6]

# r0 for the atmosphere and mirror specification at 0.5 microns (meters)
real r05, t05
# internal variables for r0 as a function of wavelength
real r0l, t0l

# spaceyn=yes means consider specification without atmosphere
# tiltyn=yes means consider specification with mean tilt removed
bool tiltyn, spaceyn

# diameter of the primary mirror (meters)
real diameter

# wavefront scale factor for secondary mirror (1.0 for primary)
real scale

# scattering loss from small scale roughness
real scatter, sigma

# structure function values
real delta, deltaatm, deltatel

# structure function ceiling for wavefront rms, (nm) 0 if none
real maxrms

# minimum and maximum spacing (in centimeters), number of points
int minsep, maxsep, npoints
real xx

# wavelengths (meters)
real wave[4], wlambda

# functions
real clgetr()
int clgeti()
bool clgetb()
real log10()
real real()

data	wave / 3.5e-7, 5.0e-7, 6.33e-7, 1.0e-5 /

begin

	r05 = clgetr ("r05")
	t05 = clgetr ("t05")
	diameter= clgetr ("diameter")
	scale = clgetr ("scale")
	scatter = clgetr ("scatter")
	maxrms = clgetr ("maxrms")
	minsep = clgeti ("minsep")
	maxsep = clgeti ("maxsep")
	npoints = clgeti ("npoints")
	tiltyn = clgetb ("tiltyn")
	spaceyn = clgetb ("spaceyn")

	if (scale == INDEF)
		scale = 1.0

# calculate logarithmic interval
	xx = ( log10(real(maxsep)) - log10(real(minsep)) ) / npoints
# NOTE: program crashes if maxsep>diameter

# loop over spacings by logarithmic interval
	for (lr=0; lr<=npoints; lr=lr+1) {

          rr = 10**( xx*lr + log10(real(minsep)) - 2.0 )
          col[1] = rr * 100.0

# loop over wavelengths
	    for (jl=1; jl<=4; jl=jl+1) {

                wlambda = wave[jl]

# ro as a function of wavelength
                r0l = r05 * ( wlambda / 5e-07 )**1.2
                t0l = t05 * ( wlambda / 5e-07 )**1.2

# small scale roughness
                sigma = ( scatter )**0.5 / 6.283185 * wlambda

# atmospheric structure function (wavelength independent)
                delta = 0.17427 * wlambda**2 * ( rr / r0l )**1.66666666666667d0
                deltaatm = 1e9 * ( delta )**0.5
                col[2] = deltaatm

# primary mirror wavefront specification
		if ( (rr*scale) >= diameter )
			delta = 0.0
		else {
                delta = 2.0 * sigma**2	# mirror wavefront spec for space

		if (! spaceyn) {	# include atmosphere

		    if (tiltyn) 	# without mean tilt
                	delta = delta + 0.17427 * wlambda**2 * 
			    ( rr * scale / t0l )**1.66666666666667 *
			    (1.0 - 0.975 * ( rr * scale / diameter )**0.3333333333333)
		# Note: tilt correction is questionable if scale >1.0

		    else		# including tilt
			delta = delta + 0.17427 * wlambda**2 * 
			    ( rr * scale / t0l )**1.66666666666667
		    
		}
		}

                deltatel = 1e9 * ( delta )**0.5		# convert to nm

		if ( (maxrms > 0.0) && (deltatel > maxrms) )
		    deltatel = maxrms	# rms wavefront ceiling

                col[jl+2] = deltatel

	    }

	call printf (" %9.3f %9.3f %9.3f %9.3f %9.3f %9.3f\n")
		for (i=1; i<=6; i=i+1) {
            	    call pargr (col[i])
		}

        }

end

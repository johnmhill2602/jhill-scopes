# DEPFOC.CL -- Compute depth-of-focus parameters for telescope focal planes.

# Written by J. M. Hill,  Steward Observatory

# Created 13JAN93

procedure depfoc(sag1)

real	sag1		{prompt='focal plane sag at R=1 arcminute (m)'}
real	ftel		{prompt='telescope focal ratio'}
#real	fpri		{prompt='primary mirror focal ratio'}
real	dpri=8.0	{prompt='primary mirror diameter (m)'}
real	lambda=0.5e-6	{prompt='wavelength (m)'}
real	ppixel=24.0e-6	{prompt='physical pixel size (m)'}
real	sample=2	{prompt='pixel sampling of image (2)'}
real	seeing=0.5	{prompt='seeing FWHM at 0.5 micron (arcsec)'}
real	isovis=0.084	{prompt='isoplanatic patch at 0.5 micron (arcmin)'}
string  version="11MAY93" {prompt='version date of script'}

begin
	# define variables
	real spixel, dpixel, scam, dcam
	real srad, drad, sfocus, dfocus, sagabs
	real ipatch, iseeing
	int snum, dnum

	# begin code

	# This calculation takes curvature of telescope focal plane as input.
	# This is expressed as the sag of the focal plane at 1 arcmin radius.
	# Then a perfect collimator/camera is assumed to magnify the telescope
	#	focal plane to a different f/ratio with no intrinsic curvature.


	# Print inputs
	print (dpri," meter F/",ftel)
	print ("Wavelength (m):                             ",lambda)
	print ("Physical pixel size (m):                    ",ppixel)

	# Sign of focal plane curvature doesn't count
	sagabs = abs(sag1)

	# Calculate size of the isoplanatic patch
	# Scale input according to wavelength
	ipatch = isovis * (lambda / 0.5e-6)**1.2
	print ("Isoplanatic Patch (arcmin):                 ", ipatch)

	# Calculate size of seeing limited pixel in arcsec
	# Scale input according to wavelength
	iseeing = seeing * (lambda / 0.5e-6)**-0.2
	spixel = iseeing / sample
	print ("Seeing limited pixel size (arcsec):         ", spixel)

	# Calculate camera focal ratio for seeing limited pixels
	scam = 206264.8 / dpri * ppixel / spixel
	print ("Seeing limited camera focal ratio:          ", scam)

	# Depth of focus -- seeing limited (20% degradation)
	sfocus = 0.2 * scam * ppixel
#	print ("Seeing limited depth of focus +-(m):        ", sfocus)

	# Calculate maximum field radius within seeing depth of focus
	# What radius is the focal plane sag twice the depth of focus?
	srad = ( 0.4 * ftel * ftel * ppixel / scam / sagabs )**0.5
	print ("Seeing limited maximum radius (arcmin):     ", srad)	

	# Calculate number of pixels across this field
	snum = srad * 60.0 / spixel
	print ("Seeing limited field radius (pixels):       ", snum)

	# Calculate size of diffraction limited pixel in arcsec
	dpixel = 2.4 * lambda / dpri / sample * 206264.8
	print ("Diffraction limited pixel (arcsec):         ", dpixel)

	# Calculate camera focal ratio for diffraction limited pixels
	dcam = 206264.8 / dpri * ppixel / dpixel
	print ("Diffraction limited camera focal ratio:     ", dcam)

	# Depth of focus -- diffraction limited  (80% Strehl)
	dfocus = 2.0 * dcam * dcam * lambda
#	print ("Diffraction limited depth of focus +-(m):   ", dfocus)

	# Calculate maximum radius within diffraction depth of focus
	# What radius is the focal plane sag twice the depth of focus?
	drad = 2.0 * ftel * ( lambda / sagabs )**0.5
	print ("Diffracton limited maximum radius (arcmin): ", drad)	

	# Calculate number of pixels across this field
	dnum = drad * 60.0 / dpixel
	print ("Diffraction limited field radius (pixels):  ", dnum)
end

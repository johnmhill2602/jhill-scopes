real sep
real spupil
real mpupil

	for ( sep=7.6; sep<=11.6; sep=sep+0.05 ) {
	 # entrance pupil position relative to primary vertex
	 spupil = 1.0d0 / ( 1.0d0 / 9.6d0 - 1.0d0 /  sep )

	 # pupil magnification,
	 #    assume Gregorian pupil magnification is negative
	 mpupil = - spupil / sep
	print ( sep, spupil, mpupil )
	}

# Procedure for Calculating First Order Telescope Parameters from
#	Various Design Inputs
# Version 05JUL90
# Version 06FEB91  Added missing code when designing from fs and l2.
# Version 07FEB91  Attempt to use alpha2 to calculate magn.
# Version 04AUG92  Change gregorian sign from magn to fs
# Version 20OCT93  Added afocal option.
# Version 16OCT97  changed INDEF to INDEFD for V2.11

procedure first_order

include "cass_common.h"

double	junkvar

begin

#  primary focal length
        l1 = d1 * f1
        call wout ( l1, "primary focal length (m)" )

#  Attempt to calculate fs, ls, magn, sep, eve based on available input.

        if( styp == 0.0d0 ) {
	    ls = l1     	# prime focus
	    call wout ( ls, "system focal length (m)" )
	}

	else if ( styp == 1.0d0 ) {
	    ls = l1		# newtonian focus
	    magn = 1.0d0
	    call wout ( ls, "system focal length (m)" )
            call wout ( magn, "magnification of secondary" )
	}


#  decide which of the input design parameters to be used

        else if ( fs == 0.0d0 ) {
	   # calculate the afocal option
	   
	   magn = afbeam / d1
	   call wout ( magn, "magnification of secondary" )

	   ls = 0.0
	   call wout ( ls, "system focal length is infinite (m)" )

	}

	else if ( fs != INDEFD && eve != INDEFD ) {
	# calculate sep (and later l2) the old way

	    call printf ( "  solving based on fs and eve\n" )
	    call flush (STDOUT)


	    if ( rnum == 3.0d0 ) {
		eve = abs ( verd ) - vt
		call wout ( eve, "effective vertex distance (m)" )
	    }

	    magn = fs / f1
	    call wout ( magn, "magnification of secondary" )

	    ls = magn * l1
	    call wout ( ls, "system focal length (m)" )

	# other code already takes care of this

	}

	else if ( fs != INDEFD && l2 != INDEFD ) {
	# calculate the implied sep and eve

	    call printf ( "  solving based on fs and l2\n" )
	    call flush (STDOUT)

	    if ( rnum > 3.0d0 ) {
		call printf ("Insufficient design parameters specified.\n")
		call flush (STDOUT)
		return
	    }

	    magn = fs / f1
            call wout ( magn, "magnification of secondary" )

	    ls = magn * l1
	    call wout ( ls, "system focal length (m)" )

	    acoef = - magn
	    bcoef = 2.0d0 * ls + l2 * (magn-1.0d0)
	    ccoef = l1 * l2  -  l2 * ls  -  l1 * ls

	    call quadratic_solr ( acoef, bcoef, ccoef, junkvar, sep )

	    call wout ( sep, "separation of m1 and m2 (m)" )
#	    call wout ( junkvar, "the other root" )

	    eve = ls - sep * (1.0d0+magn)
	    call wout ( eve, "effective vertex distance (m)" )
	}

	else if ( l2 != INDEFD && eve != INDEFD ) {
	# calculate the implied sep and fs

	    call printf ( "  solving based on l2 and eve\n" )
	    call flush (STDOUT)


	    if ( rnum > 3.0d0 ) {
		call printf ("Insufficient design parameters specified.\n")
		call flush (STDOUT)
		return
	    }

	    if ( rnum == 3.0d0 )
		eve = abs ( verd ) - vt

	    call wout ( eve, "effective vertex distance (m)" )

	    acoef = 1.0d0
	    bcoef = eve - l1 - 2.0d0 * l2
	    ccoef = l1 * l2  -  l2 * eve  - l1 * eve

	    call quadratic_solr ( acoef, bcoef, ccoef, junkvar, sep )

	    call wout ( sep, "separation of m1 and m2 (m)" )
#	    call wout ( junkvar, "the other root" )

	    magn = ( sep + eve ) / ( l1 - sep )
            call wout ( magn, "magnification of secondary" )

	    fs = f1 * magn
	    call wout ( fs, "system focal ratio" )

	    ls = l1 * magn
	    call wout ( ls, "system focal length (m)" )

	}

	else if (alpha2 != INDEFD && alpha1 == -1.0d0 && l2 != INDEFD) {
	    call printf ("  solving based on alpha2 and l2\n")
	    call flush (STDOUT)

	# solution works only for parabolic primary

	    acoef = alpha2 + 1.0d0
	    bcoef = -2.0d0 * alpha2 + 2.0d0
	    ccoef = alpha2 + 1.0d0

	    call quadratic_solr ( acoef, bcoef, ccoef, magn, junkvar )

	    call wout ( magn, "magnification of secondary" )
#	    call wout ( junkvar, "the other root" )

	    fs = f1 * magn
	    call wout ( fs, "system focal ratio" )

	    ls = l1 * magn
	    call wout ( ls, "system focal length (m)" )

	    acoef = - magn
	    bcoef = 2.0d0 * ls + l2 * (magn-1.0d0)
	    ccoef = l1 * l2  -  l2 * ls  -  l1 * ls

	    call quadratic_solr ( acoef, bcoef, ccoef, junkvar, sep )

	    call wout ( sep, "separation of m1 and m2 (m)" )
#	    call wout ( junkvar, "the other root" )

	    eve = ls - sep * (1.0d0+magn)
	    call wout ( eve, "effective vertex distance (m)" )

	}


	else if (alpha2 != INDEFD && alpha1 == -1.0d0 && eve != INDEFD) {
	    call printf ("  solving based on alpha2 and eve\n")
	    call flush (STDOUT)

	# solution works only for parabolic primary

	    acoef = alpha2 + 1.0d0
	    bcoef = -2.0d0 * alpha2 + 2.0d0
	    ccoef = alpha2 + 1.0d0

	    call quadratic_solr ( acoef, bcoef, ccoef, magn, junkvar )

	    call wout ( magn, "magnification of secondary" )
#	    call wout ( junkvar, "the other root" )

	    fs = f1 * magn
	    call wout ( fs, "system focal ratio" )

	    ls = l1 * magn
	    call wout ( ls, "system focal length (m)" )

	}


	else {
	    call printf ("Insufficient design parameters specified.\n")
	    call flush (STDOUT)
	    return
	}

end

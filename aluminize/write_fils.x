#  WRITE_FILS -- Procedure to write a filaments file
#	and store the results in the specified location.

#  History
#	31JAN91 - Created by J. M. Hill, Steward Observatory

procedure write_fils (tfilename, pp, numfils, iverb)

char	tfilename[ARB]		# name of the filaments file
pointer pp			# pointer to filament array
int	numfils			# number of filaments
int	iverb			# output verbosity flag

include "filament.h"		# memory and parameter definitions

#  Local Variables

int	ll			# loop index for writing records
int	tfd			# file descriptor

#  Functions
int	open()

begin

# Introduction
	if (iverb >= 4) {
	    call printf ("WRITE_FILS:  Writing filaments file: %s\n")
		call pargstr(tfilename)
	    call flush (STDOUT)
	}

# Open filaments file
	tfd = open (tfilename, WRITE_ONLY, TEXT_FILE)

# Loop to write the header records
	for (ll=1; ll<=numfils; ll=ll+1) {

	    call fprintf (tfd, "%4u  %12.4f %12.4f %12.4f\n")
		call pargl (KF(pp,ll))
		call pargr (XA(pp,ll))
		call pargr (YA(pp,ll))
		call pargr (ZA(pp,ll))

	}	# end of for loop

	if (iverb >= 6) {
	    call printf ("WRITE_FILS:  Wrote %4u filaments.\n")
		call pargi (numfils)
	    call flush (STDOUT)
	}

# Close the filaments file
	call close (tfd)

end

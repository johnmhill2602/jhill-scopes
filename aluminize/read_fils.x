#  READ_FILS -- Procedure to read a filaments file
#	and store the results in the specified location.

#  History
#	24JAN91 - Created by J. M. Hill, Steward Observatory
#	29JAN91 - Require nscan = 4 for minimum line.

int procedure read_fils (tfilename, pp, iverb)

char	tfilename[ARB]		# name of the filaments file
pointer pp			# pointer to filament array
int	iverb			# output verbosity flag

include "filament.h"		# memory and parameter definitions

#  Local Variables

int	ll			# loop index for reading records
int	tfd			# file descriptor

#  Functions
int	open()
int	fscan()
int	nscan()

begin

# Introduction
	if (iverb >= 4) {
	    call printf ("READ_FILS:  Reading filaments file: %s\n")
		call pargstr(tfilename)
	    call flush (STDOUT)
	}

# Record counter used for error messages
	ll = 0		# initialize record counter

# Open filaments file
	tfd = open (tfilename, READ_ONLY, TEXT_FILE)

# Loop to read the header records
	while (fscan (tfd) != EOF) {
	    call gargl (KF(pp,ll+1))
	    call gargr (XA(pp,ll+1))
	    call gargr (YA(pp,ll+1))
	    call gargr (ZA(pp,ll+1))

	# Check for the minimum useful line of data
	    if (nscan() < 4)
		break

	# Increment the filament counter
	    ll = ll + 1

	    if (iverb >= 5) {
		call printf ("READ_FILS:  %4u X=%6.2f Y=%6.2f Z=%6.2f\n")
		    call pargl (KF(pp,ll))
		    call pargr (XA(pp,ll))
		    call pargr (YA(pp,ll))
		    call pargr (ZA(pp,ll))
		call flush (STDOUT)
	    }

	# Have we filled the whole array?
	    if (ll >= MAXFIL)
		break

	}	# end of while loop

	if (iverb >= 6) {
	    call printf ("READ_FILS:  Read %4u filaments.\n")
		call pargi (ll)
	    call flush (STDOUT)
	}

# Close the filaments file
	call close (tfd)

	return (ll)
end

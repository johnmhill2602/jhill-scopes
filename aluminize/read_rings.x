#  READ_RINGS -- Procedure to read a rings file
#	and store the results in the specified location.

#  History
#	31JAN91 - Created by J. M. Hill, Steward Observatory
#	29JAN91 - Require nscan = 4 for minimum line.
#	08FEB91 - Add azimuth offset for filaments.

int procedure read_rings (tfilename, pp, iverb)

char	tfilename[ARB]		# name of the rings file
pointer pp			# pointer to ring array
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
	    call printf ("READ_RINGS:  Reading rings file: %s\n")
		call pargstr(tfilename)
	    call flush (STDOUT)
	}

# Record counter used for error messages
	ll = 0		# initialize record counter

# Open rings file
	tfd = open (tfilename, READ_ONLY, TEXT_FILE)

# Loop to read the header records
	while (fscan (tfd) != EOF) {
	    call gargl (KR(pp,ll+1))
	    call gargl (RNUM(pp,ll+1))
	    call gargr (RRAD(pp,ll+1))
	    call gargr (RHITE(pp,ll+1))
	    call gargr (ROFF(pp,ll+1))

	# Check for the minimum useful line of data
	    if (nscan() < 4)
		break

	# Increment the ring counter
	    ll = ll + 1

	    if (iverb >= 5) {
		call printf ("READ_RINGS:  %4u rnum=%6u  R=%6.2f  Z=%6.2f  off=%5.2f\n")
		    call pargl (KR(pp,ll))
		    call pargl (RNUM(pp,ll))
		    call pargr (RRAD(pp,ll))
		    call pargr (RHITE(pp,ll))
		    call pargr (ROFF(pp,ll))
		call flush (STDOUT)
	    }

	# Have we filled the whole array?
	    if (ll >= MAXRIN)
		break

	}	# end of while loop

	if (iverb >= 6) {
	    call printf ("READ_RINGS:  Read %4u rings.\n")
		call pargi (ll)
	    call flush (STDOUT)
	}

# Close the rings file
	call close (tfd)

	return (ll)
end

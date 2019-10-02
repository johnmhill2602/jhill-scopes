# FILAMENTS -- Task to generate filament position files.

include <time.h>

procedure t_filaments()

.help
#  History
#	17JAN91 - Created by J. M. Hill, Steward Observatory
#	31JAN91 - First functional code.
#	08FEB91 - Added filament offset.

Future Improvements
	Add parameters for baffles.
	Allow random filament position errors.
.endhelp

#  Include memory allocation and parameters
include	"filament.h"

#  Local Variables
pointer	rfile
pointer	fifile
int	verbosity

string	version	"08-FEB-91"	# version Date of Code
char	time[SZ_TIME]

int	numrings, numfils
int	jj, kk
real	radius, angle

pointer  sp, ff, rr

errchk	salloc, open

#  Function Declarations
long	clktime()
int	clgeti()
int	read_rings()

begin

#  Introduce Program
	call printf ("FILAMENTS Aluminizing Program, SPP Version of %s\n")
		call pargstr (version)

#  Get Date and Time
	call cnvtime (clktime(0), time, SZ_TIME)
	call printf ("       Executed on: %s\n")
		call pargstr (time)

	call flush (STDOUT)

#  Allocate Memory
	call smark (sp)

	call salloc (fifile, SZ_FNAME+1, TY_CHAR)
	call salloc (rfile, SZ_FNAME+1, TY_CHAR)

#  Get Task Parameters
	call clgstr ("fifile", Memc[fifile], SZ_FNAME)
	call clgstr ("rfile", Memc[rfile], SZ_FNAME)
	verbosity = clgeti ("verbosity")


#  Allocate memory for filaments.
	call salloc (ff, LEN_FILARRAY, TY_STRUCT)
	call salloc (rr, LEN_RINARRAY, TY_STRUCT)

#  Read the Ring File
	numrings = read_rings (Memc[rfile], rr, verbosity)

#  Generate the filament positions.
	numfils = 0

	for (jj=1; jj<=numrings; jj=jj+1) {

	    for (kk=1; kk<=RNUM(rr,jj); kk=kk+1) {	
		numfils = numfils + 1
		KF(ff,numfils) = numfils
		radius = RRAD(rr,jj)
		angle = (real(kk-1)+ROFF(rr,jj))/RNUM(rr,jj) * 2.0*acos(-1.0)

		XA(ff,numfils) = radius * cos (angle)
		YA(ff,numfils) = radius * sin (angle)
		ZA(ff,numfils) = RHITE(rr,jj)

	     }	# end of loop around the ring

	}	# end of loop over rings


#  Write the filament file.
	call write_fils (Memc[fifile], ff, numfils, verbosity)

#  Say Goodbye
	call printf ("FILAMENTS is complete.\n")

	call sfree (sp)

end

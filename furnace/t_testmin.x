
# TESTMIN -- automatic generator of ograph scripts

include	<time.h>

procedure t_TESTMIN()

.help
#  Description
	TESTMIN is a text-processor to automatically generate an ograph
#  History
	
#  Future Work

.endhelp

#  Parameter declarations
long	date                # Input files
long    offset

#  Variable Declarations
#char	time[SZ_TIME]

string  version	"10-FEB-00"		# version date of code
long datem, datel, timel


# declare functions
long	clgetl()
long	date_to_m()

begin

	date = clgetl ("date")
	offset = clgetl ("offset")

	datem = date_to_m (date)

	call minutes_to_dt ( datem, datel, timel)

    call printf ("#TESTMIN:  Read date: %06d, Minutes: %d, Converted date: %06d\n")
		call pargl (date)
		call pargl (datem)
		call pargl (datel)
	    call flush (STDOUT)

	datem = datem + offset

	call minutes_to_dt ( datem, datel, timel)

    call printf ("#TESTMIN:  Read offset: %d, Minutes: %d, Converted date: %06d %04d\n")
		call pargl (offset)
		call pargl (datem)
		call pargl (datel)
		call pargl (timel)
	    call flush (STDOUT)


end

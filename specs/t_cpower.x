# CPOWER -- Task to combine a list of number via a specified exponent

include <time.h>
include <error.h>

procedure t_cpower()

.help
# Description
This task reads a file or a list of numbers from STDIN.
The list of numbers is combined according to the parameter "power"
which specifies the exponent to be used in the combination.
For example, power=1 adds the list; power=2 combines the list quadratically.
At this level, I've written a really bad calculator.
This task was specifically written to combine r0 values with the -5/3
power.

Result = [x1**power + x2**power + x3** power + .....]**(1/power)

Note that negative number are subtracted from the total using
their absolute value.  That means this can't be used to compute
the rms of a list which contains negative numbers.

Enter a EOF (^Z) to terminate input.
The result is saved as a cl parameter.

#  History
#	05MAY92 - Created in SPP by J. M. Hill, Steward Observatory
.endhelp

#  Include memory allocation and parameters

#  Local Variables
pointer	infile, fd		# input file name, descriptor
double  power
int	verbosity		# quantity of info to print

double  sum, new, result
int     nxy

string	version	"05-MAY-92"	# version Date of Code
char	time[SZ_TIME]

pointer  sp

errchk	salloc, open

#  Function Declarations

long	clktime()
int	clgeti()
double	clgetd()
int	open()
int	nscan()
int     fscan()

begin

#  Introduce Program
   call printf ("CPOWER Function Program, SPP Version of %s\n")
       call pargstr (version)

#  Get Date and Time
   call cnvtime (clktime(0), time, SZ_TIME)
   call printf ("       Executed on: %s\n")
       call pargstr (time)

   call flush (STDOUT)

#  Allocate Memory
   call smark (sp)
   call salloc (infile, SZ_FNAME, TY_CHAR)

#  Get Task Parameters
   call clgstr ("infile", Memc[infile], SZ_FNAME)

   power = clgetd ("power")
   verbosity = clgeti ("verbosity")

   sum = 0.0d0
   result = 0.0d0
      
      call printf ("CPOWER:  Reading input list from %s, (EOF to quit)\n")
       call pargstr (Memc[infile])
   call flush (STDOUT)
   
#  Read in the input list
   iferr ( fd = open(Memc[infile],READ_ONLY,TEXT_FILE) ) {
      call eprintf("cannot open input file\n")
      call erract ( EA_FATAL )
   }

   # read the text file
   nxy = 0   # point counter
   
   while ( fscan(fd) != EOF ) {
      nxy = nxy + 1
      call gargd (new)
      if ( nscan() < 1 ) {
	 call eprintf("insufficient data - discarding\n")
	 nxy = nxy - 1
	 next
      }
      if (new > 0.0d0) {
	 sum = sum + new**power
	 result = sum**(1.0d0/power)
      }
      else if (new < 0.0d0) {
	 new = -new
	 sum = sum - new**power
	 result = sum**(1.0d0/power)
      }
      if (verbosity >= 4) {
	 call printf ("read: %9.4f,  value: %9.4f,  sum: %9.4f,  result: %10.4f\n")
	     call pargd (new)
	     call pargd (new**power)
	     call pargd (sum)
	     call pargd (result)
	 call flush (STDOUT)
      }
      

   }
   call close ( fd )

   call printf ("CPOWER:  Read %6u points.\n")
       call pargi (nxy)
   call printf ("CPOWER:  Combined to the %.6f power.\n")
       call pargd (power)
   call printf ("CPOWER:  Result: %12.6f\n")
	     call pargd (result)
   call flush (STDOUT)

   call clputd ("result", result)

#  Say Goodbye
	call printf ("CPOWER is complete.\n")

	call sfree (sp)

end

# GZPWR.CL --- graph zone power consumption
#
# This script calls claczpwr to calculate the total hpwr applied by the 
# 	heaters in particular zones.
#	A sum of the hpwr data for all
#	heaters in the specified zone is generated with units of
#	1/4 second power units.  To convert from P.U. to kilowatts,
#	divide by 240 and multiply by 7.5.
# This script graphs a number of these zone vectors

procedure  gzpwr ()

string  datatxt      {prompt="databasc text file of oven database"}
string  hpwrdata     {prompt="Name of hpwr image to process"}
string  zpwrdata     {prompt="Name of output zpwr image"}
string	version="10 June 1997"	{prompt="Version date of this routine"}

begin
	# define variables
	int  ii, jj
	file outfile, midfile, infile, intfile

	infile = hpwrdata // "[1:8,*]"
	outfile = zpwrdata
	imdelete ( outfile, go_ahead=yes, verify=no )
	imcopy ( infile, outfile, verbose=yes )

	midfile = zpwrdata // "[1,*]"
	intfile = "z0_" // zpwrdata
	imdelete ( intfile, go_ahead=yes, verify=no )
	calczpwr ( datatxt, hpwrdata, zone="Z0", zpwrimages=intfile )
	imcopy ( intfile, midfile, verbose=yes )

	midfile = zpwrdata // "[2,*]"
	intfile = "z1_" // zpwrdata
	imdelete ( intfile, go_ahead=yes, verify=no )
	calczpwr ( datatxt, hpwrdata, zone="Z1", zpwrimages=intfile )
	imcopy ( intfile, midfile, verbose=yes )

	midfile = zpwrdata // "[3,*]"
	intfile = "z2_" // zpwrdata
	imdelete ( intfile, go_ahead=yes, verify=no )
	calczpwr ( datatxt, hpwrdata, zone="Z2", zpwrimages=intfile )
	imcopy ( intfile, midfile, verbose=yes )

	midfile = zpwrdata // "[4,*]"
	intfile = "z3_" // zpwrdata
	imdelete ( intfile, go_ahead=yes, verify=no )
	calczpwr ( datatxt, hpwrdata, zone="Z3", zpwrimages=intfile )
	imcopy ( intfile, midfile, verbose=yes )
end


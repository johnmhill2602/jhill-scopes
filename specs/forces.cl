# FORCES.CL -- Compute axial and lateral forces as a function of zenith angle

# Written by J. M. Hill,  Steward Observatory

# Created 05 JAN 90
# Added Decomposition 23 AUG 90

procedure forces(forcelist,result)

file	forcelist	{prompt = 'Input list of forces'}
string	result		{prompt='Output file template'}
real	starta=90	{prompt='highest elevation angle(degrees from horizon)'}
real	stopa=0		{prompt='lowest elevation angle(degrees from horizon)'}
real	incra=15	{prompt='Angle increment(degrees)'}
bool	both=yes	{prompt='Both directions?'}
real	axiala=0	{prompt='Actuator angle 1(degrees from optical axis)'}
real	laterala=-60	{prompt='Actuator angle 2(degrees from optical axis)'}

struct *list1

begin

	#define variables
	int	actnum		# actuator number
	real	faxial		# axial force
	real	caxial		# axial correction
	real	flateral	# lateral force
	real	raxial, maxial, rlateral	# resulant forces
	real	r1, m1, r2, m2			# applied forces
	string	template
	file	fileout
	real	ang, rad	# elevation angle
	real	axrad, larad
	real	degrad=0.0174533

	list1 = forcelist
	template = result

	axrad = axiala * degrad
	larad = laterala * degrad

	while(fscan(list1,actnum,faxial,caxial,flateral) !=EOF) {

		print ("actuator: ",actnum,faxial,caxial,flateral)

		# construct output filename
		fileout = template // str(actnum)

		# check if output spectrum exists
		if( access(fileout) ) {
		    print("Output file already exists: ",fileout)
		}
		else {
		    print("Using file: ",fileout)

	    print("# actuator angle +axial -axial lateral +a1 +a2 -a1 -a2",
			>fileout)

		    # loop over elevation angle
		    for (ang=starta; ang>=stopa; ang=ang-incra) {
	
			# calculate axial, correction and lateral forces
			rad = ang * degrad
			raxial = faxial*sin(rad) + caxial*cos(rad)
			maxial = faxial*sin(rad) - caxial*cos(rad)
			rlateral = flateral*cos(rad)

			# calculate decomposed actuator forces
			# rlateral = r1 * sin(axrad) + r2 * sin(larad)
			# raxial+maxial = r1 * cos(axrad) + r2 * cos(larad)

	r1 = ( cos(larad)*rlateral - sin(larad)*raxial ) /
			( sin(axrad)*cos(larad) - cos(axrad)*sin(larad) )

	r2 = ( cos(axrad)*rlateral - sin(axrad)*raxial ) /
			( sin(larad)*cos(axrad) - cos(larad)*sin(axrad) )

	m1 = ( cos(larad)*rlateral - sin(larad)*maxial ) /
			( sin(axrad)*cos(larad) - cos(axrad)*sin(larad) )

	m2 = ( cos(axrad)*rlateral - sin(axrad)*maxial ) /
			( sin(larad)*cos(axrad) - cos(larad)*sin(axrad) )


	print(actnum,ang,raxial,maxial,rlateral,r1,r2,m1,m2, >>fileout)

		    }	# end of angle loop
	
		}	# end of else block

	}	# end of while loop

	list1 = ""

end

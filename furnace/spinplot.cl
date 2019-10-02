# SPINPLOT.CL --- script to plot ovenr rotation speed data
#
# updated to strip integers down to 7-digits with awk command

procedure spinplot()

begin
   string s1, s2, azero
   int i, s3, s4, ifirst, ilast

   head (rfile, nlines=1) | scan (s1)	
   print ("Initial absolute time is: ", s1)
   tail (rfile, nlines=1) | scan (s2)	
   print ("Final absolute time is: ", s2)

   if ( strlen(izero) > 0 ) {
	azero = izero
   } else {
	azero = s1
   }
   print("Subtracting absolute time: ",azero)

   # delete the old temporary speed file	
   delete (tfile, verify=no)
		
   # use awk to strip the time values down to 7-digits that IRAF can handle
   # print the command	
   print ("!cat ",rfile," | awk '{ print $1-", azero, ", $2 }' >", tfile)
   # execute the command
   print ("!cat ",rfile," | awk '{ print $1-", azero, ", $2 }' >", tfile) | cl

   head (tfile, nlines=1) | scan (s3)	
   print ("Initial relative time is: ", s3)
   tail (tfile, nlines=1) | scan (s4)	
   print ("Final relative time is: ", s4)



   # if istart not specified, use first value in file
   # if istart is negative, use it as offset from the end of file
   if ( istart == INDEF ) {
	ifirst=s3
   } else if ( istart < 0 ) {
	ifirst=s4+istart
   } else {
	ifirst=istart
   }

   if ( istop == INDEF ) {
	ilast=s4
   } else {
        ilast=istop
   }
   print ("Plotting from ", ifirst, " to ", ilast)

   # loop and make a series of graphs
   for (i=ifirst; i<ilast; i=i+iincr) {
      print (i)
      graph (input=tfile, mode=h, device=device, append=append,
		wx1=i, wx2=i+iincr, wy1=rmin, wy2=rmax, ylabel="milliRPM")
      # can't have the gflush if you want to append overplots
      # gflush
   }
end



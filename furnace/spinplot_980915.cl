# SPINPLOT.CL --- script to plot ovenr rotation speed data
#
# You must trim the rspeed data file down to 7-digit integers with emacs

procedure spinplot()

begin

   for (i=istart; i<=istop; i=i+iincr) {
      print (i)
      graph (input=rfile, mode=h, device=device, 
		wx1=i, wx2=i+iincr, wy1=rmin, wy2=rmax)
      gflush
   }
end



# SPINPLOT.CL --- script to plot ovenr rotation speed data
#

procedure spinplot()

begin

   #make a temporary file
   !rm /tmp/rspeed_tempv0
   !rm /tmp/rspeed_tempv2

   # You must trim the rspeed data file down to 7-digit integers
   !sed -e "s/1206//" /home/pilot/rspeed.oven0v0 > /tmp/rspeed_tempv0
   !sed -e "s/1206//" /home/pilot/rspeed.oven0v2 > /tmp/rspeed_tempv2

   for (i=istart; i<=istop; i=i+iincr) {
      print (i)
      graph (input="/tmp/rspeed_tempv0", mode=h, device=device, 
		wx1=i, wx2=i+iincr, wy1=rmin, wy2=rmax, 
		xlabel="seconds", ylabel="millirpm")
      graph (input="/tmp/rspeed_tempv2", mode=h, device=device, 
		wx1=i, wx2=i+iincr, wy1=rmin, wy2=rmax, 
		xlabel="seconds", ylabel="millirpm", append=yes, color=3)
      gflush
	sleep (2)
   }
end



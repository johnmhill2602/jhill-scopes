print "makevideo.cl version 28MAR08\n"
cd /home/pilot2/public_html/

while (0<1) { # endless loop
cl < makelateE.cl
cl < makelateF.cl
cl < makelateG.cl
cl < makelateB.cl
        sleep 60
	cl < makeliveA.cl
	sleep 60
	cl < makeliveB.cl
	sleep 60
	cl < makeliveC.cl
	sleep 60
	cl < makeliveD.cl
	sleep 60
cl < makelateE.cl
cl < makelateF.cl
cl < makelateG.cl
	sleep 60
	cl < makeliveE.cl
	sleep 60
	cl < makeliveF.cl
	sleep 60
	cl < makeliveG.cl
        sleep 60
  time
}

# file to overplot temperatures of the aluminum tcs
# ograph version by JMH 27FEB92
# you must change date with editor or epar

ograph info1=etmp factor1=1 zone1=z7 info2="" info3="" info4="" append=no

# tc 0231, 1232, 4232
ograph info1="" \\
info2="ttmp" r2=048 th2=355 z2=-10 factor2=1 \\
info3="ttmp" r3=072 th3=342 z3=-10 factor3=1 \\
info4="ttmp" r4=100 th4=356 z4=-10 factor4=1 append=yes

# tc 4234, 4513, 4520
ograph info1="" \\
info2="ttmp" r2=153 th2=353 z2=-10 factor2=1 \\
info3="ttmp" r3=005 th3=270 z3=-10 factor3=1 \\
info4="ttmp" r4=031 th4=126 z4=-10 factor4=1 append=yes

# tc 5501, 5502, 5511
ograph info1="" \\
info2="ttmp" r2=195 th2=336 z2=-10 factor2=1 \\
info3="ttmp" r3=180 th3=354 z3=-10 factor3=1 \\
info4="ttmp" r4=037 th4=303 z4=-10 factor4=1 append=yes

# tc 5522, 5523, 5524
ograph info1="" \\
info2="ttmp" r2=032 th2=352 z2=-10 factor2=1 \\
info3="ttmp" r3=135 th3=331 z3=-10 factor3=1 \\
info4="ttmp" r4=135 th4=359 z4=-10 factor4=1 append=yes

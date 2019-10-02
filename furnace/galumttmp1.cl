# file to overplot temperatures of the aluminum tcs
# ograph version by JMH 27FEB92
# you must change date with editor or epar

ograph info1=etmp factor1=1 zone1=z7 info2="" info3="" info4="" append=no

# These are aluminum TCs with radius less than 32 inches.

# tc 4502, 4513, 5503
ograph info1="" \\
info2="ttmp" r2=005 th2=090 z2=-10 factor2=1 \\
info3="ttmp" r3=005 th3=270 z3=-10 factor3=1 \\
info4="ttmp" r4=014 th4=270 z4=-10 factor4=1 append=yes

# tc 4230, 5231, 4501
ograph info1="" \\
info2="ttmp" r2=017 th2=090 z2=-10 factor2=1 \\
info3="ttmp" r3=023 th3=270 z3=-10 factor3=1 \\
info4="ttmp" r4=026 th4=279 z4=-10 factor4=1 append=yes

# tc 1230, 4520, 5520
ograph info1="" \\
info2="ttmp" r2=031 th2=054 z2=-10 factor2=1 \\
info3="ttmp" r3=031 th3=126 z3=-10 factor3=1 \\
info4="ttmp" r4=032 th4=007 z4=-10 factor4=1 append=yes

# tc 0230, 4231, 5522
ograph info1="" \\
info2="ttmp" r2=032 th2=173 z2=-10 factor2=1 \\
info3="ttmp" r3=032 th3=287 z3=-10 factor3=1 \\
info4="ttmp" r4=032 th4=353 z4=-10 factor4=1 append=yes

# file to overplot temperatures of the aluminum tcs
# ograph version by JMH 03MAR92
# you must change date with editor or epar

ograph info1=etmp factor1=1 zone1=z7 info2="" info3="" info4="" append=no

# These are aluminum TCs with radius between 131 and 195 inches

# tc 5233, 5523, 5524
ograph info1="" \\
info2="ttmp" r2=131 th2=349 z2=-10 factor2=1 \\
info3="ttmp" r3=135 th3=331 z3=-10 factor3=1 \\
info4="ttmp" r4=135 th4=359 z4=-10 factor4=1 append=yes

# tc 1233, 5500, 5234
ograph info1="" \\
info2="ttmp" r2=150 th2=332 z2=-10 factor2=1 \\
info3="ttmp" r3=152 th3=343 z3=-10 factor3=1 \\
info4="ttmp" r4=153 th4=333 z4=-10 factor4=1 append=yes

# tc 4234, 5510, 5521
ograph info1="" \\
info2="ttmp" r2=153 th2=353 z2=-10 factor2=1 \\
info3="ttmp" r3=173 th3=345 z3=-10 factor3=1 \\
info4="ttmp" r4=176 th4=344 z4=-10 factor4=1 append=yes

# tc 0234, 5502, 5513
ograph info1="" \\
info2="ttmp" r2=178 th2=336 z2=-10 factor2=1 \\
info3="ttmp" r3=180 th3=354 z3=-10 factor3=1 \\
info4="ttmp" r4=186 th4=359 z4=-10 factor4=1 append=yes

# tc 5501, 1234
ograph info1="" \\
info2="ttmp" r2=195 th2=336 z2=-10 factor2=1 \\
info3="ttmp" r3=195 th3=345 z3=-10 factor3=1 \\
info4="" append=yes

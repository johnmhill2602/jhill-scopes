# file to overplot temperatures of the aluminum tcs
# ograph version by JMH 03MAR92
# you must change date with editor or epar

ograph info1=etmp factor1=1 zone1=z7 info2="" info3="" info4="" append=no

# These are aluminum TCs with radius between 50 and 123 inches

# tc 4503, 4514, 4524
ograph info1="" \\
info2="ttmp" r2=050 th2=026 z2=-10 factor2=1 \\
info3="ttmp" r3=050 th3=206 z3=-10 factor3=1 \\
info4="ttmp" r4=058 th4=347 z4=-10 factor4=1 append=yes

# tc 1232, 5504, 5232
ograph info1="" \\
info2="ttmp" r2=072 th2=342 z2=-10 factor2=1 \\
info3="ttmp" r3=073 th3=332 z3=-10 factor3=1 \\
info4="ttmp" r4=087 th4=358 z4=-10 factor4=1 append=yes

# tc 0232, 4232, 4233
ograph info1="" \\
info2="ttmp" r2=100 th2=334 z2=-10 factor2=1 \\
info3="ttmp" r3=100 th3=356 z3=-10 factor3=1 \\
info4="ttmp" r4=105 th4=336 z4=-10 factor4=1 append=yes

# tc 5514, 0233, 5512
ograph info1="" \\
info2="ttmp" r2=106 th2=348 z2=-10 factor2=1 \\
info3="ttmp" r3=120 th3=358 z3=-10 factor3=1 \\
info4="ttmp" r4=123 th4=342 z4=-10 factor4=1 append=yes

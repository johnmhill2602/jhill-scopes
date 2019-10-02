# file to overplot temperatures of the aluminum tcs
# ograph version by JMH 03MAR92
# you must change date with editor or epar

ograph info1=etmp factor1=1 zone1=z7 info2="" info3="" info4="" append=no

# These are aluminum TCs with radius between 37 and 48 inches

# tc 4522, 4521, 4500
ograph info1="" \\
info2="ttmp" r2=037 th2=057 z2=-10 factor2=1 \\
info3="ttmp" r3=037 th3=123 z3=-10 factor3=1 \\
info4="ttmp" r4=037 th4=237 z4=-10 factor4=1 append=yes

# tc 5511, 5230, 4512
ograph info1="" \\
info2="ttmp" r2=037 th2=303 z2=-10 factor2=1 \\
info3="ttmp" r3=048 th3=005 z3=-10 factor3=1 \\
info4="ttmp" r4=048 th4=085 z4=-10 factor4=1 append=yes

# tc 4504, 4523, 4511
ograph info1="" \\
info2="ttmp" r2=048 th2=095 z2=-10 factor2=1 \\
info3="ttmp" r3=048 th3=175 z3=-10 factor3=1 \\
info4="ttmp" r4=048 th4=185 z4=-10 factor4=1 append=yes

# tc 1231, 4510, 0231
ograph info1="" \\
info2="ttmp" r2=048 th2=265 z2=-10 factor2=1 \\
info3="ttmp" r3=048 th3=275 z3=-10 factor3=1 \\
info4="ttmp" r4=048 th4=355 z4=-10 factor4=1 append=yes

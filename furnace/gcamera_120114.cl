# Script to plot new camera temperatures for GMT2
# JMH and BEP 14-JAN-2012
#
# task $gcamera = home$gcamera.cl

# Cam  1    3    4    5
# dntx 2311 1133 0200 3302
ograph noven=0 \\
info1="ttmp" r1=168 th1=353 z1=099 \\
info2="ttmp" r2=165 th2=100 z2=099 \\
info3="ttmp" r3=165 th3=213 z3=099 \\
info4="ttmp" r4=188 th4=233 z4=099 

# Cam  6    7
# dntx 3014 2020
ograph noven=0 \\
info1="ttmp" r1=188 th1=353 z1=099 \\
info2="ttmp" r2=168 th2=098 z2=099 \\
info3="" \\
info4="" 

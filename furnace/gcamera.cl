# Script to plot new camera temperatures for GMT2
# JMH and BEP 14-JAN-2012 GMT2
# Updated for GMT4 JMH 18-JAN-2015
#
# task $gcamera = home$gcamera.cl

# Cam  1    2    3    4
ograph noven=0 \\
info1="ttmp" r1=168 th1=344 z1=099 \\
info2="ttmp" r2=200 th2=292 z2=036 \\
info3="ttmp" r3=165 th3=100 z3=099 \\
info4="ttmp" r4=160 th4=175 z4=099 

# Cam  5   6    7
ograph noven=0 \\
info1="ttmp" r1=188 th1=233 z1=099 \\
info2="ttmp" r2=188 th2=353 z2=099 \\
info3="ttmp" r3=200 th3=113 z3=099 \\
info4="" 

# file to overplot temperatures of the aluminum tcs
# ograph version by JMH 20FEB92
# you must change date with editor or epar

ograph.info2=""
ograph.info3=""
ograph.info4=""
ograph.factor1=1
ograph.factor2=1
ograph.factor3=1
ograph.factor4=1
ograph info1=etmp zone1=z6 append=no

ograph.info1=""
ograph.info2="ttmp"
ograph.z2=-10
ograph.info3="ttmp"
ograph.z3=-10
ograph.info4="ttmp"
ograph.z4=-10
ograph.append=yes

# tc 4502, 4513, 5503
#ograph r2=005 th2=090  r3=005 th3=270  r4=014 th4=270
# tc 4230, 5231, 4501
#ograph r2=017 th2=090  r3=023 th3=270  r4=026 th4=279
# tc 1230, 4520, 5520
#ograph r2=031 th2=054  r3=031 th3=126  r4=032 th4=007
# tc 0230, 4231, 5522
#ograph r2=032 th2=173  r3=032 th3=287  r4=032 th4=353

# tc 0231, 1232, 4232
ograph r2=048 th2=355  r3=072 th3=342  r4=100 th4=356
# tc 4234, 4513, 4520
ograph r2=153 th2=353  r3=005 th3=270  r4=031 th4=126
# tc 5501, 5502, 5511
ograph r2=195 th2=336  r3=180 th3=354  r4=037 th4=303
# tc 5522, 5523, 5524
ograph r2=032 th2=352  r3=135 th3=331  r4=135 th4=359

ograph.append=no

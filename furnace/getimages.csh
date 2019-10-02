#!/bin/csh
# copy oven video images from crater to medusa
# in the past we ran this from abell to minimize Solaris 2.4 versus 
# Solaris 2.6 problems
#
# version 19 July 2005
cp -p /home/pilot/public_html/video*.gif /net/medusa/d0/ftp/pub/oven/
cp -p /home/pilot/public_html/temperature /net/medusa/d0/ftp/pub/oven/
cp -p /home/pilot/public_html/frame*.gif /net/medusa/d0/ftp/pub/oven/
cp -p /home/pilot/public_html/ifrd*.gif /net/medusa/d0/ftp/pub/oven/

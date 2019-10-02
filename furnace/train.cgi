#!/usr/bin/perl
#
# train - whistles gratuitously
#
# call as a cgi script
#
# Copyright (C) 2013 by J. M. Hill
# Created at Steward Observatory 
# Argument sets the refresh time in seconds, 20>
#
$version = "23AUG13";

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

system("cat /usr/demo/SOUND/sounds/train.au > /dev/audio");
sleep(1);
system("cat /usr/demo/SOUND/sounds/train.au > /dev/audio");

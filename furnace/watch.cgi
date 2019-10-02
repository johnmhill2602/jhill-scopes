#!/usr/bin/perl
#
# watch -- watch the oven error log and make a noise when something is added
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

# configuration
$path = "/home/pilot/errors.log";
$cmd = "/usr/bin/wc ";

print "Whistles when something appears in $path \n";

# Use wc to check the size of errors.log
@initialmatches = `$cmd $path`;

print "Size $initialmatches[0] \n";

# Loop forever until a ^C
while ( 1 > 0 ) {
	sleep(30); # wait 30 seconds
	@matches = `$cmd $path`;
	print "Size $matches[0] \n";
	if ($matches[0] > $initialmatches[0]) { 
		system("cat /usr/demo/SOUND/sounds/train.au > /dev/audio");
		sleep(1);
		system("cat /usr/demo/SOUND/sounds/train.au > /dev/audio");
		$initialmatches[0] = $matches[0];
	} # end if
} # end infinite while

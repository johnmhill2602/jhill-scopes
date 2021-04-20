#!/usr/bin/perl
#
# plot -- page for latest oven temperature plot
#
# call as a cgi script
#
# Copyright (C) 1997 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 12SEP98
# First Argument is the image name
# Second Argument sets the refresh time in seconds, 30>
#
$version = "08MAR21";

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

# introduction
print "Content-type: text/html\n\n";

print "<head>\n";
print "<title>$picture</title>\n";

# automatic page refresh
($picture, $refreshtime) = (split (/&/, $ARGV[0]));
$minrefresh = 20;
if ( $refreshtime > 0 && $refreshtime < $minrefresh ) {  # avoid too fast refresh
    $refreshtime = $minrefresh;
}
if ( $refreshtime >= $minrefresh ) {  # set auto refresh
    print "<meta http-equiv=\"Refresh\" content=\"$refreshtime\">\n";
}

print "</head>\n";

print "<table width=\"100%\" border=1 cellpadding=5>\n";
print "<tr>\n";
print "<td align=middle width=\"20%\">\n";
print "<img src=\"$picture\"></a>\n";
print "</td>\n";
print "</tr>\n";
print "</table>\n<p>\n";

print "GMT6 8.4m honeycomb mirror<br>\n";
print freshness($picture);
print "&nbsp; $picture<br>\n";
if ( $refreshtime >= $minrefresh ) {print "Auto refresh time = $refreshtime seconds.<br>\n"};
print "<p>\n";

#######################################################################################

sub freshness {
# subroutine to get file stats and format them into a string
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
     $atime,$mtime,$ctime,$blksize,$blocks) = stat(@_);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);

$sizea = int($size / 1000) . " kB" ;

# Prepad the month
if ($mon < 9) {$month = "0" . ($mon+1);}
else    {$month = $mon+1;}

# Prepad the day
if ($mday < 10){ $day = "0" . $mday;}
else {$day = $mday;}

# $year is number of years since 1900
if ($year > 99) {$year = $year - 100;}

# Prepad the year
if ($year < 10) {$syear = "0" . ($year);}
                 else {$syear = $year;}

# Prepad the hour
if ($hour < 10) {$shour = "0" . ($hour);}
else {$shour = $hour;}

# Prepad the minute
if ($min < 10) {$smin = "0" . ($min);}
else {$smin = $min;}

$datea = $month . "/" . $day . "/" . $syear . " " ;
$timea = $shour . ":" . $smin . " MST " ;
$freshness = $datea . $timea . $sizea ;
}

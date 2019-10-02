#!/usr/bin/perl
#
# latestp -- page for latest oven images and temperatures.
#
# call as a cgi script
#
# Copyright (C) 1997 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 14JUN97
# Argument sets the refresh time in seconds, 20>
#
$version = "16SEP15";

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

$path = "";

$infoname = "temperature";

$tempname = $path . $infoname;

$plot0name = "frame0.gif";
$plot1name = "frame1.gif";
$plot2name = "frame2.gif";
$plot3name = "frame3.gif";
$plot4name = "frame4.gif";
$plot5name = "frame5.gif";

# introduction
print "Content-type: text/html\n\n";

print "<head>\n";
print "<title>Latest Temperature Plots from the Furnace</title>\n";

if ( $ARGV[0] gt 19 ) {  # avoid too fast refresh
   print "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"$ARGV[0]\">\n"
};

print "</head>\n";

print "<body background=\"yellow.gif\" bgcolor=\"#FFFFFF\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

print "<table width=\"100%\" border=1 cellpadding=5>\n";

print "<td align=middle width=\"20%\" colspan=3>\n";

print "<center><font size=4><a href=\"http://www.as.arizona.edu\">University of Arizona</a>&nbsp;&nbsp;\n";
print "<a href=\"http://mirrorlab.arizona.edu\">Richard F. Caris Mirror Lab</a> &nbsp;&nbsp;\n";
print "<a href=\"\">VGT1</a> &nbsp;&nbsp;Sixth 6.5m Mirror<br>\n";
print "Latest Temperature Plots from the Furnace:  </font>\n";

    if ( -e $tempname ) {
        ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
                 $atime,$mtime,$ctime,$blksize,$blocks) = stat($tempname);
        ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);

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

        $datet = $month . "/" . $day . "/" . $syear ;
        $timet = $shour . ":" . $smin . " MST" ;

	open(SFILE,$tempname);
	$line = <SFILE>;
	close(SFILE);
	($tlid, $tconei, $tconeo ) = split (' ', $line, 80);
	print "<font size=4>the oven temperature was <b>", $tlid, "</b> degrees C at ", $timet, " on ", $datet, "</font>.</center>\n";
    }

print "</td>\n";
print "</tr>\n";

print "<tr>\n";


print "<td align=middle width=\"20%\">\n";
print "Rotation speed plot from <a href=\"plot_VGT1.cgi?$plot5name&$ARGV[0]\">Last 40 minutes<br>\n";
print "<img src=\"$plot5name\" width=396 height=342></a>\n";
print freshness($plot5name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "Temperature plot from <a href=\"plot_VGT1.cgi?$plot4name&$ARGV[0]\">Last 8 hours<br>\n";
print "<img src=\"$plot4name\" width=396 height=342></a>\n";
print freshness($plot4name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "Temperature plot from <a href=\"plot_VGT1.cgi?$plot3name&$ARGV[0]\">Last 36 hours<br>\n";
print "<img src=\"$plot3name\" width=396 height=342></a>\n";
print freshness($plot3name);
print "</td>\n";

print "</tr>\n";

print "<tr>\n";

print "<td align=middle width=\"20%\">\n";
print "Temperature plot from <a href=\"plot_VGT1.cgi?$plot0name&$ARGV[0]\">Last 12 hours<br>\n";
print "<img src=\"$plot0name\" width=396 height=342></a>\n";
print freshness($plot0name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "Temperature plot from <a href=\"plot_VGT1.cgi?$plot1name&$ARGV[0]\">Last 3 days<br>\n";
print "<img src=\"$plot1name\" width=396 height=342></a>\n";
print freshness($plot1name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "Temperature plot from <a href=\"plot_VGT1.cgi?$plot2name&$ARGV[0]\">Whole casting<br>\n";
print "<img src=\"$plot2name\" width=396 height=342></a>\n";
print freshness($plot2name);
print "</td>\n";


print "</tr>\n";

print "</table>\n<p>\n";


print "\n<HR>\n";



print "\nThis page was generated automatically by J. M. Hill's \"latestp.cgi\" script, version $version.<P>\n";
if ( $ARGV[0] gt 19 ) {  # avoid too fast refresh
   print "Page refresh time = $ARGV[0] seconds.<p>\n"
};

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

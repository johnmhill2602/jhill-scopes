#!/usr/bin/perl
#
# historyp -- page for latest oven images and temperatures.
#
# call as a cgi script
#
# Copyright (C) 1997-2021 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 14JUN97
# Argument sets the refresh time in seconds, 30>
#
$version = "06MAR21";

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

$path = "";

$infoname = "temperature";
$powername = "power";

$tempname = $path . $infoname;

$plot0name = "frame7.png";
$plot1name = "ghigh_gmt1.png";
$plot2name = "ghigh_gmt2.png";
$plot3name = "ghigh_gmt3.png";
$plot4name = "ghigh_gmt4.png";
$plot5name = "ghigh_gmt5.png";
$plot6name = "ghigh_gmt6.png";
$plot7name = "ghigh_lsst.png";
$plot8name = "ghigh_lbt2.png";

# introduction
print "Content-type: text/html\n\n";

print "<head>\n";
print "<title>Historical High Temperature Plots from the Furnace</title>\n";

if ( $ARGV[0] > 29 ) {  # avoid too fast refresh
    print "<meta http-equiv=\"Refresh\" content=\"$ARGV[0]\">\n";
}
print "</head>\n";

#print "<body background=\"yellow.png\" bgcolor=\"#FFFFFF\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

print "<body bgcolor=\"#EEEEEE\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

print "<table width=\"100%\" border=1 cellpadding=5>\n";

print "<td align=middle width=\"20%\" colspan=3>\n";

print "<center><font size=4><a href=\"http://abell.as.arizona.edu/~hill/GMT6\">(home)</a>&nbsp;&nbsp;\n";
print "<font size=4><a href=\"http://www.as.arizona.edu\">University of Arizona</a>&nbsp;&nbsp;\n";
print "<a href=\"http://mirrorlab.arizona.edu\">Richard F. Caris Mirror Lab</a> &nbsp;&nbsp;\n";
print "<a href=\"http://www.gmto.org\">GMT6</a> &nbsp;&nbsp;Ninth 8.4m Mirror<br>\n";
print "Temperature Plots from the Furnace:  </font>\n";

if ( -e $tempname ) {
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks) = stat($tempname);
    ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);

# Prepad the month
    if ($mon < 9) {$month = "0" . ($mon+1);}
    else {$month = $mon+1;}

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
    print "<font size=4>the temperature was <b>", $tlid, "</b> degrees C at ", $timet, " on ", $datet, "</font>;\n";
    }


if ( -e $powername ) {
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
      $atime,$mtime,$ctime,$blksize,$blocks) = stat($powername);
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

    open(SFILE,$powername);
    $line = <SFILE>;
    close(SFILE);
    ($hpwr) = split (' ', $line, 80); # average ticks in last minute
    # convert to equivalent heaters (doesn't compensate aluminum heaters)
    $upower = sprintf "%.3f", $hpwr/240.0*270; # trim to 3 decimal places
    # convert heaters to kilowatts (doesn't compensate resistance vs temp)
    $wpower = sprintf "%.1f", $hpwr*7.6; # trim to 1 decimal places
    print "<font size=4> power consumption was <b>", $wpower, "</b> kW</font>.</center><p>\n";
}

print "</td>\n";
print "</tr>\n";

print "<tr>\n";


# dimensions of oven plot pngs are 1240x1754 in 20JAN21
# I've stretched the thumbnails a bit in width.

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot0name&$ARGV[0]\">GMT6<br>\n";
print "<img src=\"$plot0name\" width=400 height=438></a><br>\n";
print freshness($plot0name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot1name&$ARGV[0]\">GMT1<br>\n";
print "<img src=\"$plot1name\" width=400 height=438></a><br>\n";
print freshness($plot1name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot2name&$ARGV[0]\">GMT2<br>\n";
print "<img src=\"$plot2name\" width=400 height=438></a><br>\n";
print freshness($plot2name);
print "</td>\n";

print "</tr>\n";

print "<tr>\n";

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot3name&$ARGV[0]\">GMT3<br>\n";
print "<img src=\"$plot3name\" width=400 height=438></a><br>\n";
print freshness($plot3name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot4name&$ARGV[0]\">GMT4<br>\n";
print "<img src=\"$plot4name\" width=400 height=438></a><br>\n";
print freshness($plot4name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot5name&$ARGV[0]\">GMT5<br>\n";
print "<img src=\"$plot5name\" width=400 height=438></a><br>\n";
print freshness($plot5name);
print "</td>\n";


print "</tr>\n";

print "<tr>\n";

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot6name&$ARGV[0]\">GMT6<br>\n";
print "<img src=\"$plot6name\" width=400 height=438></a><br>\n";
print freshness($plot6name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot7name&$ARGV[0]\">LSST<br>\n";
print "<img src=\"$plot7name\" width=400 height=438></a><br>\n";
print freshness($plot7name);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "High Temperature plot from <a href=\"plot_GMT6.cgi?$plot8name&$ARGV[0]\">LBT2<br>\n";
print "<img src=\"$plot8name\" width=400 height=438></a><br>\n";
print freshness($plot8name);
print "</td>\n";


print "</tr>\n";

print "</table>\n<p>\n";


print "\n<HR>\n";



print "\nThis page was generated automatically by J. M. Hill's \"historyp.cgi\" script, version $version.<br>\n";
if ( $ARGV[0] > 29 ) {  # avoid too fast refresh
    print "Page auto refresh time = $ARGV[0] seconds.<p>\n";
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

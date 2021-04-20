#!/usr/bin/perl
#
# cyclep -- page for cycling through oven plots
#
# call as a cgi script
#
# Copyright (C) 1997-2021 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 08MAR21
# Argument sets the refresh time in seconds, 20>
#
$version = "09MAR21";

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

$path = "";

$infoname = "temperature";
$powername = "power";

$tempname = $path . $infoname;

# individual names from latestp script (not used)
$plot0name = "frame0.png";
$plot1name = "frame1.png";
$plot2name = "frame2.png";
$plot3name = "frame3.png";
$plot4name = "frame4.png";
#$plot5name = "frame5.png";
$plot5name = "rotation.png";

# array of names for cycling in this script
# edit this array (whitespace-separated) to add/remove plots
@names = qw/frame0.png frame1.png frame2.png frame3.png frame4.png rotation.png/;
$nplot = @names; # size of the array

# automatic page refresh
$minimumrefresh = 20;
$refreshtime = $ARGV[0];
if ( $refreshtime > 0 && $refreshtime < $minimumrefresh ) {  # avoid too fast refresh
    $refreshtime = $minimumrefresh;
}

# planning for new plot on each refresh cycle (if integer minutes)
# longer refresh times take more minutes per plot
$jrefresh = int( $refreshtime / 60 ) ;
if ( $jrefresh < 1 ) {$jrefresh = 1;} # integer minutes per refresh


# Get local time
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);


# (minutes-of-hour / cycle-time modulo number-of-plots) to select plot index
$thismin = $min; # minute of the present hour
$thisplot = int( $thismin / $jrefresh ) % $nplot ;
$plot2show = $names[$thisplot];


# introduction
print "Content-type: text/html\n\n";

print "<head>\n";
print "<title>Latest Temperature Plots from the Furnace</title>\n";

if ( $refreshtime >= $minimumrefresh ) {  # set auto refresh
    print "<meta http-equiv=\"Refresh\" content=\"$refreshtime\">\n";
}

print "</head>\n";

#print "<body background=\"yellow.png\" bgcolor=\"#FFFFFF\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

print "<body bgcolor=\"#EEEEEE\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

print "<table width=\"100%\" border=1 cellpadding=5>\n";

print "<td align=middle>\n";

print "<center><font size=4>\n";
print "<small><small>$thismin&nbsp;$nplot&nbsp;$jrefresh&nbsp;$thisplot&nbsp;&nbsp;</small></small>\n";
print "<a href=\"http://abell.as.arizona.edu/~hill/GMT6\">(home)</a>&nbsp;&nbsp;\n";
print "<font size=4><a href=\"http://www.as.arizona.edu\">University of Arizona</a>&nbsp;&nbsp;\n";
print "<a href=\"http://mirrorlab.arizona.edu\">Richard F. Caris Mirror Lab</a> &nbsp;&nbsp;\n";
print "<a href=\"http://www.gmto.org\">GMT6</a> &nbsp;&nbsp;Ninth 8.4m Mirror<br>\n";
print "</font>\n";

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
    print "<font size=4>The temperature was <b>", $tlid, "</b> degrees C at ", $timet, " on ", $datet, "</font>;\n";
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
# I've stretched the thumbnails a bit in width in latestp.
print "<td align=middle>\n";
print "<a href=\"plot_GMT6.cgi?$plot2show&$refreshtime\">\n";
# Needs better tricks for stretching plots like latestp,
#   and fitting to browser size. I resisted implementing CSS Style.
print "<img src=\"$plot2show\" width=\"100%\"></a><br>\n";
print freshness($plot2show);
print "</td>\n";

print "</tr>\n";

print "</table>\n<p>\n";

print "\n<HR>\n";

print "\nThis page was generated automatically by J. M. Hill's \"cyclep.cgi\" script, version $version.<br>\n";
if ( $refreshtime >= $minimumrefresh ) {  # notify of refresh time
    print "Page auto refresh time = $refreshtime seconds.<p>\n";
}

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

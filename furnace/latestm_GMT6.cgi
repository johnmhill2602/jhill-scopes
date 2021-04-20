#!/usr/bin/perl
#
# latestm -- page for latest oven images and temperatures.
#
# call as a cgi script
#
# Copyright (C) 1997-2021 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 14JUN97
# Argument sets the refresh time in seconds, 20>
#
$version = "08MAR21"; 

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

$path = "";

$gifaname = "cam1.png";
$gifbname = "cam2.png";
$gifcname = "cam3.png";
$gifdname = "cam4.png";
$gifename = "cam5.png";
$giffname = "cam6.png";
$gifgname = "cam7.png";
$redaname = "cam1_red.png";
$redbname = "cam2_red.png";
$redcname = "cam3_red.png";
$reddname = "cam4_red.png";
$redename = "cam5_red.png";
$redfname = "cam6_red.png";
$redgname = "cam7_red.png";
$infoname = "temperature";
$speedname = "rotation";
$powername = "power";

$picaname = $path . $gifaname;
$picbname = $path . $gifbname;
$piccname = $path . $gifcname;
$picdname = $path . $gifdname;
$picename = $path . $gifename;
$picfname = $path . $giffname;
$picgname = $path . $gifgname;
$imganame = $path . $redaname;
$imgbname = $path . $redbname;
$imgcname = $path . $redcname;
$imgdname = $path . $reddname;
$imgename = $path . $redename;
$imgfname = $path . $redfname;
$imggname = $path . $redgname;
$tempname = $path . $infoname;
$rotnname = $path . $speedname;

$plot0name = "frame0.gif";
$plot1name = "frame1.gif";
$plot2name = "frame2.gif";

# introduction
print "Content-type: text/html\n\n";

print "<head>\n";
print "<title>Latest Flash Views Inside the Furnace</title>\n";

# automatic page refresh
$minrefresh = 20;
$refreshtime = $ARGV[0];
if ( $refreshtime > 0 && $refreshtime < $minrefresh ) {  # avoid too fast refresh
    $refreshtime = $minrefresh;
}
if ( $refreshtime >= $minrefresh ) {  # set auto refresh
    print "<meta http-equiv=\"Refresh\" content=\"$refreshtime\">\n";
}

print "</head>\n";

print "<body background=\"yellow.gif\" bgcolor=\"#FFFFFF\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

#print "<font size=4>\n";
print "<table width=\"100%\" border=1 cellpadding=5>\n";

print "<tr>\n"; # first row

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_GMT6.cgi?$picaname&$refreshtime\">Camera 1a (wide)<br>\n";
print "<img src=\"$imganame\" width=436 height=326></a><br>\n";
print freshness($picaname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_GMT6.cgi?$piccname&$refreshtime\">Camera 3c (wide)<br>\n";
print "<img src=\"$imgcname\" width=436 height=326></a><br>\n";
print freshness($piccname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_GMT6.cgi?$picdname&$refreshtime\">Camera 4d (wide)<br>\n";
print "<img src=\"$imgdname\" width=436 height=326></a><br>\n";
print freshness($picdname);
print "</td>\n";

print "</tr>\n<tr>\n"; # second row

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_GMT6.cgi?$picename&$refreshtime\">Camera 5e (edge)<br>\n";
print "<img src=\"$imgename\" width=436 height=326></a><br>\n";
print freshness($picename);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_GMT6.cgi?$picfname&$refreshtime\">Camera 6f (edge)<br>\n";
print "<img src=\"$imgfname\" width=436 height=326></a><br>\n";
print freshness($picfname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_GMT6.cgi?$picgname&$refreshtime\">Camera 7g (edge)<br>\n";
print "<img src=\"$imggname\" width=436 height=326></a><br>\n";
print freshness($picgname);
print "</td>\n";

print "</tr>\n<tr>\n"; # third row

print "<td align=middle width=\"20%\">\n";

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
    ($tlid, $tcone, $twall, $tbaseo, $tbasei, $tmold ) = split (' ', $line, 80);
    print "The oven temperature was:<br>";
    print "lid= <b>", $tlid, "</b> degrees C<br>";
    print "cone= <b>", $tcone, "</b> degrees C<br>";
    print "walls= <b>", $twall, "</b> degrees C<br>";
    print "outer= <b>", $tbaseo, "</b> degrees C<br>";
    print "inner= <b>", $tbasei, "</b> degrees C<br>";
    print "mold= <b>", $tmold, "</b> degrees C<br>";
    print " at ", $timet, " on ", $datet, ".\n<p>\n";
}

if ( -e $rotnname ) {
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks) = stat($rotnname);
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

    open(SFILE,$rotnname);
    $line = <SFILE>;
    close(SFILE);
    ($trot) = split (' ', $line, 80);
    #if ( $trot > 30.0) { $trot = $trot - 30.0 } # strip the alarm flag
    $srot = sprintf "%.4f", $trot; # trim to 4 decimal places
    #print "The oven rotation speed was<br> <b>", $srot, "</b> RPM<br> at ", $timet, " on ", $datet, ".\n<p>\n";
    }

if ( -e $powername ) {
    ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
       $atime,$mtime,$ctime,$blksize,$blocks) = stat($powername);
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

    open(SFILE,$powername);
    $line = <SFILE>;
    close(SFILE);
    ($hpwr) = split (' ', $line, 80); # average ticks in last minute
    # convert to equivalent heaters (doesn't compensate aluminum heaters)
    $upower = sprintf "%.3f", $hpwr/240.0*270; # trim to 3 decimal places
    # convert heaters to kilowatts (doesn't compensate resistance vs temp)
    $wpower = sprintf "%.1f", $hpwr*7.6; # trim to 1 decimal places
    print "The oven power consumption was<br> <b>", $upower, "</b> equivalent heaters using <b>", $wpower, "</b> kW<br> at ", $timet, " on ", $datet, ".\n<p>\n";
}

print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_GMT6.cgi?$picbname&$refreshtime\">Camera B (center)<br>\n";
print "<img src=\"$imgbname\" width=436 height=326></a><br>\n";
print freshness($picbname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"http://www.as.arizona.edu\">University of Arizona</a><br><br>\n";
print "<a href=\"http://mirrorlab.arizona.edu\">Richard F. Caris Mirror Lab</a><br><br>\n";
print "<a href=\"http://www.gmto.org\">GMT6</a>&nbsp;&nbsp;Ninth 8.4m Mirror<br><br>\n";
print "Latest Flash Views<br>Inside the Furnace<p>\n";
print "(click thumbnail to view fullsize image)\n";
print "</td>\n";

print "</tr>\n";

print "</table>\n<p>\n";
#print "</font>\n";


print "\n<HR>\n";



print "\nThis page was generated automatically by J. M. Hill's \"latestm.cgi\" script, version $version.<br>\n";
if ( $refreshtime >= $minrefresh ) {  # notify of refresh time
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

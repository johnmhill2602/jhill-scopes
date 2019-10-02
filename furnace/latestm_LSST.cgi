#!/usr/bin/perl
#
# latestm -- page for latest oven images and temperatures.
#
# call as a cgi script
#
# Copyright (C) 1997 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 14JUN97
# Argument sets the refresh time in seconds, 20>
#
$version = "30MAR08";

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

$path = "";

$gifaname = "videoa.gif";
$gifbname = "videob.gif";
$gifcname = "videoc.gif";
$gifdname = "videod.gif";
$gifename = "videoe.gif";
$giffname = "videof.gif";
$gifgname = "videog.gif";
$redaname = "videoa_2.gif";
$redbname = "videob_2.gif";
$redcname = "videoc_2.gif";
$reddname = "videod_2.gif";
$redename = "videoe_2.gif";
$redfname = "videof_2.gif";
$redgname = "videog_2.gif";
$infoname = "temperature";
$speedname = "rotation";

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

if ( $ARGV[0] gt 19 ) {  # avoid too fast refresh
   print "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"$ARGV[0]\">\n"
};

print "<\head>\n";

print "<body background=\"yellow.gif\" bgcolor=\"#FFFFFF\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

print "<table width=\"100%\" border=1 cellpadding=5>\n";

print "<tr>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_LSST.cgi?$picaname&$ARGV[0]\">Camera A (wide)<br>\n";
print "<img src=\"$imganame\" width=300 height=243></a>\n";
print freshness($picaname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_LSST.cgi?$piccname&$ARGV[0]\">Camera C (wide)<br>\n";
print "<img src=\"$imgcname\" width=300 height=243></a>\n";
print freshness($piccname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_LSST.cgi?$picdname&$ARGV[0]\">Camera D (wide)<br>\n";
print "<img src=\"$imgdname\" width=300 height=243></a>\n";
print freshness($picdname);
print "</td>\n";

print "</tr>\n<tr>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_LSST.cgi?$picename&$ARGV[0]\">Camera E (edge)<br>\n";
print "<img src=\"$imgename\" width=300 height=243></a>\n";
print freshness($picename);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_LSST.cgi?$picfname&$ARGV[0]\">Camera F (edge)<br>\n";
print "<img src=\"$imgfname\" width=300 height=243></a>\n";
print freshness($picfname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_LSST.cgi?$picgname&$ARGV[0]\">Camera G (edge)<br>\n";
print "<img src=\"$imggname\" width=300 height=243></a>\n";
print freshness($picgname);
print "</td>\n";

print "</tr>\n<tr>\n";

print "<td align=middle width=\"20%\">\n";

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
	print "<font size=4>The oven temperature was<br> <b>", $tlid, "</b> degrees C<br> at ", $timet, " on ", $datet, "</font>.\n<p>\n";
    }

    if ( -e $rotnname ) {
        ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
                 $atime,$mtime,$ctime,$blksize,$blocks) = stat($rotnname);
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

	open(SFILE,$rotnname);
	$line = <SFILE>;
	close(SFILE);
	($trot ) = split (' ', $line, 80);
	print "<font size=4>The oven rotation speed was<br> <b>", $trot, "</b> RPM<br> at ", $timet, " on ", $datet, "</font>.\n<p>\n";
    }

print "<br>\n";
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video_LSST.cgi?$picbname&$ARGV[0]\">Camera B (center)<br>\n";
print "<img src=\"$imgbname\" width=300 height=243></a>\n";
print freshness($picbname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<center><font size=4>University of Arizona<br>\n";
print "<a href=\"http://mirrorlab.as.arizona.edu\">Steward Observatory Mirror Lab</a><br><br>\n";
print "<a href=\"http://www.lsst.org\">LSST</a><br>Fourth 8.4m Mirror<br><br>\n";
print "Latest Flash Views<br>Inside the Furnace</font></center>\n";
print "</td>\n";

print "</tr>\n";


print "</table>\n<p>\n";


print "\n<HR>\n";



print "\nThis page was generated automatically by J. M. Hill's \"latestm.cgi\" script, version $version.<P>\n";
if ( $ARGV[0] gt 19 ) {  # avoid too fast refresh
   print "Page refresh time = $ARGV[0] seconds.<p>\n"
};

print "<a href=\"an_index_for_LSST.htm\"><font size=4> To the previous page</a></font><p>\n";

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

#!/usr/bin/perl
#
# beforem -- page for latest oven images and temperatures.
#
# call as a cgi script
#
# Copyright (C) 1997 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 14JUN97
# Argument sets the refresh time in seconds, 20>
#
$version = "18SEP15";

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

# introduction
print "Content-type: text/html\n\n";

print "<head>\n";
print "<title>Before & After Flash Views Inside the Furnace</title>\n";

if ( $ARGV[0] gt 19 ) {  # avoid too fast refresh
   print "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"$ARGV[0]\">\n"
};

print "</head>\n";

print "<body background=\"yellow.gif\" bgcolor=\"#FFFFFF\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

print "<center><font size=4><b><a href=\"http://mirrorlab.arizona.edu\">Richard F. Caris Mirror Lab</a>: VGT1 Sixth 6.5m Mirror</b></center></font>\n";

print "<table width=\"100%\" border=1 cellpadding=5>\n";

	open(SFILE,$tempname);
	$line = <SFILE>;
	close(SFILE);
	($tlid, $tconei, $tconeo ) = split (' ', $line, 80);

print "<th>Before Melting View @ 420 C</th>\n";
print "<th>Middle of Melting @ 900 C</th>\n";
print "<th>Latest Views @ ", $tlid," C</th>\n";


print "<tr>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?early1.png\">Camera 1a (wide)<br>\n";
print "<img src=\"early1_red.png\" width=436 height=326></a>\n";
print freshness("early1.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?middle1.png\">Camera 1a (wide)<br>\n";
print "<img src=\"middle1_red.png\" width=436 height=326></a>\n";
print freshness("middle1.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?$picaname&$ARGV[0]\">Camera 1a (wide)<br>\n";
print "<img src=\"$imganame\" width=436 height=326></a>\n";
print freshness($picaname);
print "</td>\n";

print "</tr>\n<tr>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?early3.png\">Camera 3c (wide)<br>\n";
print "<img src=\"early3_red.png\" width=436 height=326></a>\n";
print freshness("early3.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?middle3.png\">Camera 3c (wide)<br>\n";
print "<img src=\"middle3_red.png\" width=436 height=326></a>\n";
print freshness("middle3.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?$piccname&$ARGV[0]\">Camera 3c (wide)<br>\n";
print "<img src=\"$imgcname\" width=436 height=326></a>\n";
print freshness($piccname);
print "</td>\n";

print "</tr>\n<tr>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?early4.png\">Camera 4d (wide)<br>\n";
print "<img src=\"early4_red.png\" width=436 height=326></a>\n";
print freshness("early4.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?middle4.png\">Camera 4d (wide)<br>\n";
print "<img src=\"middle4_red.png\" width=436 height=326></a>\n";
print freshness("middle4.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?$picdname&$ARGV[0]\">Camera 4d (wide)<br>\n";
print "<img src=\"$imgdname\" width=436 height=326></a>\n";
print freshness($picdname);
print "</td>\n";

print "</tr>\n<tr>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?early5.png\">Camera 5e (edge)<br>\n";
print "<img src=\"early5_red.png\" width=436 height=326></a>\n";
print freshness("early5.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?middle5.png\">Camera 5e (edge)<br>\n";
print "<img src=\"middle5_red.png\" width=436 height=326></a>\n";
print freshness("middle5.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?$picename&$ARGV[0]\">Camera 5e (edge)<br>\n";
print "<img src=\"$imgename\" width=436 height=326></a>\n";
print freshness($picename);
print "</td>\n";

print "</tr>\n<tr>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?early6.png\">Camera 6f (edge)<br>\n";
print "<img src=\"early6_red.png\" width=436 height=326></a>\n";
print freshness("early6.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?middle6.png\">Camera 6f (edge)<br>\n";
print "<img src=\"middle6_red.png\" width=436 height=326></a>\n";
print freshness("middle6.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?$picfname&$ARGV[0]\">Camera 6f (edge)<br>\n";
print "<img src=\"$imgfname\" width=436 height=326></a>\n";
print freshness($picfname);
print "</td>\n";

print "</tr>\n<tr>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?early7.png\">Camera 7g (edge)<br>\n";
print "<img src=\"early7_red.png\" width=436 height=326></a>\n";
print freshness("early7.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?middle7.png\">Camera 7g (edge)<br>\n";
print "<img src=\"middle7_red.png\" width=436 height=326></a>\n";
print freshness("middle7.png");
print "</td>\n";

print "<td align=middle valign=top width=\"20%\">\n";
print "<a href=\"video_VGT1.cgi?$picgname&$ARGV[0]\">Camera 7g (edge)<br>\n";
print "<img src=\"$picgname\" width=436 height=326></a>\n";
print freshness($picgname);
print "</td>\n";

print "</tr>\n";

#print "<tr>\n";

#print "<td align=middle valign=top width=\"20%\">\n";
#print "<a href=\"video_VGT1.cgi?early2.png\">Camera B (center)<br>\n";
#print "<img src=\"early2_red.png\" width=436 height=326></a>\n";
#print freshness("early2.png");
#print "</td>\n";

#print "<td align=middle valign=top width=\"20%\">\n";
#print "<a href=\"video_VGT1.cgi?middle2.png\">Camera B (center)<br>\n";
#print "<img src=\"middle2_red.png\" width=436 height=326></a>\n";
#print freshness("middle2.png");
#print "</td>\n";

#print "<td align=middle valign=top width=\"20%\">\n";
#print "<a href=\"video_VGT1.cgi?$picbname&$ARGV[0]\">Camera B (center)<br>\n";
#print "<img src=\"$picbname\" width=436 height=326></a>\n";
#print freshness($picbname);
#print "</td>\n";

#print "</tr>\n";


print "</table>\n<p>\n";


print "\n<HR>\n";



print "\nThis page was generated automatically by J. M. Hill's \"beforem.cgi\" script, version $version.<P>\n";
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

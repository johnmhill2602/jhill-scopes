#!/opt/csg/bin/perl
#
# latesti -- page for latest oven images and temperatures.
#
# call as a cgi script
#
# Copyright (C) 1997 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 14JUN97
# Argument sets the refresh time in seconds, 20>
#
$version = "14SEP98";

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

$path = "";

$gifaname = "ifrda.gif";
$gifbname = "ifrdb.gif";
$gifcname = "ifrdc.gif";
$gifdname = "ifrdd.gif";
$gifename = "ifrde.gif";
$giffname = "ifrdf.gif";
$redaname = "ifrda_2.gif";
$redbname = "ifrdb_2.gif";
$redcname = "ifrdc_2.gif";
$reddname = "ifrdd_2.gif";
$redename = "ifrde_2.gif";
$redfname = "ifrdf_2.gif";
$infoname = "temperature";

$picaname = $path . $gifaname;
$picbname = $path . $gifbname;
$piccname = $path . $gifcname;
$picdname = $path . $gifdname;
$picename = $path . $gifename;
$picfname = $path . $giffname;
$imganame = $path . $redaname;
$imgbname = $path . $redbname;
$imgcname = $path . $redcname;
$imgdname = $path . $reddname;
$imgename = $path . $redename;
$imgfname = $path . $redfname;
$tempname = $path . $infoname;

# introduction
print "Content-type: text/html\n\n";

print "<head>\n";
print "<title>Latest Infrared Views Inside the Furnace</title>\n";

if ( $ARGV[0] gt 19 ) {  # avoid too fast refresh
   print "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"$ARGV[0]\">\n"
};

print "<\head>\n";

print "<body background=\"yellow.gif\" bgcolor=\"#FFFFFF\" text =\"#4949aa\" link =\"#db9255\" vlink=\"#5E8BD0\" alink=\"#FF00A0\">\n";

print "<center><H1>Second Magellan Project 6.5m Mirror</H1></center>\n";

print "<center><h1>Latest Infrared Views Inside the Furnace</h1></center>\n";


print "<table width=\"100%\" border=1 cellpadding=5>\n";

print "<tr>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video.cgi?$picaname&$ARGV[0]\">Camera A<br>\n";
print "<img src=\"$imganame\" width=243 height=282></a>\n";
print freshness($picaname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video.cgi?$picbname&$ARGV[0]\">Camera B<br>\n";
print "<img src=\"$imgbname\" width=282 height=243></a>\n";
print freshness($picbname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video.cgi?$piccname&$ARGV[0]\">Camera C<br>\n";
print "<img src=\"$imgcname\" width=282 height=243></a>\n";
print freshness($piccname);
print "</td>\n";

print "</tr>\n<tr>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video.cgi?$picdname&$ARGV[0]\">Camera D<br>\n";
print "<img src=\"$imgdname\" width=282 height=243></a>\n";
print freshness($picdname);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video.cgi?$picename&$ARGV[0]\">Camera E<br>\n";
print "<img src=\"$imgename\" width=282 height=243></a>\n";
print freshness($picename);
print "</td>\n";

print "<td align=middle width=\"20%\">\n";
print "<a href=\"video.cgi?$picfname&$ARGV[0]\">Camera F<br>\n";
print "<img src=\"$imgfname\" width=282 height=243></a>\n";
print freshness($picfname);
print "</td>\n";

print "</tr>\n";

print "</table>\n<p>\n";

    if ( -e $tempname ) {
        ($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
                 $atime,$mtime,$ctime,$blksize,$blocks) = stat($tempname);
        ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);

        $datet = $mon+1 . "/" . $mday . "/" . $year ;
        $timet = $hour . ":" . $min . " MST" ;

	open(SFILE,$tempname);
	$line = <SFILE>;
	close(SFILE);
	($tlid, $tconei, $tconeo ) = split (' ', $line, 80);
	print "The oven temperature was <b>", $tlid, "</b> degrees C at ", $timet, " on ", $datet, ".\n<p>\n";
    }

print "<p>\n";
print "\n<HR>\n";



print "\nThis page was generated automatically by J. M. Hill's \"latestm.cgi\" script, version $version.<P>\n";
if ( $ARGV[0] gt 19 ) {  # avoid too fast refresh
   print "Page refresh time = $ARGV[0] seconds.<p>\n"
};

print "<a href=\"magellan.html\"><font size=4> To the previous page</a></font><p>\n";

#######################################################################################

sub freshness {
# subroutine to get file stats and format them into a string
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
     $atime,$mtime,$ctime,$blksize,$blocks) = stat(@_);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);

$sizea = int($size / 1000) . " kB" ;
$datea = $mon+1 . "/" . $mday . "/" . $year . " " ;
$timea = $hour . ":" . $min . " MST " ;
$freshness = $datea . $timea . $sizea ;
}

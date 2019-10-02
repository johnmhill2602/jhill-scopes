#!/opt/csg/bin/perl
#
# video -- page for latest oven image
#
# call as a cgi script
#
# Copyright (C) 1997 by J. M. Hill
# Created at Steward Observatory for use by 
#   the Large Binocular Telescope Project, 12SEP98
# First Argument is the image name
# Second Argument sets the refresh time in seconds, 20>
#
$version = "12MAR99";

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

($picture, $refresh) = (split (/&/, $ARGV[0]));

# introduction
print "Content-type: text/html\n\n";

print "<head>\n";
print "<title>$picture</title>\n";

if ( $refresh gt 19 ) {  # avoid too fast refresh
   print "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"$refresh\">\n"
};

print "<\head>\n";

print "<table width=\"100%\" border=1 cellpadding=5>\n";
print "<tr>\n";
print "<td align=middle width=\"20%\">\n";
print "<img src=\"$picture\"></a>\n";
print "</td>\n";
print "</tr>\n";
print "</table>\n<p>\n";

print "2MD2 NGST Prototype Mirror<br>\n";
print freshness($picture);
print "$picture<br>\n";
if ( $refresh gt 19 ) {print "Refresh time = $refresh seconds.<p>\n"};
print "<p>\n";

#######################################################################################

sub freshness {
# subroutine to get file stats and format them into a string
($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
     $atime,$mtime,$ctime,$blksize,$blocks) = stat(@_);
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime($mtime);

$sizea = int($size / 1000) . " kB " ;
$datea = $mon+1 . "/" . $mday . "/" . $year . " " ;
$timea = $hour . ":" . $min . " MST <br>" ;
$freshness = $datea . $timea . $sizea ;
}

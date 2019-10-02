#!/usr/bin/perl
#
# collect -- retrieve latest .png images from castvideo and encode a movie
#
# call as a cgi script
#
# Copyright (C) 2012 by J. M. Hill
# Created at Steward Observatory 
#
# STILL NEED TO ADD
# start frame and stop frame rather than nkeep
# need to fix cleanup routine
# need to use directory path consistently
# need to optimize encoding parameters
# add camera and number of frames as arguments
#

$version = "24AUG13";
# Keep $nkeep of each camera image
$nkeep = 24;

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

# retrieved images are written to this $path
#   and links are made to this $path directory (could be different)
# WARNING HARDWIRED TO THIS DIRECTORY - not carefully
$path = "/data/hill/public_html/movie/";

$camname1 = "camera_1";
$camname2 = "camera_2";
$camname3 = "camera_3";
$camname4 = "camera_4";
$camname5 = "camera_5";
$camname6 = "camera_6";
$camname7 = "camera_7";

$vidname1 = "short1.mp4";
$vidname2 = "short2.mp4";
$vidname3 = "short3.mp4";
$vidname4 = "short4.mp4";
$vidname5 = "short5.mp4";
$vidname6 = "short6.mp4";
$vidname7 = "short7.mp4";

#CAM5
&cleanup($camname5,0);
&listcam($camname5,$imagename5);
&encode($camname5,$vidname5);
&cleanup($camname5,0);

#CAM6
&cleanup($camname6,0);
&listcam($camname6,$imagename6);
&encode($camname6,$vidname6);
&cleanup($camname6,0);

#CAM7
&cleanup($camname7,0);
&listcam($camname7,$imagename7);
&encode($camname7,$vidname7);
&cleanup($camname7,0);

print "Done\n";

#######################################################################################
sub cleanup {
# delete old images from the specified camera 

    $i = $_[0]; # first argument is the camera name (required)
    $keep = 0;
    $keep = $_[1]; # second argument is the number of files to keep
    #if ($keep < 1) {$keep = 1};

    if (1 > 0) { 
	#print "Working on  $i keeping $keep.\n";
	$cmd1 = "ls -1 $path/" . $i . "*.png |";
	open(SFILE, $cmd1);
	@matches = <SFILE>;
	close(SFILE);

	for ($j=0; $j < @matches-$keep; $j++) {
  	    system("rm -f $matches[$j]");
	} # end for
    }
} # end of subroutine cleanup

#######################################################################################

sub retrieve {
# retrieve the specified camera image and link it to a local file

    $aj = $_[0]; # first arguent is the camera/directory name
    $ak = $_[1]; # second argument is the image name
    $al = $_[2]; # third argument is the output image name

# check to not retrieve blank names
    if ( length($ak) > 11 ) {

# wget options
#    -q     means quiet output
#    -t 2   means two tries
#    -T 20  means 20 sec timeout
#    -N     means use timestamps and only download fresher files
#    -O file    means write the file to a specified output name
# 	
# download to new file name
$cmd2 = "wget -q -t 2 -T 20 -N -O $al http://soml:turkey4film\@casting.as.arizona.edu:4225/images/$aj/$ak |";

# print the command output for diagnostic
open(SFILE, $cmd2);
foreach $line (<SFILE>) { print "$line \n" }
close(SFILE);

	} # end if

}

#######################################################################################
sub listcam {
# retrieve the camera directory listing 
#     and extract the names of the latest images

    $cn = $_[0]; # first argument is the camera/directory name

# system command to retrieve a directory page with wget
$cmd1 = "wget -q -t 2 -T 10 -O - http://soml:turkey4film\@casting.as.arizona.edu:4225/images/$cn/ | grep png |";
$image1 = "";
#print "$cmd1 \n";

# execute the wget command and capture the result
open(SFILE, $cmd1);
    @lines = <SFILE>;
close(SFILE);

    $j = 0; # first array index
    $last = $#lines; #subscript of last line
# print "There were $last +1 images\n";

    for($k=$last-$nkeep;$k<$last;$k++) {
	$image1 = $lines[$k];
# extract the latest image name
	$index1 = index($image1,"castcam",0);
	$index2 = index($image1,"png",0);
#print "$index1 $index2 \n";
	$images[$j] = substr($image1,$index1,($index2-$index1+3));
	$index = sprintf "%03u", $j;
	$newname = $cn . "_" . $index . ".png";
	$picture = $images[$j];
	print "$k $j $picture $newname \n";
	&retrieve($cn,$picture,$newname);
	$j = $j + 1;
    } # end of loop over images

} # end of subroutine listcam

#######################################################################################
sub encode {

    $cn = $_[0]; # first argument is the camera/directory name
    $outname = $_[1]; # second argument is the movie name

    system("rm -f $outname");
    $txt4 = '/home/jhill/sw/ffmpeg/ffmpeg -i ' . $cn . '_%03d.png -q:a 1 ' . $outname;
    print "$txt4 \n";
    system("$txt4");

} # end of subroutine encode

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


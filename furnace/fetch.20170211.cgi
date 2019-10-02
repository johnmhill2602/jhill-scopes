#!/usr/bin/perl
#
# fetch -- retrieve latest .png images from castvideo
#
# call as a cgi script
#
# Copyright (C) 2012 by J. M. Hill
# Created at Steward Observatory 
# Argument sets the refresh time in seconds, 20>
#
$version = "18SEP15";
# don't use camera 2 - 20171101 JMH

# Keep 10 of each camera image

# strip \'s put in by server (apparently)
$ARGV[0] =~ s/\\(.)/$1/g;

# retrieved images are written to this $path
#   and links are made to this $path directory (could be different)
$path = "/home/pilot/public_html/";

$gifaname = "cam1.png";
$gifbname = "cam2.png";
$gifcname = "cam3.png";
$gifdname = "cam4.png";
$gifename = "cam5.png";
$giffname = "cam6.png";
$gifgname = "cam7.png";
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

$camname1 = "camera_1";
$camname2 = "camera_2";
$camname3 = "camera_3";
$camname4 = "camera_4";
$camname5 = "camera_5";
$camname6 = "camera_6";
$camname7 = "camera_7";

# CAM1
&listcam($camname1,$imagename1); # get the last filename from a directory
sleep(1); # sleep to allow time for a partial image to finish
#print "Retrieving $camname1 $imagename1 \n";
&retrieve($camname1,$imagename1,$picaname); # retrieve the image
&cleanup(1,10);
#print "\n";

# CAM2
#&listcam($camname2,$imagename2); # get the last filename from a directory
#sleep(1); # sleep to allow time for a partial image to finish
#print "Retrieving $camname2 $imagename2 \n";
#&retrieve($camname2,$imagename2,$picbname); # retrieve the image
#&cleanup(2,10);
#print "\n";

#CAM3
&listcam($camname3,$imagename3);
sleep(1); # sleep to allow time for a partial image to finish
#print "Retrieving $camname3 $imagename3 \n";
&retrieve($camname3,$imagename3,$piccname);
&cleanup(3,10);
#print "\n";

#CAM4
&listcam($camname4,$imagename4);
sleep(1); # sleep to allow time for a partial image to finish
#print "Retrieving $camname4 $imagename4 \n";
&retrieve($camname4,$imagename4,$picdname);
&cleanup(4,10);
#print "\n";

#CAM5
&listcam($camname5,$imagename5);
sleep(1); # sleep to allow time for a partial image to finish
#print "Retrieving $camname5 $imagename5 \n";
&retrieve($camname5,$imagename5,$picename);
&cleanup(5,10);
#print "\n";

#CAM6
&listcam($camname6,$imagename6);
sleep(1); # sleep to allow time for a partial image to finish
#print "Retrieving $camname6 $imagename6 \n";
&retrieve($camname6,$imagename6,$picfname);
&cleanup(6,10);
#print "\n";

#CAM7
&listcam($camname7,$imagename7);
sleep(1); # sleep to allow time for a partial image to finish
#print "Retrieving $camname7 $imagename7 \n";
&retrieve($camname7,$imagename7,$picgname);
&cleanup(7,10);
#print "\n";

#######################################################################################
sub cleanup {
# delete old images from the specified camera so that only N remain

    $i = 0;
    $i = $_[0]; # first argument is the camera number (required)
    if ($i < 1 || $i > 7 ) {$i = 0};
    $keep = 0;
    $keep = $_[1]; # second argument is the number of files to keep (default=1)
    if ($keep < 1) {$keep = 1};

    if ($i > 0) { 
	# print "Working on camera $i keeping $keep.\n";
	$cmd1 = "ls -1 $path/castcam$i*.png |";
	open(SFILE, $cmd1);
	@matches = <SFILE>;
	close(SFILE);

	for ($j=0; $j < @matches-$keep; $j++) {
  	    system("rm -f $matches[$j]");
	} # end for

    }
}

#######################################################################################

sub retrieve {
# retrieve the specified camera image and link it to a local file

    $j = $_[0]; # first argument is the camera/directory name
    $k = $_[1]; # second argument is the image name
    $l = $_[2]; # third argument is the output image name

# check to not retrieve blank names
    if ( length($k) > 11 ) {

# wget options
#    -q     means quiet output
#    -t 2   means two tries
#    -T 20  means 20 sec timeout
#    -N     means use timestamps and only download fresher files
#    -O file    means write the file to a specified output name
# 	
# download to new file name (not used)
# $cmd2 = "wget -q -t 2 -T 20 -O $l http://soml:turkey4film\@castvideo/images/$j/$k |";
# download with original file name
$cmd2 = "wget -q -t 2 -T 20 -N -P $path http://soml:turkey4film\@castvideo/images/$j/$k |";
#print "$cmd2 \n";

# print the command output for diagnostic
open(SFILE, $cmd2);
foreach $line (<SFILE>) { print "$line \n" }
close(SFILE);

$kp = $path . $k;
# create a new softlink to the standard image name
$cmd3 = "rm -f $l;ln -s  $kp $l |";
# print the command output for diagnostic
open(SFILE, $cmd3);
foreach $line (<SFILE>) { print "$line \n" }
close(SFILE);

	} # end if

}

#######################################################################################
sub listcam {
# retrieve the camera directory listing 
#     and extract the name of the latest image

    $j = $_[0]; # first argument is the camera/directory name

# system command to retrieve a directory page with wget
$cmd1 = "wget -q -t 2 -T 10 -O - http://soml:turkey4film\@castvideo/images/$j/ | grep png |";
$image1 = "";
#print "$cmd1 \n";

# execute the wget command and capture the result
open(SFILE, $cmd1);
foreach $line (<SFILE>) { $image1 = $line }
close(SFILE);

# extract the latest image name
$index1 = index($image1,"castcam",0);
$index2 = index($image1,"png",0);
#print "$index1 $index2 \n";
$image1 = substr($image1,$index1,($index2-$index1+3));
#print "$image1 \n";

# return the name as an argument
$_[1] = $image1

} # end of subroutine listcam

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




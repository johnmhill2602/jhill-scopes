#!/usr/bin/perl
#==============================================================================
# $Id: slideviewer.cgi,v 1.9 2000/09/29 21:02:22 peters Exp $
#
# Name:		slideviewer.cgi
#
# Written:	Peter Sundstrom (peters@ginini.com.au)
#
# Created:	Feb 1997
#
# Source:	http://www.ginini.com.au/tools/slideviewer/
#
# Description:	Multi-purpose slide viewer.  Specify a file with a list
#		of pictures and descriptions and it does the rest.
#
# Notes:	Image sizing code is adapted and taken from parts of WWWis.
#		http://www.tardis.ed.ac.uk/~ark/wwwis/
#
# Copyright:	(c)1997-2000 Peter Sundstrom.  
#
#		See http://www.ginini.com.au/tools/slideviewer/ for licence
#		details.
#
#==============================================================================

use CGI::Carp qw(carpout fatalsToBrowser);

#-------------------------------------------------
# GLOBAL CONFIGURABLE OPTIONS
#-------------------------------------------------

# Full directory path where the configuration file/s are kept
$ConfigDir="/data/hill/public_html/slideviewer/config/"; # on abell

# Use alternate configuration directory if not on abell - JMH
if (-d $ConfigDir) {$abell=1;}
else {$ConfigDir="/home/pilot/public_html/slideviewer/config/";}

# Name of the default configuration filename if none is specified
$DefaultCfg="$ConfigDir/GMT6.cfg";

#-----------------------------------------------------------------
# END OF GLOBAL CONFIGURABLE OPTIONS
#=================================================================

$Version='2.3.0';
use Socket;
use Sys::Hostname;

use vars qw($StartIconOn $DefRefresh $Name $IndexWidth $NextIconOn);
use vars qw($PrevIconOn $IndexHeight $EndIconOn $DirReverse);

# URL to this script
$CGI=$ENV{'SCRIPT_NAME'};

undef %Data;

$Method = $ENV{'REQUEST_METHOD'};

if ($Method eq 'GET') {
	$Query = $ENV{'QUERY_STRING'};
}
else {
	read(STDIN,$Query,$ENV{'CONTENT_LENGTH'});
}

foreach (split(/[&;]/, $Query)) {
	s/\+/ /g;
	($key, $value) = split('=', $_);
	$key =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
	$value =~ s/%([A-Fa-f0-9]{2})/pack("c",hex($1))/ge;
	$Data{$key} = $value;                
}

#
# Unbuffer output
#
$|=1;

#
#
# Check to see what configuration to use
#
$Config="$Data{config}";

if ($Config) {
	Error("Configuration file can not be a URL -  $Config") if ($Config =~ /http:/i);
	Error("Invalid Configuration format.  No pathnames allowed.") if ($Config !~ m#^([\w.-]+)$#);
	Error("Configuration file $ConfigDir/$Config does not exist") if ( ! -f "$ConfigDir/$Config");
	require "$ConfigDir/$Config";
}
else {
	Error("Configuration file can not be a URL -  $DefaultCfg") if ($DefaultCfg =~ /http:/i);
	Error("Default configuration file $DefaultCfg does not exist") if (! -f "$DefaultCfg");
	require "$DefaultCfg";
}

#
# Display the slide selection form if specified or no parameters supplied or just the 
# configuration specified.
#
DisplayForm() if ($Data{form} or ! "$Query" or ! ($Data{list} or $Data{dir}));

#
# Open the specified slide list
#
if ($Data{dir}) {
	$Dir=$Data{dir};
	Error("Directory list name can not be a URL -  $Dir") if ($Dir =~ /http:/i);
	Error("Invalid directory list name format.  No pathnames allowed") if ($Dir !~ m#^([\w.-]+)$#);
}
else {
	Error("No slideshow list specified") unless "$Data{list}";
	Error("Slideshow list name can not be a URL -  $Data{list}") if ($Data{list} =~ /http:/i);
	Error("Invalid slideshow list name format.  No pathnames allowed") if ($Data{list} !~ m#^([\w.-]+)$#);
	$ListName=$Data{list};
	$List="$SlideDir/$Data{list}";

}

#
# Check to see if we have a valid design file
#
if ($Data{design}) {
	Error("Design name format can not be a URL -  $Data{design}") if ($Data{design} =~ /http:/i);
	Error("Invalid design name format. No pathnames allowed") if ($Data{design} !~ m#^([\w.-]+)$#);
	$Design="$Data{design}";
}
else {
	$Design="default";
}

Error("Design file: $DesignDir/$Design does not exist") if (! -f "$DesignDir/$Design");

#
# Check whether we need to build the slide index popup
#
CreateIndex() if ($Data{index} eq 'yes' and $IndexPopup);

#
# Set the recyle option
#
if ($Data{cycle} eq 'on') {
	$Cycle=$Data{cycle};
}
else {
	$Cycle='off';
}

# 
# Determine direction to go in
#
$Direction=$Data{direction} if ($Data{direction});

if ($Direction eq 'forward') {
	$OtherWay='backward';
}
elsif ($Direction eq 'backward') {
	$OtherWay='forward';
}
else {
	$Direction='forward';
	$OtherWay='backward';
}

#
# Determine what slide number we are up to
#
if ($Data{slide} and $Data{slide} > 1) {
	$Slide=$Data{slide};
}
else {
	$Slide=1;
}


$Count=0;

if ($Data{dir}) {
	DirectoryList();
}
else {
	SlideList();
}


if ($Direction eq 'forward') {
	if ($Slide == 1) {
		$Prev=1;
		$Next=2;
	}
	else {
		$Prev=$Slide - 1;
		$Next=$Slide + 1;
	}
}
else {
	$Prev=$Slide + 1;
	$Next=$Slide - 1;
	
}

if ($Data{total}) {
	$Total=$Data{total};
}
else {
	$Total=$Count;
}

Error("Slide number $Slide out of range. Max is $Total") if ($Slide > $Total);

#
# Generate a random number in the slide range
#
srand(time);
$Random=int(rand $Total) +1;

#
# Determine if this image has a URL associated with it
#
if ($LURL =~ /(http:.*)(alt.*)/i) {
	$LURL=$1;
	$Alt=$2;
}

#
# Set the refresh rate if specified
#
$Refresh=$Data{refresh} if ($Data{refresh} > 0);
$Refresh=0 if ($Data{auto} eq 'off');

#
# Set refresh times
#
$Slower=$Refresh + $Adjust;
$Faster = $Refresh - $Adjust if ($Refresh > $Adjust);

#
# Determine HEIGHT and WIDTH tags from image if not specified
#
if ($Data{width}) {
	$Width=$Data{width};
	$Height=$Data{height};
}
elsif ($Data{scale}) {
	$ImagePath=ImageLocation("$Image");
	($Width,$Height)=imgsize("$ImagePath");
	$Scale=$Data{scale};

	if ($Scale < 0) {
		foreach ($i=0; $i>$Scale; $i--) {
			$Width = $Width / $ScaleFactor;
			$Height = $Height / $ScaleFactor;
		}
	}
	else {
		foreach ($i=0; $i < $Scale; $i++) {
			$Width = $Width * $ScaleFactor;
			$Height = $Height * $ScaleFactor;
		}
	}
}
else {
	$ImagePath=ImageLocation("$Image");
	($Width,$Height)=imgsize($ImagePath);
}


#
# Calculate enlargement or reduction if selected.
#
if ($Data{scale}) {
	$Scale=$Data{scale};
}
else {
	$Scale=0;
}

if ($Data{size} eq 'enlarge') {
	$Scale++;
	$Width = $Width * $ScaleFactor;
	$Height = $Height * $ScaleFactor; 
}
elsif ($Data{size} eq 'reduce') {
	$Scale--;
	$Width = $Width / $ScaleFactor;
	$Height = $Height / $ScaleFactor; 
}


#
# If this is the last slide set the end page or go back to the
# beginning if cycle mode is on.
#
if ($Next > $Total or ($Slide == 1 and $Direction eq 'backward')) {
	if ($Cycle eq 'on') {
		$URL="$CGI?list=${ListName}&dir=$Dir&config=$Config&refresh=$Refresh&direction=$Direction&cycle=on&scale=$Scale&design=$Design&total=$Total" if ($Direction eq 'forward');
		$URL="$CGI?list=${ListName}&dir=$Dir&config=$Config&refresh=$Refresh&direction=$Direction&scale=$Scale&cycle=on&slide=$Total&design=$Design&total=$Total" if ($Direction eq 'backward');
	}
	else {
		$URL="$End";
	}
}
else {
	$URL="$CGI?list=${ListName}&dir=$Dir&config=$Config&refresh=$Refresh&direction=$Direction&scale=$Scale&cycle=$Cycle&slide=$Next&design=$Design&total=$Total";
}	

DisplayPage();
exit 0;

#=============================================================================
#				END OF MAIN
#=============================================================================

sub DisplayForm {
	open(FORM,"$Form") or Error("Can not open slideshow form template $Form", $!);

	while (<FORM>) {
		next if (/^#/);
		s!%CGI%!$CGI!;
		s!<SV_CGI>!$CGI!i;

		if (/%SLIDEINDEX%/ or /<SV_SLIDEINDEX>/i) {
			open(SLIDEINDEX,"$SlideIndex") or Error("Can not open slideshow index $SlideIndex", $!);
			$Output .= "<SELECT NAME=list>\n";
			while (<SLIDEINDEX>) {
				next if (/^#/ or ! /\w+/);
				($Design,$Description)=split(/\|/);
				$Output .= "<OPTION VALUE=$Design>$Description\n";
			}

			close(SLIDEINDEX);
			$Output .= "</SELECT>\n";
			s/%SLIDEINDEX%//;
			s/<SV_SLIDEINDEX>//i;
		}

		if (/%DESIGNINDEX%/ or /<SV_DESIGNINDEX>/i) {
			open(DESIGNINDEX,"$DesignIndex") or Error("Can not open design index  $DesignIndex", $!);
			$Output .= "<SELECT NAME=design>\n";
			while (<DESIGNINDEX>) {
				next if (/^#/ or ! /\w+/);
				($Design,$Description)=split(/\|/);
				$Output .= "<OPTION VALUE=$Design>$Description\n";
			}

			close(DESIGNINDEX);
			$Output .= "</SELECT>\n";
			s/%DESIGNINDEX%//;
			s/<SV_DESIGNINDEX>//i;
		}

		$Output .= $_;

	}

	close(FORM);

	print "Content-type: text/html\n\n";
	print $Output;

	exit 0;
}

#-----------------------------------------------------------------------------
#
# Extract the image URL, description and Subtitle for the appropriate 
# slide number.
#

sub SlideList {

	open (LIST,"$List") or Error("Can not open slide show list $List", $!);

	while (<LIST>) {
		next if (/^#/ or ! /\w+/);
	
		chomp;

		if (/^:include/) {
			s/:include //;
			$IncList=$_;
			open (INCLIST,"$SlideDir/$IncList") or Error("Can not open included slide show list $IncList", $!);
			while (<INCLIST>) {
				next if (/^#/ or ! /\w+/);
	
				chomp;
				$Count++;
	
				if (/$Data{filename}/ and $Data{filename}) {
					($Image,$Title,$Subtitle,$LURL,@objects)=split(/\|/);
					$Slide=$Count;
					last if ($Data{total});
				}
	
 				if ($Count == $Slide) {
					($Image,$Title,$Subtitle,$LURL,@objects)=split(/\|/);
					last if ($Data{total});
				}
			}
	
			next;
			close (INCLIST);
		}
		
	
		$Count++;
	
		if (/$Data{filename}/ and $Data{filename}) {
			$Slide=$Count;
			($Image,$Title,$Subtitle,$LURL,@objects)=split(/\|/);
			last if ($Data{total});
		}
	
 		if ($Count == $Slide) {
			($Image,$Title,$Subtitle,$LURL,@objects)=split(/\|/);
			last if ($Data{total});
		}
	
	}
	
	close (LIST);
}

#-----------------------------------------------------------------------------
# Select the files from the directory in the specified order

sub DirSelect {
	my (@sortedfiles,@files);

	$Directory=ConvertDir();

	opendir(DIR,"$Directory") or Error("Can not open directory $Directory", $!);
	@files=grep { /jpg|jpeg|gif|png/i } readdir DIR; 	
	closedir(DIR);

	if ($DirOrder eq 'time') {
		@sortedfiles=sort { -M $Directory."/$a" <=> -M $Directory."/$b" } @files;
	}
	elsif ($DirOrder eq 'name') {
		@sortedfiles=sort @files;
	}
	else {
		Error("Directory selection method is invalid: $DirOrder.  Should be name or time");
	}

	@sortedfiles = reverse @sortedfiles if $DirReverse;

	return(@sortedfiles);
}

#-----------------------------------------------------------------------------
# Open the directory list to find the URL to look for the images in.

sub DirectoryList {

	my @sortedfiles=DirSelect();

	foreach $File (@sortedfiles) {
		$Count++;
		if ($Count == $Slide) {
			$Image="$URLDir/$File";
			($Title=$File) =~ s/\.\w+$//;
			last if ($Data{total});
		}
	}

	Error("No images found in $Directory") if ($Count == 0);
}

#-----------------------------------------------------------------------------
sub DisplayPage {

	print "Content-type: text/html\n\n";
 	print "<HTML>\n<HEAD>\n"; 

	if ($Refresh > 0) {
		print "<META HTTP-EQUIV=\"Refresh\" CONTENT=\"$Refresh;URL=$URL\">\n";
	}

	JavaScript();

	open (DESIGN,"$DesignDir/$Design") or Error("Design file $DesignDir/$Design does not exist", $!);

	while (<DESIGN>) {
		next if (/^#/);
		s/%TITLE%/$Title/g;
		s/<SV_TITLE>/$Title/ig;
		s/%SUBTITLE%/$Subtitle/g;
		s/<SV_SUBTITLE>/$Subtitle/ig;
		s/%LURL%/$LURL/g;
		s/<SV_LURL>/$LURL/ig;
		s/%IURL%/$Image/g;
		s/<SV_IURL>/$Image/ig;
		s/%ALT%/$Alt/g;
		s/<SV_ALT>/$Alt/ig;
		s/%HEIGHT%/$Height/g;
		s/<SV_HEIGHT>/$Height/ig;
		s/%WIDTH%/$Width/g;
		s/<SV_WIDTH>/$Width/ig;
		s/%OBJECT([1-9]+)%/$objects[$1-1]/g;
		s/<SV_OBJECT([1-9]+)>/$objects[$1-1]/ig;

		if (/%IMAGE%/ or /<SV_IMAGE>/i) {
			s/%IMAGE%//g;
			s/<SV_IMAGE//ig;
			#
			# Use height and width if they've been calculated.
			#
			if ($Height > 0 ) {
				if ($IURL) {
					print qq(<A HREF="$IURL"><IMG SRC=$Image HEIGHT=$Height WIDTH=$Width BORDER=0 $Alt></A>\n);
				}
				else {
					print qq(<A HREF="$URL"><IMG SRC=$Image HEIGHT=$Height WIDTH=$Width BORDER=0 ALT="$Title"></A>\n);
				}
			}
			else {
				print qq(<A HREF="$URL"><IMG SRC=$Image BORDER=0 ALT="$Title"></A>\n);
			}

		}	

		if (/%SINDEX%/) {
			if ($IndexPopup) {
				print qq(<A HREF="JavaScript: index_window()"\n);
				print qq(onMouseOver="window.status='Slide Index'\n);
				print qq(return true" onMouseOut="window.status=''; return true">Slide Index</A>\n);
			}
			else {
				DropdownIndex();
			}
			next;
		}

		if (/%COUNTER%/ or /<SV_COUNTER>/i) {
			s/%COUNTER%//g;
			s/<SV_COUNTER>//ig;
			DisplayCounter();
		}

		if (/%BUTTONS%/ or /<SV_BUTTONS>/i) {
			s/%BUTTONS%//g;
			s/<SV_BUTTONS>//ig;
			DisplayButtons();
		}

		if (/%DIRECTIONLINKS%/ or /<SV_DIRECTIONLINKS>/i) {
			s/%DIRECTIONLINKS%//g;
			s/<SV_DIRECTIONLINKS>//ig;
			DirectionLinks();
		}

		if (/%REFRESHLINKS%/ or /<SV_REFRESHLINKS>/i) {
			s/%REFRESHLINKS%//g;
			s/<SV_REFRESHLINKS>//ig;
			RefreshLinks();
		}

		if (/%SIZELINKS%/ or /<SV_SIZELINKS>/i) {
			s/%SIZELINKS%//g;
			s/<SV_SIZELINKS>//ig;
			SizeLinks();
		}

		if (/%RANDOMLINK%/ or /<SV_RANDOMLINK>/i) {
			s/%RANDOMLINK%//g;
			s/<SV_RANDOMLINK>//ig;
			RandomLink();
		}

		if (/%REVERSELINK%/ or /<SV_REVERSELINK>/i) {
			s/%REVERSELINK%//g;
			s/<SV_REVERSELINK>//ig;
			ReverseLink();
		}

		if (/%LINKS%/ or /<SV_LINKS>/i) {
			s/%LINKS%//g;
			s/<SV_LINKS>//ig;
			DisplayLinks();
		}

		if (/%CONTROLS%/ or /<SV_CONTROLS>/i) {
			s/%CONTROLS%//g;
			s/<SV_CONTROLS>//ig;
			DisplayControls();
		}

		print;
	}
	close (DESIGN);
}

#-----------------------------------------------------------------------------
sub JavaScript {

	print <<HTML;
<script language="JavaScript">

<!--
browserName = navigator.appName;
browserVer = parseInt(navigator.appVersion);

if ((navigator.appName == "Netscape" || navigator.appName=="Microsoft Internet Explorer") && (navigator.appVersion.substring(0,1) >= "3" || navigator.appVersion.charAt(22) == "4"))
version = "modern";
else version = "braindead"; 

if (version == "modern")
{       
	backon = new Image; backon.src="$PrevIconOn";
	backoff = new Image ($IconHeight,$IconWidth); backoff.src="$PrevIconOff";
	topon = new Image; topon.src="$StartIconOn";
	topoff = new Image ($IconHeight,$IconWidth); topoff.src="$StartIconOff";
	nexton = new Image; nexton.src="$NextIconOn";
	nextoff = new Image ($IconHeight, $IconWidth); nextoff.src="$NextIconOff";
	bottomon = new Image; bottomon.src="$EndIconOn";
	bottomoff = new Image ($IconHeight,$IconWidth); bottomoff.src="$EndIconOff";
}

function img_on(imgName,Text)
{
	self.status=Text;

	if (version == "modern") {
		imgOn = eval (imgName + "on.src");
		document [imgName].src = imgOn;         
	}
}

function img_off (imgName)
{ 
	self.status='';

	if (version == "modern") {           
		imgOff = eval (imgName + "off.src");
		document [imgName].src = imgOff;        
	}
}

function index_window()
{
  window.open('$CGI?index=yes&list=$ListName&dir=$Dir&design=$Design&config=$Config&cycle=$Cycle&refresh=$Refresh&scale=$Scale','Index','toolbar=no,location=no,directories=no,status=no,menubar=no,resizable=yes,copyhistory=no,scrollbars=yes,width=$IndexWidth,height=$IndexHeight');
}

// -->

</script>
HTML
}

#-----------------------------------------------------------------------------
# Displays all the controls

sub DisplayControls 
{
	DisplayCounter();
	#DisplayButtons();
	#print "<P>";
	DisplayLinks();
}

#-----------------------------------------------------------------------------
# Generate dropdown index

sub DropdownIndex {

	print <<HTML;
<FORM ACTION=$CGI METHOD=POST>
<INPUT TYPE=HIDDEN NAME=list VALUE=$ListName>
<INPUT TYPE=HIDDEN NAME=config VALUE=$Config>
<INPUT TYPE=HIDDEN NAME=dir VALUE=$Dir>
<INPUT TYPE=HIDDEN NAME=refresh VALUE=$Refresh>
<INPUT TYPE=HIDDEN NAME=cycle VALUE=$Cycle>
<INPUT TYPE=HIDDEN NAME=scale VALUE=$Scale>
<INPUT TYPE=HIDDEN NAME=direction VALUE=$Direction>
<INPUT TYPE=HIDDEN NAME=design VALUE=$Design>
<INPUT TYPE=HIDDEN NAME=total VALUE=$Total>
<SELECT NAME=slide SIZE=1>
HTML

	if ($Data{dir}) {
		DropdownDir();
	}
	else {
		DropdownList();
	}

	print "</SELECT><INPUT TYPE=submit VALUE=Go>\n";
	print "</FORM>\n";
}

#-----------------------------------------------------------------------------
sub DropdownList {
		
	my $Count=1;

	open(LIST,"$List") or Error("Can not open slide show list $List", $!);	

	while (<LIST>) {
		next if (/^#/ or ! /\w+/);

		if (/^:include/) {
			s/:include //;
			$IncList=$_;
			open (INCLIST,"$SlideDir/$IncList") or Error("Can not open included slide show list $IncList", $!);

			while (<INCLIST>) {
				next if (/^#/ or ! /\w+/);
				chomp;
				($TempImage,$TempTitle,$TempSubtitle,$TempLURL)=split(/\|/);
				print "<OPTION SELECTED VALUE=$Count>$TempTitle</OPTION>\n" if ($Count == $Slide);
				print "<OPTION VALUE=$Count>$TempTitle</OPTION>\n" if ($Count != $Slide);
				$Count++;
			}

			close (INCLIST);
			next;
		}

	
		chomp;
		($TempImage,$TempTitle,$TempSubtitle,$TempLURL)=split(/\|/);
		print "<OPTION SELECTED VALUE=$Count>$TempTitle</OPTION>\n" if ($Count == $Slide);
		print "<OPTION VALUE=$Count>$TempTitle</OPTION>\n" if ($Count != $Slide);
		$Count++;
	}
 
	close(LIST);
}

#-----------------------------------------------------------------------------
sub DropdownDir {
	my $Count=1;

	my @sortedfiles=DirSelect();

	foreach $File (@sortedfiles) {
		($Title=$File) =~ s/\.\w+$//;

		if ($Count == $Slide) {
			print "<OPTION SELECTED VALUE=$Count>$Title</OPTION>\n";
		}
		else {
			print "<OPTION VALUE=$Count>$Title</OPTION>\n";
		}

		$Count++;
	}

}

#-----------------------------------------------------------------------------
# Converts directory list alias to full directory name

sub ConvertDir {
	my $Found=0;
	my ($Key,$Value);

	open(DIRLIST,"$DirIndex") or Error("Can not open directory list $DirIndex", $!);

	while (<DIRLIST>) {
		next if (/^#/ or ! /\w+/);
		chomp;

		if (/^$Dir/) {
			($Name,$URLDir)=split(/\|/);
			$Found=1;
			last;
		}
	}

	close (DIRLIST);

	Error("$Dir not defined in $DirIndex") if ! $Found;

	return("$WebDocs/$URLDir") unless %URLMappings;

        while (($Key,$Value) = each %URLMappings) {
                if ($URLDir =~ /$Key/) {
                        ($DirPath=$URLDir) =~ s%$Key%$Value%;
                }
        }

	
        return("$DirPath");
}

#-----------------------------------------------------------------------------
# Displays the slide index counter

sub DisplayCounter 
{

	print <<HTML;
<FORM ACTION=$CGI METHOD=POST>
<INPUT TYPE=HIDDEN NAME=list VALUE=$ListName>
<INPUT TYPE=HIDDEN NAME=config VALUE=$Config>
<INPUT TYPE=HIDDEN NAME=dir VALUE=$Dir>
<INPUT TYPE=HIDDEN NAME=refresh VALUE=$Refresh>
<INPUT TYPE=HIDDEN NAME=cycle VALUE=$Cycle>
<INPUT TYPE=HIDDEN NAME=scale VALUE=$Scale>
<INPUT TYPE=HIDDEN NAME=direction VALUE=$Direction>
<INPUT TYPE=HIDDEN NAME=design VALUE=$Design>
<INPUT TYPE=HIDDEN NAME=total VALUE=$Total>
Slide <INPUT TYPE=TEXT NAME=slide VALUE=$Slide size=3> of $Total
HTML

	if ($Refresh > 0 ) {
 		print "(Refresh $Refresh secs)\n";
	}
	else {
		print "(Refresh off)\n";
	}

	print "</FORM>\n";
}

#-----------------------------------------------------------------------------
# Displays the control buttons

sub DisplayButtons {

	print <<HTML;

<A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&refresh=$Refresh&slide=$Prev&cycle=$Cycle&scale=$Scale&design=$Design&total=$Total" onMouseOver="img_on('back','Go back to the previous slide');return true" onMouseOut="img_off('back')"><IMG SRC="$PrevIconOff" name="back" BORDER=0 HEIGHT=$IconHeight width=$IconWidth ALT="Previous"></A>

<A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&refresh=$Refresh&cycle=$Cycle&scale=$Scale&design=$Design&total=$Total" onMouseOver="img_on('top','Go to the start of the slide show');return true" onMouseOut="img_off('top')"><IMG SRC="$StartIconOff" name="top" BORDER=0 HEIGHT=$IconHeight width=$IconWidth ALT="Start"></A>

<A HREF="$End" onMouseOver="img_on('bottom','Go to the last slide'); return true" onMouseOut="img_off('bottom')"><IMG SRC="$EndIconOff" name="bottom" BORDER=0 HEIGHT=$IconHeight width=$IconWidth ALT="End"></A>

<A HREF="$URL" onMouseOver="img_on('next','Go to the next slide'); return true" onMouseOut="img_off('next')"><IMG SRC="$NextIconOff" name="next" BORDER=0 HEIGHT=$IconHeight width=$IconWidth ALT="Next"></A>

HTML
}

#-----------------------------------------------------------------------------
# Displays all the text link options

sub DisplayLinks
{
	DirectionLinks();
        print "<BR>";
	RefreshLinks();

	print "| ";
	SizeLinks();

	print "| ";
	RandomLink();

	print "| ";
	ReverseLink();

}
 
#-----------------------------------------------------------------------------
# Display the previous,start,last,next links

sub DirectionLinks {
	print <<HTML;
<A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&slide=$Prev&refresh=$Refresh&cycle=$Cycle&scale=$Scale&design=$Design&total=$Total" onMouseOver="self.status='Go back to the previous slide';return true" onMouseOut="self.status=''">Previous</A> |

<A HREF="$URL" onMouseOver="self.status='Go to the next slide';return true" onMouseOut="self.status=''">Next</A> |

<A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&refresh=$Refresh&scale=$Scale&design=$Design&total=$Total" onMouseOver="self.status='Go back to the beginning of the slide show';return true" onMouseOut="self.status=''">Start</A> |

<A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&slide=$Total&direction=$Direction&refresh=$Refresh&scale=$Scale&cycle=$Cycle&design=$Design&total=$Total" onMouseOver="self.status='Go to the last slide';return true" onMouseOut="self.status=''">Last</A>

HTML
}

#-----------------------------------------------------------------------------
# Display the links to speed up, slow down and turn off refreshes.

sub RefreshLinks {
	if ($Refresh > 0) {
		print qq(<A HREF="$CGI?list=${ListName}&dir=$Dir&config=$Config&refresh=$Faster&direction=$Direction&scale=$Scale&cycle=$Cycle&slide=$Slide&design=$Design&total=$Total" onMouseOver="self.status='Speed up the refreshes';return true" onMouseOut="self.status=''">Faster</A> |\n);

		print qq(<A HREF="$CGI?list=${ListName}&dir=$Dir&config=$Config&refresh=$Slower&direction=$Direction&scale=$Scale&cycle=$Cycle&slide=$Slide&design=$Design&total=$Total" onMouseOver="self.status='Slow down the refreshes';return true" onMouseOut="self.status=''">Slower</A> \n); 

		print qq(| <A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&refresh=-1&direction=$Direction&scale=$Scale&cycle=$Cycle&slide=$Slide&design=$Design&total=$Total" onMouseOver="self.status='Turn refreshes off';return true" onMouseOut="self.status=''">Refresh Off</A>\n);
	}
	else {
		print qq(<A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&refresh=$DefRefresh&direction=$Direction&scale=$Scale&cycle=$Cycle&slide=$Slide&design=$Design&total=$Total" onMouseOver="self.status='Turn refreshes on';return true" onMouseOut="self.status=''">Refresh On</A>\n);
	}
}

#-----------------------------------------------------------------------------
# Display the Enlarge, reduce and normal size links

sub SizeLinks {
	print <<HTML;
<A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&refresh=$Refresh&size=enlarge&width=$Width&height=$Height&scale=$Scale&cycle=$Cycle&slide=$Slide&design=$Design&total=$Total" onMouseOver="self.status='Enlarge the current image';return true" onMouseOut="self.status=''">Enlarge</A> 

| <A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&refresh=$Refresh&scale=0&cycle=$Cycle&slide=$Slide&design=$Design&total=$Total" onMouseOver="self.status='Display the current image at its normal size';return true" onMouseOut="self.status=''">Normal Size</A> 

| <A HREF="$CGI?list=$ListName&dir=$Dir&config=$Config&refresh=$Refresh&size=reduce&width=$Width&height=$Height&scale=$Scale&cycle=$Cycle&slide=$Slide&design=$Design&total=$Total" onMouseOver="self.status='Reduce the size of the current image';return true" onMouseOut="self.status=''">Reduce</A> 

HTML

}

#-----------------------------------------------------------------------------
# Displays the random link

sub RandomLink {
	print <<HTML;
<A HREF="$CGI?list=${ListName}&dir=$Dir&config=$Config&refresh=$Refresh&scale=$Scale&cycle=$Cycle&slide=$Random&design=$Design&total=$Total" onMouseOver="self.status='Jump to a random image';return true" onMouseOut="self.status=''">Random Image</A>

HTML

}

#-----------------------------------------------------------------------------
# Displays the reverse direction link

sub ReverseLink {
	print <<HTML;

<A HREF="$CGI?list=${ListName}&dir=$Dir&config=$Config&refresh=$Refresh&direction=$OtherWay&scale=$Scale&cycle=$Cycle&slide=$Slide&design=$Design&total=$Total" onMouseOver="self.status='Reverse the direction of the slide show';return true" onMouseOut="self.status=''">Reverse direction</A>

HTML
}

#-----------------------------------------------------------------------------
# Converts the URL of an image to real pathname.

sub ImageLocation {
	my $Image=shift;
	my ($Key,$Value);


	return("$Image") if ($Image =~ /http:/i);
	return("$WebDocs/$Image") unless %URLMappings;

        while (($Key,$Value) = each %URLMappings) {
		$Key =~ s%/%\\/%g;
		if ($Image =~ /$Key/) {
			($ImagePath=$Image) =~ s%$Key%$Value%;
		}
	}


	if ($ImagePath) {
		return("$ImagePath");
	}
	else {
		return("$WebDocs/$Image");
	}
}

#-----------------------------------------------------------------------------
# Create either the popup or dropdown index list

sub CreateIndex
{
	Error("Slide index template $TIndex not found") if (! -f "$TIndex"); 

	open (TINDEX,"$TIndex") or Error("Can not open slide index template $TIndex", $!);

	if ($Data{dir}) {
		PopupDir();
	}
	else {
		PopupList();
	}

	close (TINDEX);

	exit 0;
}
	
#-----------------------------------------------------------------------------
sub PopupDir {
	my $Count=1;

	my @sortedfiles=DirSelect();

	print "Content-type: text/html\n\n";

	while (<TINDEX>) {
		next if (/^#/ or ! /\w+/);
		last if (/%START INDEX%/ or /<SV_START INDEX>/i);
		print;
	}

	foreach $File (@sortedfiles) {
		($Title=$File) =~ s/\.\w+$//;

		print qq($Count. <A HREF="javascript:go('$CGI?list=$Data{list}&design=$Data{design}&dir=$Dir&config=$Config&refresh=$Data{refresh}&scale=$Data{scale}&slide=$Count')">$Title</A><BR>\n);

		$Count++;
	}

	print <TINDEX>;

}

#-----------------------------------------------------------------------------
sub PopupList {
	my $Count=1;

	open (LIST,"$List") or Error("Can not open slide show list $List", $!);

	print "Content-type: text/html\n\n";


	while (<TINDEX>) {
		next if (/^#/ or ! /\w+/);
		last if (/%START INDEX%/ or /<SV_START INDEX>/i);
		print;
	}

	while (<LIST>) {
		next if (/^#/ or ! /\w+/);

		if (/^:include/) {
			s/:include //;
			$IncList=$_;
			open (INCLIST,"$SlideDir/$IncList") or Error("Can not open included slide show $IncList", $!);

			while (<INCLIST>) {
				next if (/^#/ or ! /\w+/);
				chomp;
				($Image,$Title,$Subtitle,$LURL,@objects)=split(/\|/);
				print qq($Count. <A HREF="javascript:go('$CGI?list=$Data{list}&design=$Data{design}&dir=$Dir&config=$Config&refresh=$Data{refresh}&scale=$Data{scale}&slide=$Count')">$Title</A><BR>\n);
				$Count++;
			}
			close (INCLIST);
			next;
		}
	
		chomp;
		($Image,$Title,$Subtitle,$LURL,@objects)=split(/\|/);

		print "$Count. <A HREF = \"javascript:go('$CGI?list=$Data{list}&dir=$Dir&config=$Config&design=$Data{design}&refresh=$Data{refresh}&scale=$Data{scale}&slide=$Count')\">$Title</A><BR>\n";
		$Count++;

	}

	print <TINDEX>;

	close (LIST);
}

#-----------------------------------------------------------------------------
sub Error {
	my ($Text,$Errmsg)=@_;

	print "Content-type: text/html\n\n";

	ErrorStandard("$Text","$Errmsg") if (! -f $Error);

	open (ERROR,"$Error") or ErrorStandard("$Text");

	while (<ERROR>) {
		next if (/^#/);
		s/%MESSAGE%/$Text/g;
		s/%ERROR%/$Errmsg/g;
		s/%VERSION%/$Version/g;
		s/<SV_MESSAGE>/$Text/ig;
		s/<SV_Error>/$Text/ig;
		s/<SV_VERSION>/$Version/ig;
		print;
	}

	close(ERROR);

	exit;
}

#-----------------------------------------------------------------------------
# Foolproof way to display errors if the error template doesn't exist.
sub ErrorStandard {
	my ($Text,$Errmsg)=@_;

        require Cwd;
        Cwd->import();
	my $Dir=cwd();

	print <<HTML;
<HTML>
<HEAD>
<TITLE>Slideviewer Error</TITLE>
</HEAD>

<BODY BGCOLOR="#ffffff">

<BLOCKQUOTE>
<P>
<FONT FACE=Arial SIZE=+2>
<B>$Text</B>
</FONT>
<P>

<HR>
<FONT FACE=Arial>
<H3>Diagnostics</H3>
Error Message: <I>$Errmsg</I><BR>
Full Directory path to this script: <I>$Dir</I><BR>
Slideviewer Version: <I>$Version</I><BR>
Perl Version: <I>$]</I><BR>
Server Type: <I>$ENV{'SERVER_SOFTWARE'}</I><BR>

<HR>

</FONT>
</BLOCKQUOTE>

</BODY>
</HTML>
HTML

	exit;
}

#-----------------------------------------------------------------------------
# Code adapted from wwwis
#
# looking at the filename really sucks I should be using the first 4 bytes
# of the image. If I ever do it these are the numbers.... (from chris@w3.org)
#  PNG 89 50 4e 47    
#  GIF 47 49 46 38
#  JPG ff d8 ff e0
#  XBM 23 64 65 66

sub imgsize {
	local($file)= shift @_;
	local($x,$y)=(0,0);
  
	if ($file =~ /http:/) {
		($x,$y) = &URLsize($file);
	}
	elsif ( defined($file) && open(STREAM, "<$file") ) {
    		binmode( STREAM ); # for crappy MS OSes - Win/Dos/NT use is NOT SUPPORTED
	if ($file =~ /\.jpg$/i or $file =~ /\.jpeg$/i) {
		($x,$y) = &jpegsize(STREAM);
    	} 
	elsif ($file =~ /\.gif$/i) {
		($x,$y) = &gifsize(STREAM);
	} 
	elsif($file =~ /\.xbm$/i) {
		($x,$y) = &xbmsize(STREAM);
	} 
	elsif($file =~ /\.png$/i) {
		($x,$y) = &pngsize(STREAM);
	} 
	else {
		Error("$file is not a recognised image type of gif, xbm, jpeg or png");
	}
	close(STREAM);

	}
      
	return ($x,$y);
}


#-----------------------------------------------------------------------------
sub gifsize
{
	local($GIF) = @_;
	local($type,$a,$b,$c,$d,$s)=(0,0,0,0,0,0);

	if (defined($GIF) && read($GIF, $type, 6) &&
	    $type =~ /GIF8[7,9]a/ && read($GIF, $s, 4) == 4 ) {
		($a,$b,$c,$d)=unpack("C"x4,$s);
		return ($b<<8|$a,$d<<8|$c);
	}

	return (0,0);
}

#-----------------------------------------------------------------------------
sub xbmsize {
	local($XBM) = @_;
	local($input)="";
  
	if (defined($XBM)) {
		$input .= <$XBM>;
		$input .= <$XBM>;
		$input .= <$XBM>;
		$_ = $input;

		if (/.define\s+\S+\s+(\d+)\s*\n.define\s+\S+\s+(\d+)\s*\n/i) {
			return ($1,$2);
    		}
	}

	return (0,0);
}

#-----------------------------------------------------------------------------
#  pngsize : gets the width & height (in pixels) of a png file
# cor this program is on the cutting edge of technology! (pity it's blunt!)
#  GRR 970619:  fixed bytesex assumption

sub pngsize {
	local($PNG) = @_;
	local($head) = "";
	local($a, $b, $c, $d, $e, $f, $g, $h)=0;

	if (defined($PNG)				&& 
	   read( $PNG, $head, 8 ) == 8			&&
	   $head eq "\x89\x50\x4e\x47\x0d\x0a\x1a\x0a"  &&
	   read($PNG, $head, 4) == 4			&&
	   read($PNG, $head, 4) == 4			&&
   	   $head eq "IHDR"				&&
           read($PNG, $head, 8) == 8 			) {
		($a,$b,$c,$d,$e,$f,$g,$h)=unpack("C"x8,$head);
		return ($a<<24|$b<<16|$c<<8|$d, $e<<24|$f<<16|$g<<8|$h);
	}

	return (0,0);
}

#-----------------------------------------------------------------------------
# jpegsize : gets the width and height (in pixels) of a jpeg file
# Andrew Tong, werdna@ugcs.caltech.edu           February 14, 1995
# modified slightly by alex@ed.ac.uk

sub jpegsize {
	local($JPEG) = @_;
	local($done)=0;
	local($c1,$c2,$ch,$s,$length, $dummy)=(0,0,0,0,0,0);

	if (defined($JPEG)		&&
	    read($JPEG, $c1, 1)		&&
	    read($JPEG, $c2, 1)		&&
	    ord($c1) == 0xFF		&& 
	    ord($c2) == 0xD8		) {
		while (ord($ch) != 0xDA && !$done) {
			# Find next marker (JPEG markers begin with 0xFF)
      			# This can hang the program!!
      			while (ord($ch) != 0xFF) {  read($JPEG, $ch, 1); }
      			# JPEG markers can be padded with unlimited 0xFF's
      			while (ord($ch) == 0xFF) { read($JPEG, $ch, 1); }
      			# Now, $ch contains the value of the marker.

      			if ((ord($ch) >= 0xC0) && (ord($ch) <= 0xC3)) {
				read ($JPEG, $dummy, 3); read($JPEG, $s, 4);
				($a,$b,$c,$d)=unpack("C"x4,$s);
				return ($c<<8|$d, $a<<8|$b );
      			} else {
				# NOT valid JPEG markers
				read ($JPEG, $s, 2); 
				($c1, $c2) = unpack("C"x2,$s); 
				$length = $c1<<8|$c2;
				last if (!defined($length) || $length < 2);
				read($JPEG, $dummy, $length-2);
      			}
    		}
  	}

  	return (0,0);
}

#-----------------------------------------------------------------------------
sub URLsize {
	local($five) = @_;
	local($dummy, $dummy, $server, $url);
  
	local( $x,$y) = (0,0);
  
	if ($Proxy =~ /\S+/) {
		($dummy, $dummy, $server, $url) = split(/\//, $Proxy, 4);
		$url=$five;
	} 
	else {
		($dummy, $dummy, $server, $url) = split(/\//, $five, 4);
		$url= '/' . $url;
	}
  
	local($them,$port) = split(/:/, $server);

	$port = 80 unless $port;
	$them = 'localhost' unless $them;
  
	$_=$url;

	if (/gif/i || /jpeg/i || /jpg/i || /xbm/i) {
    
		$sockaddr = 'S n a4 x8';
    
   		$hostname=hostname(); 
		($name,$aliases,$proto) = getprotobyname('tcp');
		($name,$aliases,$port) = getservbyname($port,'tcp')
		unless $port =~ /^\d+$/;;
		($name,$aliases,$type,$len,$thisaddr) = gethostbyname($hostname);
		($name,$aliases,$type,$len,$thataddr) = gethostbyname($them);
    
		&Error("Unknown server/proxy port")  if (!defined($port));
		&Error("Unable to retreive the image via the Web Server.  This could be due to an incorrect perl installation or web server being down")    if (!defined($thataddr));
    
		$this = pack($sockaddr, &AF_INET, 0, $thisaddr);
		$that = pack($sockaddr, &AF_INET, $port, $thataddr);

		# Make the socket filehandle.

		if (!((socket(S, &AF_INET, &SOCK_STREAM, $proto)) &&

	   	# Give the socket an address.
	   	(bind(S, $this)) &&

	   	# Call up the server.
	   	(connect(S,$that)) )) {
			# there was a problem
			&Error(" $!");
		} 
		else {
			# Set socket to be command buffered.
			select(S); $| = 1; select(STDOUT);
     	 
			print S "GET $url\n\n";
     	 
			if ($url =~ /\.jpg$/i || $url =~ /\.jpeg$/i) {
				($x,$y) = &jpegsize(S);
			} 
			elsif ($url =~ /\.gif$/i) {
				($x,$y) = &gifsize(S);
      			} 
			elsif ($url =~ /\.xbm$/i) {
        			($x,$y) = &xbmsize(S);
      			} 
			elsif ($url =~ /\.png$/i) {
        			($x,$y) = &pngsize(S);
      			} 
			else {
        			&Error("$url is not gif, jpeg, xbm or png");
			}         
		}
	} 
	else {
		&Error("$url is not gif, xbm or jpeg");
  	}

	return ($x,$y);
}

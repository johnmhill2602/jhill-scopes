procedure convpng

# converts IRAF GKI metacode file to png image
#
# Usage
#   convpng onowa.mc
#   convpng onowa.mc out=myname.png clobber+ newer- black+ verb=5
#   convpng onowa.mc out=public_html clobber+ newer+ black- verb=2
#
# created by J. M. Hill, Steward Observatory, 06-MAR-2021
# added new features JMH 12-MAR-2021
#   optional output file name, or output path
#   verbosity flag to control printing
#   clobber flag to allow overwriting existing output file
#   newer flag to require metacode input to be newer than output
#   black flag to edit metacode to convert yellow/green fonts 14-MAR-2021
#   foreign ls call to find which file is newer 15-MAR-2021
#     This avoids a pipe to the cl which makes dictionary full.
#   foreign bash call to edit metacode 16-MAR-2021


# Future improvements
#  - allow wildcards for input



begin

	int ii, jj, inlen, outlen, iverb
	string infile, iroot, outfile, modfile, ls_str, newfile


	# check that needed IRAF packages are loaded
	if (!defpac ("plot"))
    	   plot
	if (!defpac ("mirror"))
    	   mirror
	if (!defpac ("scopes"))
    	   scopes
	if (!defpac ("furnace"))
    	   furnace

	# check that bash shell has been defined as a foreign task
	if (!deftask ("bash"))
	   task $bash = $foreign


# the traditional default glbcolor string
#set glbcolor="pt=3,fr=9,al=3,tl=6,ax=5,tk=5"
# 0=black 1=white 2=red 3=green, 4=blue, 5=cyan 6=yellow
# 7=magenta 8=aux1(purple) 9=aux2(dark green)
# see lib$gim.h
# ax=axes, tl=tick labels, tk=ticks fr=frame al=axes labels pt=plot title
# do these have an effect on psidump?  on gkimosaic?
# They do have an effect on ograph plotted to xgterm.


       # Get parameters from convpng.par (to avoid prompts later)
       infile = input     # required
       outfile = output   # optional
       iverb = verb
       
       # Check length of outfile name or path
       outlen = strlen(outfile)
       # Find the suffix position in the input name
       jj = stridx( ".", infile ) # can't use .mc because m appears in gmt
       iroot = substr( infile, 1, jj-1 )

       # Find the suffix position in outfile
       ii = stridx( ".", outfile ) # can't use .mc because m appears in gmt
       
       # create output filename if none was specified (?.png)
       #                     or if there is no . in pathname
       #      (path of ../ will break it)
       #      (name of .foo.mc will break it)
       if ( outlen < 5 || ii < 1 ) { # .png suffix is required
	   # prepend outfile in case outfile was a path
	   if ( outlen > 0 ) {
	      # PROBLEMS if iroot contains a path
              outfile = outfile // "/" // iroot // ".png"
	   }
	   else {
              outfile = iroot // ".png"
	   }
       }
       
       # Check length of new outfile path
       outlen = strlen(outfile)

       # Create modfile name for possible metacode edit
       modfile = iroot // "_edit.mc"


       if ( iverb > 2 ) { print ("convpng: ",infile, " ---> ", outfile) }

       if ( newer && iverb > 4 ) {print ("convpng: Require input file to be newer")}
       if ( clobber && iverb > 4 ) {print ("convpng: Will clobber output file if it exists")}

       if ( black && iverb > 4 ) {print ("convpng: Will convert yellow/green fonts")}


       # Check if input file exists, and output name exists, if not then exit
       if ( access(infile) && outlen > 4 ) {

       	  # this may cause cause dictionary full error?
       	  # way to find newer file without pipe to cl
	  ls_str = "-1t "//infile//" "//outfile
	  ls (ls_str) | scan(newfile)
	  if ( iverb > 4 ) { print ("convpng: newest file is ",newfile) }
	  
	  
	  # This causes dictionary full error after several hours
	  # Get modification time of input metacode file
	  #print ("!stat -c %Y "//infile) | cl | scan (intime)


	  # Check if output file can be created or clobbered
	  if ( !access(outfile) || clobber ) {

             # check for newer flag, and skip if output file is newer
	     if ( !newer || ( infile == newfile ) ) {
	     	 if ( black ) {
		     if ( iverb > 2 ) {	print ("convpng: Editting metacode file to ",modfile) }
		     # edit input metacode file
		     print ("/home/jhill/scopes/furnace/blackfont.bash ",infile," ",modfile) | bash ("-s")
		 }
		 else {
		     modfile = infile
		     if ( iverb > 2 ) { print ("convpng: processing ",modfile) }
		 }
	         # rotate+ works for the ghigh plots
       	         gkimosaic ( modfile, nx=1, ny=1, rotate+, interact-, device="psidump" )
   	         gflush
   	         psi2png ( outfile, clobber+, clean+, verb=2 )

	     } # end - input file was newer or don't care
	     else if ( iverb > 2 ) {
	     	  print ( "convpng: Exit since output file was newer.")
	     }
	     
	  } #end - can clobber or create outfile
	  else if ( iverb > 2 ) {
	       print ("convpng: Exit without clobbering output file.")
	  }
	  
      } # end - can access infile
      else if (iverb > 2 ) {
      	   print ("convpng: Exit since input file does not exist or invalid output.")
     }

end

#/bin/bash
# Edit in-place a binary IRAF GKI metacode file to change font colors.
#   J. M. Hill, Steward Observatory, 13-MAR-21
#
# Usage1: blackfont.bash myplot.mc
#   Your original file will be clobbered without asking!
#
# Usage1: blackfont.bash myplot.mc outplot.mc
#   Your original file will not be modified!
#   Pre-existing output file will be clobbered without asking!
#
#
#   xxd converts binary file to hex text which can be editted.
#   each 2-byte GKI opcode follows ffff.
#   First sed replaces the full set_fillarea command at start of file - changing fill color from 9(olive) to 0(white).
#   Next two seds replace green text (color=3) with black text (color=1) allowing for two positions relative to linebreak.
#   Last two seds replace yellow text (color=6) with black text (color=1) allowing for two positions relative to linebreak.
#   Can still fail if the ffff 0b000 command starts a new hex line with color bytes at the end of previous line.
#   Use the maximum 256 columns in the hex block to minimize linebreaks.
#

declare -a ARGS   # array to hold copy of command line arguments

#echo "$# $@" # check number of command line arguments

if [ $# -eq 0 ]; then  # zero arguments, exit
    echo "blackfont: Must specify input file"
    exit 1
fi

if [ $# -gt 2 ]; then  # too many arguments, exit
    echo "blackfont: Too many arguments"
    exit 3
fi

if [ $# -eq 2 ]; then  # second argument is output file
    if [ $1 == $2 ]; then # output is same as input
	#echo "blackfont: output overwrote input"
	set -- $1      # remove second argument
	#echo "$# $@" # check number of command line arguments
    fi
fi

if [ $# -eq 1 ]; then  # only one argument, clobber input 
    xxd -p -c 256 "$1" | sed '
s/ffff1200050002000900/ffff1200050002000000/
s/00000300ffff/00000100ffff/g
s/0300ffff0b00/0100ffff0b00/g
s/00000600ffff/00000100ffff/g
s/0600ffff0b00/0100ffff0b00/g
' | xxd -r -p > foobar_blackfont_edit.mc
mv foobar_blackfont_edit.mc "$1"
exit 0      
fi

if [ $# -eq 2 ]; then  # second argument is output file
    xxd -p -c 256 "$1" | sed '
s/ffff1200050002000900/ffff1200050002000000/
s/00000300ffff/00000100ffff/g
s/0300ffff0b00/0100ffff0b00/g
s/00000600ffff/00000100ffff/g
s/0600ffff0b00/0100ffff0b00/g
' | xxd -r -p > "$2"
exit 0
fi

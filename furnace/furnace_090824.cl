#{ Package script task for the FURNACE package.
# 	created 10OCT92	by J. M. Hill, Steward Observatory
#	added gkimerge 10AUG93
#	added fdisplay, fimstat, fimhead, fimplot 25/26JAN94
#	added fimhist 31JAN94
#	added fhselect 02FEB94
#	added level 12FEB94
#	added fcpp, gz?hpwr 15FEB94
#	define the remote display cl 16JAN97
#	added fexport 18JAN97
#	added mkindex, Imelda's mygraph 22JAN97
#	added takepic, 08MAY97
#	added videoc, 05JUN97
#	added xgifc, 06JUN97
#	added xremote, 07JUN97
#	added temp, 09JUN97
#	added shortc, 14JUN97
#	added flkill, 15JUN97
#	added gz5hpwr, gz5ttmp 04AUG98
#	added gcamera 13SEP98
#	added spinplot 15SEP98
#	added gcolor 18SEP98
#	added psi2gif 24SEP98
#	added mkgifc  27SEP98
# 	added bandc.cl 17MAR00
#	added the ghigh series 20MAY00
#	added ghigh_lotis 04APR02
#	corrected auto_all zone names 08APR02
#	added ghigh_gmt1 23JUL05
#       added ghigh_lsst and ghigh_spmt 24AUG09

# Load necessary packages

s1 = envget ("min_lenuserarea")
if (s1 == "")
    reset min_lenuserarea = 40000
else if (int (s1) < 40000 )
    reset min_lenuserarea = 40000

# define the package
package furnace,	bin = scopesbin$

task	autos,
	level,
	gkimerge = furnace$x_furnace.e

task	killer = furnace$killer.cl
task	fdisplay = furnace$fdisplay.cl
task	fimhead = furnace$fimhead.cl
task	fimstat = furnace$fimstat.cl
task	fhselect = furnace$fhselect.cl
task	fimplot = furnace$fimplot.cl
task	fimhist = furnace$fimhist.cl
task	fexport = furnace$fexport.cl
task	fproc = furnace$fproc.cl
task	calczpwr = furnace$calczpwr.cl
#task	glvdt = furnace$glvdt.cl
task	gband = furnace$gband.cl
task	gfvpp = furnace$gfvpp.cl
task	gfcpp = furnace$gfcpp.cl
task	gcamera = furnace$gcamera.cl
task	psi2gif = furnace$psi2gif.cl
task	mkgifc = furnace$mkgifc.cl
task	spinplot = furnace$spinplot.cl
task    $mkindex=furnace$mkindex.cl
task    $mygraph=furnace$mygraph.cl
task	$galumttmp = furnace$galumttmp.cl
task	$galumttmp1 = furnace$galumttmp1.cl
task	$galumttmp2 = furnace$galumttmp2.cl
task	$galumttmp3 = furnace$galumttmp3.cl
task	$galumttmp4 = furnace$galumttmp4.cl
task	$glidttmp = furnace$glidttmp.cl
task	$gconettmp = furnace$gconettmp.cl
task	$gwallttmp = furnace$gwallttmp.cl
task	$gz3ttmp = furnace$gz3ttmp.cl
task	$gz4ttmp = furnace$gz4ttmp.cl
#task	$gz5ttmp = furnace$gz5ttmp.cl
task	$gcenter = furnace$gcenter.cl
task	$gmoldttmp = furnace$gmoldttmp.cl
task	$gz4hpwr = furnace$gz4hpwr.cl
task	$gz3hpwr = furnace$gz3hpwr.cl
task	$gz2hpwr = furnace$gz2hpwr.cl
task	$gz1hpwr = furnace$gz1hpwr.cl
task	$gz0hpwr = furnace$gz0hpwr.cl
task	$gwhole = furnace$gwhole.cl
task	$gcolor = furnace$gcolor.cl
task	$auto_all = furnace$auto_all.cl
#task	$remote = furnace$remote.cl
#task	$remote2 = furnace$remote2.cl
task	takepic = furnace$takepic.cl
task	flkill = furnace$flkill.cl
task	videoc = furnace$videoc.cl
#task	xgifc = furnace$xgifc.cl
task	shortc = furnace$shortc.cl
task	bandc = furnace$bandc.cl
#task	xremote = furnace$xremote.cl
task	temp = furnace$temp.cl
task	$ghigh_spmt = furnace$ghigh_spmt.cl
task	$ghigh_lsst = furnace$ghigh_lsst.cl
task	$ghigh_gmt1 = furnace$ghigh_gmt1.cl
task	$ghigh_lotis = furnace$ghigh_lotis.cl
task	$ghigh_lbt2 = furnace$ghigh_lbt2.cl
task	$ghigh_mag2 = furnace$ghigh_mag2.cl
task	$ghigh_lbt1 = furnace$ghigh_lbt1.cl
task	$ghigh_mag1 = furnace$ghigh_mag1.cl
task	$ghigh_mmt = furnace$ghigh_mmt.cl

# foreign task for video images
task    $tcs = "$/opt/vxworks/local/tcs oven0v1"


print ("John's Oven Utilities Package\n")

keep

clbye()

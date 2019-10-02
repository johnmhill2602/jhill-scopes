# Global Common File: cass_common.h for CASS
# Version 05NOV92, 30DEC92, 10MAY93, 20OCT93, 25OCT94, 22NOV94, 03SEP97,
#         19APR99

# Useful Constants
define	ARCSEC_RAD	206264.8062471d0	# arcsec per radian
define	DEG_RAD		57.29577951308d0	# degrees per radian
define	PI2		1.570796326795d0	# pi / 2

# Variable Definitions
double	aa      # "axis-plane half angle of combined chief rays (rad)"  
double	aap     # "in-plane half angle of combined chief rays (rad)"  
double	ab      # "half angle of beam combiner apex (rad)"                    
double	abp     # "tilt angle of beam combiner facet (rad)"                    
double	abr     # "ray angle from beam combiner to focus (rad)"         
double	ac      # "half angle of combined light cone (rad)"                   
double	ai      # "half angle of interior light cone (rad)"                   
double  aea, aeb # "ellipse angles"
double  acoef   # quadratic coefficients
double  afbeam  # "afocal telescope beam diameter (m)"
double  bcoef
double  ccoef
double	achop   # "  tolerable zero coma chop throw (arcsec), astig only"     
double  adif    # "diffraction angle"
double	aell    # "beam combiner tilt angle from optical axis (rad)"
double	af      # "fold flat tilt angle from optical axis (rad)"               
double	ag      # "in-plane projected angle from tertiary to bc (rad)"        
double	al      # "angle of chief ray for lateral offset (rad)"               
double	alpha1  # "primary asphere for rc"                                    
double	alpha2  # "secondary asphere for cass"                                
double	alpha5  # "beam combiner asphere"                                
double	amld    # "image motion from m2 lateral displacement"        
double	ap      # "telecentric angle at edge of field (radians)"              
double	aq      # "azimuth ray angle from fold flat - beam combiner (radians)"
double  ar      # "azimuth angle from bc to focus (radians)"              
double	as      # "half angle of telescope light cone (radians)"              
double	ascomb  # "reimaged half angle of telescope light cone (radians)"
double  a1      # "half angle of primary light cone (radians)" beware "al"/"ai"
double	ash	
double  asphere1  # "primary aspheric amplitude"
double  asphere2  # "secondary aspheric amplitude"
double	at      # "tertiary tilt angle from optical axis (rad)"               
double	avtr    # "image motionfrom m2 vertex rotation(arcsec/arcsec)"        
double	aw      # "ray angle from tertiary to beam combiner (rad)"            
double	ay      # "ray angle from fold flat to beam combiner (rad)"            
double	ax	
double	axp	
double	az      # "azimuth angle from tertiary to beam combiner (rad)"        
double	azcr    # "image motionfrom zero-coma rotation(arcsec/arcsec)"        
double	bcfd    # "pathlength from beam combiner to focus (m)"                
double	bch     # "height of beam combiner apex above focal plane (m)"        
double	bcx     # "impact parameter onbeam combiner,in-plane (m)"             
double	bcy     # "impact parameter onbeam combiner,lateral (m)"              
double	beta    # "beta = vertex distance / focal length of m1"               
double	bfd     # "pathlength from secondary to focus (m)"                    
double	bigy2	
double	by2a	
double	carea   # "net telescope collecting area (m**2)"                      
double  cent    # "infrared centration allowance"
double  con2    # "conjugate position to secondary vertex in primary"
double	d1      # "primary mirror diameter (m)"                               
double	d2e     # "edge diameter of secondary mirror (m)"                      
double	d1i     # "infrared diameter of primary mirror (m)"
double	d1f     # "infrared envelope on primary mirror (m)"
double	d2v     # "vertex diameter of secondary (m)"                          
double  d2h     # "diameter of hole in secondary (m)"
double	d3min   # "minor axis diameter of tertiary (m)"                       
double  d3minup
double  d3mindn
double	d3maj   # "major axis diameter of tertiary (m)"                       
double	d3off   # "offset of tertiary ellipse (m)"
double	d4      # "minor axis diameter of beam combiner facet (m)"            
double	d5      # "minor axis diameter of folding flat 5 (m)"                 
double	d6      # "minor axis diameter of folding flat 6 (m)"                 
double	dbeam2  # "diameter of beam at secondary (m)"                         
double	dbeam3  # "diameter of beam at tertiary (m)"                          
double	dbeam3h # "converging beam i.d. above tertiary (m)"                   
double	dbeam4  # "diameter of beam at beam combiner (m)"                     
double	dbeam5  # "diameter of beam at folding flat 5 (m)"                    
double	dbeam6  # "diameter of beam at folding flat 6 (m)"                    
double	dclear3 # "hole inconverging light above tertiary (m)"
double	dpupil  # "diameter of exit pupil (m)"
double  cdif    # "centration correction to secondary diameter (m)"
double  ddif    # "diffraction correction to secondary diameter (m)"
double  fdif    # "field correction to secondary diameter (m)"
double  ctif    # "centration correction to tertiary diameter (m)"
double  dtif    # "diffraction correction to tertiary diameter (m)"
double  ftif    # "field correction to tertiary diameter (m)"
double  f4if    # "field correction to m4 diameter (m)"
double  f5if    # "field correction to m5 diameter (m)"
double	d1h     # "diameter of primary hole (m)"                              
double	dlong5  # "combined length of folding flat 5 (m)"                     
double	dlong6  # "combined length of folding flat 6 (m)"                     
double  dw20    # "height of largest flat field"
double  dw20a   # "height of best focus on axis"
double  dw20h   # "height of best focus at maximum field"
double	dw20m	# "height of largest flat field (mm)" scaled defocus parameter
double	ebar    # "rms physical image radius tolerance (microns)"             
double	ecc1    # "primary eccentricity"                                      
double	ecc2    # "secondary eccentricity"                                    
double	ecc5    # "beam combiner eccentricity"
double  eox, eoy, eoz # "ellipse axis offsets (m)"
double	eta     # "eta = normalized vertex back focus"                        
double	eve     # "effective vertex distance (m)"                             
double	f1      # "primary focal ratio"                                       
double  f2      # "secondary focal ratio"
double  f2h     # "focal ratio of beam from hole in secondary"
double	fc      # "apparent combined beam focal ratio"                        
double	fh	# "focal ratio of hole in converging beam"
double	ffa     # "pathlength from focus to fold flat (m)"                    
double	ffb     # "pathlength from focus to beam combiner (m)"              
double	ffc     # "pathlength from focus to beam combiner (m)"              
double	ffd     # "pathlength from fold flat to second focus (m)"
double	fff     # "pathlength from first focus to second focus (m)"
double	field   # "field diameter (arcmin)"                                   
double	flax    # "maximum flat field diameter (arcmin)"                      
double	fmax    # "maximum curved field diameter (arcmin)"
double  fpcsep, fpccim
double	fpdia   # "linear diameter of focal plane (m)"                        
double	fproc   # "focal plane radius of curvature (m)"                       
double	fs      # "system focal ratio"                                   
double  fsi     # "effective system focal ratio for infrared"
double	fscomb  # "combined focal ratio"                                      
double	fspot   # "  tolerable focal plane motion(m)"                         
double	hlax    # "fractional flat field radius"                              
double	hmax    # "fractional curved field radius"                            
double  ha      # "field angle (arcmin)"
double  hm      # "field angle (mm)"
double  index   # "refractive index of air"
double	k	
double	l       # "l = separation / back focal distance"                      
double	l1      # "primary focal length (m)"                                  
double	l2      # "focal length of secondary (m)"                             
double	l5      # "focal length of beam combiner relay (m)"
double	ldbc	
double  lmax    # "maximum infrared wavelength"
double	ls      # "system focal length (m)"                                   
double	m5fd    # "pathlength from m5 to focus (m)"                           
double	m6fd    # "?pathlength from m6 to focus (m)"                          
double	magn    # "magnification of secondary"                                
double  magx    # "magnification by focal length"
double	mpupil  # "magnification of pupil"
double	mlg     # "throughput (ubar1*y1)"                      
double	mlg2    # "throughput (ubar2*dbeam2/2)"                  
double  na      # "numerical aperture"
double  na1     # "primary numerical aperture"
double  nac
double  nacomb
double  nai     # "effective numerical aperture"
double	obs2    # "obscuration by secondary (fractional area)"                
double	obs3	# "obscuration by tertiary (fractional area)"         
double	obsh    # "obscuration by cassegrain hole (fractional area)"          
double	obsn    # "net telescope obscuration(fractional area)"                
double	obss    # "specified central obstruction (fractional area)"           
double	pbaffle # "primary obstruction (m)"                                   
double	pfd	
double	plate   # "platescale (mm/arcsec)"                                    
double	power	# "inverse of the curvature"
double  pshift  # "paraxial focus shift (micron/micron)"
double	pspace  # "separation of primaries (m, center-to-center)"             
double  rmsia   # "rms image radius (arcsec)"
double  rmsis   # "rms image radius (microns)"
double	rnum    # "number of mirrors in optical train"                        
double	rspot   # "  induced image radius (arcsec/micron)"                    
double  rw20    # "wavefront depth of focus"
double  rw20m   # "physical depth of focus (mm)"
double	sag1    # "sagitta of primary mirror"                                 
double	sag2    # "sagitta of secondary mirror"                               
double	sep     # "separation of m1 and m2 (m)"                               
double	sigma1    # "sigmai"                                                  
double	sigma2    # "sigmaii"                                                 
double	sigma3    # "sigmaiii"                                                
double	sigma4    # "sigmaiv"                                                 
double	sigma5    # "sigmav"                                                  
double  sphere1   # "primary spheric amplitude"
double  sphere2   # "secondary spheric amplitude"
double	spotsize  # "rms angular image radius tolerance (arcsec)"            
double	spupil    # "pupil position relative to secondary (m)"                
double	srw20m    # "secondary focus tolerance (field) -- axial motion(micron)"
double	styp	# "type of telescope configuration"
double	sw020   # "wavefront focus -- axial motion(micron/micron)"            
double	sw040   # "wavefront spherical aberration-- axial motion(micron/micron
double	tfd     # "pathlength from tertiary to focus (m)"                     
double	tvtr    # "image motion from tertiary rotation (arcsec/arcsec)"        
double	ubar1   # "field radius angle (radians)"                              
double	ubar2   # "field radius for pupil (radians)"                 
double	uvfld   # "unvignetted field diameter wrt/bc (arcmin)"                
double	uvrad   # "unvignetted field radius wrt/bc (m)"                       
double	verd	# "vertex distance"
double	vdcomb	# "combined vertex distance"
double	vf      # "height of fold flat above vertex (m)"                  
double	vh      # "height of beam combiner above vertex (m)"                  
double	vhmin   # "minimum height of beam combiner above vertex (m)"       
double	vt      # "height of tertiary above vertex (m)"                       
double	vtext	
double	vy      # "adjustment of vertex distance for combined coude focus ?"
double	w040    # "w040  (microns)  spherical aberration"                     
double	w131    # "w131  (microns)  coma"                                     
double	w220p   # "w220p (microns)  field curvature"                          
double	w222    # "w222  (microns)  astigmatism"                              
double	w2e2    # "w2e2"                                                      
double	w311    # "w311  (microns)  distortion"                               
double  waveab  # "wavefront aberration"
double	wcd     # "wavefront coma -- lateral motion (micron/micron)"           
double	wcv     # "wavefront coma -- vertex chop angle (micron/arcsec)"       
double  wvp     # "wavefront coma -- primary rotation (micron/micron)"
double	wvr     # "wavefront coma -- m2 vertex rotation (micron/arcsec)"
double	wzca    # "wavefront astigmatism -- zero coma chop (micron/arcsec)"   
double	x040    # "x040  (microns)  pupil spherical aberration"                
double	x131    # "x131  (microns)  pupil coma"                      
double	x222    # "x222  (microns)  pupil astigmatism"                   
double	x220p   # "x220p (microns)  pupil curvature"                          
double	x311    # "x311  (microns)  pupil distortion"                     
double	xbigy2  # "bigy2 for pupil"                                           
double  xdif    # "diffraction radius"
double	xdya    # "scale change without refocus (fraction/micron)"            
double	xdyra   # "scale change with refocus (fraction/micron)"               
double  xrw20m  # "center depth of focus"
double	xf      # "horizontal offset of fold flat from centerplane (m)"
double	y1	# "marginal ray height at primary"
double	y2	# "normalized marginal ray height at secondary"
double	yelax   # "lateral offset of elevation axis (m)"                       
double	yf      # "lateral offset of fold flat from centerline (m)"
double	yocomb  # "lateral offset of combined focus (m)"                      
double	zcp     # "distance from m2 to zero-coma pivot (m)"                   
double	zcppf   # "distance from prime focus to zero-coma pivot (m)"          
double	zelax   # "height of elevation axis above vertex plane (m)"           
double  fjunk
double	zjunk	

bool    irm2    # "use secondary as infrared aperture stop"
bool    rayrl   # "rays enter from the right rather than the left"
bool    raypup  # "insert the exit/entrance pupil dummy surface"
bool    rayobs  # "insert telescope obstruction surfaces for vignetting"
bool    rayud   # "tertiary bends rays up or down (cosmetic)"

common /cass_common/ a1, aa, aap, ab, abp, abr, ac, ai, aea, aeb,
achop, acoef, adif, bcoef, ccoef, aell, af, afbeam, ag, al, alpha1,
alpha2, alpha5, amld, ap, aq, ar, as, ascomb, ash, asphere1, asphere2,
at, avtr, aw, ax, ay, axp, az, azcr, bcfd, bch, bcx, bcy, beta, bfd,
bigy2, by2a, carea, cent, con2, d1, d2e, d1i, d1f, d2h, d2v, d3min,
d3maj, d3off, d3minup, d3mindn, d4, d5, d6, dbeam2, dbeam3, dbeam3h, dbeam4, dbeam5, dbeam6,
dclear3, dpupil, cdif, ddif, fdif, ctif, dtif, ftif, f4if, f5if, d1h,
dlong5, dlong6, dw20, dw20a, dw20h, dw20m, ebar, ecc1, ecc2, ecc5,
eox, eoy, eoz, eta, eve, f1, f2, f2h, fc, fh, ffa, ffb, ffc, ffd, fff,
fjunk, field, flax, fmax, fpcsep, fpccim, fpdia, fproc, fs, fsi,
fscomb, fspot, ha, hm, hlax, hmax, index, k, l, l1, l2, l5, ldbc,
lmax, ls, m5fd, m6fd, magn, magx, mlg, mlg2, mpupil, na1, na, nac, nacomb,
nai, obs2, obs3, obsh, obsn, obss, pbaffle, pfd, plate, power, pspace,
rmsia, rmsis, rnum, rspot, rw20, rw20m, sag1, sag2, sep, sigma1,
sigma2, sigma3, sigma4, sigma5, spotsize, sphere1, sphere2, spupil,
srw20m, styp, sw020, sw040, tfd, tvtr, ubar1, ubar2, uvfld, uvrad,
verd, vdcomb, vh, vhmin, vt, vtext, vy, vf, w040, w131, w220p, w222,
w2e2, w311, waveab, wcd, wcv, wvp, wvr, wzca, x040, x131, x220p, x222,
x311, xbigy2, xdya, xdyra, xrw20m, xdif, xf, y1, y2, yelax, yf,
yocomb, zcp, zcppf, zelax, zjunk, irm2, rayrl, raypup, rayobs, rayud


#{ SCOPES -- The SCOPES suite of packages.

# Package script task for the SCOPES package
# 	created 17JAN91	by J. M. Hill, Steward Observatory
#	added furnace package 10OCT92

cl < "scopes$lib/zzsetenv.def"
package scopes, bin = scopesbin$

task	aluminize.pkg 	= "aluminize$aluminize.cl"
task	optics.pkg	= "optics$optics.cl"
task	specs.pkg 	= "specs$specs.cl"
task	furnace.pkg 	= "furnace$furnace.cl"

clbye()

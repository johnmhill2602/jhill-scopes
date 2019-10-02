#{ Package script task for the OPTICS package.
# 	created 17JAN91	by J. M. Hill, Steward Observatory

# These tasks developed for designing telescope optics.

print ("Optics Package\n")

# define the package
package optics,	bin = scopesbin$

task	cass = optics$x_optics.e
task	depfoc = optics$x_optics.e
task	autocass = optics$autocass.cl

clbye()

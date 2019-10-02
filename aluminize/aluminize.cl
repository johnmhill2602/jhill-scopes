#{ Package script task for the ALUMINIZE package.
# 	created 17JAN91	by J. M. Hill, Steward Observatory

# These tasks developed for modelling aluminum deposition.

print ("Aluminizing Package is not yet fully implemented.\n")

# define the package
package aluminize,	bin = scopesbin$

task	chamber = aluminize$x_aluminize.e
task	filaments = aluminize$x_aluminize.e
task	structim = aluminize$x_aluminize.e

clbye()

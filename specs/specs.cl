#{ Package script task for the SPECS package.
# 	created 31JAN91	by J. M. Hill, Steward Observatory
#       23AUG94 - Added synthim.  JMH
#	31AUG94 - Added xyzmom.  JMH
#	23SEP94 - Added rrrmom.  JMH

# These tasks developed for modelling telescope specifications.

print ("Specifications Package is not yet fully implemented.\n")

# define the package
package specs,	bin = scopesbin$

task	newspecs = specs$x_specs.e
task	structure = specs$x_specs.e
task	xyzim = specs$x_specs.e
task	xyzdot = specs$x_specs.e
task	cpower = specs$x_specs.e
task	surfit = specs$x_specs.e
task	synthim = specs$x_specs.e
task	xyzmom = specs$x_specs.e
task	rrrmom = specs$x_specs.e
task	$junk = specs$x_specs.e
task	forces = specs$forces.cl

clbye()

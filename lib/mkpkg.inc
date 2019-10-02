# Global MKPKG definitions for the SCOPES packages.

$set XFLAGS	= "$(XFLAGS) -p scopes"
$set XVFLAGS	= "$(XVFLAGS) -p scopes"
$set LFLAGS	= "$(LFLAGS) -p scopes"

$ifeq (MACH, sparc) then
$include "scopes$lib/mkpkg.sf.SUN4"
$else $ifeq (MACH, i386) then
$include "scopes$lib/mkpkg.sf.I386"
$else $ifeq (MACH, f68881) then
$include "scopes$lib/mkpkg.sf.SUN3"
$else $ifeq (MACH, ffpa) then
$include "scopes$lib/mkpkg.sf.SUN3"
$else $ifeq (MACH, vms) then
$include "scopes$lib/mkpkg.sf.VMS"
$end

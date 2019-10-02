# include file to hold filament parameters for aluminize package
# Version 08FEB91

# Parameter definitions for filaments
define  MAXFIL   2000        # maximum number of filaments
define  NUMHEAD     0        # number of header records
define  NUMTAIL     0        # number of trailer records
define  MAXRIN     30        # maximum number of filament rings


# Structure definitions for target coordinates
define  LEN_HEAD  ((NUMHEAD+NUMTAIL)*(SZ_LINE+1))
define  LEN_FIL (9)
define  LEN_FILARRAY   (LEN_HEAD + LEN_FIL*MAXFIL)
define  LEN_RIN (8)
define  LEN_RINARRAY   (LEN_HEAD + LEN_RIN*MAXRIN)

# header storage contains header plus trailer text
# $1 is the memory pointer, $2 is the header line pointer
define  HEADER    Memc[P2C(($2-1)*(SZ_LINE+1) + $1)]

# body storage contains all of the filament info
# $1 is the memory pointer, $2 is the probe pointer
define  KF        Meml[(($2-1)*LEN_FIL + $1 +     LEN_HEAD)] # filament number
define  XA        Memr[(($2-1)*LEN_FIL + $1 + 1 + LEN_HEAD)] # x coordinate
define  YA        Memr[(($2-1)*LEN_FIL + $1 + 2 + LEN_HEAD)] # y coordinate
define  ZA        Memr[(($2-1)*LEN_FIL + $1 + 3 + LEN_HEAD)] # z coordinate
define  FTHETA    Memr[(($2-1)*LEN_FIL + $1 + 4 + LEN_HEAD)] # orientation
define  XB        Memr[(($2-1)*LEN_FIL + $1 + 5 + LEN_HEAD)] # baffle x
define  YB        Memr[(($2-1)*LEN_FIL + $1 + 6 + LEN_HEAD)] # baffle y
define  ZB        Memr[(($2-1)*LEN_FIL + $1 + 7 + LEN_HEAD)] # baffle z
define  RADB      Memr[(($2-1)*LEN_FIL + $1 + 8 + LEN_HEAD)] # baffle radius

# body storage contains all of the ring info
# $1 is the memory pointer, $2 is the probe pointer
define  KR        Meml[(($2-1)*LEN_RIN + $1 +     LEN_HEAD)] # ring number
define  RNUM      Meml[(($2-1)*LEN_RIN + $1 + 1 + LEN_HEAD)] # number of fils
define  RRAD      Memr[(($2-1)*LEN_RIN + $1 + 2 + LEN_HEAD)] # ring radius
define  RHITE     Memr[(($2-1)*LEN_RIN + $1 + 3 + LEN_HEAD)] # z coordinate
define  ROFF      Memr[(($2-1)*LEN_RIN + $1 + 4 + LEN_HEAD)] # fil offset
define  BRAD      Memr[(($2-1)*LEN_RIN + $1 + 5 + LEN_HEAD)] # baffle radius
define  BSIZE     Memr[(($2-1)*LEN_RIN + $1 + 6 + LEN_HEAD)] # baffle size
define  BHITE     Memr[(($2-1)*LEN_RIN + $1 + 7 + LEN_HEAD)] # baffle z

# Image row storage; $1 is the pointer, $2 is the column number
define	ZR	Memr[($1 + ($2-1))]

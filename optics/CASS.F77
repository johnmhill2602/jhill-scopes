!  CASS.F77 - Program to Calculate Parameters of a Cassegrain Focus
!
!  To Compile:  F77 CASS
!  To Link:     F77L CASS    with MARSLIB.LB and RAYTRC:CONFIG (and CLUTS.LB)
!	F77L CASS :UDD:RAYTRC:WORK:CONFIG \
!             :UDD:RAYTRC:WORK:CLUTS:CLUTS.LB \
!             :UDD:RAYTRC:WORK:TAPE:STR \
!             :UDD:RAYTRC:WORK:TAPE:UTIL \
!             :UDD:RAYTRC:WORK:TAPE:GENIO

        PROGRAM CASS

!  Description
!       This program calculates the first order parameters of a simple
!       telescope.  These parameters are then used in third order aberration
!       calculations.  The eventual goal is to produce a field focus curve and
!       an optical diagram with proper dimensions.  The program will calculate
!       the parameters for a prime focus, a classical Cassegrain focus or a
!       Ritchey-Chretien focus.  Additional parameters have been added to
!       allow design the combined focus for a Two-Shooter.  Someday, this may
!       be generalized to an N-Shooter.

!       Note: This program calculates third order (Seidel) aberrations for
!       on-axis reflecting elements.  Higher order aberrations are ignored.
!       It does not trace rays or perform diffraction calculations.  A
!       parameter file can be generated for Weymann's RAYTRC program.
!
!       Specified Spotsize is RMS radius from image centroid = 63% encircled
!       energy radius.  Be careful what you compare it to!
!--End of Documentation

!  Warning: Beware of Typos until software has been certified.

!  History
!       25OCT86 - Created by J. M. Hill, Steward Observatory
!       26OCT86 - Add more aberration Calculations.  JMH
!       05NOV86 - Add options for Prime Focus.  JMH
!       06NOV86 - Add Combined Focus Parameters.  JMH
!       08NOV86 - More Combined Focus Calculations.  JMH
!       10NOV86 - Add Obscuration and Forced M2 Asphere.  JMH
!       12NOV86 - Add RAYTRC Output File.  JMH
!       14NOV86 - Added Focal Plane Curvature.  JMH
!       17NOV86 - Flat Focal Plane Parameters and other stuff.  JMH
!       07DEC86 - Start Adding Gregorian Option.  JMH
!       14JAN87 - Calculate Size of Hole in Primary.  JMH
!       15JAN87 - Revise Gregorian Calculation.  JMH
!       09MAR87 - Start Adding Alignment Tolerances.  JMH
!               - Calculate Zero-Coma Pivot Position.
!       10MAR87 - Calculate Tilt Sensitivities.  JMH
!       13MAR87 - Scale Change from Axial Motion.  JMH
!       15MAR87 - Update .RAY file for Folding Flats.  JMH
!       16MAR87 - .RAY file gets zero coma pivot.  JMH
!       19MAR87 - Rearrange output format.  New CONFIG Call.  JMH
!       22MAR87 - Latest version of RAYTRC.INC File.  JMH
!       27MAR87 - Added ZC chop induced astigmatism estimate.  JMH
!       20JAN88 - Improve Combined Beam Optics, New Rev of CONFIG.OB  JMH
!       20FEB88 - Angles for Offset Combined Beam Optics
!       23FEB88 - Diameter of Beam at Tertiary and BC.  JMH
!       24JUN88 - Major Axis Diameter of Tertiary,
!               - Trap <nul> string for new revision of F77.  JMH
!       28JUN88 - More Offset combined optics.  JMH
!       29JUN88 - Flats for combined coude optics.  JMH
!       18APR89 - Add a RAYTRC translation before the primary mirror.  JMH
!       15NOV89 - Better Detail on Internal Obscuration of Tertiary.  JMH
!               - Calculate Net Collecting Area
!       16NOV89 - Separate Cass Hole and Specified Obscuration.
!       20DEC89 - Modify Secondary Diameter to Account for Secondary Curvature.
!       02JAN90 - Calculate Wavefront Error from Secondary Focus Motion.  JMH

!  Possible Improvements
!       Consider wave aberration variance tolerances
!       Include effects of Central Obstruction on Coefficients
!       Optics Graphics >> RAYTRC
!       Field Focus Graphics >> MONGO
!       How to Deal With Corrector Elements
!       How to Deal with powered tertiaries
!       How to Deal with off axis elements
!       Baffle Parameters and Vignetting Boundaries
!       How to Deal with N-Shooter Designs
!       Size, Location, and Obstruction of Baffles
!       Finish Alignment Tolerances

!  Variable Declarations

        CHARACTER*10    version                 ! Version Date of Code
        PARAMETER ( version = '02-JAN-90<NUL>' )

        INTEGER         out, data, ray
        PARAMETER ( out = 20 )          ! I/O unit for output
        PARAMETER ( data = 21 )         ! I/O unit for parameter file
        PARAMETER ( ray = 22 )          ! I/O unit for ray trace data file

        CHARACTER*81    DNAME           ! Name of Data File
        CHARACTER*81    ONAME           ! Name of Default Output File
        CHARACTER*81    NNAME           ! Name of New Output File
        CHARACTER*81    RNAME           ! Name of RAYTRC Data File
        CHARACTER*81    TITLE           ! Text String


        ! Double Precision Calculations
        IMPLICIT REAL*8 ( A-H, O-Z )
        IMPLICIT INTEGER*4 ( I-N )


        REAL*8          D1              ! Primary Mirror Diameter
        REAL*8          F1              ! Primary Focal Ratio
        REAL*8          L1              ! Primary Focal Length
        REAL*8          ECC1            ! Eccentricity of Primary
        REAL*8          ALPHA1          ! Asphere of Primary
        REAL*8          SAG1            ! Sagitta of Primary

        REAL*8          SAG2            ! Sagitta of Secondary
        REAL*8          D2              ! Secondary Diameter
        REAL*8          F2              ! Secondary Focal Ratio
        REAL*8          L2              ! Secondary Focal Length
        REAL*8          ECC2            ! Eccentricity of Secondary
        REAL*8          ALPHA2          ! Asphere of Secondary
        REAL*8          MAGN            ! Magnification of Secondary
        REAL*8          OBS2            ! Fraction of Beam Area Obscured

        REAL*8          FS              ! System Focal Ratio
        REAL*8          LS              ! System Focal Length
        REAL*8          POWER           ! System Power
        REAL*8          FC              ! Apparent Focal Ratio of Combined Beam

        REAL*8          D3              ! Minor Axis Diameter of Tertiary
        REAL*8          OBS3            ! Fraction of Beam Area Obscured
        REAL*8          D4              ! Minor Axis Diameter of BC Facet

        REAL*8          DH1             ! Diameter of Central Hole
        REAL*8          OBSH            ! Obstruction of Central Hole
        REAL*8          FH              ! Focal Ratio from Central Hole
        REAL*8          OBSS            ! Specified Central Obscuration

        REAL*8          OBSN            ! Net Central Obscuration
        REAL*8          CAREA           ! Collecting Area

        REAL*8          VE              ! Vertex Distance = e
        REAL*8          EVE             ! Effective Vertex Distance
        ! Vertex Distance Parameters
        REAL*8          L               ! Second Parameter ??
        REAL*8          BETA            ! (relative of L)
        REAL*8          ETA             ! (another relative)
        REAL*8          K
        REAL*8          VT              ! Height of M3 above vertex
        REAL*8          VTEXT           ! Tip of M3 above vertex
        REAL*8          VH              ! Height of M4=BC above vertex
        REAL*8          VY              ! Horizontal height for coude flats
        REAL*8          SEP             ! Separion of M1 and M2 = d
        REAL*8          BFD             ! Back Focal Distance from M2
        REAL*8          TFD             ! Back Focal Distance from M3
        REAL*8          BCFD             ! Back Focal Distance from M4=BC
        REAL*8          M5FD            ! Back Focal Distance from M5 flat
        REAL*8          M6FD            ! Back Focal Distance from M6 flat
        REAL*8          PFD             ! BFD from Pupil = virtual
        REAL*8          PSPACE          ! Separation of Dual Primaries
        REAL*8          YOCOMB          ! Lateral Offset of Combined Focus
        REAL*8          LDBC            ! Horizontal Distance from M3 to BC
        REAL*8          SPUPIL          ! Distance of Pupil from M2

        REAL*8          Y1              ! Entrance Pupil Radius = D1/2
        REAL*8          Y2              ! Marginal Ray Height at M2
        REAL*8          FIELD           ! Diameter of Field (arcminutes)
        REAL*8          UBAR1           ! Angular Radius of Field (radians)
        REAL*8          PLATE           ! Platescale (mm/arcsec)
        REAL*8          FPDIA           ! Focal Plane Diameter
        REAL*8          MLG             ! Script "M", Lagrange = UBAR * Y
        REAL*8          SPOTSIZE        ! Allowed RMS Image Radius (arcsec)
        REAL*8          EBAR            ! Physical RMS Image Radius (microns)
        REAL*8          W2E2            

        REAL*8          SIG1            ! Structural Aberration Coefficients
        REAL*8          SIG2
        REAL*8          SIG3
        REAL*8          SIG4
        REAL*8          SIG5

        REAL*8          W040            ! Wave Aberration Coefficients
        REAL*8          W131
        REAL*8          W222
        REAL*8          W220P
        REAL*8          W311

        REAL*8          DW20            ! Scaled Defocus Parameter
        REAL*8          RW20            ! Scaled Depth of Focus Parameter
        REAL*8          FPROC           ! Focal Plane Radius of Curvature

        REAL*8          AA              ! Chief Ray Angle at Combined Focus
        REAL*8          AL              ! Lateral Chief Ray Angle at Comb. Foc.
        REAL*8          AB              ! Half Angle of BC Apex
        REAL*8          AC              ! Half Angle of Combined Beams
        REAL*8          AG              ! Angle of Tertiary to BC Ray(in plane)
        REAL*8          AW              ! Angle of Tertiary to BC Ray
        REAL*8          AT              ! Angle of Tertiary Tilt
        REAL*8          AX              ! Angle of Uncombined Extreme Chief Ray
        REAL*8          AZ              ! Rotation Azimuth of Tertiary Tilt
        REAL*8          ASH             ! Half Angle of Converging Hole Beam
        REAL*8          AXP             ! Angle of Prime  Extreme Chief Ray

        LOGICAL         EX              ! Existence Flag
        CHARACTER*81    YN              ! text string
        CHARACTER*81    DATE            ! Date and Time String
        CHARACTER*81    RLAB            ! Dummy Text String

%INCLUDE ":UDD:RAYTRC:WORK:RAYTRC.INC"
%INCLUDE ":UDD:RAYTRC:WORK:RAYDEFS.INC"


!  Begin Code
        PI2 = DASIN( 1.0d0 )            ! pi/2
        DEGRAD = 90.0d0 / PI2           ! degrees/radian

!  Introduce Program
        PRINT *,'CASS - Telescope Design Program, Version '
        CALL WSTRING(-1,version,'#',10,ier)

!  Get Date and Time
        CALL FITSDATETIME(DATE,1,1,IER)

!  Setup Default Parameters
        D1 = 8.0d0
        F1 = 1.0d0
        FS = -1.0d0
        VE = 1.0d0
        FIELD = 0.0d0
        TITLE = 'Data File<NUL>'
        ALPHA1 = 0.0d0
        ALPHA2 = 0.0d0
        SPOTSIZE = 0.1d0
        PSPACE = 0.0d0
        YOCOMB = 0.0d0
        RNUM = 2.0d0
        STYP = 2.0d0
	YELAX = 0.0d0
        ZELAX = 0.0d0

!  Form Default Data File Name
        DNAME = '<NUL>'

!  Set Default Output File Name
        ONAME = '<NUL>'


100     CONTINUE

!  Check for Existence of Data File
        IF( LENSTR(DNAME).LE.0 ) THEN
            EX = .FALSE.
        ELSE
            INQUIRE( file=DNAME, exist=EX )
        END IF

!  Examine the Data File If It Exists
        IF( EX ) THEN

        !  Open Data File
            OPEN( data, file=DNAME, status='OLD', err=9000, iostat=IER,
     *                  pad='YES', iointent='INPUT' )

            PRINT *,'  Reading Data File: '
            CALL WSTRING(-1,dname,'#',40,ier)

        !  Read Data File
            CALL READSTR( data, TITLE, 80, IER )
            IF( LENSTR(TITLE).LE.0 ) GOTO 175
            CALL WSTRING( -1, TITLE, ' ', 80, IER )

21000       FORMAT( 5X, G15.7 )

            CALL RDBLE( data, RNUM, IER, *175, *9010 )
            WRITE(*,21000) RNUM
            CALL WSTRING(-1,'     Number of Mirrors (m)','#',60,ier)

            CALL RDBLE( data, STYP, IER, *175, *9010 )
            WRITE(*,21000) STYP
            IF( STYP.EQ.0.0d0 ) THEN
              CALL WSTRING(-1,'     Prime Focus Configuration','#',60,ier)
            ELSE IF( STYP.EQ.1.0d0 ) THEN
              CALL WSTRING(-1,'     Newtonian Configuration','#',60,ier)
            ELSE IF( STYP.EQ.2.0d0 ) THEN
              CALL WSTRING(-1,'     Cassegrain Configuration','#',60,ier)
            ELSE IF( STYP.EQ.3.0d0 ) THEN
              CALL WSTRING(-1,'     Gregorian Configuration','#',60,ier)
            ELSE
              CALL WSTRING(-1,'     Telescope Configuration Unknown','#',60,ier)
            END IF

            CALL RDBLE( data, D1, IER, *175, *9010 )
            WRITE(*,21000) D1
            CALL WSTRING(-1,'     Primary Diameter (m)','#',60,ier)

            CALL RDBLE( data, F1, IER, *175, *9010 )
            WRITE(*,21000) F1
            CALL WSTRING(-1,'     Primary Focal Ratio','#',60,ier)

            CALL RDBLE( data, FS, IER, *175, *9010 )
            WRITE(*,21000) FS
            CALL WSTRING(-1,'     System Focal Ratio','#',60,ier)

            CALL RDBLE( data, VE, IER, *175, *9010 )
            WRITE(*,21000) VE
            CALL WSTRING(-1,'     Vertex Distance (m)','#',60,ier)

            CALL RDBLE( data, FIELD, IER, *175, *9010 )
            WRITE(*,21000) FIELD
            CALL WSTRING(-1,'     Field Diameter (arcmin)','#',60,ier)

            CALL RDBLE( data, PBAFFLE, IER, *175, *9010 )
            WRITE(*,21000) PBAFFLE
            CALL WSTRING(-1,'     Primary Central Obstruction (0 to calculate)','#',60,ier)

            CALL RDBLE( data, ALPHA1, IER, *175, *9010 )
            WRITE(*,21000) ALPHA1
            CALL WSTRING(-1,'     Primary Asphere (0 to calculate)','#',60,ier)

            CALL RDBLE( data, ALPHA2, IER, *175, *9010 )
            WRITE(*,21000) ALPHA2
            CALL WSTRING(-1,'     Secondary Asphere (0 to calculate)','#',60,ier)

            CALL RDBLE( data, SPOTSIZE, IER, *175, *9010 )
            WRITE(*,21000) SPOTSIZE
            CALL WSTRING(-1,'     RMS Angular Image Radius Tolerance (arcsec)',
     *                      '#',60,ier)

        IF( RNUM.LT.3.0d0 ) GOTO 175

            CALL RDBLE( data, VT, IER, *175, *9010 )
            WRITE(*,21000) VT
            CALL WSTRING(-1,'     Height of Tertiary above Vertex (m)','#',60,ier)

        IF( RNUM.LT.4.0d0 ) GOTO 175

            CALL RDBLE( data, PSPACE, IER, *175, *9010 )
            WRITE(*,21000) PSPACE
            CALL WSTRING(-1,'     Primary Separation (m, center-to-center, 0 for single)','#',60,ier)

            CALL RDBLE( data, VH, IER, *175, *9010 )
            WRITE(*,21000) VH
            CALL WSTRING(-1,'     Height of Beam Combiner above Vertex Plane (m)',
     *                      '#',60,ier)

            CALL RDBLE( data, YOCOMB, IER, *175, *9010 )
            WRITE(*,21000) YOCOMB
            CALL WSTRING(-1,'     Lateral Offset of Combined Focus (m)',
     *                      '#',60,ier)

        IF( RNUM.LT.5.0d0 ) GOTO 175

            CALL RDBLE( data, ZELAX, IER, *175, *9010 )
            WRITE(*,21000) ZELAX
            CALL WSTRING(-1,'     Height of El. Axis Above Vertex Plane (m)',
     *                      '#',60,ier)

            CALL RDBLE( data, YELAX, IER, *175, *9010 )
            WRITE(*,21000) YELAX
            CALL WSTRING(-1,'     Lateral Offset of El. Axis (m)',
     *                      '#',60,ier)

175         CONTINUE

        !  Close Data File
            CLOSE( data )

        !  Ask if this Data File Should Be Used
190         YN = 'Y<NUL>'
            CALL MASKYN( -1, '  Should This Data File Be Used',
     *                  YN, 80, IER, *200, *195, *100, *190 )

195         DNAME = '<NUL>'     ! Set No Data File Name to take other branch
            GOTO 100            ! Look for Data File Again

        !  Ask if Data File Parameters should be used
200         YN = 'Y<NUL>'
            CALL MASKYN( -1, ' Should Optical Parameters Be Used AS IS',
     *                  YN, 80, IER, *500, *300, *190, *200 )

        ELSE

245         DNAME = '<NUL>'
        ! Get Alternative Data File Name
250         CALL MNAME( -1, '  Enter Name of Data File to Read (return for none): ',
     *                  DNAME, 80, IER, *300, *250, *250 )

            GOTO 100

        END IF


!  Enter New Parameters

        ! Title
300     CALL MNAME( -1, '  Enter a Data File Title: ',
     *                  TITLE, 80, IER, *300, *100, *300 )

        ! Number of Mirrors
302     CALL MDBLE( -1, '  Enter Number of Mirrors in Optical Train: ',
     *                  RNUM, 1.0d0, 6.0d0, RNUM, IER, *300, *302 )

        ! Telescope Configuration
        CALL WSTRING(-1,'    Prime Focus Configuration  = 0',' ',60,ier)
        CALL WSTRING(-1,'    Newtonian Configuration    = 1',' ',60,ier)
        CALL WSTRING(-1,'    Cassegrain Configuration   = 2',' ',60,ier)
        CALL WSTRING(-1,'    Gregorian Configuration    = 3',' ',60,ier)
303     CALL MDBLE(-1, '  Enter Telescope Configuration Number: ',
     *                  STYP, 0.0d0, 3.0d0, STYP, IER, *302, *303 )

        ! Primary Diameter
305     CALL MDBLE( -1, '  Enter Primary Mirror Diameter (meters): ',
     *                  D1, 0.0d0, 100.d0, D1, IER, *303, *305 )

        ! Primary Focal Ratio
310     CALL MDBLE( -1, '  Enter Primary Focal Ratio: ',
     *                  F1, 0.0d0, 100.d0, F1, IER, *305, *310 )

!  Check for a Prime Focus System
        IF( STYP.EQ.0.0d0 ) THEN
            FS = F1
            VE = - ( D1 * F1 )
            GOTO 340
        END IF

!  Check for a Newtonian System
        IF( STYP.EQ.1.0d0 ) THEN
            FS = F1
            GOTO 330
        END IF

        ! System Focal Ratio
320     CALL MDBLE( -1, '  Enter System Focal Ratio: ',
     *                  FS, 0.0d0, 999.d0, FS, IER, *310, *320 )


        ! Vertex Distance
        IF( RNUM .LT. 3 ) THEN
330       CALL MDBLE( -1, '  Enter Vertex Distance (+ is below primary): ',
     *                  VE, 0.0d0, 0.0d0, VE,  IER, *320, *330 )
        ELSE IF( RNUM .LT. 4 ) THEN
331       CALL MDBLE( -1, '  Enter Axis -- Focus Distance (usually positive): ',
     *                  VE, 0.0d0, 0.0d0, VE,  IER, *320, *331 )
        ELSE
332       CALL MDBLE( -1, '  Enter Vertex Plane -- Focus Distance (+ is below): ',
     *                  VE, 0.0d0, 0.0d0, VE,  IER, *320, *332 )
        END IF

        ! Field Diameter
340     CALL MDBLE( -1, '  Enter Field Diameter (arcmin): ',
     *                  FIELD, 0.0d0, 999.d0, FIELD, IER, *330, *340 )

        ! Central Obstruction
345     CALL MDBLE( -1, '  Enter Primary Obstruction (0 to calculate): ',
     *                  PBAFFLE, 0.0d0, D1, PBAFFLE, IER, *340, *345 )

        ! Primary Asphere
350     CALL MDBLE( -1, '  Enter Primary Asphere (0 to calculate): ',
     *                  ALPHA1, 0.0d0, 0.0d0, ALPHA1, IER, *345, *350 )

        ! Secondary Asphere
355     CALL MDBLE( -1, '  Enter Secondary Asphere (0 to calculate): ',
     *                  ALPHA2, 0.0d0, 0.0d0, ALPHA2, IER, *350, *355 )

        ! Error Tolerance
360     CALL MDBLE( -1, '  Enter RMS Angular Image Radius Tolerance (arcsec): ',
     *                  SPOTSIZE, 0.0d0, 30.d0, SPOTSIZE, IER, *355, *360 )

!  Check for a Simple Cassegrain System
        IF( RNUM.LT.3.0d0 ) GOTO 400

        L1 = D1 * F1

        ! Tertiary Height
365     CALL MDBLE( -1, '  Enter Height of Tertiary above Vertex (m): ',
     *                  VT, -L1, L1, VT, IER, *360, *365 )

!  Check for a Combined Beam or 4 mirror telescope
        IF( RNUM.LT.4.0d0 ) GOTO 400

        ! Primary Separation
370     CALL MDBLE( -1, '  Enter Primary Separation (center-center m, 0 = single dish): ',
     *                  PSPACE, 0.0d0, 30.d0, PSPACE, IER, *365, *370 )

        IF( PSPACE.EQ.0.0d0 ) GOTO 400

        ! Beam Combiner Height
375     CALL MDBLE( -1, '  Enter Height of Beam Combiner above Vertex (m): ',
     *                  VH, 0.0d0, LS, VH, IER, *370, *375 )

        ! Beam Combiner Offset
380     CALL MDBLE( -1, '  Enter Lateral Offset of Combined Focus (m): ',
     *                  YOCOMB, -D1, D1, YOCOMB, IER, *375, *380 )

        IF( RNUM.LT.5.0d0 ) GOTO 400

        ! Height of El. Axis Above Vertex Plane
385     CALL MDBLE( -1, '  Enter Height of El. Axis above Vertex (m): ',
     *                  ZELAX, -D1, D1, ZELAX, IER, *380, *385 )

        ! Lateral Offset of Elevation Axis
390     CALL MDBLE( -1, '  Enter Offset of El. Axis from Baseline (m): ',
     *                  YELAX, -D1, D1, YELAX, IER, *385, *390 )



400     CONTINUE
!  Should This Data Be Saved?
410     YN = 'Y<NUL>'
        CALL MASKYN( -1, '  Should this Data be Saved',
     *                  YN, 80, IER, *420, *500, *360, *410 )

!  Get Name of New Data File
420     NNAME = DNAME
        CALL MNAME( -1, '  Enter Name of New Data File: ',
     *                  NNAME, 80, IER, *410, *410, *420 )

!  Open New Data File
        OPEN( data, file=NNAME, status='FRESH', err=9000, iostat=IER,
     *                  pad='YES', carriagecontrol='FORTRAN' )

!  Write Data File
        CALL WSTRING(data, TITLE, '#', 80, IER )

20000   FORMAT( G15.7 )

        WRITE(data,20000) RNUM
        CALL WSTRING(data,'     Number of Mirrors in Optical Train','#',60,ier)

        WRITE(data,20000) STYP
        IF( STYP.EQ.0.0d0 ) THEN
          CALL WSTRING(data,'     Prime Focus Configuration','#',60,ier)
        ELSE IF( STYP.EQ.1.0d0 ) THEN
          CALL WSTRING(data,'     Newtonian Configuration','#',60,ier)
        ELSE IF( STYP.EQ.2.0d0 ) THEN
          CALL WSTRING(data,'     Cassegrain Configuration','#',60,ier)
        ELSE IF( STYP.EQ.3.0d0 ) THEN
          CALL WSTRING(data,'     Gregorian Configuration','#',60,ier)
        ELSE
          CALL WSTRING(data,'     Unknown Configuration','#',60,ier)
        END IF

        WRITE(data,20000) D1
        CALL WSTRING(data,'     Primary Diameter (m)','#',60,ier)

        WRITE(data,20000) F1
        CALL WSTRING(data,'     Primary Focal Ratio','#',60,ier)

        WRITE(data,20000) FS
        CALL WSTRING(data,'     System Focal Ratio','#',60,ier)

        WRITE(data,20000) VE
        CALL WSTRING(data,'     Vertex Distance (m)','#',60,ier)

        WRITE(data,20000) FIELD
        CALL WSTRING(data,'     Field Diameter (arcmin)','#',60,ier)

        WRITE(data,20000) PBAFFLE
        CALL WSTRING(data,'     Primary Obstruction (m)','#',60,ier)

        WRITE(data,20000) ALPHA1
        CALL WSTRING(data,'     Primary Asphere','#',60,ier)

        WRITE(data,20000) ALPHA2
        CALL WSTRING(data,'     Secondary Asphere','#',60,ier)

        WRITE(data,20000) SPOTSIZE
        CALL WSTRING(data,'     RMS Angular Image Radius Tolerance (arcsec)',
     *                    '#',60,ier)

        IF( RNUM.LT.3.0d0 ) GOTO 495

        WRITE(data,20000) VT
        CALL WSTRING(data,'     Height of Tertiary Above Vertex (m)',
     *                    '#',60,IER)

        IF( RNUM.LT.4.0d0 ) GOTO 495
        IF( PSPACE.LE.0.0d0 ) GOTO 495

        WRITE(data,20000) PSPACE
        CALL WSTRING(data,'     Separation of Primaries (m, center-to-center)','#',60,IER)

        WRITE(data,20000) VH
        CALL WSTRING(data,'     Height of Beam Combiner Above Vertex Plane (m)',
     *                    '#',60,IER)

        WRITE(data,20000) YOCOMB
        CALL WSTRING(data,'     Lateral Offset of Combined Focus (m)',
     *                    '#',60,IER)

        IF( RNUM.LT.5.0d0 ) GOTO 495

        WRITE(data,20000) ZELAX
        CALL WSTRING(data,'     Height of El. Axis Above Vertex Plane (m)',
     *                    '#',60,IER)

        WRITE(data,20000) YELAX
        CALL WSTRING(data,'     Lateral Offset of El. Axis (m)',
     *                    '#',60,IER)


495     CALL WSTRING(data,' ',' ',60,ier)       ! Blank line terminates read

        CALL WSTRING(data,'End of Data File for CASS.F77',' ',60,ier)

!  Close Data File
        CLOSE( data )



500     CONTINUE

!  Check for Existence of Default Output File
520     IF( LENSTR(ONAME).LE.0 ) THEN
            EX = .FALSE.
        ELSE
            INQUIRE( file=ONAME, exist=EX )
        END IF

        PRINT *,'  Output File: '
        CALL WSTRING(-1,ONAME,'#',40,IER)

        YN = 'Y<NUL>'
!  Should a Fresh Output File Be Created
530     IF ( EX ) THEN
            GOTO 540
        ELSE
            GOTO 560
        END IF

540     CALL MASKYN(-1,'  Do you want to append to the existing file',
     *                  YN, 80, IER, *570, *550, *500, *540 )

550     CALL MASKYN(-1,'  Should an output file with a new name be created',
     *                  YN, 80, IER, *560, *600, *540, *550 )

!  Name of Output File
560     CALL MNAME(-1, '  Enter name of output file: ',
     *                  ONAME, 80, IER, *560, *550, *560 )

        INQUIRE( file=ONAME, exist=EX )

        PRINT *,'  Output File: '
        CALL WSTRING(-1,ONAME,'#',40,IER)

        IF( EX ) THEN
            GOTO 540
        ELSE
            GOTO 600
        END IF


!  Open Old Output File to Append
570     OPEN(out, file=ONAME, status='OLD', position='END', err=9100,
     *          iostat=IER, pad='YES', carriagecontrol='FORTRAN' )

!  Write Header on Output File
        CALL WSTRING(out,'OUTPUT FILE for CASS.F77, Third Order Aberration Calculations',
     *          '0',80,ier)
        CALL WSTRING(out,'  Version ',' ',60,ier)
        CALL WSTRING(out, version, '#', 10, ier)
        CALL WSTRING(out,'   Executed: ','#',20,ier)
        CALL WSTRING(out,DATE,'#',30,ier)

        GOTO 700


!  Open Fresh Output File
600     OPEN(out, file=ONAME, status='FRESH', err=9100,
     *          iostat=IER, pad='YES', carriagecontrol='FORTRAN' )

!  Write Header on Output File
        CALL WSTRING(out,'OUTPUT FILE for CASS.F77, Third Order Aberration Calculations',
     *          '#',80,ier)
        CALL WSTRING(out,'  Version ',' ',60,ier)
        CALL WSTRING(out, version, '#', 10, ier)
        CALL WSTRING(out,'   Executed: ','#',20,ier)
        CALL WSTRING(out,DATE,'#',30,ier)





700     CONTINUE
!  Show the Data

        CALL WSTRING(-1, TITLE, '0', 80, IER )
        CALL WSTRING(out, TITLE, '0', 80, IER )

        CALL TOUT( 'Telescope Input Parameters' )

        CALL WOUT( RNUM,'     Number of Mirrors in Optical Train' )

        IF( STYP.EQ.0.0d0 ) THEN
          CALL WOUT( STYP,'     Prime Focus Configuration' )
        ELSE IF( STYP.EQ.1.0d0 ) THEN
          CALL WOUT( STYP,'     Newtonian Configuration' )
        ELSE IF( STYP.EQ.2.0d0 ) THEN
          CALL WOUT( STYP,'     Cassegrain Configuration' )
        ELSE IF( STYP.EQ.3.0d0 ) THEN
          CALL WOUT( STYP,'     Gregorian Configuration' )
        ELSE
          CALL WOUT( STYP,'     Unknown Configuration' )
        END IF

        CALL WOUT( D1,'     Primary Mirror Diameter (m)' )

        CALL WOUT( F1,'     Primary Focal Ratio' )

        CALL WOUT( FS,'     System Focal Ratio' )

        EVE = VE

        IF( RNUM.GE.4.0d0 ) THEN
            CALL WOUT( VE,'     Vertex Plane -- Focus Distance (m)' )

        ELSE IF( RNUM.EQ.3.0d0 ) THEN
            CALL WOUT( VE,'     Axis -- Focus Distance (m)' )

        ELSE
            CALL WOUT( VE,'     Vertex -- Focus Distance (m)' )

        END IF


        CALL WOUT( FIELD,'     Field Diameter (arcmin)' )

        CALL WOUT( PBAFFLE,'     Primary Obstruction (m)' )

!  Calculate First Order Parameters

        CALL TOUT( 'Other Telescope Parameters' )

!  Primary Focal Length
        L1 = D1 * F1
        CALL WOUT( L1,'     Primary Focal Length (m)' )


!  System Focal Length
        LS = D1 * FS
        IF( STYP.EQ.0.0d0 ) LS = L1     ! Prime Focus
        IF( STYP.EQ.3.0d0 ) LS = -LS    ! Reverse for Gregorian
        CALL WOUT( LS,'     System Focal Length (m)' )


!  System Power
        POWER = 1.0d0 / LS


!  Magnification of Secondary
        MAGN = LS / L1
        CALL WOUT( MAGN,'     Magnification of Secondary "M"' )

!  Platescale
        PLATE = DABS( LS * 1000.0d0 / 206264.806d0 )

!  Field Radius Angle = Field diameter / 2 * rad/arcmin
        UBAR1 = FIELD / 2.0d0 * 0.000290888208666d0

!  Linear Diameter of Focal Plane
        FPDIA = FIELD * 0.060d0 * PLATE

!  Marginal Ray Height at Primary (m)
        Y1 = D1 / 2.0d0

!  Lagrange Invariant or a Relative Thereof = UBAR1 * Y1 + YBAR * U
        MLG = UBAR1 * Y1
        CALL WOUT( MLG,'     Throughput (UBAR1*Y1)' )

!  Half Angle of the Final Beam
        AS = DATAN( 0.5d0 / FS )
        CALL WOUT( AS,'     Half Angle of Telescope Light Cone (radians)' )

!  If more than 2 mirrors, Calculate the distance to the focal plane
        IF( RNUM.GE.4.0d0 ) THEN

            CALL WOUT( PSPACE,'     Separation of Primaries (m, center-to-center)' )

            CALL WOUT( VT,'     Height of Tertiary Above Vertex (m)' )

            CALL WOUT( VH,'     Height of Beam Combiner Above Vertex (m)' )

        ! lateral offset of combined focus along symmetry plane (sign ?)
            CALL WOUT( YOCOMB,'     Lateral Offset of Combined Focus (m)' )

        ! adjustment of vertex distance for combined coude focus
            IF( RNUM.GE.5.0d0 ) THEN
                VY = DABS( YOCOMB - YELAX )
                CALL WOUT( ZELAX,'     Height of Elevation Axis Above Vertex Plane (m)' )
                CALL WOUT( YELAX,'     Lateral Offset of Elevation Axis (m)' )

            ELSE
                VY = 0.0d0
            END IF

        ! In-plane Half Angle of Combined Beams for proper phasing
            AA = PSPACE / D1 * AS
            CALL WOUT( AA,'     Half Angle of Combined Chief Rays (rad)' )

        ! Half Angle of Combined Light Cone
            AC = ( PSPACE + D1 ) / D1 * AS
            CALL WOUT( AC,'     Half Angle of Combined Light Cone (rad)' )

        ! Out of Plane Angle of Chief Rays for Offset Combined Focus
            AL = 2.0d0 * YOCOMB / D1 * AS
            CALL WOUT( AL,'     Angle of Chief Ray for Lateral Offset (rad)' )

        ! Combined Beam F/ratio, The long way.
            FC = 0.5d0 / DTAN( AC )
            CALL WOUT( FC,'     Combined Beam Focal Ratio' )

        ! Impact Point of Chief Rays w/ respect to combined axis, in-plane
            BCX = ( VE + VH + VY ) * DSIN( AA )
            CALL WOUT( BCX,'     Impact Parameter on Beam Combiner,in-plane (m)' )

        ! Impact Point of Chief Rays w/ respect to combined axis, lateral
            BCY = ( VE + VH + VY ) * DSIN( AL )
            CALL WOUT( BCY,'     Impact Parameter on Beam Combiner,lateral (m)' )

        ! Angle of Ray from Tertiary to Beam Combiner
        ! This is the angle in the plane containing the optical axes.
            AG = DATAN( ( VH - VT ) / ( PSPACE/2.d0 - BCX ) )
            CALL WOUT( AG,'     In-plane Projected Angle from Tertiary to BC (rad)' )

        ! Rotation Azimuth of Ray from teritary to beam combiner
        ! This is also the wedge angle of the offset beam combiner +-.
        ! This is also the rotation azimuth of the tertiary mirror
           AZ = DATAN( ( YOCOMB - BCY ) / ( PSPACE/2.0d0 - BCX ) )
           CALL WOUT( AZ,'     Azimuth Angle from Tertiary to Beam Combiner (rad)' )
        ! Distance in horizontal plane from tertiary to beam combiner
           LDBC = DSQRT( ( YOCOMB - BCY )**2 + ( PSPACE/2.0d0 - BCX )**2 )

        ! Net Ray Angle from Tertiary to Beam Combiner (in that plane)
           AW = DATAN( ( VH - VT ) / LDBC )
           CALL WOUT( AW,'     Ray Angle from Tertiary to Beam Combiner (rad)' )

        ! Tilt of Tertiary Mirror
            AT = 0.5d0 * ( PI2 - AW )
            CALL WOUT( AT,'     Tertiary Tilt Angle from Optical Axis (rad)' )

        ! Half Angle of Beam Combiner
            AB = 0.5d0 * ( PI2 + AW + AA )
            CALL WOUT( AB,'     Half Angle of Beam Combiner Apex (rad)' )

        ! Pathlength from Beam Combiner to Focus
            BCFD = ( VH + VE + VY ) / DCOS( AA ) / DCOS( AL )
            CALL WOUT( BCFD,'     Pathlength from Beam Combiner to Focus (m)' )

        ! Effective Height of Beam Combiner Apex Above the Focal Plane
            BCH = VH + VE + VY - BCX / DTAN( AB)
            CALL WOUT( BCH,'     Height of Beam Combiner Apex Above Focal Plane (m)' )

        ! Pathlength from Tertiary to Focus
            TFD = LDBC / DCOS( AW )
            TFD = TFD + BCFD
            CALL WOUT( TFD,'     Pathlength from Tertiary to Focus (m)' )

        ! Effective Vertex Distance, ignoring folding flats
            EVE = TFD - VT
            CALL WOUT( EVE,'     Effective Vertex Distance (m)' )


        ! Folding Flats for Combined Coude Focus,  Still Experimental
            IF( RNUM.GE.5.0d0 ) THEN

            ! Effective Vertex Distance from M5 folding flat to focus
            !    Assumes M5 nominally 45 deg at elevation axis
                ZJUNK = ( VH - ZELAX + BCY ) / ( 1.0d0 + DSIN( AL ) )
                M5FD = BCFD - ZJUNK / DCOS( AA ) / DCOS( AL )
                CALL WOUT( M5FD,'     Pathlength from M5 to Focus (m)' )
            END IF

            IF( RNUM.GE.6.0d0 ) THEN

            ! Effective Vertex Distance from M6 folding flat to focus
            ! ???? Is this equation using the right strategy???
            ! Actual Pathlength is a function of Zenith Angle
                ZJUNK = DABS( YOCOMB - YELAX + M5FD*DSIN(AL) ) / 
     *                  ( 1.0d0 + DSIN( AL ) )
                M6FD = M5FD - ZJUNK / DCOS( AA ) / DCOS( AL )
                CALL WOUT( M6FD,'     ?Pathlength from M6 to Focus (m)' )
            END IF


        ELSE IF( RNUM.EQ.3.0d0 ) THEN

        ! Assume a bent cass or nasmyth configuration

            CALL WOUT( VT,'     Height of Tertiary Above Vertex (m)' )

        !       Let the tertiary Mirror be at 45 degrees
            AT = 0.5d0 * PI2
            CALL WOUT( AT,'     Tertiary Tilt from Axis (rad)' )

        !       Let VE be the distance from the axis
            TFD = DABS( VE )
            EVE = TFD - VT
            CALL WOUT( EVE,'     Effective Vertex Distance (m)' )

        END IF

        IF( RNUM.GE.2.0d0 ) THEN

        !  Separation of Primary and Secondary
                ! Conventional Cassegrain (convex)
            SEP = L1 * ( LS - EVE ) / ( LS + L1 )
                ! Gregorian (concave) uses negative LS
                ! See also W&R (6)
            CALL WOUT( SEP,'     Separation of M1 and M2 (m)' )

        !  Back Focal Distance from Secondary
            BFD = SEP + EVE
            CALL WOUT( BFD,'     Pathlength from Secondary to Focus (m)' )

        !  Parameter "L" = Separation / Back Focal Distance
            L = SEP / BFD
            CALL WOUT( L,'     "L" = Separation / Back Focal Distance' )

        !  Parameter BETA from W&R (3)
            BETA = ( BFD - SEP ) / L1
            CALL WOUT( BETA,'     "Beta" = Vertex Distance / Focal Length of M1')

        !  Parameter ETA from W&R (2)
            ETA = ( BFD - SEP ) / D1
            CALL WOUT( ETA,'     "Eta" = Normalized Vertex Back Focus')

        ELSE IF( RNUM.EQ.1.0d0 ) THEN

        !  Separation of Primary and Secondary
        !  Prime Focus Has No Secondary
                SEP = 0.0

        !  Back Focal Distance from Secondary
            BFD = SEP + EVE

        !  Parameter "L" = Separation / Back Focal Distance
            L = SEP / BFD
            CALL WOUT( L,'     "L" = Separation / Back Focal Distance' )

        !  Parameter BETA from W&R (3)
            BETA = ( BFD - SEP ) / L1
            CALL WOUT( BETA,'     "Beta" = Vertex Distance / Focal Length of M1')

        !  Parameter ETA from W&R (2)
            ETA = ( BFD - SEP ) / D1
            CALL WOUT( ETA,'     "Eta" = Normalized Vertex Back Focus')

        END IF


!  Size of Central Obstruction
        OBSS = ( PBAFFLE / D1 )**2
        IF( PBAFFLE.GT.0.0d0 ) THEN
          CALL WOUT( OBSS,'     Specified Central Obstruction (fractional area)' )
        END IF

        IF( (RNUM.GT.2.0d0) .AND. (VT.GE.0.0d0) ) THEN
!       Tertiary folds above primary
            DH1 = 0.0d0
            OBSH = 0.0d0

        ELSE IF( (RNUM.EQ.2.0d0) .AND. (EVE.LT.0.0d0) ) THEN
!       Cassegrain focus above vertex
            DH1 = 0.0d0
            OBSH = 0.0d0

        ELSE IF( RNUM.LT.2.0d0 ) THEN
!       Prime focus
            DH1 = 0.0d0
            OBSH = 0.0d0

        ELSE
!       Primary must have a hole, derived from W&R (16)
        ! W&R (16) is more complex to account for tilted chief rays.
        ! The simple equation was DH1 = FPDIA + 2.0d0 * UBAR1 * EVE
            DH1 = D1 * ETA / FS + FPDIA / MAGN / FS * (FS**2-ETA**2) / (F1+ETA)
            CALL WOUT( DH1,'     Diameter of Primary Hole (m)' )

!       Area of Central Obstruction
            OBSH = ( DH1 / D1 )**2
            CALL WOUT( OBSH,'     Obscuration by Cassegrain Hole (fractional area)' )

        END IF


!  Is there power on the secondary?  If not, calculate parameters for a 
!       Prime or Newtonian Focus
        IF( ( L1 / LS ) .EQ. 1.0d0 ) THEN

        ! Newtonian or Prime Focus, Secondary FL = infinity
            L2 = 0.0d0
            CALL WOUT( L2,'     Focal Length of Secondary (flat)' )

        !  Back Focal Distance from Pupil
            PFD = BFD + SEP

        !  Secondary Diameter = Beam Spread + Field Allowance
            IF( RNUM.GE.2.0 ) THEN
                D2 = BFD / FS  +  2.0d0 * UBAR1 * SEP
                CALL WOUT( D2,'     Diameter of Secondary (m)' )
            ELSE
                D2 = 0.0
            END IF

        !  Obscuration Caused by Secondary
            OBS2 = ( D2 / D1 )**2
            CALL WOUT( OBS2,'     Obscuration by Secondary (fractional area)' )

        !  Diameter of Beam at Secondary
            DBEAM2 = BFD / FS
            CALL WOUT( DBEAM2,'     Diameter of Beam at Secondary (m)' )

        ! Calculate the Primary Asphere if Not Specified
            IF( ALPHA1.EQ.0.0d0 ) THEN
                ALPHA1 = -1.0d0         ! Parabolic
                CALL WOUT( ALPHA1,'     Primary Asphere Parabolic' )
            ELSE
                CALL WOUT( ALPHA1,'     Primary Asphere Fixed' )
            END IF

                IF( ALPHA1.LT.0.0d0 ) THEN
                    ECC1 = DSQRT( - ALPHA1 )        ! Normal
                ELSE
                    ECC1 = - DSQRT( ALPHA1 )        ! Oblate Spheroid
                END IF
                CALL WOUT( ECC1,'     Primary Eccentricity' )

        ! Calculate Structural Aberration Coefficients for a Single Mirror
        !       Assume the Stop is at the Mirror,  These terms add to the 
        !       two mirror terms, but it was hard to trap 1-M in the code.

            CALL TOUT( 'Normalized Structural Aberration Coefficients' )

            SIG1 = 1.0d0 + ALPHA1
            CALL WOUT( SIG1,'     SigmaI' )

            SIG2 = -1.0d0
            CALL WOUT( SIG2,'     SigmaII' )

            SIG3 = 1.0d0
            CALL WOUT( SIG3,'     SigmaIII' )

            SIG4 = -1.0d0
            CALL WOUT( SIG4,'     SigmaIV' )

            SIG5 = 0.0d0
            CALL WOUT( SIG5,'     SigmaV' )


        ELSE
        ! Curved Secondary

        !  Secondary Focal Length
            L2 = 1.0d0 / ( 1.0d0/(SEP-L1) + 1.0d0/BFD )
            CALL WOUT( L2,'     Focal Length of Secondary (m)' )

        !  Pupil Position Relative to Secondary
            SPUPIL = 1.0d0 / ( 1.0d0/L2 - 1.0d0/SEP )
            CALL WOUT( SPUPIL,'     Pupil Position Relative to Secondary (m)' )

        !  Back Focal Distance from Pupil (virtual)
            PFD = BFD - SPUPIL

        !  Secondary Diameter = Beam Spread + Field Allowance
            D2 = BFD / FS  +  2.0d0 * UBAR1 * SEP
            CALL WOUT( D2,'     Vertex Diameter of Secondary (m)' )

        !  Obscuration Caused by Secondary
            OBS2 = ( D2 / D1 )**2
            CALL WOUT( OBS2,'     Obscuration by Secondary (fractional area)' )

        !  Diameter of Beam at Secondary
            DBEAM2 = BFD / FS
            CALL WOUT( DBEAM2,'     Diameter of Beam at Secondary (m)' )

        !  Normalized Marginal Ray Height at Secondary
            Y2 = 1.0d0 / ( 1.0d0 + MAGN * L )


        !  Calculate the Aspheres
            BIGY2 = ( 1.0d0 + MAGN ) / ( 1.0d0 - MAGN )

            K = ( 1.0d0 - MAGN )**3 / ( 1.0d0 + MAGN * L )

!!!! THIS COULD BE BETTER

        ! If ALPHA1 has not been defined, calculate RC Parameters
            IF( ALPHA1.EQ.0.0d0 ) THEN

            !  Ritchey-Chretien Conic Constants
            !  ALPHA1 used to set SIG1=0
                ALPHA1 = -1.0d0 - 2.0d0 / L / MAGN**3
                CALL WOUT( ALPHA1,'     Primary Asphere for RC' )

                IF( ALPHA2.EQ.0.0d0 ) THEN

                !  ALPHA2 used to set SIG2=0
                    ALPHA2 = 2.0d0 / L / K - BIGY2**2
                    CALL WOUT( ALPHA2,'     Secondary Asphere for RC' )

                ELSE

                    CALL WOUT( ALPHA2,'     Secondary Asphere Fixed' )

                END IF


        ! If ALPHA1 is fixed, calculate the relevant ALPHA2
            ELSE

                CALL WOUT( ALPHA1,'     Primary Asphere Fixed' )

                IF ( ALPHA2.EQ.0.0d0 ) THEN

                ! ALPHA2 used to set SIG1=0
                    ALPHA2 = - BIGY2**2 - MAGN**3 * (1.d0+ALPHA1) / K
                    CALL WOUT( ALPHA2,'     Secondary Asphere for Cass' )

                ELSE

                    CALL WOUT( ALPHA2,'     Secondary Asphere Fixed' )

                END IF

            END IF


        !  There are lots of ways to specify the asphere.
        !       W&R (20) use k = kappa - 1
        !       kappa = alpha + 1 = epsilon (from Wynne 1968)
        !       alpha = k
        !       eccentricity = sqrt( -alpha )

            IF( ALPHA1.LT.0.0d0 ) THEN
                ECC1 = DSQRT( - ALPHA1 )        ! Normal
            ELSE
                ECC1 = - DSQRT( ALPHA1 )        ! Oblate Spheroid
            END IF
            CALL WOUT( ECC1,'     Primary Eccentricity' )

            IF( ALPHA2.LT.0.0d0 ) THEN
                ECC2 = DSQRT( - ALPHA2 )        ! Normal
            ELSE
                ECC2 = - DSQRT( ALPHA2 )        ! Oblate Spheroid
            END IF
            CALL WOUT( ECC2,'     Secondary Eccentricity' )


        !  Calculate Structural Aberration Coefficients for 2 Mirror System

            CALL TOUT( 'Normalized Structural Aberration Coefficients' )

            BY2A = BIGY2**2 + ALPHA2

            SIG1 = MAGN**3*(1.d0+ALPHA1) + K*BY2A
            CALL WOUT( SIG1,'     SigmaI' )

            SIG2 = -1.0d0 + L*K/2.d0*BY2A
            CALL WOUT( SIG2,'     SigmaII' )

            SIG3 = 1.0d0 - (1.d0-MAGN)*L + L**2*K/4.d0*BY2A
            CALL WOUT( SIG3,'     SigmaIII' )

            SIG4 = -1.0d0 - MAGN*L*(1.d0-MAGN)
            CALL WOUT( SIG4,'     SigmaIV' )

            SIG5 = L*(1.d0-MAGN)
     *               - L**2/4.d0*(1.d0-MAGN)*(3.d0-MAGN) + L**3/8.d0*K*BY2A
            CALL WOUT( SIG5,'     SigmaV' )

        END IF



!  Sagitta of Primary Mirror
        SAG1 = D1**2 / 16.0d0 / L1 / DSQRT(1.0d0 - (ALPHA1+1)*(D1/2.0d0/L1)**2)
        CALL WOUT( SAG1,'     Sagitta of Primary Mirror' )

!  Sagitta of Secondary Mirror
        IF( RNUM.GE.2.0d0) THEN         ! Is there a secondary?

          IF( L1.NE.LS ) THEN           ! Does it have power?

          ! Calculate sagitta from vertex diameter and asphere
            SAG2 = D2**2/16.0d0/L2/DSQRT(1.0d0-(ALPHA2+1)*(D2/2.0d0/L2)**2)
            CALL WOUT( SAG2,'     Sagitta of Secondary Mirror' )

          ! Calculate New Edge Diameter of the Secondary Adjusting Beam Spread
            D2 = (BFD - SAG2) / FS  +  2.0d0 * UBAR1 * SEP
            CALL WOUT( D2,'     Diameter of Secondary Mirror' )

          ELSE
          ! Flat Secondary
            SAG2 = 0.0d0

          END IF

        END IF

!  Angle of Off-Axis (field) Chief Ray for a single Telescope
        AX = DASIN( FPDIA / 2.0d0 / PFD )

        IF( RNUM.GE.3.0d0 ) THEN

        ! Size of the Point Beam at the Tertiary
            DBEAM3 = TFD / FS
            CALL WOUT( DBEAM3,'     Diameter of Beam at Tertiary (m)' )

        ! Size of the Tertiary
            D3 = TFD * 2.0d0 * DTAN( AS ) + FPDIA - TFD * 2.0d0 * DTAN( AX )
            CALL WOUT( D3,'     Minor Axis Diameter of Tertiary (m)' )

            D3MAJ = D3 / COS( AT )
            CALL WOUT( D3MAJ,'     Major Axis Diameter of Tertiary (m)' )

        ! Obscuration by the Tertiary in the Converging Beam
            IF( VT.GT.0.0d0 ) THEN

              ! Focal ratio of the hole in the converging beam from a central
                ! obstruction other than the tertiary.  Does not account for
                ! an off-axis shadow from the secondary mirror.
              FH = L1 / DMAX1( D2, PBAFFLE )

              ! Highest point on the tertiary.  This does not account for
                ! decentering the tertiary to minimize the obscuration.
              VTEXT = VT + D3 * DTAN(AT) / 2.0d0

              ! Diameter of the hole in the point converging beam at tertiary.
              DBEAM3H = ( L1 - VTEXT ) / FH
!              CALL WOUT( DBEAM3H,'     Converging Beam I.D. above Tertiary (m)' )

              ! Half angle of the hole in the converging beam (equivalent AS)
              ASH = DATAN( 0.5d0 / FH )

              ! Angle of off-axis (field) chief ray from prime focus.
                ! Primary focal length is the distance from focus to exit pupil
                ! Diameter of focal plane at prime is FPDIA / MAGN
              AXP = DASIN( FPDIA / MAGN / 2.0d0 / L1 )

              ! Diameter of the clear hole in the converging beam at the
                ! maximum height of tertiary including the field
              DCLEAR3 = (L1-VTEXT) * 2.0d0 * DTAN(ASH) - FPDIA / MAGN
     *                + (L1-VTEXT) * 2.0d0 * DTAN(AXP)
              CALL WOUT( DCLEAR3,'     Hole in Converging Light above Tertiary (m)' )

              ! Is the tertiary smaller than the clear hole?
              IF( D3 .GT. DCLEAR3 ) THEN

                ! This assumes a circular tertiary, lower estimate.
                OBS3 = (  D3 / D1  *  L1 / (L1-VT)  ) ** 2
                CALL WOUT( OBS3,'     Minimum Obscuration by Tertiary (fractional area)' )
                ! This assumes top edge of elliptical tertiary, upper estimate.
                OBS3 = (  D3 / D1  *  L1 / (L1-VTEXT)  ) ** 2
                CALL WOUT( OBS3,'     Maximum Obscuration by Tertiary (fractional area)' )

              ELSE
                OBS3 = 0.0d0
              ENDIF

            ELSE
                OBS3 = 0.0d0
            END IF

        END IF

        IF( RNUM.GE.4.0d0 ) THEN

        ! Size of the Point Beam at the Beam Combiner
            DBEAM4 = BCFD / FS
            CALL WOUT( DBEAM4,'     Diameter of Beam at Beam Combiner (m)' )

        ! Size of the Beam Combiner Facet
            D4 = BCFD * 2.0d0 * DTAN( AS ) + FPDIA - BCFD * 2.0d0 * DTAN( AX )
            CALL WOUT( D4,'     Minor Axis Diameter of Beam Combiner Facet (m)' )
        ! These numbers do not take beam combiner wedge for lateral offset into
        !       account.  Assume Wedge Angle << Apex Angle.

        ! Maximum Unvignetted Field
            UVRAD = PFD * DSIN( AA ) * BCH / ( PFD * COS( AA ) - BCH )
            CALL WOUT( UVRAD,'     Unvignetted Field Radius wrt/BC (m)' )

            UVFLD = UVRAD * 2.0d3 / 6.0d1 / PLATE
            CALL WOUT( UVFLD,'     Unvignetted Field Diameter wrt/BC (arcmin)' )

        END IF

        IF( RNUM.GE.5.0d0 ) THEN

        ! Size of the Point Beam at the Beam Combiner
            DBEAM5 = M5FD / FS
            CALL WOUT( DBEAM5,'     Diameter of Beam at Folding Flat 5 (m)' )

        ! Size of the Flat for One Telescope
            D5 = M5FD * 2.0d0 * DTAN( AS ) + FPDIA - M5FD * 2.0d0 * DTAN( AX )
            CALL WOUT( D5,'     Minor Axis Diameter of Folding Flat 5 (m)' )

        ! Size of the Flat for Both Beams
            DLONG5 = D5 + M5FD * DSIN( AA ) * 2.0d0
            CALL WOUT( DLONG5,'     Combined Length of Folding Flat 5 (m)' )

        ! Note: The actual shape of this mirror is 
        !         DLONG5  wide  by  D5 / COS( tilt ) high

        END IF

        IF( RNUM.GE.6.0d0 ) THEN

        ! Size of the Point Beam at the Beam Combiner
            DBEAM6 = M6FD / FS
            CALL WOUT( DBEAM6,'     Diameter of Beam at Folding Flat 6 (m)' )

        ! Size of the Flat for One Telescope
            D6 = M6FD * 2.0d0 * DTAN( AS ) + FPDIA - M6FD * 2.0d0 * DTAN( AX )
            CALL WOUT( D6,'     Minor Axis Diameter of Folding Flat 6 (m)' )

        ! Size of the Flat for Both Beams
            DLONG6 = D6 + M6FD * DSIN( AA ) * 2.0d0
            CALL WOUT( DLONG6,'     Combined Length of Folding Flat 6 (m)' )

        ! Note: The actual shape of this mirror is 
        !         DLONG6  wide  by  D6 / COS( tilt ) high

        END IF

!  Calculate Net Obstruction of the Telescope and Collecting Area

        ! Select maximum obscuration between primary, secondary, tertiary
        OBSN = DMAX1( OBSS, OBSH, OBS2, OBS3 )
        CALL WOUT( OBSN,'     Net Telescope Obscuration (fractional area)' )

        ! Calculate Primary Collecting Area
        CAREA = PI2 / 2.0d0 * D1**2
        CAREA = CAREA * ( 1.0d0 - OBSN )
        CALL WOUT( CAREA,'     Net Telescope Collecting Area (m**2)' )


!  Calculate Third Order Aberrations in Microns

        CALL TOUT( 'Wavefront Aberration Coefficients' )

        W040 = Y1**4 / 32.d0 * POWER**3 * SIG1 * 1.D6
        CALL WOUT( W040,'     W040  (microns)  Spherical Aberration' )

        W131 = MLG / 4.d0 * Y1**2 * POWER**2 * SIG2 * 1.D6
        CALL WOUT( W131,'     W131  (microns)  Coma' )

        W222 = 0.5d0 * MLG**2 * POWER * SIG3 * 1.D6
        CALL WOUT( W222,'     W222  (microns)  Astigmatism' )

        W220P = 0.25d0 * MLG**2 * POWER * SIG4 * 1.D6
        CALL WOUT( W220P,'     W220P (microns)  Field Curvature' )

        W311 = MLG**3 / Y1**2 * SIG5 * 1.D6
        CALL WOUT( W311,'     W311  (microns)  Distortion' )


!  Image Plane Params

        CALL TOUT( 'Focal Plane Parameters' )

        CALL WOUT( PLATE,'     Platescale (mm/arcsec)' )

        CALL WOUT( UBAR1,'     Field Radius Angle (radians)' )

        CALL WOUT( FPDIA,'     Linear Diameter of Focal Plane (m)' )


!  Calculate Allowed Image Size Tolerance

        CALL WOUT( SPOTSIZE,'     RMS Angular Image Radius Tolerance (arcsec)' )

        EBAR = SPOTSIZE * PLATE * 1.0D3
        CALL WOUT( EBAR,'     RMS Physical Image Radius Tolerance (microns)' )

        W2E2 = ( EBAR / 2.d0 / FS )**2
!        CALL WOUT( W2E2,'     W2E2' )


!  Calculate Fractional Field Angle with Largest Acceptable Images

!  Assume a curved focal plane so DW20 is set at height of best images

        ! Find the Roots of the RW20 Equation in Height Squared

        ! ACOEF * H**4 + BCOEF * H**2 + CCOEF = 0
        ACOEF = -0.5d0 * W222**2
        BCOEF = -2.d0/3.d0 * W131**2
        CCOEF = W2E2 - 4.d0/9.d0 * W040**2

        ! B**2 - 4AC
        HMAX = BCOEF**2 - 4.d0 * ACOEF * CCOEF

        ! Make sure there are real roots
        IF( HMAX.GE.0.0D0 ) THEN
            ! ( - B - SQRT ) / 2A
            HMAX = ( - BCOEF - DSQRT( HMAX ) ) / 2.d0 / ACOEF
            ! Make sure there are positive roots  ?????
            IF( HMAX.LT.0.0d0 ) HMAX = 0.0d0
        ELSE
            HMAX = 0.0D0
        END IF

        ! Convert Height Squared to Height
        HMAX = DSQRT( HMAX )
        CALL WOUT( HMAX,'     Fractional Curved Field Radius' )

        FMAX = HMAX * FIELD
        CALL WOUT( FMAX,'     Maximum Curved Field Diameter (arcmin)' )

!  Assume Focal Plane is a parabola, see also Depth of Focus Calculations below
!       Positive ROC turns out to be concave UP in a regular Cass telescope.
!       This sign convention may be reverse from W&R (30)
        FPROC = FPDIA**2 * 1.0d6 / 64.d0 / FS**2 / ( W220P + W222 )
        CALL WOUT( FPROC,'     Focal Plane Radius of Curvature (m)' )


!  Assume a flat focal plane
!       This may mean shifting away from the best axial focus

        ! Calculate Range of Focus on the Axis ( H = 0 )
        RW20 = W2E2  -  4.d0/9.d0 * W040**2
        IF( RW20.LT.0.0d0 ) THEN
            RW20 = 0.0d0
        ELSE
            RW20 =  DSQRT( 0.5d0 * RW20 )
        END IF

        ! Offset the flat plane toward the curvature
        RW20 = - DSIGN( RW20, FPROC )

        ! Calculate Best Focus Height at Maximum Field Calculated Above
        DW20 = -4.d0/3.d0 * W040 - ( W220P + W222 ) * HMAX**2

        ! Is Maximum Flat Field Set by Curvature or Aberrations?
        IF( DABS(RW20).LT.DABS(DW20) ) DW20 = RW20


        ! Find the Roots of the RW20 Equation in Height Squared
        !       Equation Now Includes the DW20 Terms

        ! ACOEF * H**4 + BCOEF * H**2 + CCOEF = 0
        ACOEF = -0.5d0 * W222**2 - 2.0d0 * ( W220P + 0.5d0 * W222 )**2
        BCOEF = -2.d0/3.d0 * W131**2
     *          - 4.d0 * (DW20 + 4.d0/3.d0*W040) * ( W220P + 0.5d0 * W222 )
        CCOEF = W2E2 - 4.d0/9.d0 * W040**2 - 2.d0 * (DW20 + 4.d0/3.d0*W040)**2

        ! B**2 - 4AC
        HLAX = BCOEF**2 - 4.d0 * ACOEF * CCOEF

        ! Make sure there are real roots
        IF( HLAX.GE.0.0D0 ) THEN
            ! ( - B - SQRT ) / 2A
            HLAX = ( - BCOEF - DSQRT( HLAX ) ) / 2.d0 / ACOEF
            ! Make sure there are positive roots  ?????
            IF( HLAX.LT.0.0d0 ) HLAX = 0.0d0
        ELSE
            HLAX = 0.0D0
        END IF

        ! Convert Height Squared to Height
        HLAX = DSQRT( HLAX )
        CALL WOUT( HLAX,'     Fractional Flat Field Radius' )

        FLAX = HLAX * FIELD
        CALL WOUT( FLAX,'     Maximum Flat Field Diameter (arcmin)' )

        ! Calculate Focus Position of Best Flat Field (mm)
        DW20M = DW20 * 8.d0 * FS**2 / 1.0d3
        CALL WOUT( DW20M,'     Height of Largest Flat Field (mm)' )



!  Calculate Field-Focus Curve

        NSTEP = 20

        WRITE(*,22000)
        WRITE(out,22000)
22000   FORMAT( 1X,'Field Focus Curve for aligned system',/,
     *          1X,'     Radius        Focal Plane Height',
     *          1X,'     Image Size         Wave Aberration',/,
     *          1X,' (mm)   (arcmin)    (mm)     (+/-mm) ',
     *          1X,'  (micron)  (arcsec)      (micron rms)' )

!       Loop from Center to Edge of Field
        DO IH = 0, NSTEP

        ! Calculate Fractional Field Height
            H = DBLE(IH) / DBLE(NSTEP)

        ! Calculate Best Focus Location
            DW20 = -4.d0/3.d0 * W040 - ( W220P + W222 ) * H**2

        ! Calculate Range of Focus
            RW20 = W2E2  -  4.d0/9.d0 * W040**2
     *                   -  2.d0/3.d0 * W131**2 * H**2
     *                   -  0.5d0     * W222**2 * H**4
            IF( RW20.LT.0.0d0 ) THEN
                RW20 = 0.0d0
            ELSE
                RW20 = DSQRT( 0.5d0 * RW20 )
            END IF

        ! Calculate the RMS Image Radius
            RMSIS = 2.d0/3.d0 * W131**2 * H**2
     *              + 4.d0/9.d0 * W040**2
     *              + 0.5d0 * W222**2 * H**4
        !       in microns
            RMSIS = DSQRT( RMSIS ) * 2.0d0 * FS
        !       in arcsec
            RMSIA = RMSIS / 1.d3 / PLATE

        ! Calculate Field Angle in arcminutes
            HA = H * FIELD / 2.d0

        ! Calculate Field Position in MM
            HM = HA * 60.0d0 * PLATE

        ! Convert Depth of Focus to Millimeters
            DW20M = DW20 * 8.d0 * FS**2 / 1.d3
            RW20M = RW20 * 8.d0 * FS**2 / 1.d3
            IF(IH.EQ.0) XRW20M = RW20M  ! Save the Center Depth of Focus

        ! Calculate the Wave Aberration Variance
        !   This is not the surface of minimum wavefront error.
            WAVEAB = ( DW20 + W040 + (W220P+W222/2.d0) * H**2 )**2 / 12.d0
     *               + W040**2 / 180.d0
     *               + (W222*H**2)**2 / 24.d0
     *               + (W131*H)**2 / 72.d0
            WAVEAB = DSQRT( WAVEAB )

            WRITE(*,22002) HM, HA, DW20M, RW20M, RMSIS, RMSIA, WAVEAB
            WRITE(out,22002) HM, HA, DW20M, RW20M, RMSIS, RMSIA, WAVEAB

22002   FORMAT( 1X, F7.2, 1X, F6.2, 5X, G10.4, G9.3, 1X, G9.3,
     *          1X, G9.3, 5X, G9.3 )

        END DO



        IF( RNUM.GE.2.0d0 ) THEN

            CALL TOUT( 'Secondary Alignment Tolerances based on RMS Image Radius' )


!  Calculate Focus Wavefront Error caused by secondary axial motion
        ! Ignore the sign and assume other aberrations are small
            SW020 = MAGN**2 / 8.0d0 / FS**2
            CALL WOUT( SW020,'     Wavefront Focus -- Axial Motion (micron/micron)' )

!  Calculate Secondary Focus = Axial Motion Tolerance
        !       This gives it all the remaining spot size by using the whole 
        !       focus range.
            SRW20M = XRW20M / MAGN**2 * 1.0d3
            CALL WOUT( SRW20M,'     Secondary Focus Tolerance (on-axis) -- Axial Motion (micron)' )
            SRW20M = RW20M / MAGN**2 * 1.0d3
            CALL WOUT( SRW20M,'     Secondary Focus Tolerance (field) -- Axial Motion (micron)' )

        !  Change in Scale with Axial Motion without refocus 1/micron
            XDYA = 1.d-6/LS * ( MAGN**2 * (2.d0+BETA) + BETA ) / MAGN /(1.d0+BETA)
            CALL WOUT( XDYA,'     Scale Change Without Refocus (fraction/micron)')

        !  Change in Scale with Axial Motion with refocus 1/micron
            XDYRA = 1.d-6/LS * (1.d0 - MAGN**2) / 4.d0 / (1.d0+BETA)
            CALL WOUT( XDYRA,'     Scale Change With Refocus (fraction/micron)')

        !  Spherical Aberration Induced by Axial Motion
            SW040 = (MAGN+1.d0) * ( 2.d0 * MAGN * (MAGN-1.d0) * (FS-ETA) +1.d0)
     $              /256.d0 / FS**3 / F1 / (FS-ETA)
            CALL WOUT( SW040,'     Wavefront Spherical Aberration -- Axial Motion (micron/micron)')
        !  What Image Radius does this produce? 
        !  In microns = 2 * FS * SQRT( 4/9 W040**2 )
           RSPOT = 1.333d0 * FS * SW040
           CALL WOUT( RSPOT,'       Induced Image Radius (micron/micron)' )
        !  In arcsec
           RSPOT = RSPOT / 1.d3 / PLATE
           CALL WOUT( RSPOT,'       Induced Image Radius (arcsec/micron)' )
        !  How much motion is tolerable?
           RSPOT = SPOTSIZE / RSPOT
           CALL WOUT( RSPOT,'       Tolerable Secondary Motion (micron)' )
        !  How much does this move the focal plane?
           FSPOT = - RSPOT * MAGN ** 2 / 1.d6
           CALL WOUT( FSPOT,'       Tolerable Focal Plane Motion (m)' )

!  Calculate the Location of the Zero-Coma Pivot Point, W&R (60)
            ZCP = 2.d0 * L2 * (MAGN+1.d0) / ( (MAGN+1.d0) -ALPHA2*(MAGN-1.d0) )
            CALL WOUT( ZCP,'     Distance from M2 to Zero-Coma Pivot (m)' )
   
!  Calculate the location of Zero-Coma Point Relative to Prime Focus
            ZCPPF = L1 - SEP + ZCP
            CALL WOUT( ZCPPF,'     Distance from Prime Focus to Zero-Coma Pivot (m)')

!  Calculate Image Motion from Zero-Coma Rotation
           AZCR = ( 2.d0 * L2 - ZCP ) * ( 1.d0 - MAGN ) / LS
           CALL WOUT( AZCR,'     Image Motion from Zero-Coma Rotation (arcsec/arcsec)')

!  Calculate Image Motion from Vertex Rotation
           AVTR = 2.d0 * L2 * ( 1.d0 - MAGN ) / LS
           CALL WOUT( AVTR,'     Image Motion from M2 Vertex Rotation (arcsec/arcsec)')

!  Calculate Induced Coma from Lateral Displacement
        !       This is Displacement from the Zero-Coma Pivot
           WCD = ( 1.d0 + (F1+ETA) / MAGN**2 / (FS-ETA) ) / 32.d0 / F1**3
           CALL WOUT( WCD,'     Wavefront Coma -- Lateral Motion (micron/micron)')
        !  What Image Radius does this produce? 
        !  In microns = 2 * FS * SQRT( 2/3 * W131**2 )
           RSPOT = 1.633d0 * FS * WCD
           CALL WOUT( RSPOT,'       Induced Image Radius (micron/micron)' )
        !  In arcsec
           RSPOT = RSPOT / 1.d3 / PLATE
           CALL WOUT( RSPOT,'       Induced Image Radius (arcsec/micron)' )
        !  How much motion is tolerable?
           RSPOT = SPOTSIZE / RSPOT
           CALL WOUT( RSPOT,'       Tolerable Motion (micron)' )

!  Calculate Induced Coma from M2 Vertex Rotation
           WVR = ZCP * WCD * 1.d6 / 206264.806d0
           CALL WOUT( WVR,'     Wavefront Coma -- Vertex Rotation (micron/arcsec)')

        !  What Image Radius does this produce? 
        !  In microns = 2 * FS * SQRT( 2/3 * W131**2 )
           RSPOT = 1.633d0 * FS * WVR
           CALL WOUT( RSPOT,'       Induced Image Radius (micron/arcsec)' )
        !  In arcsec
           RSPOT = RSPOT / 1.d3 / PLATE
           CALL WOUT( RSPOT,'       Induced Image Radius (arcsec/arcsec)' )
        !  How much motion is tolerable?
           RSPOT = SPOTSIZE / RSPOT
           CALL WOUT( RSPOT,'       Tolerable Rotation (arcsec)' )

!  Calculate Induced Coma from M2 Vertex Chop in focal plane units
           WCV = WVR / AVTR
           CALL WOUT( WCV,'     Wavefront Coma -- Vertex Chop Angle (micron/arcsec)')

        !  What Image Radius does this produce? 
        !  In microns = 2 * FS * SQRT( 2/3 * W131**2 )
           RSPOT = 1.633d0 * FS * WCV
           CALL WOUT( RSPOT,'       Induced Image Radius (micron/arcsec)' )
        !  In arcsec
           RSPOT = RSPOT / 1.d3 / PLATE
           CALL WOUT( RSPOT,'       Induced Image Radius (arcsec/arcsec)' )
        !  How much motion is tolerable?
           RSPOT = SPOTSIZE / RSPOT
           CALL WOUT( RSPOT,'       Tolerable Chop Throw (arcsec)' )

        !  What is permissible Zero Coma Chop before astigmatism gets you?
           AFUDGE = 9.54d-07            ! Constant for Chop in Arcsec
           WZCA = 0
           CALL WOUT( WZCA,'     Wavefront Astigmatism -- Zero Coma Chop (micron/arcsec)' )
        !  In microns
        !  In arcsec
!           RSPOT = AFUDGE * L * FS / F1**2
!          CALL WOUT( RSPOT,'       Induced Image Radius at field center (arcsec/arcsec)' )
        !  How much motion is tolerable
           ACHOP = DABS( SPOTSIZE * F1**2 / AFUDGE / L / FS )
           ACHOP = DSQRT( ACHOP )
           CALL WOUT( ACHOP,'       Tolerable Zero Coma Chop Throw (arcsec), astig only')

        END IF          ! End of Secondary Alignment

!  Close Output File
        CLOSE( out )



!  Ask about graphics output



!  Ask about RAYTRC Output
5000    CONTINUE

        YN = 'N<nul>'
5010    CALL MASKYN( -1, '  Do you want a RAYTRC data file',
     *                  YN, 80, IER, *5020, *6000, *5000, *5010 )

5020    CONTINUE

!  Get the Data File Name
        CFILE = 'CASS.RAY<nul>'
5022    CALL MNAME( -1, '  Enter name of Ray file: ',
     *                  CFILE, 29, IER, *5100, *5010, *5022 )


5100    CALL SETOP(0)
!  Set the File Label
        CALL CONCAT( 'Data from CASS.F77: <nul>',TITLE,RLAB,80,IER)
        CALL STRPAD( RLAB, 80, IER )    ! Pad with Blanks to 80 characters
        LABEL = RLAB(1:80)      ! Copy String to Get Rid of Trailing Null

        MTCHF = 1               ! Type Chief Ray
        MPCHF = 1               ! Print Chief Ray
        NWVL  = 1               ! 1 wavelength
        WVLN(1) = 5000.0
        INMM  = 1               ! units = MM
        IDGRD = 1               ! units = RAD
        ICXY  = 1               ! 'R' image parameter
        FRC   = 0.63            ! Fraction of light in image
        MIDOP = 1
        NGL   = 0               ! Number of User Glasses
        RTYASK = 'NO'
        RPNASK = 'NO'
        RSTASK = 'NO'
        ITYASK = 'NO'
        IPNASK = 'NO'
        ISTASK = 'NO'
        CYLASK = 'NO'
        IJOP = 1                ! Set Operation 1

!  Factors for Generating Ray Bundle
5110    CALL SETOP(IJOP)
        MMOP(IJOP) = 1          ! Generate Ray Bundle
        COMMNT(IJOP) = '"GENERATE INCOMING RAY BUNDLE"'
        NAZ = 16
        NRD = 12
        NDXR(1) = 0
        FMX = D1 / 2.0d0 * 1d3          ! Outer Radius
        FMN = DH1 / 2.0d0 * 1d3         ! Inner Radius
        IF( D2.GT.DH1 ) FMN = D2 / 2.0d0 * 1d3
        NDXR(JNDX) = 0          ! Set Medium = AIR
        INF = 0                 ! Object at Infinity
        MMT = 0

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  This could be better if Actual Vignetting at the Secondary were calculated.


!  Factors for Translation to Primary (from near secondary)\
!       This is only needed because RAYTRC has trouble with negative OPD
5118    CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO PRIMARY"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) = -SEP * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors for Rotating Off Axis
5120    CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE OFF-AXIS"'
        PPH(JROT) = 0.0
        TTH(JROT) = UBAR1
        WWM(JROT) = 0.0
        
        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors for Reflection Off Primary
5130    CALL SETOP(IJOP)
        MMOP(IJOP) = 4
        COMMNT(IJOP) = '"REFLECT OFF PRIMARY MIRROR"'
        KTYP(JSRF) = 2          ! Conic Surface
        RADCRV(JCON) = L1 * 2.0d0 * 1d3      ! Radius of Curvature
        EECSQ(JCON) = - ALPHA1  ! Eccentricity Squared
        LAXC(JCON) = 1          ! Axial Symmetry
        NCVX(JCON) = 1          ! Convex Direction
        JJT(JSRF) = 2           ! Reflective Surface
        JIMSRF(JSRF) = 0        ! Plot Flag

        JTYSRF(JSRF) = 0        ! Don't Type Surface
        JPNSRF(JSRF) = 0        ! Don't Print Surface
        JSTSRF(JSRF) = 0        ! Don't Store Surface
        NNVG(JSRF) = 0          ! No Vignetting Boundaries
        NTVG(JSRF) = 1          ! Trace if Vignetted

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

        IF( RNUM.LT.2.0d0 ) GOTO 5200


!  Factors for Translation to Secondary
5140    CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO SECONDARY"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) = SEP * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors for Translation to Zero-Coma Pivot
        CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO ZERO-COMA PIVOT"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  - ZCP * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

!  Factors to Rotate Around Zero-Coma Pivot
!       A positive angle moves image in -X direction
        CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE AT PIVOT"'
        PPH(JROT) = 0.0
        TTH(JROT) = 0.0
        WWM(JROT) = 0.0

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors for Translation back to secondary from pivot
        CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE BACK TO SECONDARY"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  ZCP * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors for Reflection Off Secondary
5150    CALL SETOP(IJOP)
        MMOP(IJOP) = 4
        COMMNT(IJOP) = '"REFLECT OFF SECONDARY MIRROR"'
        KTYP(JSRF) = 2          ! Conic Surface
        RADCRV(JCON) = - L2 * 2.0d0 * 1d3    ! Radius of Curvature
        EECSQ(JCON) = - ALPHA2  ! Eccentricity Squared
        LAXC(JCON) = 1          ! Axial Symmetry
        NCVX(JCON) = 1          ! Convex Direction
        JJT(JSRF) = 2           ! Reflective Surface
        JIMSRF(JSRF) = 0        ! Plot Flag

        JTYSRF(JSRF) = 0        ! Don't Type Surface
        JPNSRF(JSRF) = 0        ! Don't Print Surface
        JSTSRF(JSRF) = 0        ! Don't Store Surface
        NNVG(JSRF) = 0          ! No Vignetting Boundaries
        NTVG(JSRF) = 1          ! Trace if Vignetted


        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors for Translation to Zero-Coma Pivot
        CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO ZERO-COMA PIVOT"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  - ZCP * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

!  Factors to Rotate back to the primary axis
!       use angle of opposite sign compared to the one above.
        CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE AT PIVOT"'
        PPH(JROT) = 0.0
        TTH(JROT) = 0.0
        WWM(JROT) = 0.0

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors for Translation back to secondary from pivot
        CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE BACK TO SECONDARY"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  ZCP * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


        IF( RNUM.LE.2 ) GOTO 5160


!  Factors for Translation to Tertiary Flat
5300    CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO TERTIARY FLAT"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  ( TFD - BFD ) * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

!  Factors to Rotate azimuth of Tertiary Flat
5310    IF( AZ.EQ.0.0 ) GOTO 5315
        CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE TERTIARY AZIMUTH"'
        PPH(JROT) = 0.0
        TTH(JROT) = 0.0
        WWM(JROT) = AZ

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors to Rotate to Tertiary Flat
5315    CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE OFF-AXIS"'
        PPH(JROT) = 0.0
        TTH(JROT) = AT
        WWM(JROT) = 0.0

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors to Reflect off Tertiary Flat
5320    CALL SETOP(IJOP)
        MMOP(IJOP) = 4
        COMMNT(IJOP) = '"REFLECT OFF TERTIARY FLAT"'
        KTYP(JSRF) = 1          ! Plane Surface
        PLTH(JPLN) = 0.d0       ! Polar Angle
        PLPH(JPLN) = 0.d0       ! Azimuthal Angle
        JJT(JSRF) = 2           ! Reflective Surface
        JIMSRF(JSRF) = 0        ! Plot Flag

        JTYSRF(JSRF) = 0        ! Don't Type Surface
        JPNSRF(JSRF) = 0        ! Don't Print Surface
        JSTSRF(JSRF) = 0        ! Don't Store Surface
        NNVG(JSRF) = 0          ! No Vignetting Boundaries
        NTVG(JSRF) = 1          ! Trace if Vignetted

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors to Rotate from Tertiary Flat
5330    CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE OFF-AXIS"'
        PPH(JROT) = 0.0
        TTH(JROT) = AT
        WWM(JROT) = 0.0

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

        IF( RNUM.LE.3 ) GOTO 5400


!  Factors for Translation to Beam Combiner
5340    CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO BEAM COMBINER"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) = ( TFD - BCFD ) * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

!  Factors to Rotate to Beam Combiner
5350    CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE OFF-AXIS"'
        PPH(JROT) = 0.0
        TTH(JROT) = AB - AG
! Did we ge the sign right???????????????????????????
        WWM(JROT) = 0.0

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors to Reflect off Beam Combiner
5360    CALL SETOP(IJOP)
        MMOP(IJOP) = 4
        COMMNT(IJOP) = '"REFLECT OFF BEAM COMBINER"'
        KTYP(JSRF) = 1          ! Plane Surface
        PLTH(JPLN) = 0.d0       ! Polar Angle
        PLPH(JPLN) = 0.d0       ! Azimuthal Angle
        JJT(JSRF) = 2           ! Reflective Surface
        JIMSRF(JSRF) = 0        ! Plot Flag

        JTYSRF(JSRF) = 0        ! Don't Type Surface
        JPNSRF(JSRF) = 0        ! Don't Print Surface
        JSTSRF(JSRF) = 0        ! Don't Store Surface
        NNVG(JSRF) = 0          ! No Vignetting Boundaries
        NTVG(JSRF) = 1          ! Trace if Vignetted

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation



!  Factors to Rotate from Beam Combiner
5370    CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE OFF-AXIS"'
        PPH(JROT) = 0.0
        TTH(JROT) = AB - AG
        WWM(JROT) = 0.0

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


5375    IF( AZ.EQ.0.0 ) GOTO 5380
        CALL SETOP(IJOP)
        MMOP(IJOP) = 3
        COMMNT(IJOP) = '"ROTATE OUT OF TERTIARY AZIMUTH"'
        PPH(JROT) = 0.0
        TTH(JROT) = 0.0
        WWM(JROT) = -AZ

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


!  Factors for Translation to Focal Plane
5380    CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO FOCAL PLANE"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  -BCFD * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

        GOTO 5170               ! Focal Plane


!  Factors for Translation to Focal Plane
5400    CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO FOCAL PLANE"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  TFD * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation


        GOTO 5170               ! To Focal Plane


!  Factors for Translation to Focal Plane
5160    CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO FOCAL PLANE"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  - BFD * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

!  Factors for Focal Plane
5170    CALL SETOP(IJOP)
        MMOP(IJOP) = 4
        COMMNT(IJOP) = '"CURVED FOCAL PLANE"'
        KTYP(JSRF) = 2          ! Conic Surface
        RADCRV(JCON) = FPROC * 1d3    ! Radius of Curvature
        EECSQ(JCON) = 1.d0      ! Parabola
        LAXC(JCON) = 1          ! Axial Symmetry
        NCVX(JCON) = 1          ! Convex Direction
        JJT(JSRF) = 1           ! Dummy Surface
        JIMSRF(JSRF) = 3        ! Plot Flag = analysis and plot

        JTYSRF(JSRF) = 0        ! Don't Type Surface
        JPNSRF(JSRF) = 0        ! Don't Print Surface
        JSTSRF(JSRF) = 0        ! Don't Store Surface
        NNVG(JSRF) = 0          ! No Vignetting Boundaries
        NTVG(JSRF) = 1          ! Trace if Vignetted

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

!  Add a flat focal plane
        GOTO 5210


!  Factors for Translation to Focal Plane
5200    CALL SETOP(IJOP)
        MMOP(IJOP) = 2
        COMMNT(IJOP) = '"TRANSLATE TO FOCAL PLANE"'
        DDX(JTRN) = 0.0d0
        DDY(JTRN) = 0.0d0
        DDZ(JTRN) =  L1 * 1d3

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

!  Factors for Focal Plane
5210    CALL SETOP(IJOP)
        MMOP(IJOP) = 4
        COMMNT(IJOP) = '"FLAT FOCAL PLANE"'
        KTYP(JSRF) = 1          ! Plane Surface
        PLTH(JPLN) = 0.0d0      ! Polar Angle
        PLPH(JPLN) = 0.0d0      ! Azimuthal Angle
        JJT(JSRF) = 1           ! Dummy Surface
        JIMSRF(JSRF) = 2        ! Plot Flag = analysis only

        JTYSRF(JSRF) = 0        ! Don't Type Surface
        JPNSRF(JSRF) = 0        ! Don't Print Surface
        JSTSRF(JSRF) = 0        ! Don't Store Surface
        NNVG(JSRF) = 0          ! No Vignetting Boundaries
        NTVG(JSRF) = 1          ! Trace if Vignetted

        JTYRAY(IJOP) = 0        ! Don't Type Ray
        JPNRAY(IJOP) = 0        ! Don't Print Ray
        JSTRAY(IJOP) = 0        ! Don't Store Ray
        IJOP = IJOP + 1         ! Ready for Next Operation

        GOTO 5800


!  Count the Operations
5800    NOP = IJOP - 1

!  Write the Data File with a Call to the RAYTRC routine CONFIG
        CALL CONFIG(1,0,-1 )

        PRINT *,'  RAYTRC Data File Written.'


6000    CONTINUE

!  Ask about another pass
6010    CALL MASKYN( -1, '  Modify Parameters for Another Pass',
     *                  YN, 80, IER, *300, *6100, *6000, *6010 )

6100    CONTINUE

!  Ask about reading another data file
6110    CALL MASKYN( -1, '  Read Another Data File',
     *                  YN, 80, IER, *245, *6200, *6010, *6110 )

6200    CONTINUE



        CALL MRUNSTATS(-1,IER)

        STOP 'CASS COMPLETE'


!  Error Returns
9000    PRINT *,'CASS ERROR - Bad OPEN of Data File: '
        CALL WSTRING(-1,dname,'#',40,jer)
        GOTO 10000

9010    PRINT *,'CASS ERROR - Bad Read of Data File.'
        GOTO 175

9100    PRINT *,'CASS ERROR - Bad OPEN for Output File: '
        CALL WSTRING(-1,ONAME,'#',40,jer)
        GOTO 10000

10000   CONTINUE

        CALL MQMSG(IER,-1)

        CALL MRUNSTATS(-1,IER)

        STOP 'CASS ERROR EXIT'
        END

!  Subroutine to Write Text Output and Keep Code Cleaner
        SUBROUTINE TOUT( TEXT )

        CHARACTER*129   TEXT            ! Label

        INTEGER         OUT             ! I/O Unit for Open Output File
        PARAMETER( out = 20 )

        CALL WSTRING(-1,TEXT,' ',80,IER)

        CALL WSTRING(out,TEXT,' ',80,IER)

        RETURN
        END

!  Subroutine to Write Parameter Output and Keep Code Cleaner
        SUBROUTINE WOUT( DVALUE, TEXT )

        REAL*8          DVALUE          ! Parameter Value
        CHARACTER*129   TEXT            ! Label

        INTEGER         OUT             ! I/O Unit for Open Output File
        PARAMETER( out = 20 )

        WRITE(*,21000) DVALUE
21000   FORMAT( 5X, G15.7 )
        CALL WSTRING(-1,TEXT,'#',88,IER)

        WRITE(out,21000) DVALUE
        CALL WSTRING(out,TEXT,'#',88,IER)

        RETURN
        END

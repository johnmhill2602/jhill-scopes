C Subroutine to Calculate the Structure Function for a Grid of Amplitudes
C This is the double precsion version

      SUBROUTINE STRUCT (NPTS,DX,DY,DZ,NBIN,IDEC,RMSZ,SCALE,SNUM)

!  To Complile: F77 STRUCTURE

!  Description
!    This subroutine calculates a histogram of the structure function of a
!    surface.  The input to the subroutine consists of a set of x,y
!    coordinates and amplitudes at each point.  Users should be aware that
!    the calculation time increases as the square of the number of points.
!    The points may be spaced uniformly or randomly as this algorithm assumes
!    arbitrary spacing.  The inputs to the program are currently defined as
!    double, although they could be defined as integer x,y,z values.  The
!    output of the program is a histogram of logarithmically spaced bins
!    containing the rms surface deviation on various spatial scales.  The
!    number and spacing of the bins is selectable.  Note that the structure
!    function will be square root of 2 larger than a simple rms, because it
!    does not remove the mean.

!  Argument Declarations

        INTEGER         NPTS            ! Number of points in the grid
        REAL*8          DX(NPTS)        ! X coordinates of the points
        REAL*8          DY(NPTS)        ! Y coordinates of the points
        REAL*8          DZ(NPTS)        ! Amplitudes of the points
        INTEGER         NBIN            ! Number of histogram bins
        INTEGER         IDEC            ! Number of bins per dex
        REAL*8          RMSZ(NBIN+1)    ! rms amplitude vs spatial scale
        REAL*8          SCALE(NBIN+1)   ! spatial scale for RMSZ
        REAL*8          SNUM(NBIN+1)    ! number of pairs for RMSZ
!--End of Documentation

!  History
!       Created by J.M. Hill, Steward Observatory  Spring 1988
!       27JUL88 - Reject repeated X,Y points.  JMH
!       29APR92 - Double Precision XYZ points.  JMH

!  Variable Declarations

!  Begin Code

!  Initialize the arrays to zero
        DO I = 1, NBIN
            SNUM(I) = 0.0
            RMSZ(I) = 0.0
        END DO
        RTOTAL = 0.0
        ITOTAL = 0

!  Outer Loop
        DO 2000 JPT = 1, NPTS

!       Inner Loop
            DO 1000 KPT = JPT+1, NPTS

              ! calculate the distance between two points
                XX = DX(JPT) - DX(KPT)
                YY = DY(JPT) - DY(KPT)
                DISTANCE = SQRT( XX**2 + YY**2 )
                IF( DISTANCE.LE.0.0D0 ) GOTO 1000        ! repeated point  ??

              ! calculate which bin this distance falls in
              !     bins are intervals of 1/IDEC dex
                IBIN = 1 + NINT( IDEC * LOG10(DISTANCE) )

              ! increment the counter for the appropriate bin
                IF( IBIN.LE.0 ) GOTO 1000
                IF( IBIN.GT.NBIN ) GOTO 1000
                SNUM(IBIN) = SNUM(IBIN) + 1.0
                ITOTAL = ITOTAL + 1

              ! add in the square of the distance to that bin
                ZSQR = ( DZ(JPT) - DZ(KPT) )**2
                
                RMSZ(IBIN) = RMSZ(IBIN) + ZSQR

              ! add in the square of the distance to the total
                RTOTAL = RTOTAL + ZSQR

1000        CONTINUE     ! End inner loop

2000    CONTINUE          ! End outer loop



!  Calculate Statistics for all of the histogram bins.
        DO KK = 1, NBIN
              ! Mean scale of the bin
                SCALE(KK) = 10**(FLOAT(KK-1)/IDEC)

                IF(SNUM(KK).GT.0.0) THEN
                    RMSZ(KK) = SQRT( RMSZ(KK)/SNUM(KK) )
                ELSE
                    RMSZ(KK) = 0.0
                END IF
        END DO

        IF( ITOTAL.GT.0 ) THEN
           RTOTAL = SQRT( RTOTAL/ITOTAL )
           ! Save total rms in NBIN+1
           SCALE(NBIN+1) = 0.0d0                  
           RMSZ(NBIN+1) = RTOTAL
           SNUM(NBIN+1) = ITOTAL
        END IF


        RETURN

        END

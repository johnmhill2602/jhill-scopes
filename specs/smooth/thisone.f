C   ROUTINE NAME   - IQHSCV
C
C-----------------------------------------------------------------------
C
C   COMPUTER            - VAX/DOUBLE
C
C   LATEST REVISION     - JUNE 1, 1981
C
C   PURPOSE             - SMOOTH SURFACE FITTING WITH IRREGULARLY
C                           DISTRIBUTED DATA POINTS
C
C   USAGE               - CALL IQHSCV (XD,YD,ZD,ND,XI,NXI,YI,NYI,ZI,IZI,
C                           IWK,WK,IER)
C
C   ARGUMENTS    XD     - VECTOR OF LENGTH ND. (INPUT)
C                YD     - VECTOR OF LENGTH ND. (INPUT)
C                ZD     - VECTOR OF LENGTH ND. (INPUT)
C                         ZD(I) IS THE FUNCTION VALUE AT THE POINT
C                           (XD(I),YD(I)) FOR I=1,...,ND.
C                ND     - NUMBER OF DATA POINTS. (INPUT) ND MUST BE
C                           GREATER THAN OR EQUAL TO 4.
C                XI     - VECTOR OF LENGTH NXI. (INPUT)
C                           THE SEQUENCE XI MUST BE MONOTONE
C                           INCREASING.
C                NXI    - NUMBER OF ELEMENTS IN XI. (INPUT) NXI MUST
C                           BE GREATER THAN OR EQUAL TO 1.
C                YI     - VECTOR OF LENGTH NYI. (INPUT)
C                           THE SEQUENCE YI MUST BE MONOTONE
C                           INCREASING.
C                NYI    - NUMBER OF ELEMENTS IN YI. (INPUT) NYI MUST
C                           BE GREATER THAN OR EQUAL TO 1.
C                ZI     - NXI BY NYI MATRIX CONTAINING THE INTERPOLATED
C                           VALUES. (OUTPUT) ZI(I,J) IS THE ESTIMATED
C                           VALUE AT THE POINT (XI(I),YI(J)) FOR
C                           I=1,...,NXI AND J=1,...,NYI.
C                IZI    - ROW DIMENSION OF THE MATRIX ZI EXACTLY AS
C                           SPECIFIED IN THE DIMENSION STATEMENT
C                           IN THE CALLING PROGRAM. (INPUT)
C                IWK    - INTEGER WORK VECTOR OF LENGTH
C                           31*ND+NXI*NYI.
C                WK     - REAL WORK VECTOR OF LENGTH 6*ND.
C                IER    - ERROR PARAMETER. (OUTPUT)
C                         TERMINAL ERROR
C                           IER = 129, ND IS LESS THAN 4, OR NXI
C                             IS LESS THAN 1, OR NYI IS LESS THAN 1.
C                           IER = 130, ALL DATA POINTS ARE COLLINEAR
C                           IER = 131, SOME DATA POINTS ARE IDENTICAL,
C                             THAT IS, XD(I)=XD(J) AND YD(I)=YD(J) FOR
C                             SOME I AND J, I NOT EQUAL TO J AND
C                             I=1,...,ND, J=1,...,ND.
C
C   PRECISION/HARDWARE  - SINGLE AND DOUBLE/H32
C                       - SINGLE/H36,H48,H60
C
C   REQD. ROUTINES      - IQHSD,IQHSE,IQHSF,IQHSG,IQHSH,UERTST,UGETIO
C
C   NOTATION            - INFORMATION ON SPECIAL NOTATION AND
C                           CONVENTIONS IS AVAILABLE IN THE MANUAL
C                           INTRODUCTION OR THROUGH ROUTINE UHELP
C
C-----------------------------------------------------------------------
C
      SUBROUTINE IQHSCV (XD,YD,ZD,ND,XI,NXI,YI,NYI,ZI,IZI,IWK,WK,IER)
C                                  SPECIFICATIONS FOR ARGUMENTS
      INTEGER            ND,NXI,NYI,IZI,IER,IWK(1)
      DOUBLE PRECISION   XD(1),YD(1),ZD(1),XI(1),YI(1),ZI(IZI,1),WK(1)
C                                  SPECIFICATIONS FOR LOCAL VARIABLES
      INTEGER            IL1,IL2,ITI,IXI,IYI,IZ,JIG0MN,JIG0MX,JIG1MN,
     1                   JIG1MX,JIGP,JNGP,JWIGP0,JWIGP,JWIPL,JWIPT,
     2                   JWIWL,JWIWP,JWNGP0,JWNGP,JWWPD,NDP0,NGP0,NGP1,
     3                   NL,NNGP,NT,NXI0,NYI0
      INTEGER            ITPV
      DOUBLE PRECISION   DMMY(27)
      COMMON /IBCDPT/    DMMY,ITPV
C                                  SETTING OF SOME INPUT PARAMETERS TO
C                                    LOCAL VARIABLES.
C                                  FIRST EXECUTABLE STATEMENT
      IER = 0
      NDP0 = ND
      NXI0 = NXI
      NYI0 = NYI
C                                  ERROR CHECK.
      IF (NDP0.LT.4) GO TO 30
      IF (NXI0.LT.1.OR.NYI0.LT.1) GO TO 30
      IWK(1) = NDP0
      IWK(3) = NXI0
      IWK(4) = NYI0
C                                  ALLOCATION OF STORAGE AREAS IN THE
C                                    IWK ARRAY.
      JWIPT = 16
      JWIWL = 6*NDP0+1
      JWNGP0 = JWIWL-1
      JWIPL = 24*NDP0+1
      JWIWP = 30*NDP0+1
      JWIGP0 = 31*NDP0
      JWWPD = 5*NDP0+1
C                                  TRIANGULATES THE X-Y PLANE.
      CALL IQHSG (NDP0,XD,YD,NT,IWK(JWIPT),NL,IWK(JWIPL),IWK(JWIWL),
     1 IWK(JWIWP),WK,IER)
      IF (IER.GE.128) GO TO 9000
      IWK(5) = NT
      IWK(6) = NL
      IF (NT.EQ.0) GO TO 9005
C                                  SORTS OUTPUT GRID POINTS IN
C                                    ASCENDING ORDER OF THE TRIANGLE
C                                    NUMBER AND THE BORDER LINE SEGMENT
C                                    NUMBER.
      CALL IQHSH (XD,YD,NT,IWK(JWIPT),NL,IWK(JWIPL),NXI0,NYI0,XI,YI,
     1 IWK(JWNGP0+1),IWK(JWIGP0+1))
C
C                                  ESTIMATES PARTIAL DERIVATIVES AT ALL
C                                    DATA POINTS.
C
      CALL IQHSE (NDP0,XD,YD,ZD,NT,IWK(JWIPT),WK,WK(JWWPD))
C
C                                  INTERPOLATES THE ZI VALUES.
      ITPV = 0
      JIG0MX = 0
      JIG1MN = NXI0*NYI0+1
      NNGP = NT+2*NL
      DO 25 JNGP=1,NNGP
         ITI = JNGP
         IF (JNGP.LE.NT) GO TO 5
         IL1 = (JNGP-NT+1)/2
         IL2 = (JNGP-NT+2)/2
         IF (IL2.GT.NL) IL2 = 1
         ITI = IL1*(NT+NL)+IL2
    5    JWNGP = JWNGP0+JNGP
         NGP0 = IWK(JWNGP)
         IF (NGP0.EQ.0) GO TO 15
         JIG0MN = JIG0MX+1
         JIG0MX = JIG0MX+NGP0
         DO 10 JIGP=JIG0MN,JIG0MX
            JWIGP = JWIGP0+JIGP
            IZ = IWK(JWIGP)
            IYI = (IZ-1)/NXI0+1
            IXI = IZ-NXI0*(IYI-1)
            CALL IQHSF (XD,YD,ZD,NT,IWK(JWIPT),NL,IWK(JWIPL),WK,ITI,
     1      XI(IXI),YI(IYI),ZI(IXI,IYI))
   10    CONTINUE
   15    JWNGP = JWNGP0+2*NNGP+1-JNGP
         NGP1 = IWK(JWNGP)
         IF (NGP1.EQ.0) GO TO 25
         JIG1MX = JIG1MN-1
         JIG1MN = JIG1MN-NGP1
         DO 20 JIGP=JIG1MN,JIG1MX
            JWIGP = JWIGP0+JIGP
            IZ = IWK(JWIGP)
            IYI = (IZ-1)/NXI0+1
            IXI = IZ-NXI0*(IYI-1)
            CALL IQHSF (XD,YD,ZD,NT,IWK(JWIPT),NL,IWK(JWIPL),WK,ITI,
     1      XI(IXI),YI(IYI),ZI(IXI,IYI))
   20    CONTINUE
   25 CONTINUE
      GO TO 9005
C                                  ERROR EXIT
   30 IER = 129
 9000 CONTINUE
      CALL UERTST (IER,6HIQHSCV)
 9005 RETURN
      END
C   ROUTINE NAME   - IQHSD
C
C-----------------------------------------------------------------------
C
C   COMPUTER            - VAX/DOUBLE
C
C   LATEST REVISION     - JUNE 1, 1980
C
C   PURPOSE             - NUCLEUS CALLED ONLY BY SUBROUTINE IQHSCV
C
C   PRECISION/HARDWARE  - SINGLE AND DOUBLE/H32
C                       - SINGLE/H36,H48,H60
C
C   REQD. ROUTINES      - NONE
C
C   NOTATION            - INFORMATION ON SPECIAL NOTATION AND
C                           CONVENTIONS IS AVAILABLE IN THE MANUAL
C                           INTRODUCTION OR THROUGH ROUTINE UHELP
C
C-----------------------------------------------------------------------
C
      INTEGER FUNCTION IQHSD (X,Y,I1,I2,I3,I4)
C                                  SPECIFICATIONS FOR ARGUMENTS
      INTEGER            I1,I2,I3,I4
      DOUBLE PRECISION   X(1),Y(1)
C                                  SPECIFICATIONS FOR LOCAL VARIABLES
      INTEGER            IDX
      DOUBLE PRECISION   A1SQ,A2SQ,A3SQ,A4SQ,B1SQ,B2SQ,B3SQ,B4SQ,C1SQ,
     1                   C2SQ,C3SQ,C4SQ,EPSLN,S1SQ,S2SQ,S3SQ,S4SQ,TOL,
     2                   U1,U2,U3,U4,X1,X2,X3,X4,Y1,Y2,Y3,Y4
      EQUIVALENCE        (C2SQ,C1SQ),(A3SQ,B2SQ),(B3SQ,A1SQ),
     1                   (A4SQ,B1SQ),(B4SQ,A2SQ),(C4SQ,C3SQ)
C                                  MACHINE PRECISION
      DATA               TOL/2.775557562D-17/
C                                  FIRST EXECUTABLE STATEMENT
      EPSLN = TOL*100.0D0
C                                  PRELIMINARY PROCESSING
      X1 = X(I1)
      Y1 = Y(I1)
      X2 = X(I2)
      Y2 = Y(I2)
      X3 = X(I3)
      Y3 = Y(I3)
      X4 = X(I4)
      Y4 = Y(I4)
C                                  CALCULATION
      IDX = 0
      U3 = (Y2-Y3)*(X1-X3)-(X2-X3)*(Y1-Y3)
      U4 = (Y1-Y4)*(X2-X4)-(X1-X4)*(Y2-Y4)
      IF (U3*U4.LE.0.0D0) GO TO 5
      U1 = (Y3-Y1)*(X4-X1)-(X3-X1)*(Y4-Y1)
      U2 = (Y4-Y2)*(X3-X2)-(X4-X2)*(Y3-Y2)
      A1SQ = (X1-X3)**2+(Y1-Y3)**2
      B1SQ = (X4-X1)**2+(Y4-Y1)**2
      C1SQ = (X3-X4)**2+(Y3-Y4)**2
      A2SQ = (X2-X4)**2+(Y2-Y4)**2
      B2SQ = (X3-X2)**2+(Y3-Y2)**2
      C3SQ = (X2-X1)**2+(Y2-Y1)**2
      S1SQ = U1*U1/(C1SQ*DMAX1(A1SQ,B1SQ))
      S2SQ = U2*U2/(C2SQ*DMAX1(A2SQ,B2SQ))
      S3SQ = U3*U3/(C3SQ*DMAX1(A3SQ,B3SQ))
      S4SQ = U4*U4/(C4SQ*DMAX1(A4SQ,B4SQ))
      IF ((DMIN1(S3SQ,S4SQ)-DMIN1(S1SQ,S2SQ)).GT.EPSLN) IDX = 1
    5 IQHSD = IDX
      RETURN
      END
C   ROUTINE NAME   - IQHSE
C
C-----------------------------------------------------------------------
C
C   COMPUTER            - VAX/DOUBLE
C
C   LATEST REVISION     - JUNE 1, 1980
C
C   PURPOSE             - NUCLEUS CALLED ONLY BY SUBROUTINE IQHSCV
C
C   PRECISION/HARDWARE  - SINGLE AND DOUBLE/H32
C                       - SINGLE/H36,H48,H60
C
C   REQD. ROUTINES      - NONE
C
C   NOTATION            - INFORMATION ON SPECIAL NOTATION AND
C                           CONVENTIONS IS AVAILABLE IN THE MANUAL
C                           INTRODUCTION OR THROUGH ROUTINE UHELP
C
C-----------------------------------------------------------------------
C
      SUBROUTINE IQHSE  (NDP,XD,YD,ZD,NT,IPT,PD,WK)
C                                  SPECIFICATIONS FOR ARGUMENTS
      INTEGER            NDP,NT,IPT(1)
      DOUBLE PRECISION   XD(1),YD(1),ZD(1),PD(1),WK(1)
C                                  SPECIFICATIONS FOR LOCAL VARIABLES
      INTEGER            IDP,IPTI(3),IT,IV,JPD0,JPDMX,JPD,JPT0,JPT,NDP0,
     1                   NT0
      DOUBLE PRECISION   DX1,DX2,DY1,DY2,DZ1,DZ2,DZX1,DZX2,DZY1,DZY2,
     1                   EPSLN,TOL,XV(3),VPXX,VPXY,VPX,VPYX,VPYY,VPY,
     2                   VPZMN,VPZ,YV(3),ZV(3),ZXV(3),ZYV(3)
C                                  MACHINE PRECISION
      DATA               TOL/2.775557562D-17/
C                                  FIRST EXECUTABLE STATEMENT
      EPSLN = TOL*100.0D0
C                                  PRELIMINARY PROCESSING
      NDP0 = NDP
      NT0 = NT
C                                  CLEARS THE PD ARRAY.
      JPDMX = 5*NDP0
      DO 5 JPD=1,JPDMX
         PD(JPD) = 0.0D0
    5 CONTINUE
      DO 10 IDP=1,NDP
         WK(IDP) = 0.0D0
   10 CONTINUE
C                                  ESTIMATES ZX AND ZY.
      DO 25 IT=1,NT0
         JPT0 = 3*(IT-1)
         DO 15 IV=1,3
            JPT = JPT0+IV
            IDP = IPT(JPT)
            IPTI(IV) = IDP
            XV(IV) = XD(IDP)
            YV(IV) = YD(IDP)
            ZV(IV) = ZD(IDP)
   15    CONTINUE
         DX1 = XV(2)-XV(1)
         DY1 = YV(2)-YV(1)
         DZ1 = ZV(2)-ZV(1)
         DX2 = XV(3)-XV(1)
         DY2 = YV(3)-YV(1)
         DZ2 = ZV(3)-ZV(1)
         VPX = DY1*DZ2-DZ1*DY2
         VPY = DZ1*DX2-DX1*DZ2
         VPZ = DX1*DY2-DY1*DX2
         VPZMN = DABS(DX1*DX2+DY1*DY2)*EPSLN
         IF (DABS(VPZ).LE.VPZMN) GO TO 25
         DO 20 IV=1,3
            IDP = IPTI(IV)
            JPD0 = 5*(IDP-1)+1
            PD(JPD0) = PD(JPD0)+VPX
            PD(JPD0+1) = PD(JPD0+1)+VPY
            WK(IDP) = WK(IDP)+VPZ
   20    CONTINUE
   25 CONTINUE
      DO 30 IDP=1,NDP0
         JPD0 = 5*(IDP-1)+1
         PD(JPD0) = -PD(JPD0)/WK(IDP)
         PD(JPD0+1) = -PD(JPD0+1)/WK(IDP)
   30 CONTINUE
C                                  ESTIMATES ZXX, ZXY, AND ZYY.
      DO 45 IT=1,NT0
         JPT0 = 3*(IT-1)
         DO 35 IV=1,3
            JPT = JPT0+IV
            IDP = IPT(JPT)
            IPTI(IV) = IDP
            XV(IV) = XD(IDP)
            YV(IV) = YD(IDP)
            JPD0 = 5*(IDP-1)+1
            ZXV(IV) = PD(JPD0)
            ZYV(IV) = PD(JPD0+1)
   35    CONTINUE
         DX1 = XV(2)-XV(1)
         DY1 = YV(2)-YV(1)
         DZX1 = ZXV(2)-ZXV(1)
         DZY1 = ZYV(2)-ZYV(1)
         DX2 = XV(3)-XV(1)
         DY2 = YV(3)-YV(1)
         DZX2 = ZXV(3)-ZXV(1)
         DZY2 = ZYV(3)-ZYV(1)
         VPXX = DY1*DZX2-DZX1*DY2
         VPXY = DZX1*DX2-DX1*DZX2
         VPYX = DY1*DZY2-DZY1*DY2
         VPYY = DZY1*DX2-DX1*DZY2
         VPZ = DX1*DY2-DY1*DX2
         VPZMN = DABS(DX1*DX2+DY1*DY2)*EPSLN
         IF (DABS(VPZ).LE.VPZMN) GO TO 45
         DO 40 IV=1,3
            IDP = IPTI(IV)
            JPD0 = 5*(IDP-1)+3
            PD(JPD0) = PD(JPD0)+VPXX
            PD(JPD0+1) = PD(JPD0+1)+VPXY+VPYX
            PD(JPD0+2) = PD(JPD0+2)+VPYY
   40    CONTINUE
   45 CONTINUE
      DO 50 IDP=1,NDP0
         JPD0 = 5*(IDP-1)+3
         PD(JPD0) = -PD(JPD0)/WK(IDP)
         PD(JPD0+1) = -PD(JPD0+1)/(2.0D0*WK(IDP))
         PD(JPD0+2) = -PD(JPD0+2)/WK(IDP)
   50 CONTINUE
      RETURN
      END
C   ROUTINE NAME   - IQHSF
C
C-----------------------------------------------------------------------
C
C   COMPUTER            - VAX/DOUBLE
C
C   LATEST REVISION     - JUNE 1, 1980
C
C   PURPOSE             - NUCLEUS CALLED ONLY BY SUBROUTINE IQHSCV
C
C   PRECISION/HARDWARE  - SINGLE AND DOUBLE/H32
C                       - SINGLE/H36,H48,H60
C
C   REQD. ROUTINES      - NONE
C
C   NOTATION            - INFORMATION ON SPECIAL NOTATION AND
C                           CONVENTIONS IS AVAILABLE IN THE MANUAL
C                           INTRODUCTION OR THROUGH ROUTINE UHELP
C
C-----------------------------------------------------------------------
C
      SUBROUTINE IQHSF  (XD,YD,ZD,NT,IPT,NL,IPL,PDD,ITI,XII,YII,ZII)
C                                  SPECIFICATIONS FOR ARGUMENTS
      INTEGER            NT,NL,ITI,IPT(1),IPL(1)
      DOUBLE PRECISION   XD(1),YD(1),ZD(1),PDD(1),XII,YII,ZII
C                                  SPECIFICATIONS FOR LOCAL VARIABLES
      INTEGER            IDP,IL1,IL2,IT0,I,JIPL,JIPT,JPDD,JPD,KPD,NTL
      INTEGER            ITPV
      DOUBLE PRECISION   X0,Y0,AP,BP,CP,DP,P00,P10,P20,P30,P40,P50,P5,
     1                   P01,P11,P21,P31,P41,P02,P12,P22,P32,P03,P13,
     2                   P23,P04,P14,P05
      DOUBLE PRECISION   AA,AB,ACT2,AC,ADBC,AD,A,BB,BC,BDT2,B,CC,CD,
     1                   CSUV,C,DD,DLT,DX,DY,D,G1,G2,H1,H2,H3,LU,
     2                   LV,X(3),P0,P1,P2,P3,P4,PD(15),THSV,THUS,THUV,
     3                   THXU,U,V,Y(3),Z0,ZUU(3),ZUV(3),ZU(3),ZVV(3),
     4                   ZV(3),Z(3)
      double precision   ckdat2
C ckdat2 is the IRAF name for ckdatan2()
      COMMON /IBCDPT/    X0,Y0,AP,BP,CP,DP,P00,P10,P20,P30,P40,P50,
     1                   P01,P11,P21,P31,P41,P02,P12,P22,P32,P03,P13,
     2                   P23,P04,P14,P05,ITPV
      EQUIVALENCE        (P5,P50)
C                                  FIRST EXECUTABLE STATEMENT
C                                  PRELIMINARY PROCESSING
      IT0 = ITI
      NTL = NT+NL
      IF (IT0.LE.NTL) GO TO 5
      IL1 = IT0/NTL
      IL2 = IT0-IL1*NTL
      IF (IL1.EQ.IL2) GO TO 30
      GO TO 55
C                                  CALCULATION OF ZII BY INTERPOLATION.
C                                    CHECKS IF THE NECESSARY
C                                    COEFFICIENTS HAVE BEEN CALCULATED.
    5 IF (IT0.EQ.ITPV) GO TO 25
C                                  LOADS COORDINATE AND PARTIAL
C                                    DERIVATIVE VALUES AT THE VERTEXES.
      JIPT = 3*(IT0-1)
      JPD = 0
      DO 15 I=1,3
         JIPT = JIPT+1
         IDP = IPT(JIPT)
         X(I) = XD(IDP)
         Y(I) = YD(IDP)
         Z(I) = ZD(IDP)
         JPDD = 5*(IDP-1)
         DO 10 KPD=1,5
            JPD = JPD+1
            JPDD = JPDD+1
            PD(JPD) = PDD(JPDD)
   10    CONTINUE
   15 CONTINUE
C                                  DETERMINES THE COEFFICIENTS FOR THE
C                                    COORDINATE SYSTEM TRANSFORMATION
C                                    FROM THE X-Y SYSTEM TO THE U-V
C                                    SYSTEM AND VICE VERSA.
      X0 = X(1)
      Y0 = Y(1)
      A = X(2)-X0
      B = X(3)-X0
      C = Y(2)-Y0
      D = Y(3)-Y0
      AD = A*D
      BC = B*C
      DLT = AD-BC
      AP = D/DLT
      BP = -B/DLT
      CP = -C/DLT
      DP = A/DLT
C                                  CONVERTS THE PARTIAL DERIVATIVES AT
C                                    THE VERTEXES OF THE TRIANGLE FOR
C                                    THE U-V COORDINATE SYSTEM.
      AA = A*A
      ACT2 = 2.0D0*A*C
      CC = C*C
      AB = A*B
      ADBC = AD+BC
      CD = C*D
      BB = B*B
      BDT2 = 2.0D0*B*D
      DD = D*D
      DO 20 I=1,3
         JPD = 5*I
         ZU(I) = A*PD(JPD-4)+C*PD(JPD-3)
         ZV(I) = B*PD(JPD-4)+D*PD(JPD-3)
         ZUU(I) = AA*PD(JPD-2)+ACT2*PD(JPD-1)+CC*PD(JPD)
         ZUV(I) = AB*PD(JPD-2)+ADBC*PD(JPD-1)+CD*PD(JPD)
         ZVV(I) = BB*PD(JPD-2)+BDT2*PD(JPD-1)+DD*PD(JPD)
   20 CONTINUE
C                                  CALCULATES THE COEFFICIENTS OF THE
C                                    POLYNOMIAL.
      P00 = Z(1)
      P10 = ZU(1)
      P01 = ZV(1)
      P20 = 0.5D0*ZUU(1)
      P11 = ZUV(1)
      P02 = 0.5D0*ZVV(1)
      H1 = Z(2)-P00-P10-P20
      H2 = ZU(2)-P10-ZUU(1)
      H3 = ZUU(2)-ZUU(1)
      P30 = 10.0D0*H1-4.0D0*H2+0.5D0*H3
      P40 = -15.0D0*H1+7.0D0*H2-H3
      P50 = 6.0D0*H1-3.0D0*H2+0.5D0*H3
      H1 = Z(3)-P00-P01-P02
      H2 = ZV(3)-P01-ZVV(1)
      H3 = ZVV(3)-ZVV(1)
      P03 = 10.0D0*H1-4.0D0*H2+0.5D0*H3
      P04 = -15.0D0*H1+7.0D0*H2-H3
      P05 = 6.0D0*H1-3.0D0*H2+0.5D0*H3
      LU = DSQRT(AA+CC)
      LV = DSQRT(BB+DD)
      THXU = ckdat2(C,A)
      THUV = ckdat2(D,B)-THXU
      CSUV = DCOS(THUV)
      P41 = 5.0D0*LV*CSUV/LU*P50
      P14 = 5.0D0*LU*CSUV/LV*P05
      H1 = ZV(2)-P01-P11-P41
      H2 = ZUV(2)-P11-4.0D0*P41
      P21 = 3.0D0*H1-H2
      P31 = -2.0D0*H1+H2
      H1 = ZU(3)-P10-P11-P14
      H2 = ZUV(3)-P11-4.0D0*P14
      P12 = 3.0D0*H1-H2
      P13 = -2.0D0*H1+H2
      THUS = ckdat2(D-C,B-A)-THXU
      THSV = THUV-THUS
      AA = DSIN(THSV)/LU
      BB = -DCOS(THSV)/LU
      CC = DSIN(THUS)/LV
      DD = DCOS(THUS)/LV
      AC = AA*CC
      AD = AA*DD
      BC = BB*CC
      G1 = AA*AC*(3.0D0*BC+2.0D0*AD)
      G2 = CC*AC*(3.0D0*AD+2.0D0*BC)
      H1 = -AA*AA*AA*(5.0D0*AA*BB*P50+(4.0D0*BC+AD)*P41)-CC*CC*CC*(5.0D0
     1*CC
     +*DD*P05+(4.0D0*AD+BC)*P14)
      H2 = 0.5D0*ZVV(2)-P02-P12
      H3 = 0.5D0*ZUU(3)-P20-P21
      P22 = (G1*H2+G2*H3-H1)/(G1+G2)
      P32 = H2-P22
      P23 = H3-P22
      ITPV = IT0
C                                  CONVERTS XII AND YII TO U-V SYSTEM.
   25 DX = XII-X0
      DY = YII-Y0
      U = AP*DX+BP*DY
      V = CP*DX+DP*DY
C                                  EVALUATES THE POLYNOMIAL.
      P0 = P00+V*(P01+V*(P02+V*(P03+V*(P04+V*P05))))
      P1 = P10+V*(P11+V*(P12+V*(P13+V*P14)))
      P2 = P20+V*(P21+V*(P22+V*P23))
      P3 = P30+V*(P31+V*P32)
      P4 = P40+V*P41
      ZII = P0+U*(P1+U*(P2+U*(P3+U*(P4+U*P5))))
      RETURN
C                                  CALCULATION OF ZII BY EXTRAPOLATION
C                                    IN THE RECTANGLE. CHECKS IF THE
C                                    NECESSARY COEFFICIENTS HAVE BEEN
C                                    CALCULATED.
   30 IF (IT0.EQ.ITPV) GO TO 50
C                                  LOADS COORDINATE AND PARTIAL
C                                    DERIVATIVE VALUES AT THE END
C                                    POINTS OF THE BORDER LINE SEGMENT.
      JIPL = 3*(IL1-1)
      JPD = 0
      DO 40 I=1,2
         JIPL = JIPL+1
         IDP = IPL(JIPL)
         X(I) = XD(IDP)
         Y(I) = YD(IDP)
         Z(I) = ZD(IDP)
         JPDD = 5*(IDP-1)
         DO 35 KPD=1,5
            JPD = JPD+1
            JPDD = JPDD+1
            PD(JPD) = PDD(JPDD)
   35    CONTINUE
   40 CONTINUE
C                                  DETERMINES THE COEFFICIENTS FOR THE
C                                    COORDINATE SYSTEM TRANSFORMATION
C                                    FROM THE X-Y SYSTEM TO THE U-V
C                                    SYSTEM AND VICE VERSA.
      X0 = X(1)
      Y0 = Y(1)
      A = Y(2)-Y(1)
      B = X(2)-X(1)
      C = -B
      D = A
      AD = A*D
      BC = B*C
      DLT = AD-BC
      AP = D/DLT
      BP = -B/DLT
      CP = -BP
      DP = AP
C                                  CONVERTS THE PARTIAL DERIVATIVES AT
C                                    THE END POINTS OF THE BORDER LINE
C                                    SEGMENT FOR THE U-V COORDINATE
C                                    SYSTEM.
      AA = A*A
      ACT2 = 2.0D0*A*C
      CC = C*C
      AB = A*B
      ADBC = AD+BC
      CD = C*D
      BB = B*B
      BDT2 = 2.0D0*B*D
      DD = D*D
      DO 45 I=1,2
         JPD = 5*I
         ZU(I) = A*PD(JPD-4)+C*PD(JPD-3)
         ZV(I) = B*PD(JPD-4)+D*PD(JPD-3)
         ZUU(I) = AA*PD(JPD-2)+ACT2*PD(JPD-1)+CC*PD(JPD)
         ZUV(I) = AB*PD(JPD-2)+ADBC*PD(JPD-1)+CD*PD(JPD)
         ZVV(I) = BB*PD(JPD-2)+BDT2*PD(JPD-1)+DD*PD(JPD)
   45 CONTINUE
C                                  CALCULATES THE COEFFICIENTS OF THE
C                                    POLYNOMIAL.
      P00 = Z(1)
      P10 = ZU(1)
      P01 = ZV(1)
      P20 = 0.5D0*ZUU(1)
      P11 = ZUV(1)
      P02 = 0.5D0*ZVV(1)
      H1 = Z(2)-P00-P01-P02
      H2 = ZV(2)-P01-ZVV(1)
      H3 = ZVV(2)-ZVV(1)
      P03 = 10.0D0*H1-4.0D0*H2+0.5D0*H3
      P04 = -15.0D0*H1+7.0D0*H2-H3
      P05 = 6.0D0*H1-3.0D0*H2+0.5D0*H3
      H1 = ZU(2)-P10-P11
      H2 = ZUV(2)-P11
      P12 = 3.0D0*H1-H2
      P13 = -2.0D0*H1+H2
      P21 = 0.0D0
      P23 = -ZUU(2)+ZUU(1)
      P22 = -1.5D0*P23
      ITPV = IT0
C                                  CONVERTS XII AND YII TO U-V SYSTEM.
   50 DX = XII-X0
      DY = YII-Y0
      U = AP*DX+BP*DY
      V = CP*DX+DP*DY
C                                  EVALUATES THE POLYNOMIAL.
      P0 = P00+V*(P01+V*(P02+V*(P03+V*(P04+V*P05))))
      P1 = P10+V*(P11+V*(P12+V*P13))
      P2 = P20+V*(P21+V*(P22+V*P23))
      ZII = P0+U*(P1+U*P2)
      RETURN
C                                  CALCULATION OF ZII BY EXTRAPOLATION
C                                    IN THE TRIANGLE. CHECKS IF THE
C                                    NECESSARY COEFFICIENTS HAVE BEEN
C                                    CALCULATED.
   55 IF (IT0.EQ.ITPV) GO TO 65
C                                  LOADS COORDINATE AND PARTIAL
C                                    DERIVATIVE VALUES AT THE VERTEX OF
C                                    THE TRIANGLE.
      JIPL = 3*IL2-2
      IDP = IPL(JIPL)
      X0 = XD(IDP)
      Y0 = YD(IDP)
      Z0 = ZD(IDP)
      JPDD = 5*(IDP-1)
      DO 60 KPD=1,5
         JPDD = JPDD+1
         PD(KPD) = PDD(JPDD)
   60 CONTINUE
C                                  CALCULATES THE COEFFICIENTS OF THE
C                                    POLYNOMIAL.
      P00 = Z0
      P10 = PD(1)
      P01 = PD(2)
      P20 = 0.5D0*PD(3)
      P11 = PD(4)
      P02 = 0.5D0*PD(5)
      ITPV = IT0
C                                  CONVERTS XII AND YII TO U-V SYSTEM.
   65 U = XII-X0
      V = YII-Y0
C                                  EVALUATES THE POLYNOMIAL.
      P0 = P00+V*(P01+V*P02)
      P1 = P10+V*P11
      ZII = P0+U*(P1+U*P20)
      RETURN
      END
C   ROUTINE NAME   - IQHSG
C
C-----------------------------------------------------------------------
C
C   COMPUTER            - VAX/DOUBLE
C
C   LATEST REVISION     - JUNE 1, 1980
C
C   PURPOSE             - NUCLEUS CALLED ONLY BY SUBROUTINE IQHSCV
C
C   PRECISION/HARDWARE  - SINGLE AND DOUBLE/H32
C                       - SINGLE/H36,H48,H60
C
C   REQD. ROUTINES      - IQHSD
C
C   NOTATION            - INFORMATION ON SPECIAL NOTATION AND
C                           CONVENTIONS IS AVAILABLE IN THE MANUAL
C                           INTRODUCTION OR THROUGH ROUTINE UHELP
C
C-----------------------------------------------------------------------
C
      SUBROUTINE IQHSG  (NDP,XD,YD,NT,IPT,NL,IPL,IWL,IWP,WK,IER)
C                                  SPECIFICATIONS FOR ARGUMENTS
      INTEGER            NDP,NT,NL,IER,IPT(1),IPL(1),IWL(1),IWP(1)
      DOUBLE PRECISION   XD(1),YD(1),WK(1)
C                                  SPECIFICATIONS FOR LOCAL VARIABLES
      INTEGER            ILF,ILIV,ILT3,ILVS,IL,IP1P1,IP1,IP2,IP3,IPL1,
     1                   IPL2,IPLJ1,IPLJ2,IPMN1,IPMN2,IPT1,IPT2,IPT3,
     2                   IPTI1,IPTI2,IPTI,IP,IREP,IT1T3,IT2T3,ITF(2),
     3                   ITS,ITT3R,ITT3,IT,IXVSPV,IXVS,JL1,JL2,JLT3,JP1,
     4                   JP2,JPC,JPMN,JPMX,JP,JWL1MN,JWL1,JWL,NDP0,
     5                   NDPM1,NL0,NLFC,NLFT2,NLF,NLNT3,NLN,NLSHT3,NLSH,
     6                   NLT3,NREP,NT0,NTF,IQHSD,NTT3P3,NTT3
      DOUBLE PRECISION   DSQI,DSQMN,EPSLN,SP,TOL,VP,X1,X2,X3,XDMP,Y1,Y2,
     1                   Y3,YDMP
      DOUBLE PRECISION   DSQF,SPDT,VPDT,U1,U2,U3,V1,V2,V3
      DATA               NREP/100/
C                                  MACHINE PRECISION
      DATA               TOL/2.775557562D-17/
C                                  STATEMENT FUNCTIONS
      DSQF(U1,V1,U2,V2) = (U2-U1)**2+(V2-V1)**2
      SPDT(U1,V1,U2,V2,U3,V3) = (U2-U1)*(U3-U1)+(V2-V1)*(V3-V1)
      VPDT(U1,V1,U2,V2,U3,V3) = (V3-V1)*(U2-U1)-(U3-U1)*(V2-V1)
C                                  FIRST EXECUTABLE STATEMENT
      EPSLN = TOL*100.0D0
C                                  PRELIMINARY PROCESSING
      NDP0 = NDP
      NDPM1 = NDP0-1
C                                  DETERMINES THE CLOSEST PAIR OF DATA
C                                    POINTS AND THEIR MIDPOINT.
      DSQMN = DSQF(XD(1),YD(1),XD(2),YD(2))
      IPMN1 = 1
      IPMN2 = 2
      DO 10 IP1=1,NDPM1
         X1 = XD(IP1)
         Y1 = YD(IP1)
         IP1P1 = IP1+1
         DO 5 IP2=IP1P1,NDP0
            DSQI = DSQF(X1,Y1,XD(IP2),YD(IP2))
            IF (DSQI.EQ.0.0D0) GO TO 160
            IF (DSQI.GE.DSQMN) GO TO 5
            DSQMN = DSQI
            IPMN1 = IP1
            IPMN2 = IP2
    5    CONTINUE
   10 CONTINUE
      XDMP = (XD(IPMN1)+XD(IPMN2))/2.0D0
      YDMP = (YD(IPMN1)+YD(IPMN2))/2.0D0
C                                  SORTS THE OTHER (NDP-2) DATA POINTS
C                                    IN ASCENDING ORDER OF DISTANCE
C                                    FROM THE MIDPOINT AND STORES THE
C                                    SORTED DATA POINT NUMBERS IN THE
C                                    IWP ARRAY.
      JP1 = 2
      DO 15 IP1=1,NDP0
         IF (IP1.EQ.IPMN1.OR.IP1.EQ.IPMN2) GO TO 15
         JP1 = JP1+1
         IWP(JP1) = IP1
         WK(JP1) = DSQF(XDMP,YDMP,XD(IP1),YD(IP1))
   15 CONTINUE
      DO 25 JP1=3,NDPM1
         DSQMN = WK(JP1)
         JPMN = JP1
         DO 20 JP2=JP1,NDP0
            IF (WK(JP2).GE.DSQMN) GO TO 20
            DSQMN = WK(JP2)
            JPMN = JP2
   20    CONTINUE
         ITS = IWP(JP1)
         IWP(JP1) = IWP(JPMN)
         IWP(JPMN) = ITS
         WK(JPMN) = WK(JP1)
   25 CONTINUE
C                                  IF NECESSARY, MODIFIES THE ORDERING
C                                    IN SUCH A WAY THAT THE FIRST THREE
C                                    DATA POINTS ARE NOT COLLINEAR.
      X1 = XD(IPMN1)
      Y1 = YD(IPMN1)
      X2 = XD(IPMN2)
      Y2 = YD(IPMN2)
      DO 30 JP=3,NDP0
         IP = IWP(JP)
         SP = SPDT(XD(IP),YD(IP),X1,Y1,X2,Y2)
         VP = VPDT(XD(IP),YD(IP),X1,Y1,X2,Y2)
         IF (DABS(VP).GT.(DABS(SP)*EPSLN)) GO TO 35
   30 CONTINUE
      GO TO 165
   35 IF (JP.EQ.3) GO TO 45
      JPMX = JP
      DO 40 JPC=4,JPMX
         JP = JPMX+4-JPC
         IWP(JP) = IWP(JP-1)
   40 CONTINUE
      IWP(3) = IP
C                                  FORMS THE FIRST TRIANGLE. STORES
C                                    POINT NUMBERS OF THE VERTEXES OF
C                                    THE TRIANGLE IN THE IPT ARRAY, AND
C                                    STORES POINT NUMBERS OF THE
C                                    BORDER LINE SEGMENTS AND THE
C                                    TRIANGLE NUMBER IN THE IPL ARRAY.
   45 IP1 = IPMN1
      IP2 = IPMN2
      IP3 = IWP(3)
      IF (VPDT(XD(IP1),YD(IP1),XD(IP2),YD(IP2),XD(IP3),YD(IP3)).GE.0.0D0
     1)
     +GO TO 50
      IP1 = IPMN2
      IP2 = IPMN1
   50 NT0 = 1
      NTT3 = 3
      IPT(1) = IP1
      IPT(2) = IP2
      IPT(3) = IP3
      NL0 = 3
      NLT3 = 9
      IPL(1) = IP1
      IPL(2) = IP2
      IPL(3) = 1
      IPL(4) = IP2
      IPL(5) = IP3
      IPL(6) = 1
      IPL(7) = IP3
      IPL(8) = IP1
      IPL(9) = 1
C                                  ADDS THE REMAINING (NDP-3) DATA
C                                    POINTS, ONE BY ONE.
      DO 150 JP1=4,NDP0
         IP1 = IWP(JP1)
         X1 = XD(IP1)
         Y1 = YD(IP1)
C                                  DETERMINES THE FIRST INVISIBLE AND
C                                    VISIBLE BORDER LINE SEGMENTS,
C                                    ILIV AND ILVS.
         DO 65 IL=1,NL0
            IP2 = IPL(3*IL-2)
            IP3 = IPL(3*IL-1)
            X2 = XD(IP2)
            Y2 = YD(IP2)
            X3 = XD(IP3)
            Y3 = YD(IP3)
            SP = SPDT(X1,Y1,X2,Y2,X3,Y3)
            VP = VPDT(X1,Y1,X2,Y2,X3,Y3)
            IF (IL.NE.1) GO TO 55
            IXVS = 0
            IF (VP.LE.(DABS(SP)*(-EPSLN))) IXVS = 1
            ILIV = 1
            ILVS = 1
            GO TO 65
   55       IXVSPV = IXVS
            IF (VP.GT.(DABS(SP)*(-EPSLN))) GO TO 60
            IXVS = 1
            IF (IXVSPV.EQ.1) GO TO 65
            ILVS = IL
            IF (ILIV.NE.1) GO TO 70
            GO TO 65
   60       IXVS = 0
            IF (IXVSPV.EQ.0) GO TO 65
            ILIV = IL
            IF (ILVS.NE.1) GO TO 70
   65    CONTINUE
         IF (ILIV.EQ.1.AND.ILVS.EQ.1) ILVS = NL0
   70    IF (ILVS.LT.ILIV) ILVS = ILVS+NL0
C                                  SHIFTS (ROTATES) THE IPL ARRAY TO
C                                    HAVE THE INVISIBLE BORDER LINE
C                                    SEGMENTS CONTAINED IN THE FIRST
C                                    PART OF THE IPL ARRAY.
         IF (ILIV.EQ.1) GO TO 85
         NLSH = ILIV-1
         NLSHT3 = NLSH*3
         DO 75 JL1=1,NLSHT3
            JL2 = JL1+NLT3
            IPL(JL2) = IPL(JL1)
   75    CONTINUE
         DO 80 JL1=1,NLT3
            JL2 = JL1+NLSHT3
            IPL(JL1) = IPL(JL2)
   80    CONTINUE
         ILVS = ILVS-NLSH
C                                  ADDS TRIANGLES TO THE IPT ARRAY,
C                                    UPDATES BORDER LINE SEGMENTS IN
C                                    THE IPL ARRAY, AND SETS FLAGS FOR
C                                    THE BORDER LINE SEGMENTS TO BE
C                                    REEXAMINED IN THE IWL ARRAY.
   85    JWL = 0
         DO 105 IL=ILVS,NL0
            ILT3 = IL*3
            IPL1 = IPL(ILT3-2)
            IPL2 = IPL(ILT3-1)
            IT = IPL(ILT3)
C                                  ADDS A TRIANGLE TO THE IPT
C                                    ARRAY.
            NT0 = NT0+1
            NTT3 = NTT3+3
            IPT(NTT3-2) = IPL2
            IPT(NTT3-1) = IPL1
            IPT(NTT3) = IP1
C                                  UPDATES BORDER LINE SEGMENTS IN
C                                    THE IPL ARRAY.
            IF (IL.NE.ILVS) GO TO 90
            IPL(ILT3-1) = IP1
            IPL(ILT3) = NT0
   90       IF (IL.NE.NL0) GO TO 95
            NLN = ILVS+1
            NLNT3 = NLN*3
            IPL(NLNT3-2) = IP1
            IPL(NLNT3-1) = IPL(1)
            IPL(NLNT3) = NT0
C                                  DETERMINES THE VERTEX THAT DOES
C                                    NOT LIE ON THE BORDER LINE
C                                    SEGMENTS.
   95       ITT3 = IT*3
            IPTI = IPT(ITT3-2)
            IF (IPTI.NE.IPL1.AND.IPTI.NE.IPL2) GO TO 100
            IPTI = IPT(ITT3-1)
            IF (IPTI.NE.IPL1.AND.IPTI.NE.IPL2) GO TO 100
            IPTI = IPT(ITT3)
C                                  CHECKS IF THE EXCHANGE IS
C                                    NECESSARY.
C
  100       IF (IQHSD(XD,YD,IP1,IPTI,IPL1,IPL2).EQ.0) GO TO 105
C
C                                  MODIFIES THE IPT ARRAY WHEN
C                                    NECESSARY.
            IPT(ITT3-2) = IPTI
            IPT(ITT3-1) = IPL1
            IPT(ITT3) = IP1
            IPT(NTT3-1) = IPTI
            IF (IL.EQ.ILVS) IPL(ILT3) = IT
            IF (IL.EQ.NL0.AND.IPL(3).EQ.IT) IPL(3) = NT0
C
C                                  SETS FLAGS IN THE IWL ARRAY.
            JWL = JWL+4
            IWL(JWL-3) = IPL1
            IWL(JWL-2) = IPTI
            IWL(JWL-1) = IPTI
            IWL(JWL) = IPL2
  105    CONTINUE
         NL0 = NLN
         NLT3 = NLNT3
         NLF = JWL/2
         IF (NLF.EQ.0) GO TO 150
C                                  IMPROVES TRIANGULATION.
         NTT3P3 = NTT3+3
         DO 145 IREP=1,NREP
            DO 135 ILF=1,NLF
               IPL1 = IWL(2*ILF-1)
               IPL2 = IWL(2*ILF)
C                                  LOCATES IN THE IPT ARRAY TWO
C                                    TRIANGLES ON BOTH SIDES OF THE
C                                    FLAGGED LINE SEGMENT.
               NTF = 0
               DO 110 ITT3R=3,NTT3,3
                  ITT3 = NTT3P3-ITT3R
                  IPT1 = IPT(ITT3-2)
                  IPT2 = IPT(ITT3-1)
                  IPT3 = IPT(ITT3)
                  IF (IPL1.NE.IPT1.AND.IPL1.NE.IPT2.AND.IPL1.NE.IPT3) GO
     1             TO 110
                  IF (IPL2.NE.IPT1.AND.IPL2.NE.IPT2.AND.IPL2.NE.IPT3) GO
     1             TO 110
                  NTF = NTF+1
                  ITF(NTF) = ITT3/3
                  IF (NTF.EQ.2) GO TO 115
  110          CONTINUE
               IF (NTF.LT.2) GO TO 135
C                                  DETERMINES THE VERTEXES OF THE
C                                    TRIANGLES THAT DO NOT LIE ON
C                                    THE LINE SEGMENT.
  115          IT1T3 = ITF(1)*3
               IPTI1 = IPT(IT1T3-2)
               IF (IPTI1.NE.IPL1.AND.IPTI1.NE.IPL2) GO TO 120
               IPTI1 = IPT(IT1T3-1)
               IF (IPTI1.NE.IPL1.AND.IPTI1.NE.IPL2) GO TO 120
               IPTI1 = IPT(IT1T3)
  120          IT2T3 = ITF(2)*3
               IPTI2 = IPT(IT2T3-2)
               IF (IPTI2.NE.IPL1.AND.IPTI2.NE.IPL2) GO TO 125
               IPTI2 = IPT(IT2T3-1)
               IF (IPTI2.NE.IPL1.AND.IPTI2.NE.IPL2) GO TO 125
               IPTI2 = IPT(IT2T3)
C                                  CHECKS IF THE EXCHANGE IS
C                                    NECESSARY.
C
  125          IF (IQHSD(XD,YD,IPTI1,IPTI2,IPL1,IPL2).EQ.0) GO TO 135
C                                  MODIFIES THE IPT ARRAY WHEN
C                                    NECESSARY.
               IPT(IT1T3-2) = IPTI1
               IPT(IT1T3-1) = IPTI2
               IPT(IT1T3) = IPL1
               IPT(IT2T3-2) = IPTI2
               IPT(IT2T3-1) = IPTI1
               IPT(IT2T3) = IPL2
C                                  SETS NEW FLAGS.
               JWL = JWL+8
               IWL(JWL-7) = IPL1
               IWL(JWL-6) = IPTI1
               IWL(JWL-5) = IPTI1
               IWL(JWL-4) = IPL2
               IWL(JWL-3) = IPL2
               IWL(JWL-2) = IPTI2
               IWL(JWL-1) = IPTI2
               IWL(JWL) = IPL1
               DO 130 JLT3=3,NLT3,3
                  IPLJ1 = IPL(JLT3-2)
                  IPLJ2 = IPL(JLT3-1)
                  IF ((IPLJ1.EQ.IPL1.AND.IPLJ2.EQ.IPTI2).OR.(IPLJ2.EQ.IP
     1            L1.AND.IPLJ1.EQ.IPTI2)) IPL(JLT3)
     2            = ITF(1)
                  IF ((IPLJ1.EQ.IPL2.AND.IPLJ2.EQ.IPTI1).OR.(IPLJ2.EQ.IP
     1            L2.AND.IPLJ1.EQ.IPTI1)) IPL(JLT3)
     2            = ITF(2)
  130          CONTINUE
  135       CONTINUE
            NLFC = NLF
            NLF = JWL/2
            IF (NLF.EQ.NLFC) GO TO 150
C                                  RESETS THE IWL ARRAY FOR THE
C                                    NEXT ROUND.
            JWL1MN = 2*NLFC+1
            NLFT2 = NLF*2
            DO 140 JWL1=JWL1MN,NLFT2
               JWL = JWL1+1-JWL1MN
               IWL(JWL) = IWL(JWL1)
  140       CONTINUE
            NLF = JWL/2
  145    CONTINUE
  150 CONTINUE
C                                  REARRANGES THE IPT ARRAY SO THAT THE
C                                    VERTEXES OF EACH TRIANGLE ARE
C                                    LISTED COUNTER-CLOCKWISE.
      DO 155 ITT3=3,NTT3,3
         IP1 = IPT(ITT3-2)
         IP2 = IPT(ITT3-1)
         IP3 = IPT(ITT3)
         IF (VPDT(XD(IP1),YD(IP1),XD(IP2),YD(IP2),XD(IP3),YD(IP3)).GE.0.
     1D0   0) GO TO 155
         IPT(ITT3-2) = IP2
         IPT(ITT3-1) = IP1
  155 CONTINUE
      NT = NT0
      NL = NL0
      RETURN
C                                  ERROR EXIT
  160 IER = 131
      RETURN
  165 IER = 130
      RETURN
      END
C   ROUTINE NAME   - IQHSH
C
C-----------------------------------------------------------------------
C
C   COMPUTER            - VAX/DOUBLE
C
C   LATEST REVISION     - JUNE 1, 1980
C
C   PURPOSE             - NUCLEUS CALLED ONLY BY SUBROUTINE IQHSCV
C
C   PRECISION/HARDWARE  - SINGLE AND DOUBLE/H32
C                       - SINGLE/H36,H48,H60
C
C   REQD. ROUTINES      - NONE
C
C   NOTATION            - INFORMATION ON SPECIAL NOTATION AND
C                           CONVENTIONS IS AVAILABLE IN THE MANUAL
C                           INTRODUCTION OR THROUGH ROUTINE UHELP
C
C-----------------------------------------------------------------------
C
      SUBROUTINE IQHSH  (XD,YD,NT,IPT,NL,IPL,NXI,NYI,XI,YI,NGP,IGP)
C                                  SPECIFICATIONS FOR ARGUMENTS
      INTEGER            NT,NL,NXI,NYI,IPT(1),IPL(1),NGP(1),IGP(1)
      DOUBLE PRECISION   XD(1),YD(1),XI(1),YI(1)
C                                  SPECIFICATIONS FOR LOCAL VARIABLES
      INTEGER            IL0T3,IL0,ILP1T3,ILP1,INSD,IP1,IP2,IP3,IT0T3,
     1                   IT0,IXIMN,IXIMX,IXI,IYI,IZI,JIGP0,JIGP1I,JIGP1,
     2                   JNGP0,JNGP1,L,NGP0,NGP1,NL0,NT0,NXI0,NXINYI,
     3                   NYI0
      DOUBLE PRECISION   X1,X2,X3,XII,XIMN,XIMX,XMN,XMX,Y1,Y2,Y3,YII,
     1                   YIMN,YIMX,YMN,YMX
      DOUBLE PRECISION   SPDT,VPDT,U1,U2,U3,V1,V2,V3
C                                  STATEMENT FUNCTIONS
      SPDT(U1,V1,U2,V2,U3,V3) = (U1-U2)*(U3-U2)+(V1-V2)*(V3-V2)
      VPDT(U1,V1,U2,V2,U3,V3) = (U1-U3)*(V2-V3)-(V1-V3)*(U2-U3)
C                                  FIRST EXECUTABLE STATEMENT
      NT0 = NT
      NL0 = NL
      NXI0 = NXI
      NYI0 = NYI
      NXINYI = NXI0*NYI0
      XIMN = DMIN1(XI(1),XI(NXI0))
      XIMX = DMAX1(XI(1),XI(NXI0))
      YIMN = DMIN1(YI(1),YI(NYI0))
      YIMX = DMAX1(YI(1),YI(NYI0))
C                                  DETERMINES GRID POINTS INSIDE THE
C                                    DATA AREA.
      JNGP0 = 0
      JNGP1 = 2*(NT0+2*NL0)+1
      JIGP0 = 0
      JIGP1 = NXINYI+1
      DO 80 IT0=1,NT0
         NGP0 = 0
         NGP1 = 0
         IT0T3 = IT0*3
         IP1 = IPT(IT0T3-2)
         IP2 = IPT(IT0T3-1)
         IP3 = IPT(IT0T3)
         X1 = XD(IP1)
         Y1 = YD(IP1)
         X2 = XD(IP2)
         Y2 = YD(IP2)
         X3 = XD(IP3)
         Y3 = YD(IP3)
         XMN = DMIN1(X1,X2,X3)
         XMX = DMAX1(X1,X2,X3)
         YMN = DMIN1(Y1,Y2,Y3)
         YMX = DMAX1(Y1,Y2,Y3)
         INSD = 0
         DO 10 IXI=1,NXI0
            IF (XI(IXI).GE.XMN.AND.XI(IXI).LE.XMX) GO TO 5
            IF (INSD.EQ.0) GO TO 10
            IXIMX = IXI-1
            GO TO 15
    5       IF (INSD.EQ.1) GO TO 10
            INSD = 1
            IXIMN = IXI
   10    CONTINUE
         IF (INSD.EQ.0) GO TO 75
         IXIMX = NXI0
   15    DO 70 IYI=1,NYI0
            YII = YI(IYI)
            IF (YII.LT.YMN.OR.YII.GT.YMX) GO TO 70
            DO 65 IXI=IXIMN,IXIMX
               XII = XI(IXI)
               L = 0
               IF (VPDT(X1,Y1,X2,Y2,XII,YII)) 65,20,25
   20          L = 1
   25          IF (VPDT(X2,Y2,X3,Y3,XII,YII)) 65,30,35
   30          L = 1
   35          IF (VPDT(X3,Y3,X1,Y1,XII,YII)) 65,40,45
   40          L = 1
   45          IZI = NXI0*(IYI-1)+IXI
               IF (L.EQ.1) GO TO 50
               NGP0 = NGP0+1
               JIGP0 = JIGP0+1
               IGP(JIGP0) = IZI
               GO TO 65
   50          IF (JIGP1.GT.NXINYI) GO TO 60
               DO 55 JIGP1I=JIGP1,NXINYI
                  IF (IZI.EQ.IGP(JIGP1I)) GO TO 65
   55          CONTINUE
   60          NGP1 = NGP1+1
               JIGP1 = JIGP1-1
               IGP(JIGP1) = IZI
   65       CONTINUE
   70    CONTINUE
   75    JNGP0 = JNGP0+1
         NGP(JNGP0) = NGP0
         JNGP1 = JNGP1-1
         NGP(JNGP1) = NGP1
   80 CONTINUE
C                                  DETERMINES GRID POINTS OUTSIDE THE
C                                    DATA AREA. - IN SEMI-INFINITE
C                                    RECTANGULAR AREA.
      DO 225 IL0=1,NL0
         NGP0 = 0
         NGP1 = 0
         IL0T3 = IL0*3
         IP1 = IPL(IL0T3-2)
         IP2 = IPL(IL0T3-1)
         X1 = XD(IP1)
         Y1 = YD(IP1)
         X2 = XD(IP2)
         Y2 = YD(IP2)
         XMN = XIMN
         XMX = XIMX
         YMN = YIMN
         YMX = YIMX
         IF (Y2.GE.Y1) XMN = DMIN1(X1,X2)
         IF (Y2.LE.Y1) XMX = DMAX1(X1,X2)
         IF (X2.LE.X1) YMN = DMIN1(Y1,Y2)
         IF (X2.GE.X1) YMX = DMAX1(Y1,Y2)
         INSD = 0
         DO 90 IXI=1,NXI0
            IF (XI(IXI).GE.XMN.AND.XI(IXI).LE.XMX) GO TO 85
            IF (INSD.EQ.0) GO TO 90
            IXIMX = IXI-1
            GO TO 95
   85       IF (INSD.EQ.1) GO TO 90
            INSD = 1
            IXIMN = IXI
   90    CONTINUE
         IF (INSD.EQ.0) GO TO 155
         IXIMX = NXI0
   95    DO 150 IYI=1,NYI0
            YII = YI(IYI)
            IF (YII.LT.YMN.OR.YII.GT.YMX) GO TO 150
            DO 145 IXI=IXIMN,IXIMX
               XII = XI(IXI)
               L = 0
               IF (VPDT(X1,Y1,X2,Y2,XII,YII)) 105,100,145
  100          L = 1
  105          IF (SPDT(X2,Y2,X1,Y1,XII,YII)) 145,110,115
  110          L = 1
  115          IF (SPDT(X1,Y1,X2,Y2,XII,YII)) 145,120,125
  120          L = 1
  125          IZI = NXI0*(IYI-1)+IXI
               IF (L.EQ.1) GO TO 130
               NGP0 = NGP0+1
               JIGP0 = JIGP0+1
               IGP(JIGP0) = IZI
               GO TO 145
  130          IF (JIGP1.GT.NXINYI) GO TO 140
               DO 135 JIGP1I=JIGP1,NXINYI
                  IF (IZI.EQ.IGP(JIGP1I)) GO TO 145
  135          CONTINUE
  140          NGP1 = NGP1+1
               JIGP1 = JIGP1-1
               IGP(JIGP1) = IZI
  145       CONTINUE
  150    CONTINUE
  155    JNGP0 = JNGP0+1
         NGP(JNGP0) = NGP0
         JNGP1 = JNGP1-1
         NGP(JNGP1) = NGP1
C                                  - IN SEMI-INFINITE TRIANGULAR AREA.
         NGP0 = 0
         NGP1 = 0
         ILP1 = MOD(IL0,NL0)+1
         ILP1T3 = ILP1*3
         IP3 = IPL(ILP1T3-1)
         X3 = XD(IP3)
         Y3 = YD(IP3)
         XMN = XIMN
         XMX = XIMX
         YMN = YIMN
         YMX = YIMX
         IF (Y3.GE.Y2.AND.Y2.GE.Y1) XMN = X2
         IF (Y3.LE.Y2.AND.Y2.LE.Y1) XMX = X2
         IF (X3.LE.X2.AND.X2.LE.X1) YMN = Y2
         IF (X3.GE.X2.AND.X2.GE.X1) YMX = Y2
         INSD = 0
         DO 165 IXI=1,NXI0
            IF (XI(IXI).GE.XMN.AND.XI(IXI).LE.XMX) GO TO 160
            IF (INSD.EQ.0) GO TO 165
            IXIMX = IXI-1
            GO TO 170
  160       IF (INSD.EQ.1) GO TO 165
            INSD = 1
            IXIMN = IXI
  165    CONTINUE
         IF (INSD.EQ.0) GO TO 220
         IXIMX = NXI0
  170    DO 215 IYI=1,NYI0
            YII = YI(IYI)
            IF (YII.LT.YMN.OR.YII.GT.YMX) GO TO 215
            DO 210 IXI=IXIMN,IXIMX
               XII = XI(IXI)
               L = 0
               IF (SPDT(X1,Y1,X2,Y2,XII,YII)) 180,175,210
  175          L = 1
  180          IF (SPDT(X3,Y3,X2,Y2,XII,YII)) 190,185,210
  185          L = 1
  190          IZI = NXI0*(IYI-1)+IXI
               IF (L.EQ.1) GO TO 195
               NGP0 = NGP0+1
               JIGP0 = JIGP0+1
               IGP(JIGP0) = IZI
               GO TO 210
  195          IF (JIGP1.GT.NXINYI) GO TO 205
               DO 200 JIGP1I=JIGP1,NXINYI
                  IF (IZI.EQ.IGP(JIGP1I)) GO TO 210
  200          CONTINUE
  205          NGP1 = NGP1+1
               JIGP1 = JIGP1-1
               IGP(JIGP1) = IZI
  210       CONTINUE
  215    CONTINUE
  220    JNGP0 = JNGP0+1
         NGP(JNGP0) = NGP0
         JNGP1 = JNGP1-1
         NGP(JNGP1) = NGP1
  225 CONTINUE
      RETURN
      END
C   ROUTINE NAME   - UERTST
C
C-----------------------------------------------------------------------
C
C   COMPUTER            - VAX/SINGLE
C
C   LATEST REVISION     - NOVEMBER 1, 1979
C
C   PURPOSE             - PRINT A MESSAGE REFLECTING AN ERROR CONDITION
C
C   USAGE               - CALL UERTST (IER,NAME)
C
C   ARGUMENTS    IER    - ERROR PARAMETER. (INPUT)
C                           IER = I+J WHERE
C                             I = 128 IMPLIES TERMINAL ERROR,
C                             I =  64 IMPLIES WARNING WITH FIX, AND
C                             I =  32 IMPLIES WARNING.
C                             J = ERROR CODE RELEVANT TO CALLING
C                                 ROUTINE.
C                NAME   - A SIX CHARACTER LITERAL STRING GIVING THE
C                           NAME OF THE CALLING ROUTINE. (INPUT)
C
C   PRECISION/HARDWARE  - SINGLE/ALL
C
C   REQD. ROUTINES      - UGETIO
C
C   NOTATION            - INFORMATION ON SPECIAL NOTATION AND
C                           CONVENTIONS IS AVAILABLE IN THE MANUAL
C                           INTRODUCTION OR THROUGH ROUTINE UHELP
C
C   REMARKS      THE ERROR MESSAGE PRODUCED BY UERTST IS WRITTEN
C                ONTO THE STANDARD OUTPUT UNIT. THE OUTPUT UNIT
C                NUMBER CAN BE DETERMINED BY CALLING UGETIO AS
C                FOLLOWS..   CALL UGETIO(1,NIN,NOUT).
C                THE OUTPUT UNIT NUMBER CAN BE CHANGED BY CALLING
C                UGETIO AS FOLLOWS..
C                                NIN = 0
C                                NOUT = NEW OUTPUT UNIT NUMBER
C                                CALL UGETIO(3,NIN,NOUT)
C                SEE THE UGETIO DOCUMENT FOR MORE DETAILS.
C
C-----------------------------------------------------------------------
C
      SUBROUTINE UERTST (IER,NAME)
C                                  SPECIFICATIONS FOR ARGUMENTS
      INTEGER            IER
      INTEGER*2          NAME(3)
C                                  SPECIFICATIONS FOR LOCAL VARIABLES
      INTEGER*2          NAMSET(3),NAMEQ(3)
      DATA               NAMSET/2HUE,2HRS,2HET/
      DATA               NAMEQ/2H  ,2H  ,2H  /
C                                  FIRST EXECUTABLE STATEMENT
      DATA               LEVEL/4/,IEQDF/0/,IEQ/1H=/
      IF (IER.GT.999) GO TO 25
      IF (IER.LT.-32) GO TO 55
      IF (IER.LE.128) GO TO 5
      IF (LEVEL.LT.1) GO TO 30
C                                  PRINT TERMINAL MESSAGE
      CALL UGETIO(1,NIN,IOUNIT)
      IF (IEQDF.EQ.1) goto 30
      IF (IEQDF.EQ.0) goto 30
      GO TO 30
    5 IF (IER.LE.64) GO TO 10
      IF (LEVEL.LT.2) GO TO 30
C                                  PRINT WARNING WITH FIX MESSAGE
      CALL UGETIO(1,NIN,IOUNIT)
      IF (IEQDF.EQ.1) goto 30
      IF (IEQDF.EQ.0) goto 30
      GO TO 30
   10 IF (IER.LE.32) GO TO 15
C                                  PRINT WARNING MESSAGE
      IF (LEVEL.LT.3) GO TO 30
      CALL UGETIO(1,NIN,IOUNIT)
      IF (IEQDF.EQ.1) goto 30
      IF (IEQDF.EQ.0) goto 30
      GO TO 30
   15 CONTINUE
C                                  CHECK FOR UERSET CALL
      DO 20 I=1,3
         IF (NAME(I).NE.NAMSET(I)) GO TO 25
   20 CONTINUE
      LEVOLD = LEVEL
      LEVEL = IER
      IER = LEVOLD
      IF (LEVEL.LT.0) LEVEL = 4
      IF (LEVEL.GT.4) LEVEL = 4
      GO TO 30
   25 CONTINUE
      IF (LEVEL.LT.4) GO TO 30
C                                  PRINT NON-DEFINED MESSAGE
      CALL UGETIO(1,NIN,IOUNIT)
      IF (IEQDF.EQ.1) goto 30
      IF (IEQDF.EQ.0) goto 30
   30 IEQDF = 0
      RETURN
C   35 FORMAT(19H *** TERMINAL ERROR,10X,7H(IER = ,I3,
C     1       20H) FROM ROUTINE ,3A2,A1,3A2)
C   40 FORMAT(36H *** WARNING WITH FIX ERROR  (IER = ,I3,
C     1       20H) FROM ROUTINE ,3A2,A1,3A2)
C   45 FORMAT(18H *** WARNING ERROR,11X,7H(IER = ,I3,
C     1       20H) FROM ROUTINE ,3A2,A1,3A2)
C   50 FORMAT(20H *** UNDEFINED ERROR,9X,7H(IER = ,I5,
C     1       20H) FROM ROUTINE ,3A2,A1,3A2)
C                                  SAVE P FOR P = R CASE
C                                    P IS THE PAGE NAME
C                                    R IS THE ROUTINE NAME
   55 IEQDF = 1
      DO 60 I=1,3
   60 NAMEQ(I) = NAME(I)
   65 RETURN
      END
C   ROUTINE NAME   - UGETIO
C
C-----------------------------------------------------------------------
C
C   COMPUTER            - VAX/SINGLE
C
C   LATEST REVISION     - JUNE 1, 1981
C
C   PURPOSE             - TO RETRIEVE CURRENT VALUES AND TO SET NEW
C                           VALUES FOR INPUT AND OUTPUT UNIT
C                           IDENTIFIERS.
C
C   USAGE               - CALL UGETIO(IOPT,NIN,NOUT)
C
C   ARGUMENTS    IOPT   - OPTION PARAMETER. (INPUT)
C                           IF IOPT=1, THE CURRENT INPUT AND OUTPUT
C                           UNIT IDENTIFIER VALUES ARE RETURNED IN NIN
C                           AND NOUT, RESPECTIVELY.
C                           IF IOPT=2, THE INTERNAL VALUE OF NIN IS
C                           RESET FOR SUBSEQUENT USE.
C                           IF IOPT=3, THE INTERNAL VALUE OF NOUT IS
C                           RESET FOR SUBSEQUENT USE.
C                NIN    - INPUT UNIT IDENTIFIER.
C                           OUTPUT IF IOPT=1, INPUT IF IOPT=2.
C                NOUT   - OUTPUT UNIT IDENTIFIER.
C                           OUTPUT IF IOPT=1, INPUT IF IOPT=3.
C
C   PRECISION/HARDWARE  - SINGLE/ALL
C
C   REQD. ROUTINES      - NONE REQUIRED
C
C   NOTATION            - INFORMATION ON SPECIAL NOTATION AND
C                           CONVENTIONS IS AVAILABLE IN THE MANUAL
C                           INTRODUCTION OR THROUGH ROUTINE UHELP
C
C   REMARKS      EACH ROUTINE THAT PERFORMS INPUT AND/OR OUTPUT
C                OPERATIONS CALLS UGETIO TO OBTAIN THE CURRENT UNIT
C                IDENTIFIER VALUES. IF UGETIO IS CALLED WITH IOPT=2 OR
C                IOPT=3, NEW UNIT IDENTIFIER VALUES ARE ESTABLISHED.
C                SUBSEQUENT INPUT/OUTPUT IS PERFORMED ON THE NEW UNITS.
C
C-----------------------------------------------------------------------
C
      SUBROUTINE UGETIO(IOPT,NIN,NOUT)
C                                  SPECIFICATIONS FOR ARGUMENTS
      INTEGER            IOPT,NIN,NOUT
C                                  SPECIFICATIONS FOR LOCAL VARIABLES
      INTEGER            NIND,NOUTD
      DATA               NIND/5/,NOUTD/6/
C                                  FIRST EXECUTABLE STATEMENT
      IF (IOPT.EQ.3) GO TO 10
      IF (IOPT.EQ.2) GO TO 5
      IF (IOPT.NE.1) GO TO 9005
      NIN = NIND
      NOUT = NOUTD
      GO TO 9005
    5 NIND = NIN
      GO TO 9005
   10 NOUTD = NOUT
 9005 RETURN
      END

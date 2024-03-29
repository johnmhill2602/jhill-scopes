	SUBROUTINE DJHORTH(X,Y,NPTS,A,B,S,W,CHISQ,IORD,SIGMAS,D,SIGMAD,
     *    RESIDY,PREDIC)

c************************************************************************
c       NOTE: THE IMPLICIT NAMING CONVENTIONS IS CHANGED SUCH THAT
c             REALS ARE DOUBLE PRECISION
c
        IMPLICIT REAL*8(A-H,O-Z),INTEGER(I-N)
c
c************************************************************************

C
C
C  LEAST SQUARES FIT TO ORTHOGONAL POLYNOMIALS
C
C  BY THE FORSYTHE METHOD
C
C  AFTER D. M. PETERSON, IN P.A.S.P. 91,546 (1979)
C  AFTER FORSYTHE, IN J.S.I.A.M. 5,74 (1957)
C	SEE ALSO RALSTON P247 AND KELLY P68
C
C  COPIED FROM PROGRAM OF M. KEANE
C
C  IMPLEMENTED ON STEWARD OBSERVATORY ECLIPSE
C       BY J. M. HILL     27 OCT 83
C	CREATED FROM 'LSORTH' AND 'POLYCON' 4 NOV 83
C
C  ERRORS ON CALCULATED COEFFICIENTS ADDED BY JMH 1 NOV 83
C
C  THIS VERSION OF 2 NOV 83 HAS FTEST SUPRESSED   JMH
C
C  ALSO GENERATES COEFFICIENTS AND ERRORS FOR NORMAL POLYNOMIALS
C
C  VERSION OF 7 NOV RETURNS RESIDUALS AND PREDICTED Y VALUES
C
C  VERSION OF 01JUN85 CONVERTED TO F77   JMH
C
C  VERSION OF 31OCT85 MADE DOUBLE PRECISION SUBROUTINE JDE
C
C  VERSION OF 26NOV85 CHECK FOR NFREE = 0 BEFORE DIVISION  JMH
C  VERSION OF 30NOV85 UNDO CHECK
C
C  TO COMPILE:  F77 DJHORTH.77
C
C  NO ADDITIONAL SUBROUTINE OR FUNCTION CALLS REQUIRED
C
C
C
C
C  Y = F(X) = SUM[S(I)*P(I,X)]
C
C  P(I+1) = (X-A(I))*P(I) - B(I)*P(I-1)
C
C  P(1) = 1.
C  P(2) = X - XMEAN = X - A(1)
C  P(3) = (X-A(2))*(X-A(1)) - B(2)
C
C
C  IF IORD.NE.0 IT SETS MAX ORDER OF THE FIT
C  IF IORD.EQ.0 MAX ORDER IS IMAXST-1 (9)
C  LINEAR IS THE MINIMUM ORDER (1)
C
C
C  OF COURSE, THE NUMBER OF DISTINCT VALUES OF X EXCEEDS THE
C       ORDER OF THE FIT
C
C  LIMIT ON NPTS IS SET BY DIMENSIONS IN CALLING PROGRAM
C
C
C
C         LIST OF VARIABLES
C
C	X(N)	ARRAY CONTAINING THE INDEPENDENT VARIABLE
C	Y(N)	ARRAY CONTAINING THE DEPENDENT VARIABLE
C	S(I)	COEFFICIENTS OF THE ORTHOGONAL POLYNOMIAL FIT
C	P(I)	SET OF ORTHOGONAL POLYNOMIALS
C	A(I)	ORTHOGONAL FIT PARAMETER -- ALPHA
C	B(I)	ORTHOGONAL FIT PARAMETER -- BETA
C	W(I)	WEIGHTS USED IN ORTHOGONAL FIT
C	IORD	ORDER OF THE FIT
C	IMAXST	MAXIMUM ORDER OF THE FIT
C	CHISQ	SUMMED SQUARED RESIDUALS
C	NPTS	NUMBER OF POINTS TO BE FIT
C
C	SIGMAS(I) ESTIMATED ERROR ON S(I)   = SQRT(CHISQ/W(I))
C	D(I)	COEFFICIENTS OF NORMAL POLYNOMIAL IN POWERS OF X
C	SIGMAD(I)  ESTIMATED ERROR ON D(I)  ???? BY FACTOR OF NFREE
C	BETA(J,M)	MATRIX ELEMENT TO GENERATE NORMAL POLYNOMIALS
C	RESIDY(N)	RESIDUAL OF THE FIT   Y(N) - PREDIC(N)
C	PREDIC(N)	PREDICTED Y VALUE
C
C
C	ALL VARIABLES DIMENSIONED TO HANDLE ANY FIT UP TO ORDER 9
C		FOR ANY NUMBER OF DATA POINTS WITHIN REASON.
C		INCREASE SIZE OF P(10) AND BETA(12,11) AND MAXTST
C		FOR HIGHER ORDER FITS.
C	DIMENSION ARGUMENTS PASSED TO THIS SUBROUTINE TO AT LEAST
C		ORDER+1 FOR VARIABLES WITH INDEX 'I'
C	DIMENSION TO NUMBER OF POINTS FOR VARIABLES WITH INDEX 'N'
C
C
	REAL*8 X(*),Y(*),A(*),B(*),S(*),W(*),SIGMAS(*),D(*),SIGMAD(*)
	REAL*8 P(10),BETA(12,11)
	REAL*8 RESIDY(*),PREDIC(*)

	INTEGER IORD,IMAXST,IMAX,NPTS



C  INITIALIZE VARIABLES

	IMAXST=10

	IMAX=IMAXST

	IF(IORD.NE.0) IMAX=MAX0(IABS(IORD)+1,2)

	DO 10 I=1,IMAX
	W(I)=0.
	S(I)=0.
	A(I)=0.
 	B(I)=0.
	D(I)=0.
	SIGMAD(I)=0.
10	SIGMAS(I)=0.


C  TEST FOR TOO FEW POINTS ??


C  CALCULATE ZEROTH ORDER PARAMETERS

	P(1)=1.

	DO 20 N=1,NPTS
C	TRANSFER Y TO RESIDY FOR POLYNOMIAL FIT
		RESIDY(N)=Y(N)
		PREDIC(N)=0.

C	ZEROTH ORDER PARAMETERS
		W(1)=W(1)+1.
		S(1)=S(1)+Y(N)
20		A(1)=A(1)+X(N)

	S(1)=S(1)/W(1)
	A(1)=A(1)/W(1)




C  CALCULATE HIGHER ORDER PARAMETERS

	I=1

C  LOOP RENTRY HERE

40	I1=I
	IF(IMAX.GT.I) I=I+1
	CHISQ=0.


C  SUM UP RESIDUALS AND COEFFICIENTS FOR ALL X,Y POINTS

	DO 70 N=1,NPTS

C  EVALUATE POLYNOMIALS P(I), I=2,ORDER+1

		P(2)=X(N)-A(1)

		IF(I.EQ.2) GO TO 60


		DO 50 K=3,I
			K1=K-1
50			P(K)=(X(N)-A(K1))*P(K1)-B(K1)*P(K-2)


C	STORE RESIDUAL 'DEL' IN THE RESIDY(I) ARRAY

60		DEL=RESIDY(N)-S(I1)*P(I1)
		RESIDY(N)=DEL

C  EVALUATE THE ORTHOGONAL POLYNOMIAL AT EACH X VALUE
C	AND RETURN THE CALCULATED VALUE IN PREDIC(N)
		PREDIC(N)=PREDIC(N)+S(I1)*P(I1)

		CHISQ=CHISQ+DEL*DEL

		IF(IMAX.LE.I1) GO TO 70

		P2=P(I)**2
		S(I)=S(I)+DEL*P(I)
		A(I)=A(I)+X(N)*P2
		W(I)=W(I)+P2

70	CONTINUE

	IF(IMAX.LE.I1) GO TO 80
	A(I)=A(I)/W(I)
	B(I)=W(I)/W(I1)
	S(I)=S(I)/W(I)




C  FTEST SECTION IN ORIGINAL PROGRAM WAS HERE   --JMH


C  RETURN TO CALCULATE HIGHER ORDER COEFFICIENTS

	GO TO 40


80	CONTINUE

C	CALCULATE ERRORS ON COEFFICIENTS (S)     JMH

	DO 150 II=1,IMAX
150	SIGMAS(II)=DSQRT(CHISQ/W(II))



C  THIS SECTION WAS FORMERLY IN 'POLYCON'
C  NOW CONVERT ORTHOGONAL COEFFICIENTS S(I) TO NORMAL D(I)

C	ZERO THE TRANSFORMATION MATRIX

	DO 100 I=1,12
		DO 100 J=1,11
100		BETA(I,J)=0.


C  FILL THE MATRIX VIA THE RECURSION RELATION
C	BETA(J,M) = 0	IF M>J
C			OR IF M = 0 OR J = 0
C	BETA(J,M) = 1	IF M = J
C
C	BETA(J,M) = BETA(J-1,M-1)
C			-A(J-1)*BETA(J-1,M)
C				-B(J-1)*BETA(J-2,M)
C
C	THE MATRIX BETA IS DIMENSIONED AT (12,11) TO AVOID PROBLEMS
C		WITH ZERO OR NEGATIVE INDICES IN THE RECURSION RELATION
C		INDICES ARE OFFSET ACCORDINGLY
C
C	THE NON-OFFSET MATRIX IS LOWER DIAGONAL BUT MEMORY IS CHEAP
C
C
C
C	SET THE (1,1) ELEMENT TO 1.0
	BETA(3,2)=1.0

C	NOW LOOP TO GENERATE THE OTHER NONZERO MATRIX ELEMENTS

	DO 300 J=2,IORD+1
		LJ=J+2
		DO 300 M=1,J
			LM=M+1
300	BETA(LJ,LM)=BETA(LJ-1,LM-1)-A(J-1)*BETA(LJ-1,LM)
     *   -B(J-1)*BETA(LJ-2,LM)


C	EVALUATE THE COEFFICIENTS AND THEIR ERRORS
C	FOR THE SET OF POLYNOMIALS BASED ON POWERS OF X
C
	DO 600 JJ=1,IORD+1

		DO 500 MM=JJ,IORD+1
			D(JJ)=D(JJ)+S(MM)*BETA(MM+2,JJ+1)
			SIGMAD(JJ)=SIGMAD(JJ)+BETA(MM+2,JJ+1)**2/W(MM)
500			CONTINUE


C  CALCULATE ERRORS   SOME TEXTS ARE UNCLEAR ABOUT REALITY OF THE
C			FACTOR OF SQRT(NFREE)

		NFREE=NPTS-IORD-1

c                IF( NFREE.LE.0 ) THEN
c                    SIGMAD(JJ) = 0
c                ELSE
                    SIGMAD(JJ)=DSQRT(SIGMAD(JJ)*CHISQ/NFREE)
c                ENDIF

600		CONTINUE




	RETURN
	END

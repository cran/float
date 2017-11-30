C Wrapper to fix a portability issue with passing characters from C on
C windows gfortran

C helpers; these map to the definitions in ../inst/include/float/slapack.h

      CHARACTER FUNCTION CUPLO(IUPLO)
      INTEGER IUPLO
      IF (IUPLO .EQ. 0) THEN
        CUPLO = 'L'
      ELSE
        CUPLO = 'U'
      END IF
      RETURN
      END FUNCTION

      CHARACTER FUNCTION CTRANS(ITRANS)
      INTEGER ITRANS
      IF (ITRANS .EQ. 0) THEN
        CTRANS = 'N'
      ELSE
        CTRANS = 'T'
      END IF
      RETURN
      END FUNCTION

      CHARACTER FUNCTION CDIAG(IDIAG)
      INTEGER IDIAG
      IF (IDIAG .EQ. 0) THEN
        CDIAG = 'N'
      ELSE
        CDIAG = 'U'
      END IF
      RETURN
      END FUNCTION

      CHARACTER FUNCTION CNORM(INORM)
      INTEGER INORM
      IF (INORM .EQ. 0) THEN
        CNORM = 'O'
      ELSE
        CNORM = 'I'
      END IF
      RETURN
      END FUNCTION

      CHARACTER FUNCTION CJOBZ(IJOBZ)
      INTEGER IJOBZ
      IF (IJOBZ .EQ. 0) THEN
        CJOBZ = 'N'
      ELSE IF (IJOBZ .EQ. 1) THEN
        CJOBZ = 'V'
      ELSE IF (IJOBZ .EQ. 2) THEN
        CJOBZ = 'A'
      ELSE IF (IJOBZ .EQ. 3) THEN
        CJOBZ = 'S'
      ELSE
        CJOBZ = 'O'
      END IF
      RETURN
      END FUNCTION

      CHARACTER FUNCTION CRANGE(IRANGE)
      INTEGER IRANGE
      IF (IRANGE .EQ. 0) THEN
        CRANGE = 'A'
      ELSE IF (IRANGE .EQ. 1) THEN
        CRANGE = 'V'
      ELSE
        CRANGE = 'T'
      END IF
      RETURN
      END FUNCTION

      CHARACTER FUNCTION CSIDE(ISIDE)
      INTEGER ISIDE
      IF (ISIDE .EQ. 0) THEN
        CSIDE = 'L'
      ELSE
        CSIDE = 'R'
      END IF
      RETURN
      END FUNCTION



C blas routines

      SUBROUTINE RSYRK(IUPLO,ITRANS,N,K,ALPHA,A,LDA,BETA,C,LDC)
      REAL ALPHA,BETA
      INTEGER K,LDA,LDC,N
      INTEGER ITRANS,IUPLO
      REAL A(LDA,*),C(LDC,*)
      EXTERNAL SSYRK
      CHARACTER TRANS,UPLO,CUPLO,CTRANS
      
      UPLO = CUPLO(IUPLO)
      TRANS = CTRANS(ITRANS)
      CALL SSYRK(UPLO, TRANS, N, K, ALPHA, A, LDA, BETA, C, LDC)
      
      END SUBROUTINE



C lapack routines

      SUBROUTINE RTRTRS(IUPLO,ITRANS,IDIAG,N,NRHS,A,LDA,B,LDB,INFO)
      INTEGER IDIAG, ITRANS, IUPLO
      INTEGER INFO, LDA, LDB, N, NRHS
      REAL A( LDA, * ), B( LDB, * )
      EXTERNAL STRTRS
      CHARACTER TRANS,UPLO,DIAG,CUPLO,CTRANS,CDIAG
      
      UPLO = CUPLO(IUPLO)
      TRANS = CTRANS(ITRANS)
      DIAG = CDIAG(IDIAG)
      CALL STRTRS(UPLO, TRANS, DIAG, N, NRHS, A, LDA, B, LDB, INFO)
      
      END SUBROUTINE



      SUBROUTINE RPOTRF(IUPLO,N,A,LDA,INFO)
      INTEGER IUPLO
      INTEGER INFO, LDA, N
      REAL A( LDA, * )
      CHARACTER UPLO,CUPLO
      
      UPLO = CUPLO(IUPLO)
      CALL SPOTRF(UPLO, N, A, LDA, INFO)
      
      END SUBROUTINE



      SUBROUTINE RTRCON(INORM,IUPLO,IDIAG,N,A,LDA,RCOND,WORK,IWORK,
     $                  INFO)
      INTEGER IDIAG, INORM, IUPLO
      INTEGER INFO, LDA, N
      REAL RCOND
      INTEGER IWORK( * )
      REAL A( LDA, * ), WORK( * )
      CHARACTER DIAG,NORM,UPLO,CDIAG,CNORM,CUPLO
      
      NORM = CNORM(INORM)
      UPLO = CUPLO(IUPLO)
      DIAG = CDIAG(IDIAG)
      CALL STRCON(NORM,UPLO,DIAG,N,A,LDA,RCOND,WORK,IWORK,INFO)
      
      END SUBROUTINE



      SUBROUTINE RGECON(INORM,N,A,LDA,ANORM,RCOND,WORK,IWORK,INFO)
      INTEGER INORM
      INTEGER INFO, LDA, N
      REAL ANORM, RCOND
      INTEGER IWORK( * )
      REAL A( LDA, * ), WORK( * )
      CHARACTER NORM,CNORM
      
      NORM = CNORM(INORM)
      CALL SGECON(NORM,N,A,LDA,ANORM,RCOND,WORK,IWORK,INFO)
      
      END SUBROUTINE



      SUBROUTINE RSYEVR(IJOBZ, IRANGE, IUPLO, N, A, LDA, VL, VU, IL, IU,
     $ ABSTOL, M, W, Z, LDZ, ISUPPZ, WORK, LWORK, IWORK, LIWORK, INFO)
      INTEGER IJOBZ, IRANGE, IUPLO
      INTEGER IL, INFO, IU, LDA, LDZ, LIWORK, LWORK, M, N
      REAL ABSTOL, VL, VU
      INTEGER ISUPPZ( * ), IWORK( * )
      REAL A( LDA, * ), W( * ), WORK( * ), Z( LDZ, * )
      CHARACTER JOBZ,RANGE,UPLO,CJOBZ,CRANGE,CUPLO
      
      JOBZ = CJOBZ(IJOBZ)
      RANGE = CRANGE(IRANGE)
      UPLO = CUPLO(IUPLO)
      CALL SSYEVR(JOBZ, RANGE, UPLO, N, A, LDA, VL, VU, IL, IU,
     $ ABSTOL, M, W, Z, LDZ, ISUPPZ, WORK, LWORK, IWORK, LIWORK, INFO)
      
      END SUBROUTINE



      SUBROUTINE RORMQR(ISIDE,ITRANS, M, N, K, A, LDA, TAU, C, LDC,
     $                   WORK, LWORK, INFO )
      INTEGER ISIDE, ITRANS
      INTEGER INFO, K, LDA, LDC, LWORK, M, N
      REAL A( LDA, * ), C( LDC, * ), TAU( * ), WORK( * )
      CHARACTER SIDE,TRANS,CSIDE,CTRANS
      
      SIDE = CSIDE(ISIDE)
      TRANS = CTRANS(ITRANS)
      CALL SORMQR(SIDE,TRANS,M,N,K,A,LDA,TAU,C,LDC,WORK,LWORK,INFO)
      
      END SUBROUTINE



      SUBROUTINE RGESDD(IJOBZ, M, N, A, LDA, S, U, LDU, VT, LDVT,
     $                   WORK, LWORK, IWORK, INFO )
      INTEGER IJOBZ
      INTEGER INFO, LDA, LDU, LDVT, LWORK, M, N
      INTEGER IWORK( * )
      REAL A(LDA,*), S(*), U(LDU,*), VT(LDVT,*), WORK(*)
      CHARACTER JOBZ,CJOBZ
      
      JOBZ = CJOBZ(IJOBZ)
      CALL SGESDD(JOBZ,M,N,A,LDA,S,U,LDU,VT,LDVT,WORK,LWORK,IWORK,INFO)
      
      END SUBROUTINE



      SUBROUTINE RGEMM(ITRANSA,ITRANSB,M,N,K,ALPHA,A,LDA,B,
     $                 LDB,BETA,C,LDC)
      REAL ALPHA,BETA
      INTEGER K,LDA,LDB,LDC,M,N
      INTEGER ITRANSA,ITRANSB
      REAL A(LDA,*),B(LDB,*),C(LDC,*)
      CHARACTER TRANSA,TRANSB,CTRANS
      
      TRANSA = CTRANS(ITRANSA)
      TRANSB = CTRANS(ITRANSB)
      CALL SGEMM(TRANSA,TRANSB,M,N,K,ALPHA,A,LDA,B,LDB,BETA,C,LDC)
      
      END SUBROUTINE



      SUBROUTINE RPOTRI( IUPLO, N, A, LDA, INFO )
      INTEGER IUPLO
      INTEGER INFO, LDA, N
      REAL A( LDA, * )
      CHARACTER UPLO,CUPLO
      
      UPLO = CUPLO(IUPLO)
      CALL SPOTRI(UPLO, N, A, LDA, INFO)
      
      END SUBROUTINE

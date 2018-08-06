#include <float/slapack.h>

#include "Rfloat.h"
#include "unroll.h"


static inline int worksize(const len_t m, const len_t n)
{
  int lwork;
  float tmp;
  
  F77_CALL(sgeqp3)(&m, &n, &(float){0}, &m, &(int){0}, &(float){0}, &tmp, &(int){-1}, &(int){0});
  lwork = (int) tmp;
  
  return MAX(lwork, 1);
}

static inline int get_rank(const len_t m, const len_t n, const float *const restrict qr, const double tol)
{
  const float minval = fabsf((float) tol*qr[0]);
  const len_t minmn = MIN(m, n);
  
  for (len_t i=1; i<minmn; i++)
  {
    if (fabsf(qr[i + m*i]) < minval)
      return i;
  }
  
  return minmn;
}

static inline int Qty(const int side, const int trans, const len_t m, const len_t n, const len_t nrhs, const float *const restrict qr, const float *const restrict qraux, float *const restrict y)
{
  int info;
  int lwork = -1;
  float tmp;
  
  F77_CALL(rormqr)(&side, &trans, &m, &nrhs, &n, qr, &m, qraux, y, &m, &tmp, &lwork, &info);
  lwork = (int) tmp;
  float *work = malloc(lwork * sizeof(*work));
  CHECKMALLOC(work);
  
  F77_CALL(rormqr)(&side, &trans, &m, &nrhs, &n, qr, &m, qraux, y, &m, work, &lwork, &info);
  
  if (info != 0)
    error("sormqr() returned info=%d\n", info);
  
  free(work);
  return info;
}



SEXP R_qr_spm(SEXP x, SEXP tol)
{
  SEXP qrlist, qrlist_names;
  SEXP qr, rank, qraux, pivot;
  int info;
  const len_t m = NROWS(x);
  const len_t n = NCOLS(x);
  const len_t minmn = MIN(m, n);
  
  PROTECT(rank = allocVector(INTSXP, 1));
  PROTECT(pivot = allocVector(INTSXP, n));
  
  PROTECT(qr = newmat(m, n));
  PROTECT(qraux = newvec(minmn));
  
  
  int lwork = worksize(m, n);
  float *work = malloc(lwork * sizeof(*work));
  CHECKMALLOC(work);
  
  memcpy(DATA(qr), DATA(x), (size_t)m*n*sizeof(float));
  memset(INTEGER(pivot), 0, n*sizeof(int));
  
  F77_CALL(sgeqp3)(&m, &n, DATA(qr), &m, INTEGER(pivot), DATA(qraux), work, &lwork, &info);
  
  free(work);
  
  if (info != 0)
    error("sgeqp3() returned info=%d\n", info);
  
  INTEGER(rank)[0] = get_rank(m, n, DATA(qr), REAL(tol)[0]);
  
  PROTECT(qrlist_names = allocVector(STRSXP, 4));
  SET_STRING_ELT(qrlist_names, 0, mkChar("qr"));
  SET_STRING_ELT(qrlist_names, 1, mkChar("rank"));
  SET_STRING_ELT(qrlist_names, 2, mkChar("qraux"));
  SET_STRING_ELT(qrlist_names, 3, mkChar("pivot"));
  
  PROTECT(qrlist = allocVector(VECSXP, 4));
  SET_VECTOR_ELT(qrlist, 0, qr);
  SET_VECTOR_ELT(qrlist, 1, rank);
  SET_VECTOR_ELT(qrlist, 2, qraux);
  SET_VECTOR_ELT(qrlist, 3, pivot);
  
  setAttrib(qrlist, R_NamesSymbol, qrlist_names);
  
  classgets(qrlist, mkString("qr"));
  UNPROTECT(6);
  return qrlist;
}



SEXP R_qrQ_spm(SEXP qr, SEXP qraux, SEXP complete_)
{
  SEXP ret;
  const int side = SIDE_L;
  const int trans = TRANS_N;
  const len_t m = NROWS(qr);
  const len_t n = NCOLS(qr);
  const int complete = INTEGER(complete_)[0];
  
  const len_t nrhs = complete ? m : MIN(m, n);
  PROTECT(ret = newmat(m, nrhs));
  float *retf = FLOAT(ret);
  
  memset(retf, 0, (size_t)m*nrhs*sizeof(float));
  for (len_t i=0; i<m*nrhs; i+=m+1)
    retf[i] = 1.0f;
  
  Qty(side, trans, m, n, nrhs, DATA(qr), DATA(qraux), retf);
  
  UNPROTECT(1);
  return ret;
}



SEXP R_qrR_spm(SEXP qr, SEXP complete_)
{
  SEXP R;
  const len_t m = NROWS(qr);
  const len_t n = NCOLS(qr);
  const int complete = INTEGER(complete_)[0];
  const len_t nrows = complete ? m : MIN(m, n);
  
  PROTECT(R = newmat(nrows, n));
  float *qrf = FLOAT(qr);
  float *Rf = FLOAT(R);
  
  memset(Rf, 0, (size_t)nrows*n*sizeof(float));
  for (len_t j=0; j<n; j++)
  {
    for (len_t i=0; i<=j && i<nrows; i++)
      Rf[i + nrows*j] = qrf[i + m*j];
  }
  
  UNPROTECT(1);
  return R;
}



SEXP R_qrqy_spm(SEXP qr, SEXP qraux, SEXP y, SEXP trans_)
{
  SEXP ret;
  const int side = SIDE_L;
  const int trans = LOGICAL(trans_)[0] ? TRANS_T : TRANS_N;
  const len_t m = NROWS(qr);
  const len_t n = NCOLS(qr);
  const len_t nrhs = NCOLS(y);
  
  PROTECT(ret = newmat(m, nrhs));
  Qty(side, trans, m, n, nrhs, DATA(qr), DATA(qraux), DATA(ret));
  
  UNPROTECT(1);
  return ret;
}

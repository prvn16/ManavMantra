/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * inv.c
 *
 * Code generation for function 'inv'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "inv.h"
#include "imwarp.h"
#include "warning.h"
#include "norm.h"
#include "colon.h"
#include "xgetrf.h"
#include "visionRecovertformCodeGeneration_kernel_mexutil.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"
#include "blas.h"

/* Variable Definitions */
static emlrtRSInfo lk_emlrtRSI = { 21, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo mk_emlrtRSI = { 22, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo nk_emlrtRSI = { 173,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo ok_emlrtRSI = { 174,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo pk_emlrtRSI = { 177,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo qk_emlrtRSI = { 180,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo rk_emlrtRSI = { 183,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo sk_emlrtRSI = { 190,/* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo tk_emlrtRSI = { 14, /* lineNo */
  "eml_ipiv2perm",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\private\\eml_ipiv2perm.m"/* pathName */
};

static emlrtRSInfo vk_emlrtRSI = { 76, /* lineNo */
  "xtrsm",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xtrsm.m"/* pathName */
};

static emlrtRSInfo wk_emlrtRSI = { 77, /* lineNo */
  "xtrsm",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xtrsm.m"/* pathName */
};

static emlrtRTEInfo dj_emlrtRTEI = { 14,/* lineNo */
  15,                                  /* colNo */
  "inv",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pName */
};

/* Function Definitions */
void inv(const emlrtStack *sp, const real32_T x_data[], const int32_T x_size[2],
         real32_T y_data[], int32_T y_size[2])
{
  int32_T n;
  int32_T c;
  int32_T b_x_size[2];
  real32_T b_x_data[12];
  int32_T ipiv_data[3];
  int32_T ipiv_size[2];
  real32_T c_x_data[9];
  int32_T p_data[3];
  int32_T p_size[2];
  int32_T k;
  int32_T j;
  real32_T n1x;
  char_T DIAGA;
  char_T TRANSA;
  char_T UPLO;
  char_T SIDE;
  ptrdiff_t m_t;
  int32_T i;
  ptrdiff_t n_t;
  ptrdiff_t lda_t;
  ptrdiff_t ldb_t;
  real32_T n1xinv;
  real32_T rc;
  const mxArray *y;
  const mxArray *m1;
  static const int32_T iv12[2] = { 1, 6 };

  static const char_T rfmt[6] = { '%', '1', '4', '.', '6', 'e' };

  char_T cv1[14];
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  if (x_size[0] != x_size[1]) {
    emlrtErrorWithMessageIdR2018a(sp, &dj_emlrtRTEI, "Coder:MATLAB:square",
      "Coder:MATLAB:square", 0);
  }

  if (x_size[0] == 0) {
    y_size[0] = 0;
    y_size[1] = x_size[1];
  } else {
    st.site = &lk_emlrtRSI;
    n = x_size[0];
    y_size[0] = x_size[0];
    y_size[1] = x_size[1];
    c = x_size[0] * x_size[1];
    if (0 <= c - 1) {
      memset(&y_data[0], 0, (uint32_T)(c * (int32_T)sizeof(real32_T)));
    }

    b_x_size[0] = x_size[0];
    b_x_size[1] = x_size[1];
    c = x_size[0] * x_size[1];
    if (0 <= c - 1) {
      memcpy(&b_x_data[0], &x_data[0], (uint32_T)(c * (int32_T)sizeof(real32_T)));
    }

    b_st.site = &nk_emlrtRSI;
    xgetrf(&b_st, x_size[0], x_size[0], b_x_data, b_x_size, x_size[0], ipiv_data,
           ipiv_size);
    c = b_x_size[0] * b_x_size[1];
    if (0 <= c - 1) {
      memcpy(&c_x_data[0], &b_x_data[0], (uint32_T)(c * (int32_T)sizeof(real32_T)));
    }

    b_st.site = &ok_emlrtRSI;
    c_st.site = &tk_emlrtRSI;
    d_st.site = &tj_emlrtRSI;
    e_st.site = &uj_emlrtRSI;
    f_st.site = &vj_emlrtRSI;
    eml_signed_integer_colon(&f_st, x_size[0], p_data, p_size);
    for (k = 0; k < ipiv_size[1]; k++) {
      if (ipiv_data[k] > 1 + k) {
        c = p_data[ipiv_data[k] - 1];
        p_data[ipiv_data[k] - 1] = p_data[k];
        p_data[k] = c;
      }
    }

    b_st.site = &pk_emlrtRSI;
    for (k = 0; k < n; k++) {
      c = p_data[k] - 1;
      y_data[k + y_size[0] * (p_data[k] - 1)] = 1.0F;
      b_st.site = &qk_emlrtRSI;
      for (j = k; j < n; j++) {
        if (y_data[j + y_size[0] * c] != 0.0F) {
          b_st.site = &rk_emlrtRSI;
          for (i = j + 1; i < n; i++) {
            y_data[i + y_size[0] * c] -= y_data[j + y_size[0] * c] * b_x_data[i
              + b_x_size[0] * j];
          }
        }
      }
    }

    b_st.site = &sk_emlrtRSI;
    c_st.site = &vk_emlrtRSI;
    c_st.site = &wk_emlrtRSI;
    n1x = 1.0F;
    DIAGA = 'N';
    TRANSA = 'N';
    UPLO = 'U';
    SIDE = 'L';
    m_t = (ptrdiff_t)x_size[0];
    n_t = (ptrdiff_t)x_size[0];
    lda_t = (ptrdiff_t)x_size[0];
    ldb_t = (ptrdiff_t)x_size[0];
    strsm(&SIDE, &UPLO, &TRANSA, &DIAGA, &m_t, &n_t, &n1x, &c_x_data[0], &lda_t,
          &y_data[0], &ldb_t);
    st.site = &mk_emlrtRSI;
    n1x = norm(x_data, x_size);
    n1xinv = norm(y_data, y_size);
    rc = 1.0F / (n1x * n1xinv);
    if ((n1x == 0.0F) || (n1xinv == 0.0F) || (rc == 0.0F)) {
      b_st.site = &xk_emlrtRSI;
      warning(&b_st);
    } else {
      if (muSingleScalarIsNaN(rc) || (rc < 1.1920929E-7F)) {
        b_st.site = &yk_emlrtRSI;
        y = NULL;
        m1 = emlrtCreateCharArray(2, iv12);
        emlrtInitCharArrayR2013a(&b_st, 6, m1, &rfmt[0]);
        emlrtAssign(&y, m1);
        c_st.site = &um_emlrtRSI;
        emlrt_marshallIn(&c_st, b_sprintf(&c_st, y, d_emlrt_marshallOut(rc),
          &e_emlrtMCI), "sprintf", cv1);
        b_st.site = &yk_emlrtRSI;
        b_warning(&b_st, cv1);
      }
    }
  }
}

/* End of code generation (inv.c) */

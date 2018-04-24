/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * det.c
 *
 * Code generation for function 'det'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "det.h"
#include "eml_int_forloop_overflow_check.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo gb_emlrtRSI = { 36, /* lineNo */
  "xzgetrf",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzgetrf.m"/* pathName */
};

static emlrtRSInfo hb_emlrtRSI = { 50, /* lineNo */
  "xzgetrf",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzgetrf.m"/* pathName */
};

static emlrtRSInfo ib_emlrtRSI = { 58, /* lineNo */
  "xzgetrf",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzgetrf.m"/* pathName */
};

static emlrtRSInfo jb_emlrtRSI = { 23, /* lineNo */
  "ixamax",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\ixamax.m"/* pathName */
};

static emlrtRSInfo kb_emlrtRSI = { 24, /* lineNo */
  "ixamax",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\ixamax.m"/* pathName */
};

static emlrtRSInfo mb_emlrtRSI = { 45, /* lineNo */
  "xgeru",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xgeru.m"/* pathName */
};

static emlrtRSInfo nb_emlrtRSI = { 45, /* lineNo */
  "xger",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xger.m"/* pathName */
};

static emlrtRSInfo ob_emlrtRSI = { 15, /* lineNo */
  "xger",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\xger.m"/* pathName */
};

static emlrtRSInfo pb_emlrtRSI = { 54, /* lineNo */
  "xgerx",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\xgerx.m"/* pathName */
};

static emlrtRSInfo qb_emlrtRSI = { 41, /* lineNo */
  "xgerx",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\xgerx.m"/* pathName */
};

static emlrtRSInfo md_emlrtRSI = { 21, /* lineNo */
  "det",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\det.m"/* pathName */
};

static emlrtRSInfo nd_emlrtRSI = { 30, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

/* Function Definitions */
real_T det(const emlrtStack *sp, const real_T x[9])
{
  real_T y;
  real_T b_x[9];
  int32_T iy;
  int32_T j;
  int8_T ipiv[3];
  int32_T c;
  boolean_T isodd;
  int32_T jy;
  int32_T ix;
  real_T smax;
  real_T s;
  int32_T b;
  int32_T b_j;
  int32_T ijA;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &md_emlrtRSI;
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
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  memcpy(&b_x[0], &x[0], 9U * sizeof(real_T));
  b_st.site = &nd_emlrtRSI;
  for (iy = 0; iy < 3; iy++) {
    ipiv[iy] = (int8_T)(1 + iy);
  }

  for (j = 0; j < 2; j++) {
    c = j << 2;
    c_st.site = &gb_emlrtRSI;
    d_st.site = &jb_emlrtRSI;
    iy = 0;
    ix = c;
    smax = muDoubleScalarAbs(b_x[c]);
    e_st.site = &kb_emlrtRSI;
    for (jy = 2; jy <= 3 - j; jy++) {
      ix++;
      s = muDoubleScalarAbs(b_x[ix]);
      if (s > smax) {
        iy = jy - 1;
        smax = s;
      }
    }

    if (b_x[c + iy] != 0.0) {
      if (iy != 0) {
        ipiv[j] = (int8_T)((j + iy) + 1);
        ix = j;
        iy += j;
        for (jy = 0; jy < 3; jy++) {
          smax = b_x[ix];
          b_x[ix] = b_x[iy];
          b_x[iy] = smax;
          ix += 3;
          iy += 3;
        }
      }

      b = (c - j) + 3;
      c_st.site = &hb_emlrtRSI;
      for (iy = c + 1; iy < b; iy++) {
        b_x[iy] /= b_x[c];
      }
    }

    c_st.site = &ib_emlrtRSI;
    d_st.site = &mb_emlrtRSI;
    e_st.site = &nb_emlrtRSI;
    f_st.site = &ob_emlrtRSI;
    iy = c;
    jy = c + 3;
    g_st.site = &qb_emlrtRSI;
    for (b_j = 1; b_j <= 2 - j; b_j++) {
      smax = b_x[jy];
      if (b_x[jy] != 0.0) {
        ix = c + 1;
        b = (iy - j) + 6;
        g_st.site = &pb_emlrtRSI;
        if ((!(iy + 5 > b)) && (b > 2147483646)) {
          h_st.site = &lb_emlrtRSI;
          check_forloop_overflow_error(&h_st);
        }

        for (ijA = iy + 4; ijA < b; ijA++) {
          b_x[ijA] += b_x[ix] * -smax;
          ix++;
        }
      }

      jy += 3;
      iy += 3;
    }
  }

  y = b_x[0];
  isodd = false;
  for (jy = 0; jy < 2; jy++) {
    y *= b_x[(jy + 3 * (jy + 1)) + 1];
    if (ipiv[jy] > 1 + jy) {
      isodd = !isodd;
    }
  }

  if (isodd) {
    y = -y;
  }

  return y;
}

/* End of code generation (det.c) */

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
#include "mwmathutil.h"
#include <string.h>
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "det.h"
#include "eml_int_forloop_overflow_check.h"
#include "xgetrf.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo hj_emlrtRSI = { 21, /* lineNo */
  "det",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\det.m"/* pathName */
};

static emlrtRSInfo jj_emlrtRSI = { 30, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

static emlrtRSInfo qj_emlrtRSI = { 36, /* lineNo */
  "xzgetrf",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzgetrf.m"/* pathName */
};

static emlrtRSInfo rj_emlrtRSI = { 50, /* lineNo */
  "xzgetrf",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzgetrf.m"/* pathName */
};

static emlrtRSInfo sj_emlrtRSI = { 58, /* lineNo */
  "xzgetrf",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+reflapack\\xzgetrf.m"/* pathName */
};

static emlrtRSInfo xj_emlrtRSI = { 23, /* lineNo */
  "ixamax",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\ixamax.m"/* pathName */
};

static emlrtRSInfo yj_emlrtRSI = { 24, /* lineNo */
  "ixamax",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\ixamax.m"/* pathName */
};

static emlrtRSInfo ak_emlrtRSI = { 45, /* lineNo */
  "xgeru",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xgeru.m"/* pathName */
};

static emlrtRSInfo bk_emlrtRSI = { 45, /* lineNo */
  "xger",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+blas\\xger.m"/* pathName */
};

static emlrtRSInfo ck_emlrtRSI = { 15, /* lineNo */
  "xger",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\xger.m"/* pathName */
};

static emlrtRSInfo dk_emlrtRSI = { 54, /* lineNo */
  "xgerx",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\xgerx.m"/* pathName */
};

static emlrtRSInfo ek_emlrtRSI = { 41, /* lineNo */
  "xgerx",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+refblas\\xgerx.m"/* pathName */
};

static emlrtRTEInfo cj_emlrtRTEI = { 12,/* lineNo */
  15,                                  /* colNo */
  "det",                               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\det.m"/* pName */
};

/* Function Definitions */
real32_T b_det(const emlrtStack *sp, const real32_T x[9])
{
  real32_T y;
  int32_T iy;
  real32_T b_x[9];
  int32_T j;
  int8_T ipiv[3];
  int32_T c;
  boolean_T isodd;
  int32_T jy;
  int32_T ix;
  real32_T smax;
  real32_T s;
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
  st.site = &hj_emlrtRSI;
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
  for (iy = 0; iy < 9; iy++) {
    b_x[iy] = x[iy];
  }

  b_st.site = &jj_emlrtRSI;
  for (iy = 0; iy < 3; iy++) {
    ipiv[iy] = (int8_T)(1 + iy);
  }

  for (j = 0; j < 2; j++) {
    c = j << 2;
    c_st.site = &qj_emlrtRSI;
    d_st.site = &xj_emlrtRSI;
    iy = 0;
    ix = c;
    smax = muSingleScalarAbs(b_x[c]);
    e_st.site = &yj_emlrtRSI;
    for (jy = 2; jy <= 3 - j; jy++) {
      ix++;
      s = muSingleScalarAbs(b_x[ix]);
      if (s > smax) {
        iy = jy - 1;
        smax = s;
      }
    }

    if (b_x[c + iy] != 0.0F) {
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
      c_st.site = &rj_emlrtRSI;
      for (iy = c + 1; iy < b; iy++) {
        b_x[iy] /= b_x[c];
      }
    }

    c_st.site = &sj_emlrtRSI;
    d_st.site = &ak_emlrtRSI;
    e_st.site = &bk_emlrtRSI;
    f_st.site = &ck_emlrtRSI;
    iy = c;
    jy = c + 3;
    g_st.site = &ek_emlrtRSI;
    for (b_j = 1; b_j <= 2 - j; b_j++) {
      smax = b_x[jy];
      if (b_x[jy] != 0.0F) {
        ix = c + 1;
        b = (iy - j) + 6;
        g_st.site = &dk_emlrtRSI;
        if ((!(iy + 5 > b)) && (b > 2147483646)) {
          h_st.site = &mb_emlrtRSI;
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

real32_T det(const emlrtStack *sp, const real32_T x_data[], const int32_T
             x_size[2])
{
  real32_T y;
  int32_T b_x_size[2];
  int32_T loop_ub;
  real32_T b_x_data[12];
  int32_T ipiv_data[3];
  int32_T ipiv_size[2];
  boolean_T isodd;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  if (x_size[0] != x_size[1]) {
    emlrtErrorWithMessageIdR2018a(sp, &cj_emlrtRTEI, "Coder:MATLAB:square",
      "Coder:MATLAB:square", 0);
  }

  if ((x_size[0] == 0) || (x_size[1] == 0)) {
    y = 1.0F;
  } else {
    b_x_size[0] = x_size[0];
    b_x_size[1] = x_size[1];
    loop_ub = x_size[0] * x_size[1];
    if (0 <= loop_ub - 1) {
      memcpy(&b_x_data[0], &x_data[0], (uint32_T)(loop_ub * (int32_T)sizeof
              (real32_T)));
    }

    st.site = &hj_emlrtRSI;
    xgetrf(&st, x_size[0], x_size[1], b_x_data, b_x_size, x_size[0], ipiv_data,
           ipiv_size);
    y = b_x_data[0];
    for (loop_ub = 1; loop_ub - 1 <= b_x_size[0] - 2; loop_ub++) {
      y *= b_x_data[loop_ub + b_x_size[0] * loop_ub];
    }

    isodd = false;
    for (loop_ub = 0; loop_ub <= ipiv_size[1] - 2; loop_ub++) {
      if (ipiv_data[loop_ub] > 1 + loop_ub) {
        isodd = !isodd;
      }
    }

    if (isodd) {
      y = -y;
    }
  }

  return y;
}

/* End of code generation (det.c) */

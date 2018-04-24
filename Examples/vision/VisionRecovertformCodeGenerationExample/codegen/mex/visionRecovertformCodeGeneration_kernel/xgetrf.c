/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * xgetrf.c
 *
 * Code generation for function 'xgetrf'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "xgetrf.h"
#include "error.h"
#include "visionRecovertformCodeGeneration_kernel_mexutil.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"
#include "lapacke.h"

/* Variable Definitions */
static emlrtRSInfo ij_emlrtRSI = { 27, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

static emlrtRSInfo kj_emlrtRSI = { 90, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

static emlrtRSInfo lj_emlrtRSI = { 82, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

static emlrtRSInfo mj_emlrtRSI = { 78, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

static emlrtRSInfo nj_emlrtRSI = { 58, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

static emlrtRSInfo oj_emlrtRSI = { 57, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

static emlrtRSInfo pj_emlrtRSI = { 50, /* lineNo */
  "xgetrf",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+lapack\\xgetrf.m"/* pathName */
};

/* Function Definitions */
void b_xgetrf(const emlrtStack *sp, real32_T A_data[], int32_T A_size[2],
              int32_T ipiv_data[], int32_T ipiv_size[2], int32_T *info)
{
  ptrdiff_t info_t;
  ptrdiff_t ipiv_t[3];
  int32_T k;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &ij_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &pj_emlrtRSI;
  if (A_size[0] == 0) {
    ipiv_size[0] = 1;
    ipiv_size[1] = 0;
    *info = 0;
  } else {
    b_st.site = &oj_emlrtRSI;
    b_st.site = &nj_emlrtRSI;
    b_st.site = &mj_emlrtRSI;
    b_st.site = &lj_emlrtRSI;
    info_t = LAPACKE_sgetrf_work(102, (ptrdiff_t)3, (ptrdiff_t)3, &A_data[0],
      (ptrdiff_t)3, &ipiv_t[0]);
    *info = (int32_T)info_t;
    ipiv_size[0] = 1;
    ipiv_size[1] = 3;
    b_st.site = &kj_emlrtRSI;
    if (*info < 0) {
      if (*info == -1010) {
        c_st.site = &yh_emlrtRSI;
        b_error(&c_st);
      } else {
        c_st.site = &ai_emlrtRSI;
        g_error(&c_st, *info);
      }
    }

    for (k = 0; k < 3; k++) {
      ipiv_data[k] = (int32_T)ipiv_t[k];
    }
  }
}

void xgetrf(const emlrtStack *sp, int32_T m, int32_T n, real32_T A_data[],
            int32_T A_size[2], int32_T lda, int32_T ipiv_data[], int32_T
            ipiv_size[2])
{
  int32_T i28;
  int32_T varargin_1;
  const mxArray *y;
  const mxArray *m18;
  static const int32_T iv38[2] = { 1, 15 };

  ptrdiff_t info_t;
  ptrdiff_t ipiv_t_data[3];
  int32_T info;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &ij_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &pj_emlrtRSI;
  if ((A_size[0] == 0) || (A_size[1] == 0)) {
    ipiv_size[0] = 1;
    ipiv_size[1] = 0;
  } else {
    b_st.site = &oj_emlrtRSI;
    c_st.site = &vh_emlrtRSI;
    i28 = muIntScalarMin_sint32(m, n);
    varargin_1 = muIntScalarMax_sint32(i28, 1);
    b_st.site = &oj_emlrtRSI;
    c_st.site = &tb_emlrtRSI;
    if ((int8_T)varargin_1 != varargin_1) {
      y = NULL;
      m18 = emlrtCreateCharArray(2, iv38);
      emlrtInitCharArrayR2013a(&b_st, 15, m18, &cv0[0]);
      emlrtAssign(&y, m18);
      c_st.site = &sm_emlrtRSI;
      i_error(&c_st, y, &b_emlrtMCI);
    }

    b_st.site = &nj_emlrtRSI;
    c_st.site = &vh_emlrtRSI;
    b_st.site = &mj_emlrtRSI;
    c_st.site = &vh_emlrtRSI;
    b_st.site = &lj_emlrtRSI;
    c_st.site = &wh_emlrtRSI;
    info_t = LAPACKE_sgetrf_work(102, (ptrdiff_t)m, (ptrdiff_t)n, &A_data[0],
      (ptrdiff_t)lda, &ipiv_t_data[0]);
    info = (int32_T)info_t;
    ipiv_size[0] = 1;
    ipiv_size[1] = (int8_T)varargin_1;
    b_st.site = &kj_emlrtRSI;
    c_st.site = &xh_emlrtRSI;
    if (info < 0) {
      if (info == -1010) {
        c_st.site = &yh_emlrtRSI;
        b_error(&c_st);
      } else {
        c_st.site = &ai_emlrtRSI;
        g_error(&c_st, info);
      }
    }

    for (info = 0; info < (int8_T)varargin_1; info++) {
      ipiv_data[info] = (int32_T)ipiv_t_data[info];
    }
  }
}

/* End of code generation (xgetrf.c) */

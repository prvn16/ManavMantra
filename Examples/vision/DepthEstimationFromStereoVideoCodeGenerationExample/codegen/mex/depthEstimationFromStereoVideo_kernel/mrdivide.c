/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * mrdivide.c
 *
 * Code generation for function 'mrdivide'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "mrdivide.h"
#include "warning.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo yf_emlrtRSI = { 1,  /* lineNo */
  "mrdivide",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\mrdivide.p"/* pathName */
};

static emlrtRSInfo ag_emlrtRSI = { 48, /* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo bg_emlrtRSI = { 251,/* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

static emlrtRSInfo cg_emlrtRSI = { 76, /* lineNo */
  "lusolve",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\lusolve.m"/* pathName */
};

/* Function Definitions */
void mrdivide(const emlrtStack *sp, const real_T A[9], const real_T B[9], real_T
              y[9])
{
  real_T b_A[9];
  int32_T r1;
  int32_T r2;
  int32_T r3;
  real_T maxval;
  real_T a21;
  int32_T rtemp;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &yf_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  b_st.site = &ag_emlrtRSI;
  memcpy(&b_A[0], &B[0], 9U * sizeof(real_T));
  r1 = 0;
  r2 = 1;
  r3 = 2;
  maxval = muDoubleScalarAbs(B[0]);
  a21 = muDoubleScalarAbs(B[1]);
  if (a21 > maxval) {
    maxval = a21;
    r1 = 1;
    r2 = 0;
  }

  if (muDoubleScalarAbs(B[2]) > maxval) {
    r1 = 2;
    r2 = 1;
    r3 = 0;
  }

  b_A[r2] = B[r2] / B[r1];
  b_A[r3] /= b_A[r1];
  b_A[3 + r2] -= b_A[r2] * b_A[3 + r1];
  b_A[3 + r3] -= b_A[r3] * b_A[3 + r1];
  b_A[6 + r2] -= b_A[r2] * b_A[6 + r1];
  b_A[6 + r3] -= b_A[r3] * b_A[6 + r1];
  if (muDoubleScalarAbs(b_A[3 + r3]) > muDoubleScalarAbs(b_A[3 + r2])) {
    rtemp = r2;
    r2 = r3;
    r3 = rtemp;
  }

  b_A[3 + r3] /= b_A[3 + r2];
  b_A[6 + r3] -= b_A[3 + r3] * b_A[6 + r2];
  if ((b_A[r1] == 0.0) || (b_A[3 + r2] == 0.0) || (b_A[6 + r3] == 0.0)) {
    c_st.site = &bg_emlrtRSI;
    d_st.site = &cg_emlrtRSI;
    warning(&d_st);
  }

  for (rtemp = 0; rtemp < 3; rtemp++) {
    y[rtemp + 3 * r1] = A[rtemp] / b_A[r1];
    y[rtemp + 3 * r2] = A[3 + rtemp] - y[rtemp + 3 * r1] * b_A[3 + r1];
    y[rtemp + 3 * r3] = A[6 + rtemp] - y[rtemp + 3 * r1] * b_A[6 + r1];
    y[rtemp + 3 * r2] /= b_A[3 + r2];
    y[rtemp + 3 * r3] -= y[rtemp + 3 * r2] * b_A[6 + r2];
    y[rtemp + 3 * r3] /= b_A[6 + r3];
    y[rtemp + 3 * r2] -= y[rtemp + 3 * r3] * b_A[3 + r3];
    y[rtemp + 3 * r1] -= y[rtemp + 3 * r3] * b_A[r3];
    y[rtemp + 3 * r1] -= y[rtemp + 3 * r2] * b_A[r2];
  }
}

/* End of code generation (mrdivide.c) */

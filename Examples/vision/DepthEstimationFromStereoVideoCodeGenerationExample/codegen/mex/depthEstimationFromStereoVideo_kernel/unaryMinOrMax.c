/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * unaryMinOrMax.c
 *
 * Code generation for function 'unaryMinOrMax'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "unaryMinOrMax.h"
#include "eml_int_forloop_overflow_check.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo mk_emlrtRSI = { 894,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

static emlrtRSInfo nk_emlrtRSI = { 910,/* lineNo */
  "unaryMinOrMax",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\unaryMinOrMax.m"/* pathName */
};

/* Function Declarations */
static int32_T findFirst(const emlrtStack *sp, const emxArray_real_T *x);

/* Function Definitions */
static int32_T findFirst(const emlrtStack *sp, const emxArray_real_T *x)
{
  int32_T idx;
  boolean_T overflow;
  int32_T k;
  boolean_T exitg1;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (!muDoubleScalarIsNaN(x->data[0])) {
    idx = 1;
  } else {
    idx = 0;
    st.site = &mk_emlrtRSI;
    overflow = ((!(2 > x->size[0])) && (x->size[0] > 2147483646));
    if (overflow) {
      b_st.site = &lb_emlrtRSI;
      check_forloop_overflow_error(&b_st);
    }

    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k <= x->size[0])) {
      if (!muDoubleScalarIsNaN(x->data[k - 1])) {
        idx = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  return idx;
}

int32_T b_findFirst(const emlrtStack *sp, const emxArray_real_T *x)
{
  int32_T idx;
  boolean_T overflow;
  int32_T k;
  boolean_T exitg1;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  if (!muDoubleScalarIsNaN(x->data[0])) {
    idx = 1;
  } else {
    idx = 0;
    st.site = &mk_emlrtRSI;
    overflow = ((!(2 > x->size[1])) && (x->size[1] > 2147483646));
    if (overflow) {
      b_st.site = &lb_emlrtRSI;
      check_forloop_overflow_error(&b_st);
    }

    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k <= x->size[1])) {
      if (!muDoubleScalarIsNaN(x->data[k - 1])) {
        idx = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  return idx;
}

real_T b_minOrMaxRealFloatVector(const emlrtStack *sp, const emxArray_real_T *x)
{
  real_T ex;
  int32_T idx;
  boolean_T overflow;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  if (x->size[0] <= 2) {
    if (x->size[0] == 1) {
      ex = x->data[0];
    } else if ((x->data[0] < x->data[1]) || (muDoubleScalarIsNaN(x->data[0]) &&
                (!muDoubleScalarIsNaN(x->data[1])))) {
      ex = x->data[1];
    } else {
      ex = x->data[0];
    }
  } else {
    st.site = &lk_emlrtRSI;
    idx = findFirst(&st, x);
    if (idx == 0) {
      ex = x->data[0];
    } else {
      st.site = &kk_emlrtRSI;
      ex = x->data[idx - 1];
      b_st.site = &nk_emlrtRSI;
      overflow = ((!(idx + 1 > x->size[0])) && (x->size[0] > 2147483646));
      if (overflow) {
        c_st.site = &lb_emlrtRSI;
        check_forloop_overflow_error(&c_st);
      }

      while (idx + 1 <= x->size[0]) {
        if (ex < x->data[idx]) {
          ex = x->data[idx];
        }

        idx++;
      }
    }
  }

  return ex;
}

real_T minOrMaxRealFloatVector(const emlrtStack *sp, const emxArray_real_T *x)
{
  real_T ex;
  int32_T idx;
  boolean_T overflow;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  if (x->size[0] <= 2) {
    if (x->size[0] == 1) {
      ex = x->data[0];
    } else if ((x->data[0] > x->data[1]) || (muDoubleScalarIsNaN(x->data[0]) &&
                (!muDoubleScalarIsNaN(x->data[1])))) {
      ex = x->data[1];
    } else {
      ex = x->data[0];
    }
  } else {
    st.site = &lk_emlrtRSI;
    idx = findFirst(&st, x);
    if (idx == 0) {
      ex = x->data[0];
    } else {
      st.site = &kk_emlrtRSI;
      ex = x->data[idx - 1];
      b_st.site = &nk_emlrtRSI;
      overflow = ((!(idx + 1 > x->size[0])) && (x->size[0] > 2147483646));
      if (overflow) {
        c_st.site = &lb_emlrtRSI;
        check_forloop_overflow_error(&c_st);
      }

      while (idx + 1 <= x->size[0]) {
        if (ex > x->data[idx]) {
          ex = x->data[idx];
        }

        idx++;
      }
    }
  }

  return ex;
}

void minOrMaxRealFloatVectorKernel(const emlrtStack *sp, const emxArray_real_T
  *x, int32_T first, int32_T last, real_T *ex, int32_T *idx)
{
  int32_T k;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  *ex = x->data[first - 1];
  *idx = first;
  st.site = &nk_emlrtRSI;
  if ((!(first + 1 > last)) && (last > 2147483646)) {
    b_st.site = &lb_emlrtRSI;
    check_forloop_overflow_error(&b_st);
  }

  for (k = first; k < last; k++) {
    if (*ex > x->data[k]) {
      *ex = x->data[k];
      *idx = k + 1;
    }
  }
}

/* End of code generation (unaryMinOrMax.c) */

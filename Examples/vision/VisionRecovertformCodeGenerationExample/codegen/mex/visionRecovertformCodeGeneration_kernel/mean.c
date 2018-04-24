/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * mean.c
 *
 * Code generation for function 'mean'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "mean.h"
#include "eml_int_forloop_overflow_check.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRTEInfo xi_emlrtRTEI = { 17,/* lineNo */
  15,                                  /* colNo */
  "mean",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\mean.m"/* pName */
};

/* Function Definitions */
real32_T mean(const emlrtStack *sp, const emxArray_real32_T *x)
{
  real32_T y;
  int32_T firstBlockLength;
  int32_T nblocks;
  int32_T lastBlockLength;
  int32_T k;
  int32_T xblockoffset;
  real32_T bsum;
  int32_T hi;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
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
  if ((x->size[1] == 1) || (x->size[1] != 1)) {
  } else {
    emlrtErrorWithMessageIdR2018a(sp, &xi_emlrtRTEI,
      "Coder:toolbox:autoDimIncompatibility",
      "Coder:toolbox:autoDimIncompatibility", 0);
  }

  st.site = &yg_emlrtRSI;
  b_st.site = &xc_emlrtRSI;
  if (x->size[1] == 0) {
    y = 0.0F;
  } else {
    c_st.site = &yc_emlrtRSI;
    if (x->size[1] <= 1024) {
      firstBlockLength = x->size[1];
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = x->size[1] / 1024;
      lastBlockLength = x->size[1] - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }

    y = x->data[0];
    d_st.site = &bd_emlrtRSI;
    for (k = 2; k <= firstBlockLength; k++) {
      y += x->data[k - 1];
    }

    d_st.site = &ad_emlrtRSI;
    for (firstBlockLength = 2; firstBlockLength <= nblocks; firstBlockLength++)
    {
      xblockoffset = (firstBlockLength - 1) << 10;
      bsum = x->data[xblockoffset];
      if (firstBlockLength == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }

      d_st.site = &ah_emlrtRSI;
      if ((!(2 > hi)) && (hi > 2147483646)) {
        e_st.site = &mb_emlrtRSI;
        check_forloop_overflow_error(&e_st);
      }

      for (k = 2; k <= hi; k++) {
        bsum += x->data[(xblockoffset + k) - 1];
      }

      y += bsum;
    }
  }

  y /= (real32_T)x->size[1];
  return y;
}

/* End of code generation (mean.c) */

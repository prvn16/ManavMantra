/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * FeaturePointsImpl.c
 *
 * Code generation for function 'FeaturePointsImpl'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "FeaturePointsImpl.h"
#include "all.h"
#include "validatesize.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo eb_emlrtRSI = { 292,/* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

static emlrtRSInfo fb_emlrtRSI = { 315,/* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

/* Function Definitions */
void FeaturePointsImpl_checkLocation(const emlrtStack *sp, const
  emxArray_real32_T *location)
{
  boolean_T p;
  int32_T i5;
  int32_T k;
  boolean_T exitg1;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &eb_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  b_st.site = &q_emlrtRSI;
  p = true;
  i5 = location->size[0] << 1;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= i5 - 1)) {
    if (!muSingleScalarIsNaN(location->data[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ii_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:vision.internal.SURFPoints_cg:expectedNonNaN", 3, 4, 5, "input");
  }

  b_st.site = &q_emlrtRSI;
  p = all(location);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ci_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:vision.internal.SURFPoints_cg:expectedFinite", 3, 4, 5, "input");
  }

  b_st.site = &q_emlrtRSI;
  p = true;
  i5 = location->size[0] << 1;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= i5 - 1)) {
    if (!(location->data[k] <= 0.0F)) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &bi_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedPositive",
      "MATLAB:vision.internal.SURFPoints_cg:expectedPositive", 3, 4, 5, "input");
  }

  b_st.site = &q_emlrtRSI;
  if (!size_check(location)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ji_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:vision.internal.SURFPoints_cg:incorrectSize", 3, 4, 5, "Input");
  }
}

void FeaturePointsImpl_checkMetric(const emlrtStack *sp, const emxArray_real32_T
  *metric)
{
  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &fb_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  b_st.site = &gb_emlrtRSI;
  c_st.site = &q_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= metric->size[0] - 1)) {
    if (!muSingleScalarIsNaN(metric->data[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ii_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:vision.internal.SURFPoints_cg:expectedNonNaN", 3, 4, 6, "Metric");
  }

  c_st.site = &q_emlrtRSI;
  p = b_all(metric);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ci_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:vision.internal.SURFPoints_cg:expectedFinite", 3, 4, 6, "Metric");
  }
}

/* End of code generation (FeaturePointsImpl.c) */

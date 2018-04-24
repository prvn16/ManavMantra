/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sort1.c
 *
 * Code generation for function 'sort1'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "sort1.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "sortIdx.h"
#include "eml_int_forloop_overflow_check.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo ke_emlrtRSI = { 81, /* lineNo */
  "sort",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m"/* pathName */
};

static emlrtRSInfo le_emlrtRSI = { 84, /* lineNo */
  "sort",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m"/* pathName */
};

static emlrtRSInfo me_emlrtRSI = { 87, /* lineNo */
  "sort",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m"/* pathName */
};

static emlrtRSInfo ne_emlrtRSI = { 90, /* lineNo */
  "sort",                              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m"/* pathName */
};

static emlrtRTEInfo he_emlrtRTEI = { 1,/* lineNo */
  20,                                  /* colNo */
  "sort",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m"/* pName */
};

static emlrtRTEInfo rh_emlrtRTEI = { 56,/* lineNo */
  1,                                   /* colNo */
  "sort",                              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\sort.m"/* pName */
};

/* Function Definitions */
void sort(const emlrtStack *sp, emxArray_real32_T *x, emxArray_int32_T *idx)
{
  emxArray_real32_T *vwork;
  int32_T vlen;
  int32_T vstride;
  int32_T j;
  int32_T iv37[2];
  boolean_T overflow;
  emxArray_int32_T *iidx;
  int32_T k;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real32_T1(sp, &vwork, 1, &rh_emlrtRTEI, true);
  vlen = x->size[1];
  vstride = x->size[1];
  j = vwork->size[0];
  vwork->size[0] = vstride;
  emxEnsureCapacity_real32_T1(sp, vwork, j, &he_emlrtRTEI);
  for (j = 0; j < 2; j++) {
    iv37[j] = x->size[j];
  }

  j = idx->size[0] * idx->size[1];
  idx->size[0] = iv37[0];
  idx->size[1] = iv37[1];
  emxEnsureCapacity_int32_T1(sp, idx, j, &he_emlrtRTEI);
  vstride = x->size[0];
  st.site = &ke_emlrtRSI;
  overflow = ((!(1 > x->size[0])) && (x->size[0] > 2147483646));
  if (overflow) {
    b_st.site = &mb_emlrtRSI;
    check_forloop_overflow_error(&b_st);
  }

  j = 0;
  emxInit_int32_T(sp, &iidx, 1, &he_emlrtRTEI, true);
  while (j + 1 <= vstride) {
    st.site = &le_emlrtRSI;
    if ((!(1 > vlen)) && (vlen > 2147483646)) {
      b_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&b_st);
    }

    for (k = 0; k < vlen; k++) {
      vwork->data[k] = x->data[j + k * vstride];
    }

    st.site = &me_emlrtRSI;
    sortIdx(&st, vwork, iidx);
    st.site = &ne_emlrtRSI;
    for (k = 0; k < vlen; k++) {
      x->data[j + k * vstride] = vwork->data[k];
      idx->data[j + k * vstride] = iidx->data[k];
    }

    j++;
  }

  emxFree_int32_T(sp, &iidx);
  emxFree_real32_T(sp, &vwork);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (sort1.c) */

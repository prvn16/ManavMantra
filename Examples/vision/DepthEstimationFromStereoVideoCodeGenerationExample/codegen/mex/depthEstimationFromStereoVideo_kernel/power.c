/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * power.c
 *
 * Code generation for function 'power'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "power.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "eml_int_forloop_overflow_check.h"
#include "scalexpAlloc.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRTEInfo pb_emlrtRTEI = { 19,/* lineNo */
  24,                                  /* colNo */
  "scalexpAllocNoCheck",               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\scalexpAllocNoCheck.m"/* pName */
};

static emlrtRTEInfo qb_emlrtRTEI = { 1,/* lineNo */
  14,                                  /* colNo */
  "power",                             /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\power.m"/* pName */
};

/* Function Definitions */
void b_power(const emlrtStack *sp, const emxArray_real_T *a, emxArray_real_T *y)
{
  emxArray_real_T *z;
  emxArray_real_T *b_z;
  uint32_T a_idx_0;
  int32_T k;
  uint32_T b_a_idx_0;
  boolean_T overflow;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T1(sp, &z, 1, &qb_emlrtRTEI, true);
  emxInit_real_T1(sp, &b_z, 1, &qb_emlrtRTEI, true);
  st.site = &bi_emlrtRSI;
  b_st.site = &ci_emlrtRSI;
  c_st.site = &di_emlrtRSI;
  a_idx_0 = (uint32_T)a->size[0];
  k = b_z->size[0];
  b_z->size[0] = (int32_T)a_idx_0;
  emxEnsureCapacity_real_T(&c_st, b_z, k, &pb_emlrtRTEI);
  a_idx_0 = (uint32_T)a->size[0];
  b_a_idx_0 = (uint32_T)a->size[0];
  k = z->size[0];
  z->size[0] = (int32_T)b_a_idx_0;
  emxEnsureCapacity_real_T(&c_st, z, k, &b_emlrtRTEI);
  if (!dimagree(z, a)) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ne_emlrtRTEI, "MATLAB:dimagree",
      "MATLAB:dimagree", 0);
  }

  emxFree_real_T(&c_st, &z);
  b_a_idx_0 = (uint32_T)a->size[0];
  k = y->size[0];
  y->size[0] = (int32_T)b_a_idx_0;
  emxEnsureCapacity_real_T(&b_st, y, k, &c_emlrtRTEI);
  c_st.site = &ei_emlrtRSI;
  d_st.site = &fi_emlrtRSI;
  overflow = ((!(1 > b_z->size[0])) && (b_z->size[0] > 2147483646));
  emxFree_real_T(&d_st, &b_z);
  if (overflow) {
    e_st.site = &lb_emlrtRSI;
    check_forloop_overflow_error(&e_st);
  }

  for (k = 0; k < (int32_T)a_idx_0; k++) {
    y->data[k] = a->data[k] * a->data[k];
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void power(const real_T a[307200], real_T y[307200])
{
  int32_T k;
  for (k = 0; k < 307200; k++) {
    y[k] = a[k] * a[k];
  }
}

/* End of code generation (power.c) */

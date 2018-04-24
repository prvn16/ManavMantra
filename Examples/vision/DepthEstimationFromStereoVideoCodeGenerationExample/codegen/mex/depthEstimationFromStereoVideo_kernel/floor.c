/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * floor.c
 *
 * Code generation for function 'floor'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "floor.h"
#include "eml_int_forloop_overflow_check.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo gi_emlrtRSI = { 10, /* lineNo */
  "floor",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elfun\\floor.m"/* pathName */
};

/* Function Definitions */
void b_floor(real_T x[614400])
{
  int32_T k;
  for (k = 0; k < 614400; k++) {
    x[k] = muDoubleScalarFloor(x[k]);
  }
}

void c_floor(real_T x[307200])
{
  int32_T k;
  for (k = 0; k < 307200; k++) {
    x[k] = muDoubleScalarFloor(x[k]);
  }
}

void d_floor(const emlrtStack *sp, emxArray_real_T *x)
{
  int32_T nx;
  int32_T k;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &gi_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  nx = x->size[0] << 1;
  b_st.site = &hi_emlrtRSI;
  if ((!(1 > nx)) && (nx > 2147483646)) {
    c_st.site = &lb_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }

  for (k = 0; k < nx; k++) {
    x->data[k] = muDoubleScalarFloor(x->data[k]);
  }
}

void e_floor(const emlrtStack *sp, emxArray_real_T *x)
{
  int32_T nx;
  boolean_T overflow;
  int32_T k;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &gi_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  nx = x->size[0];
  b_st.site = &hi_emlrtRSI;
  overflow = ((!(1 > x->size[0])) && (x->size[0] > 2147483646));
  if (overflow) {
    c_st.site = &lb_emlrtRSI;
    check_forloop_overflow_error(&c_st);
  }

  for (k = 0; k < nx; k++) {
    x->data[k] = muDoubleScalarFloor(x->data[k]);
  }
}

/* End of code generation (floor.c) */

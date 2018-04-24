/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * meshgrid.c
 *
 * Code generation for function 'meshgrid'
 *
 */

/* Include files */
#include <string.h>
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "meshgrid.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "eml_int_forloop_overflow_check.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo si_emlrtRSI = { 31, /* lineNo */
  "meshgrid",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\meshgrid.m"/* pathName */
};

static emlrtRSInfo ti_emlrtRSI = { 32, /* lineNo */
  "meshgrid",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\meshgrid.m"/* pathName */
};

static emlrtRTEInfo tb_emlrtRTEI = { 1,/* lineNo */
  23,                                  /* colNo */
  "meshgrid",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\meshgrid.m"/* pName */
};

/* Function Definitions */
void b_meshgrid(const emlrtStack *sp, const emxArray_real_T *x, const
                emxArray_real_T *y, emxArray_real_T *xx, emxArray_real_T *yy)
{
  int32_T ny;
  int32_T unnamed_idx_0;
  int32_T unnamed_idx_1;
  int32_T i17;
  boolean_T overflow;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  ny = y->size[1];
  unnamed_idx_0 = y->size[1];
  unnamed_idx_1 = x->size[1];
  i17 = xx->size[0] * xx->size[1];
  xx->size[0] = unnamed_idx_0;
  xx->size[1] = unnamed_idx_1;
  emxEnsureCapacity_real_T1(sp, xx, i17, &tb_emlrtRTEI);
  unnamed_idx_0 = y->size[1];
  unnamed_idx_1 = x->size[1];
  i17 = yy->size[0] * yy->size[1];
  yy->size[0] = unnamed_idx_0;
  yy->size[1] = unnamed_idx_1;
  emxEnsureCapacity_real_T1(sp, yy, i17, &tb_emlrtRTEI);
  if ((x->size[1] == 0) || (y->size[1] == 0)) {
  } else {
    st.site = &si_emlrtRSI;
    overflow = (x->size[1] > 2147483646);
    if (overflow) {
      b_st.site = &lb_emlrtRSI;
      check_forloop_overflow_error(&b_st);
    }

    for (unnamed_idx_0 = 0; unnamed_idx_0 < x->size[1]; unnamed_idx_0++) {
      st.site = &ti_emlrtRSI;
      if ((!(1 > ny)) && (ny > 2147483646)) {
        b_st.site = &lb_emlrtRSI;
        check_forloop_overflow_error(&b_st);
      }

      for (unnamed_idx_1 = 0; unnamed_idx_1 < ny; unnamed_idx_1++) {
        xx->data[unnamed_idx_1 + xx->size[0] * unnamed_idx_0] = x->
          data[unnamed_idx_0];
        yy->data[unnamed_idx_1 + yy->size[0] * unnamed_idx_0] = y->
          data[unnamed_idx_1];
      }
    }
  }
}

void c_meshgrid(const emlrtStack *sp, const emxArray_real32_T *x, const
                emxArray_real32_T *y, emxArray_real32_T *xx, emxArray_real32_T
                *yy)
{
  int32_T ny;
  int32_T unnamed_idx_0;
  int32_T unnamed_idx_1;
  int32_T i43;
  boolean_T overflow;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  ny = y->size[1];
  unnamed_idx_0 = y->size[1];
  unnamed_idx_1 = x->size[1];
  i43 = xx->size[0] * xx->size[1];
  xx->size[0] = unnamed_idx_0;
  xx->size[1] = unnamed_idx_1;
  emxEnsureCapacity_real32_T(sp, xx, i43, &tb_emlrtRTEI);
  unnamed_idx_0 = y->size[1];
  unnamed_idx_1 = x->size[1];
  i43 = yy->size[0] * yy->size[1];
  yy->size[0] = unnamed_idx_0;
  yy->size[1] = unnamed_idx_1;
  emxEnsureCapacity_real32_T(sp, yy, i43, &tb_emlrtRTEI);
  if ((x->size[1] == 0) || (y->size[1] == 0)) {
  } else {
    st.site = &si_emlrtRSI;
    overflow = (x->size[1] > 2147483646);
    if (overflow) {
      b_st.site = &lb_emlrtRSI;
      check_forloop_overflow_error(&b_st);
    }

    for (unnamed_idx_0 = 0; unnamed_idx_0 < x->size[1]; unnamed_idx_0++) {
      st.site = &ti_emlrtRSI;
      if ((!(1 > ny)) && (ny > 2147483646)) {
        b_st.site = &lb_emlrtRSI;
        check_forloop_overflow_error(&b_st);
      }

      for (unnamed_idx_1 = 0; unnamed_idx_1 < ny; unnamed_idx_1++) {
        xx->data[unnamed_idx_1 + xx->size[0] * unnamed_idx_0] = x->
          data[unnamed_idx_0];
        yy->data[unnamed_idx_1 + yy->size[0] * unnamed_idx_0] = y->
          data[unnamed_idx_1];
      }
    }
  }
}

void meshgrid(const real_T x[640], const real_T y[480], real_T xx[307200],
              real_T yy[307200])
{
  int32_T j;
  int32_T i;
  for (j = 0; j < 640; j++) {
    memcpy(&yy[j * 480], &y[0], 480U * sizeof(real_T));
    for (i = 0; i < 480; i++) {
      xx[i + 480 * j] = x[j];
    }
  }
}

/* End of code generation (meshgrid.c) */

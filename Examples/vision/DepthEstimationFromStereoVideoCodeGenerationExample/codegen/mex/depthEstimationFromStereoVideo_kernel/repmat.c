/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * repmat.c
 *
 * Code generation for function 'repmat'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "repmat.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "assertValidSizeArg.h"
#include "matlabCodegenHandle.h"
#include "bwtraceboundary.h"
#include "depthEstimationFromStereoVideo_kernel_mexutil.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo oq_emlrtRSI = { 60, /* lineNo */
  "repmat",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pathName */
};

static emlrtRTEInfo ec_emlrtRTEI = { 1,/* lineNo */
  14,                                  /* colNo */
  "repmat",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pName */
};

/* Function Definitions */
void b_repmat(const emlrtStack *sp, const uint8_T a_data[], const real_T
              varargin_1[2], uint8_T b_data[], int32_T b_size[2])
{
  const mxArray *y;
  const mxArray *m9;
  static const int32_T iv28[2] = { 1, 15 };

  int32_T ntilerows;
  int32_T jcol;
  int32_T ibmat;
  int32_T itilerow;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &ck_emlrtRSI;
  assertValidSizeArg(&st, varargin_1);
  if ((int8_T)(int32_T)varargin_1[0] != (int32_T)varargin_1[0]) {
    y = NULL;
    m9 = emlrtCreateCharArray(2, iv28);
    emlrtInitCharArrayR2013a(sp, 15, m9, &cv1[0]);
    emlrtAssign(&y, m9);
    st.site = &qs_emlrtRSI;
    f_error(&st, y, &d_emlrtMCI);
  }

  b_size[0] = (int8_T)(int32_T)varargin_1[0];
  b_size[1] = 3;
  ntilerows = (int32_T)varargin_1[0];
  st.site = &aq_emlrtRSI;
  st.site = &oq_emlrtRSI;
  for (jcol = 0; jcol < 3; jcol++) {
    ibmat = jcol * ntilerows;
    st.site = &yp_emlrtRSI;
    for (itilerow = 1; itilerow <= ntilerows; itilerow++) {
      st.site = &do_emlrtRSI;
      b_data[(ibmat + itilerow) - 1] = a_data[jcol];
    }
  }
}

void repmat(const emlrtStack *sp, const real_T varargin_1[2], emxArray_boolean_T
            *b)
{
  int32_T i29;
  int32_T loop_ub;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &ck_emlrtRSI;
  assertValidSizeArg(&st, varargin_1);
  i29 = b->size[0] * b->size[1];
  b->size[0] = (int32_T)varargin_1[0];
  b->size[1] = (int32_T)varargin_1[1];
  emxEnsureCapacity_boolean_T1(sp, b, i29, &ec_emlrtRTEI);
  loop_ub = (int32_T)varargin_1[0] * (int32_T)varargin_1[1];
  for (i29 = 0; i29 < loop_ub; i29++) {
    b->data[i29] = false;
  }
}

/* End of code generation (repmat.c) */

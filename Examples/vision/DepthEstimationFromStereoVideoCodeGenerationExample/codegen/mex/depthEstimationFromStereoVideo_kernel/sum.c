/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sum.c
 *
 * Code generation for function 'sum'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "sum.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRTEInfo yf_emlrtRTEI = { 22,/* lineNo */
  23,                                  /* colNo */
  "sumprod",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\datafun\\private\\sumprod.m"/* pName */
};

/* Function Definitions */
real_T b_sum(const emlrtStack *sp, const int16_T x_data[], const int32_T x_size
             [2])
{
  real_T y;
  int32_T k;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &hm_emlrtRSI;
  if ((x_size[1] == 1) || (x_size[1] != 1)) {
  } else {
    emlrtErrorWithMessageIdR2018a(&st, &yf_emlrtRTEI,
      "Coder:toolbox:autoDimIncompatibility",
      "Coder:toolbox:autoDimIncompatibility", 0);
  }

  if (x_size[1] == 0) {
    y = 0.0;
  } else {
    y = x_data[0];
    for (k = 2; k <= x_size[1]; k++) {
      y += (real_T)x_data[k - 1];
    }
  }

  return y;
}

real_T c_sum(const emlrtStack *sp, const boolean_T x_data[], const int32_T
             x_size[2])
{
  real_T y;
  int32_T k;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &hm_emlrtRSI;
  if ((x_size[1] == 1) || (x_size[1] != 1)) {
  } else {
    emlrtErrorWithMessageIdR2018a(&st, &yf_emlrtRTEI,
      "Coder:toolbox:autoDimIncompatibility",
      "Coder:toolbox:autoDimIncompatibility", 0);
  }

  if (x_size[1] == 0) {
    y = 0.0;
  } else {
    y = x_data[0];
    for (k = 2; k <= x_size[1]; k++) {
      y += (real_T)x_data[k - 1];
    }
  }

  return y;
}

real_T sum(const uint8_T x[307200])
{
  real_T y;
  int32_T k;
  y = x[0];
  for (k = 0; k < 307199; k++) {
    y += (real_T)x[k + 1];
  }

  return y;
}

/* End of code generation (sum.c) */

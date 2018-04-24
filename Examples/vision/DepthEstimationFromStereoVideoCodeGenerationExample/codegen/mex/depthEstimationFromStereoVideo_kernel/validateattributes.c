/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * validateattributes.c
 *
 * Code generation for function 'validateattributes'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "validateattributes.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
void b_validateattributes(const emlrtStack *sp, const emxArray_real32_T *a)
{
  boolean_T p;
  int32_T i20;
  int32_T k;
  boolean_T exitg1;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &ic_emlrtRSI;
  p = true;
  i20 = a->size[0] * a->size[1];
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= i20 - 1)) {
    if (!muSingleScalarIsNaN(a->data[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&st, &xe_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:interp2d:expectedNonNaN", 3, 4, 1, "Y");
  }
}

void validateattributes(const emlrtStack *sp, const emxArray_real32_T *a)
{
  boolean_T p;
  int32_T i19;
  int32_T k;
  boolean_T exitg1;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &ic_emlrtRSI;
  p = true;
  i19 = a->size[0] * a->size[1];
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= i19 - 1)) {
    if (!muSingleScalarIsNaN(a->data[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&st, &xe_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:interp2d:expectedNonNaN", 3, 4, 1, "X");
  }
}

/* End of code generation (validateattributes.c) */

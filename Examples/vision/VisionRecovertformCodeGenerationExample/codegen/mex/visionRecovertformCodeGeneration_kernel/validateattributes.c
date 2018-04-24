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
#include "visionRecovertformCodeGeneration_kernel.h"
#include "validateattributes.h"
#include "all.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Function Definitions */
void b_validateattributes(const emlrtStack *sp, const real32_T a[9])
{
  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &q_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 9)) {
    if ((!muSingleScalarIsInf(a[k])) && (!muSingleScalarIsNaN(a[k]))) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&st, &ci_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:affine2d.set.T:expectedFinite", 3, 4, 1, "T");
  }
}

void validateattributes(const emlrtStack *sp, const real32_T a_data[], const
  int32_T a_size[2])
{
  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  emxArray_real32_T b_a_data;
  emlrtStack st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &q_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (3 == a_size[k]) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&st, &ji_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:affine2d.set.T:incorrectSize", 3, 4, 1, "T");
  }

  st.site = &q_emlrtRSI;
  b_a_data.data = (real32_T *)a_data;
  b_a_data.size = (int32_T *)a_size;
  b_a_data.allocatedSize = -1;
  b_a_data.numDimensions = 2;
  b_a_data.canFreeData = false;
  p = all(&b_a_data);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&st, &ci_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:affine2d.set.T:expectedFinite", 3, 4, 1, "T");
  }
}

/* End of code generation (validateattributes.c) */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * bsxfun.c
 *
 * Code generation for function 'bsxfun'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "bsxfun.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRTEInfo pd_emlrtRTEI = { 1,/* lineNo */
  14,                                  /* colNo */
  "bsxfun",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\bsxfun.m"/* pName */
};

static emlrtRTEInfo vf_emlrtRTEI = { 50,/* lineNo */
  15,                                  /* colNo */
  "bsxfun",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\bsxfun.m"/* pName */
};

/* Function Definitions */
void b_bsxfun(const emlrtStack *sp, const emxArray_real32_T *a, const
              emxArray_real32_T *b, emxArray_real32_T *c)
{
  int32_T sck;
  int32_T szc;
  int32_T acoef;
  int32_T bcoef;
  int32_T k;
  if (b->size[0] == 1) {
    sck = a->size[0];
  } else if (a->size[0] == 1) {
    sck = b->size[0];
  } else if (a->size[0] == b->size[0]) {
    sck = a->size[0];
  } else {
    sck = muIntScalarMin_sint32(b->size[0], a->size[0]);
    emlrtErrorWithMessageIdR2018a(sp, &vf_emlrtRTEI,
      "MATLAB:bsxfun:arrayDimensionsMustMatch",
      "MATLAB:bsxfun:arrayDimensionsMustMatch", 0);
  }

  szc = c->size[0] * c->size[1];
  c->size[0] = sck;
  c->size[1] = 3;
  emxEnsureCapacity_real32_T(sp, c, szc, &pd_emlrtRTEI);
  if (c->size[0] != 0) {
    for (sck = 0; sck < 3; sck++) {
      szc = c->size[0];
      acoef = (a->size[0] != 1);
      bcoef = (b->size[0] != 1);
      for (k = 0; k < szc; k++) {
        c->data[k + c->size[0] * sck] = a->data[acoef * k + a->size[0] * sck] *
          b->data[bcoef * k];
      }
    }
  }
}

void bsxfun(const real_T a[614400], const real_T b[2], real_T c[614400])
{
  int32_T k;
  int32_T b_k;
  for (k = 0; k < 2; k++) {
    for (b_k = 0; b_k < 307200; b_k++) {
      c[b_k + 307200 * k] = a[b_k + 307200 * k] - b[k];
    }
  }
}

/* End of code generation (bsxfun.c) */

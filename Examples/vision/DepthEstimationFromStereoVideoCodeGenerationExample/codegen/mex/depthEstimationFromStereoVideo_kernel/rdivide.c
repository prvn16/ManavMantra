/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * rdivide.c
 *
 * Code generation for function 'rdivide'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "rdivide.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRTEInfo ob_emlrtRTEI = { 1,/* lineNo */
  14,                                  /* colNo */
  "rdivide",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\rdivide.m"/* pName */
};

/* Function Definitions */
void b_rdivide(const emlrtStack *sp, const emxArray_real32_T *y,
               emxArray_real32_T *z)
{
  int32_T i44;
  int32_T loop_ub;
  i44 = z->size[0];
  z->size[0] = y->size[0];
  emxEnsureCapacity_real32_T1(sp, z, i44, &ob_emlrtRTEI);
  loop_ub = y->size[0];
  for (i44 = 0; i44 < loop_ub; i44++) {
    z->data[i44] = 1.0F / y->data[i44];
  }
}

void rdivide(const emlrtStack *sp, const emxArray_real_T *x, real_T y,
             emxArray_real_T *z)
{
  int32_T i12;
  int32_T loop_ub;
  i12 = z->size[0];
  z->size[0] = x->size[0];
  emxEnsureCapacity_real_T(sp, z, i12, &ob_emlrtRTEI);
  loop_ub = x->size[0];
  for (i12 = 0; i12 < loop_ub; i12++) {
    z->data[i12] = x->data[i12] / y;
  }
}

/* End of code generation (rdivide.c) */

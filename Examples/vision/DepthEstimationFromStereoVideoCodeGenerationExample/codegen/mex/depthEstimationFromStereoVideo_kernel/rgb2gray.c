/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * rgb2gray.c
 *
 * Code generation for function 'rgb2gray'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "rgb2gray.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "libmwrgb2gray_tbb.h"

/* Variable Definitions */
static emlrtRTEInfo ed_emlrtRTEI = { 1,/* lineNo */
  14,                                  /* colNo */
  "rgb2gray",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\images\\rgb2gray.m"/* pName */
};

/* Function Definitions */
void rgb2gray(const emlrtStack *sp, const emxArray_uint8_T *X, emxArray_uint8_T *
              I)
{
  int32_T i40;
  uint32_T origSize[3];
  for (i40 = 0; i40 < 3; i40++) {
    origSize[i40] = (uint32_T)X->size[i40];
  }

  i40 = I->size[0] * I->size[1];
  I->size[0] = (int32_T)origSize[0];
  I->size[1] = (int32_T)origSize[1];
  emxEnsureCapacity_uint8_T(sp, I, i40, &ed_emlrtRTEI);
  rgb2gray_tbb_uint8(&X->data[0], (real_T)X->size[0] * (real_T)X->size[1],
                     &I->data[0], true);
}

/* End of code generation (rgb2gray.c) */

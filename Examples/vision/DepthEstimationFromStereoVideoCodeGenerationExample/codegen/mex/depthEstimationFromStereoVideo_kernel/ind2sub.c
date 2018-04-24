/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * ind2sub.c
 *
 * Code generation for function 'ind2sub'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "ind2sub.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
boolean_T b_allinrange(const emxArray_int32_T *x, int32_T hi)
{
  boolean_T p;
  int32_T k;
  int32_T exitg1;
  k = 0;
  do {
    exitg1 = 0;
    if (k <= x->size[0] - 1) {
      if ((x->data[k] >= 1) && (x->data[k] <= hi)) {
        k++;
      } else {
        p = false;
        exitg1 = 1;
      }
    } else {
      p = true;
      exitg1 = 1;
    }
  } while (exitg1 == 0);

  return p;
}

/* End of code generation (ind2sub.c) */

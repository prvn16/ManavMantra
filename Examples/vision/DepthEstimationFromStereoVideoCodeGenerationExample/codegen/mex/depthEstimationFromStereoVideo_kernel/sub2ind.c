/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sub2ind.c
 *
 * Code generation for function 'sub2ind'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "sub2ind.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
boolean_T allinrange(const emxArray_real_T *x, int32_T hi)
{
  boolean_T p;
  int32_T k;
  int32_T exitg1;
  k = 0;
  do {
    exitg1 = 0;
    if (k <= x->size[0] - 1) {
      if ((x->data[k] >= 1.0) && (x->data[k] <= hi)) {
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

/* End of code generation (sub2ind.c) */

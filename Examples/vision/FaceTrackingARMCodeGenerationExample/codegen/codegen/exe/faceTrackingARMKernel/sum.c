/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: sum.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "sum.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_boolean_T *x
 * Return Type  : double
 */
double b_sum(const emxArray_boolean_T *x)
{
  double y;
  int k;
  if (x->size[0] == 0) {
    y = 0.0;
  } else {
    y = x->data[0];
    for (k = 2; k <= x->size[0]; k++) {
      y += (double)x->data[k - 1];
    }
  }

  return y;
}

/*
 * Arguments    : const emxArray_real32_T *x
 * Return Type  : float
 */
float sum(const emxArray_real32_T *x)
{
  float y;
  int firstBlockLength;
  int nblocks;
  int lastBlockLength;
  int k;
  int xblockoffset;
  float bsum;
  int hi;
  if (x->size[0] == 0) {
    y = 0.0F;
  } else {
    if (x->size[0] <= 1024) {
      firstBlockLength = x->size[0];
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = x->size[0] / 1024;
      lastBlockLength = x->size[0] - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }

    y = x->data[0];
    for (k = 2; k <= firstBlockLength; k++) {
      y += x->data[k - 1];
    }

    for (firstBlockLength = 2; firstBlockLength <= nblocks; firstBlockLength++)
    {
      xblockoffset = (firstBlockLength - 1) << 10;
      bsum = x->data[xblockoffset];
      if (firstBlockLength == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }

      for (k = 2; k <= hi; k++) {
        bsum += x->data[(xblockoffset + k) - 1];
      }

      y += bsum;
    }
  }

  return y;
}

/*
 * File trailer for sum.c
 *
 * [EOF]
 */

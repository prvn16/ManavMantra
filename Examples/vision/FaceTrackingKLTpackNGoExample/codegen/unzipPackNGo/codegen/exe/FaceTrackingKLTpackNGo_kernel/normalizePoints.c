/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: normalizePoints.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "normalizePoints.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *p
 *                emxArray_real32_T *normPoints
 *                float T[9]
 * Return Type  : void
 */
void b_normalizePoints(const emxArray_real32_T *p, emxArray_real32_T *normPoints,
  float T[9])
{
  emxArray_real32_T *points;
  int firstBlockLength;
  int xblockoffset;
  int ia;
  boolean_T guard1 = false;
  int lastBlockLength;
  float cent[2];
  int nblocks;
  int xj;
  int k;
  int xoffset;
  int hi;
  float meanDistanceFromCenter;
  unsigned int unnamed_idx_1;
  float bsum[2];
  emxArray_real32_T *y;
  float b_y;
  float c_y[3];
  emxInit_real32_T(&points, 2);
  firstBlockLength = p->size[1];
  xblockoffset = points->size[0] * points->size[1];
  points->size[0] = 2;
  points->size[1] = firstBlockLength;
  emxEnsureCapacity_real32_T(points, xblockoffset);
  for (xblockoffset = 0; xblockoffset < firstBlockLength; xblockoffset++) {
    for (ia = 0; ia < 2; ia++) {
      points->data[ia + points->size[0] * xblockoffset] = p->data[ia + p->size[0]
        * xblockoffset];
    }
  }

  xblockoffset = p->size[1];
  guard1 = false;
  if (xblockoffset == 0) {
    guard1 = true;
  } else {
    xblockoffset = p->size[1];
    if (xblockoffset == 0) {
      guard1 = true;
    } else {
      xblockoffset = p->size[1];
      if (xblockoffset <= 1024) {
        firstBlockLength = p->size[1];
        lastBlockLength = 0;
        nblocks = 1;
      } else {
        firstBlockLength = 1024;
        xblockoffset = p->size[1];
        nblocks = xblockoffset / 1024;
        xblockoffset = p->size[1];
        lastBlockLength = xblockoffset - (nblocks << 10);
        if (lastBlockLength > 0) {
          nblocks++;
        } else {
          lastBlockLength = 1024;
        }
      }

      for (xj = 0; xj < 2; xj++) {
        cent[xj] = points->data[xj];
      }

      for (k = 2; k <= firstBlockLength; k++) {
        xoffset = (k - 1) << 1;
        for (xj = 0; xj < 2; xj++) {
          meanDistanceFromCenter = cent[xj] + points->data[xoffset + xj];
          cent[xj] = meanDistanceFromCenter;
        }
      }

      for (ia = 2; ia <= nblocks; ia++) {
        xblockoffset = (ia - 1) << 11;
        for (xj = 0; xj < 2; xj++) {
          bsum[xj] = points->data[xblockoffset + xj];
        }

        if (ia == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }

        for (k = 2; k <= hi; k++) {
          xoffset = xblockoffset + ((k - 1) << 1);
          for (xj = 0; xj < 2; xj++) {
            meanDistanceFromCenter = bsum[xj] + points->data[xoffset + xj];
            bsum[xj] = meanDistanceFromCenter;
          }
        }

        for (xj = 0; xj < 2; xj++) {
          cent[xj] += bsum[xj];
        }
      }
    }
  }

  if (guard1) {
    for (firstBlockLength = 0; firstBlockLength < 2; firstBlockLength++) {
      cent[firstBlockLength] = 0.0F;
    }
  }

  xblockoffset = p->size[1];
  for (ia = 0; ia < 2; ia++) {
    cent[ia] /= (float)xblockoffset;
  }

  xblockoffset = p->size[1];
  ia = normPoints->size[0] * normPoints->size[1];
  normPoints->size[0] = 2;
  normPoints->size[1] = xblockoffset;
  emxEnsureCapacity_real32_T(normPoints, ia);
  if (normPoints->size[1] != 0) {
    hi = normPoints->size[1];
    xblockoffset = p->size[1];
    firstBlockLength = (xblockoffset != 1);
    for (k = 0; k < hi; k++) {
      ia = firstBlockLength * k;
      for (xblockoffset = 0; xblockoffset < 2; xblockoffset++) {
        normPoints->data[xblockoffset + normPoints->size[0] * k] = p->
          data[xblockoffset + p->size[0] * ia] - cent[xblockoffset];
      }
    }
  }

  xblockoffset = points->size[0] * points->size[1];
  points->size[0] = 2;
  points->size[1] = normPoints->size[1];
  emxEnsureCapacity_real32_T(points, xblockoffset);
  unnamed_idx_1 = (unsigned int)normPoints->size[1];
  firstBlockLength = (int)unnamed_idx_1 << 1;
  for (k = 0; k < firstBlockLength; k++) {
    points->data[k] = normPoints->data[k] * normPoints->data[k];
  }

  emxInit_real32_T(&y, 2);
  if (points->size[1] == 0) {
    xblockoffset = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = 0;
    emxEnsureCapacity_real32_T(y, xblockoffset);
  } else {
    xblockoffset = y->size[0] * y->size[1];
    y->size[0] = 1;
    y->size[1] = points->size[1];
    emxEnsureCapacity_real32_T(y, xblockoffset);
    for (firstBlockLength = 0; firstBlockLength < points->size[1];
         firstBlockLength++) {
      ia = firstBlockLength << 1;
      y->data[firstBlockLength] = points->data[ia];
      y->data[firstBlockLength] += points->data[ia + 1];
    }
  }

  emxFree_real32_T(&points);
  firstBlockLength = y->size[1];
  for (k = 0; k < firstBlockLength; k++) {
    y->data[k] = (float)sqrt(y->data[k]);
  }

  if (y->size[1] == 0) {
    b_y = 0.0F;
  } else {
    if (y->size[1] <= 1024) {
      firstBlockLength = y->size[1];
      lastBlockLength = 0;
      nblocks = 1;
    } else {
      firstBlockLength = 1024;
      nblocks = y->size[1] / 1024;
      lastBlockLength = y->size[1] - (nblocks << 10);
      if (lastBlockLength > 0) {
        nblocks++;
      } else {
        lastBlockLength = 1024;
      }
    }

    b_y = y->data[0];
    for (k = 2; k <= firstBlockLength; k++) {
      b_y += y->data[k - 1];
    }

    for (ia = 2; ia <= nblocks; ia++) {
      xblockoffset = (ia - 1) << 10;
      meanDistanceFromCenter = y->data[xblockoffset];
      if (ia == nblocks) {
        hi = lastBlockLength;
      } else {
        hi = 1024;
      }

      for (k = 2; k <= hi; k++) {
        meanDistanceFromCenter += y->data[(xblockoffset + k) - 1];
      }

      b_y += meanDistanceFromCenter;
    }
  }

  meanDistanceFromCenter = b_y / (float)y->size[1];
  emxFree_real32_T(&y);
  if (meanDistanceFromCenter > 0.0F) {
    meanDistanceFromCenter = 1.41421354F / meanDistanceFromCenter;
  } else {
    meanDistanceFromCenter = 1.0F;
  }

  for (xblockoffset = 0; xblockoffset < 3; xblockoffset++) {
    c_y[xblockoffset] = meanDistanceFromCenter;
  }

  for (xblockoffset = 0; xblockoffset < 9; xblockoffset++) {
    T[xblockoffset] = 0.0F;
  }

  for (firstBlockLength = 0; firstBlockLength < 3; firstBlockLength++) {
    T[firstBlockLength + 3 * firstBlockLength] = c_y[firstBlockLength];
  }

  for (xblockoffset = 0; xblockoffset < 2; xblockoffset++) {
    T[6 + xblockoffset] = -meanDistanceFromCenter * cent[xblockoffset];
  }

  T[8] = 1.0F;
  firstBlockLength = normPoints->size[0] * normPoints->size[1] - 1;
  xblockoffset = normPoints->size[0] * normPoints->size[1];
  normPoints->size[0] = 2;
  emxEnsureCapacity_real32_T(normPoints, xblockoffset);
  for (xblockoffset = 0; xblockoffset <= firstBlockLength; xblockoffset++) {
    normPoints->data[xblockoffset] *= meanDistanceFromCenter;
  }
}

/*
 * File trailer for normalizePoints.c
 *
 * [EOF]
 */

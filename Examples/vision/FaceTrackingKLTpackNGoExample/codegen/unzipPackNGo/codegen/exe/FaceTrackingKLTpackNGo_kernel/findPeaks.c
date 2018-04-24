/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: findPeaks.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "findPeaks.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "bwmorph.h"
#include "imregionalmax.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static int div_s32(int numerator, int denominator);

/* Function Definitions */

/*
 * Arguments    : int numerator
 *                int denominator
 * Return Type  : int
 */
static int div_s32(int numerator, int denominator)
{
  int quotient;
  unsigned int absNumerator;
  unsigned int absDenominator;
  boolean_T quotientNeedsNegation;
  if (denominator == 0) {
    if (numerator >= 0) {
      quotient = MAX_int32_T;
    } else {
      quotient = MIN_int32_T;
    }
  } else {
    if (numerator < 0) {
      absNumerator = ~(unsigned int)numerator + 1U;
    } else {
      absNumerator = (unsigned int)numerator;
    }

    if (denominator < 0) {
      absDenominator = ~(unsigned int)denominator + 1U;
    } else {
      absDenominator = (unsigned int)denominator;
    }

    quotientNeedsNegation = ((numerator < 0) != (denominator < 0));
    absNumerator /= absDenominator;
    if (quotientNeedsNegation) {
      quotient = -(int)absNumerator;
    } else {
      quotient = (int)absNumerator;
    }
  }

  return quotient;
}

/*
 * Arguments    : const emxArray_real32_T *metric
 *                emxArray_real32_T *loc
 * Return Type  : void
 */
void findPeaks(const emxArray_real32_T *metric, emxArray_real32_T *loc)
{
  int idx;
  int k;
  boolean_T exitg1;
  float maxMetric;
  emxArray_boolean_T *bw;
  int i15;
  int nx;
  emxArray_int32_T *ii;
  emxArray_int32_T *b_idx;
  short siz[2];
  emxArray_int32_T *vk;
  if (!rtIsNaNF(metric->data[0])) {
    idx = 1;
  } else {
    idx = 0;
    k = 2;
    exitg1 = false;
    while ((!exitg1) && (k <= metric->size[0] * metric->size[1])) {
      if (!rtIsNaNF(metric->data[k - 1])) {
        idx = k;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  if (idx == 0) {
    maxMetric = metric->data[0];
  } else {
    maxMetric = metric->data[idx - 1];
    while (idx + 1 <= metric->size[0] * metric->size[1]) {
      if (maxMetric < metric->data[idx]) {
        maxMetric = metric->data[idx];
      }

      idx++;
    }
  }

  if (maxMetric <= 4.94065645841247E-324) {
    i15 = loc->size[0] * loc->size[1];
    loc->size[0] = 0;
    loc->size[1] = 2;
    emxEnsureCapacity_real32_T(loc, i15);
  } else {
    emxInit_boolean_T1(&bw, 2);
    imregionalmax(metric, bw);
    idx = metric->size[0] * metric->size[1] - 1;
    k = 0;
    for (nx = 0; nx <= idx; nx++) {
      if (metric->data[nx] < 0.01F * maxMetric) {
        k++;
      }
    }

    emxInit_int32_T(&ii, 1);
    i15 = ii->size[0];
    ii->size[0] = k;
    emxEnsureCapacity_int32_T(ii, i15);
    k = 0;
    for (nx = 0; nx <= idx; nx++) {
      if (metric->data[nx] < 0.01F * maxMetric) {
        ii->data[k] = nx + 1;
        k++;
      }
    }

    k = ii->size[0] - 1;
    for (i15 = 0; i15 <= k; i15++) {
      bw->data[ii->data[i15] - 1] = false;
    }

    bwmorph(bw);
    k = bw->size[1];
    for (i15 = 0; i15 < k; i15++) {
      bw->data[bw->size[0] * i15] = false;
    }

    k = bw->size[1];
    nx = bw->size[0] - 1;
    for (i15 = 0; i15 < k; i15++) {
      bw->data[nx + bw->size[0] * i15] = false;
    }

    k = bw->size[0];
    for (i15 = 0; i15 < k; i15++) {
      bw->data[i15] = false;
    }

    k = bw->size[0];
    nx = bw->size[1] - 1;
    for (i15 = 0; i15 < k; i15++) {
      bw->data[i15 + bw->size[0] * nx] = false;
    }

    nx = bw->size[0] * bw->size[1];
    idx = 0;
    i15 = ii->size[0];
    ii->size[0] = nx;
    emxEnsureCapacity_int32_T(ii, i15);
    k = 1;
    exitg1 = false;
    while ((!exitg1) && (k <= nx)) {
      if (bw->data[k - 1]) {
        idx++;
        ii->data[idx - 1] = k;
        if (idx >= nx) {
          exitg1 = true;
        } else {
          k++;
        }
      } else {
        k++;
      }
    }

    emxFree_boolean_T(&bw);
    emxInit_int32_T(&b_idx, 1);
    i15 = ii->size[0];
    if (1 > idx) {
      ii->size[0] = 0;
    } else {
      ii->size[0] = idx;
    }

    emxEnsureCapacity_int32_T(ii, i15);
    i15 = b_idx->size[0];
    b_idx->size[0] = ii->size[0];
    emxEnsureCapacity_int32_T(b_idx, i15);
    k = ii->size[0];
    for (i15 = 0; i15 < k; i15++) {
      b_idx->data[i15] = ii->data[i15];
    }

    k = b_idx->size[0];
    i15 = loc->size[0] * loc->size[1];
    loc->size[0] = k;
    loc->size[1] = 2;
    emxEnsureCapacity_real32_T(loc, i15);
    k <<= 1;
    for (i15 = 0; i15 < k; i15++) {
      loc->data[i15] = 0.0F;
    }

    for (i15 = 0; i15 < 2; i15++) {
      siz[i15] = (short)metric->size[i15];
    }

    i15 = ii->size[0];
    ii->size[0] = b_idx->size[0];
    emxEnsureCapacity_int32_T(ii, i15);
    k = b_idx->size[0];
    for (i15 = 0; i15 < k; i15++) {
      ii->data[i15] = b_idx->data[i15] - 1;
    }

    emxFree_int32_T(&b_idx);
    emxInit_int32_T(&vk, 1);
    i15 = vk->size[0];
    vk->size[0] = ii->size[0];
    emxEnsureCapacity_int32_T(vk, i15);
    k = ii->size[0];
    for (i15 = 0; i15 < k; i15++) {
      vk->data[i15] = div_s32(ii->data[i15], siz[0]);
    }

    i15 = ii->size[0];
    emxEnsureCapacity_int32_T(ii, i15);
    k = ii->size[0];
    for (i15 = 0; i15 < k; i15++) {
      ii->data[i15] -= vk->data[i15] * siz[0];
    }

    k = ii->size[0];
    for (i15 = 0; i15 < k; i15++) {
      loc->data[i15 + loc->size[0]] = (float)(ii->data[i15] + 1);
    }

    emxFree_int32_T(&ii);
    k = vk->size[0];
    for (i15 = 0; i15 < k; i15++) {
      loc->data[i15] = (float)(vk->data[i15] + 1);
    }

    emxFree_int32_T(&vk);
  }
}

/*
 * File trailer for findPeaks.c
 *
 * [EOF]
 */

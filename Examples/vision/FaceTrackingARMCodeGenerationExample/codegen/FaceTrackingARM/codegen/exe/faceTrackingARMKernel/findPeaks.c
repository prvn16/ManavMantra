/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: findPeaks.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "findPeaks.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "bwmorph.h"
#include "imregionalmax.h"

/* Function Definitions */

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
  boolean_T bw_data[34615];
  int bw_size[2];
  int i25;
  int nx;
  emxArray_int32_T *ii;
  emxArray_int32_T *b_idx;
  unsigned short unnamed_idx_0;
  unsigned char siz[2];
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
    i25 = loc->size[0] * loc->size[1];
    loc->size[0] = 0;
    loc->size[1] = 2;
    emxEnsureCapacity_real32_T(loc, i25);
  } else {
    imregionalmax(metric, bw_data, bw_size);
    idx = metric->size[0] * metric->size[1] - 1;
    k = 0;
    for (nx = 0; nx <= idx; nx++) {
      if (metric->data[nx] < 0.01F * maxMetric) {
        k++;
      }
    }

    emxInit_int32_T(&ii, 1);
    i25 = ii->size[0];
    ii->size[0] = k;
    emxEnsureCapacity_int32_T(ii, i25);
    k = 0;
    for (nx = 0; nx <= idx; nx++) {
      if (metric->data[nx] < 0.01F * maxMetric) {
        ii->data[k] = nx + 1;
        k++;
      }
    }

    k = ii->size[0] - 1;
    for (i25 = 0; i25 <= k; i25++) {
      bw_data[ii->data[i25] - 1] = false;
    }

    bwmorph(bw_data, bw_size);
    k = bw_size[1];
    for (i25 = 0; i25 < k; i25++) {
      bw_data[bw_size[0] * i25] = false;
    }

    k = bw_size[1];
    for (i25 = 0; i25 < k; i25++) {
      bw_data[(bw_size[0] + bw_size[0] * i25) - 1] = false;
    }

    k = bw_size[0];
    if (0 <= k - 1) {
      memset(&bw_data[0], 0, (unsigned int)(k * (int)sizeof(boolean_T)));
    }

    k = bw_size[0];
    if (0 <= k - 1) {
      memset(&bw_data[bw_size[0] * bw_size[1] - bw_size[0]], 0, (unsigned int)
             (((((k + bw_size[0] * bw_size[1]) - bw_size[0]) - bw_size[0] *
                bw_size[1]) + bw_size[0]) * (int)sizeof(boolean_T)));
    }

    nx = bw_size[0] * bw_size[1];
    idx = 0;
    i25 = ii->size[0];
    ii->size[0] = nx;
    emxEnsureCapacity_int32_T(ii, i25);
    k = 1;
    exitg1 = false;
    while ((!exitg1) && (k <= nx)) {
      if (bw_data[k - 1]) {
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

    emxInit_int32_T(&b_idx, 1);
    i25 = ii->size[0];
    if (1 > idx) {
      ii->size[0] = 0;
    } else {
      ii->size[0] = idx;
    }

    emxEnsureCapacity_int32_T(ii, i25);
    i25 = b_idx->size[0];
    b_idx->size[0] = ii->size[0];
    emxEnsureCapacity_int32_T(b_idx, i25);
    k = ii->size[0];
    for (i25 = 0; i25 < k; i25++) {
      b_idx->data[i25] = ii->data[i25];
    }

    unnamed_idx_0 = (unsigned short)b_idx->size[0];
    i25 = loc->size[0] * loc->size[1];
    loc->size[0] = unnamed_idx_0;
    loc->size[1] = 2;
    emxEnsureCapacity_real32_T(loc, i25);
    k = unnamed_idx_0 << 1;
    for (i25 = 0; i25 < k; i25++) {
      loc->data[i25] = 0.0F;
    }

    for (i25 = 0; i25 < 2; i25++) {
      siz[i25] = (unsigned char)metric->size[i25];
    }

    i25 = ii->size[0];
    ii->size[0] = b_idx->size[0];
    emxEnsureCapacity_int32_T(ii, i25);
    k = b_idx->size[0];
    for (i25 = 0; i25 < k; i25++) {
      ii->data[i25] = b_idx->data[i25] - 1;
    }

    emxFree_int32_T(&b_idx);
    emxInit_int32_T(&vk, 1);
    i25 = vk->size[0];
    vk->size[0] = ii->size[0];
    emxEnsureCapacity_int32_T(vk, i25);
    k = ii->size[0];
    for (i25 = 0; i25 < k; i25++) {
      nx = siz[0];
      idx = ii->data[i25];
      if (nx == 0) {
        if (idx >= 0) {
          vk->data[i25] = MAX_int32_T;
        } else {
          vk->data[i25] = MIN_int32_T;
        }
      } else {
        vk->data[i25] = idx / nx;
      }
    }

    i25 = ii->size[0];
    emxEnsureCapacity_int32_T(ii, i25);
    k = ii->size[0];
    for (i25 = 0; i25 < k; i25++) {
      ii->data[i25] -= vk->data[i25] * siz[0];
    }

    k = ii->size[0];
    for (i25 = 0; i25 < k; i25++) {
      loc->data[i25 + loc->size[0]] = (float)(ii->data[i25] + 1);
    }

    emxFree_int32_T(&ii);
    k = vk->size[0];
    for (i25 = 0; i25 < k; i25++) {
      loc->data[i25] = (float)(vk->data[i25] + 1);
    }

    emxFree_int32_T(&vk);
  }
}

/*
 * File trailer for findPeaks.c
 *
 * [EOF]
 */

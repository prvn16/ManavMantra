/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: excludePointsOutsideROI.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "excludePointsOutsideROI.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "bsxfun.h"

/* Function Definitions */

/*
 * Arguments    : const int originalROI_data[]
 *                const int expandedROI_data[]
 *                const emxArray_real32_T *locInExpandedROI
 *                const emxArray_real32_T *metric
 *                emxArray_real32_T *validLocation
 *                emxArray_real32_T *validMetric
 * Return Type  : void
 */
void excludePointsOutsideROI(const int originalROI_data[], const int
  expandedROI_data[], const emxArray_real32_T *locInExpandedROI, const
  emxArray_real32_T *metric, emxArray_real32_T *validLocation, emxArray_real32_T
  *validMetric)
{
  int y2;
  int q1;
  int x2;
  int i29;
  emxArray_real32_T *locInImage;
  float expandedROI[2];
  int loop_ub;
  boolean_T tmp_data[34615];
  int end;
  boolean_T b_tmp_data[34615];
  emxArray_int32_T *r9;
  emxArray_int32_T *r10;
  y2 = originalROI_data[0];
  q1 = originalROI_data[2];
  if ((y2 < 0) && (q1 < MIN_int32_T - y2)) {
    y2 = MIN_int32_T;
  } else if ((y2 > 0) && (q1 > MAX_int32_T - y2)) {
    y2 = MAX_int32_T;
  } else {
    y2 += q1;
  }

  if (y2 < -2147483647) {
    x2 = MIN_int32_T;
  } else {
    x2 = y2 - 1;
  }

  y2 = originalROI_data[1];
  q1 = originalROI_data[3];
  if ((y2 < 0) && (q1 < MIN_int32_T - y2)) {
    y2 = MIN_int32_T;
  } else if ((y2 > 0) && (q1 > MAX_int32_T - y2)) {
    y2 = MAX_int32_T;
  } else {
    y2 += q1;
  }

  if (y2 < -2147483647) {
    y2 = MIN_int32_T;
  } else {
    y2--;
  }

  for (i29 = 0; i29 < 2; i29++) {
    expandedROI[i29] = (float)expandedROI_data[i29] - 1.0F;
  }

  emxInit_real32_T(&locInImage, 2);
  bsxfun(locInExpandedROI, expandedROI, locInImage);
  loop_ub = locInImage->size[0];
  for (i29 = 0; i29 < loop_ub; i29++) {
    tmp_data[i29] = (((double)locInImage->data[i29] >= originalROI_data[0]) &&
                     ((double)locInImage->data[i29 + locInImage->size[0]] >=
                      originalROI_data[1]) && ((double)locInImage->data[i29] <=
      x2));
  }

  q1 = locInImage->size[0];
  for (i29 = 0; i29 < q1; i29++) {
    b_tmp_data[i29] = ((double)locInImage->data[i29 + locInImage->size[0]] <= y2);
  }

  end = loop_ub - 1;
  q1 = 0;
  for (x2 = 0; x2 <= end; x2++) {
    if (tmp_data[x2] && b_tmp_data[x2]) {
      q1++;
    }
  }

  emxInit_int32_T(&r9, 1);
  i29 = r9->size[0];
  r9->size[0] = q1;
  emxEnsureCapacity_int32_T(r9, i29);
  y2 = 0;
  for (x2 = 0; x2 <= end; x2++) {
    if (tmp_data[x2] && b_tmp_data[x2]) {
      r9->data[y2] = x2 + 1;
      y2++;
    }
  }

  i29 = validLocation->size[0] * validLocation->size[1];
  validLocation->size[0] = r9->size[0];
  validLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(validLocation, i29);
  for (i29 = 0; i29 < 2; i29++) {
    q1 = r9->size[0];
    for (y2 = 0; y2 < q1; y2++) {
      validLocation->data[y2 + validLocation->size[0] * i29] = locInImage->data
        [(r9->data[y2] + locInImage->size[0] * i29) - 1];
    }
  }

  emxFree_int32_T(&r9);
  emxFree_real32_T(&locInImage);
  end = loop_ub - 1;
  q1 = 0;
  for (x2 = 0; x2 <= end; x2++) {
    if (tmp_data[x2] && b_tmp_data[x2]) {
      q1++;
    }
  }

  emxInit_int32_T(&r10, 1);
  i29 = r10->size[0];
  r10->size[0] = q1;
  emxEnsureCapacity_int32_T(r10, i29);
  y2 = 0;
  for (x2 = 0; x2 <= end; x2++) {
    if (tmp_data[x2] && b_tmp_data[x2]) {
      r10->data[y2] = x2 + 1;
      y2++;
    }
  }

  i29 = validMetric->size[0];
  validMetric->size[0] = r10->size[0];
  emxEnsureCapacity_real32_T2(validMetric, i29);
  loop_ub = r10->size[0];
  for (i29 = 0; i29 < loop_ub; i29++) {
    validMetric->data[i29] = metric->data[r10->data[i29] - 1];
  }

  emxFree_int32_T(&r10);
}

/*
 * File trailer for excludePointsOutsideROI.c
 *
 * [EOF]
 */

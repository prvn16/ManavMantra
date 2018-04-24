/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: excludePointsOutsideROI.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "excludePointsOutsideROI.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "bsxfun.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const int originalROI_data[]
 *                const int originalROI_size[2]
 *                const int expandedROI_data[]
 *                const emxArray_real32_T *locInExpandedROI
 *                const emxArray_real32_T *metric
 *                emxArray_real32_T *validLocation
 *                emxArray_real32_T *validMetric
 * Return Type  : void
 */
void excludePointsOutsideROI(const int originalROI_data[], const int
  originalROI_size[2], const int expandedROI_data[], const emxArray_real32_T
  *locInExpandedROI, const emxArray_real32_T *metric, emxArray_real32_T
  *validLocation, emxArray_real32_T *validMetric)
{
  int y2;
  int i20;
  int q1;
  int x2;
  emxArray_real32_T *locInImage;
  float expandedROI[2];
  emxArray_boolean_T *r6;
  emxArray_boolean_T *r7;
  int end;
  emxArray_int32_T *r8;
  emxArray_int32_T *r9;
  if (originalROI_size[0] == 0) {
    i20 = validLocation->size[0] * validLocation->size[1];
    validLocation->size[0] = 0;
    validLocation->size[1] = 2;
    emxEnsureCapacity_real32_T(validLocation, i20);
    i20 = validMetric->size[0];
    validMetric->size[0] = 0;
    emxEnsureCapacity_real32_T2(validMetric, i20);
  } else {
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

    for (i20 = 0; i20 < 2; i20++) {
      expandedROI[i20] = (float)expandedROI_data[i20] - 1.0F;
    }

    emxInit_real32_T(&locInImage, 2);
    emxInit_boolean_T(&r6, 1);
    bsxfun(locInExpandedROI, expandedROI, locInImage);
    q1 = locInImage->size[0];
    i20 = r6->size[0];
    r6->size[0] = q1;
    emxEnsureCapacity_boolean_T2(r6, i20);
    for (i20 = 0; i20 < q1; i20++) {
      r6->data[i20] = (((double)locInImage->data[i20] >= originalROI_data[0]) &&
                       ((double)locInImage->data[i20 + locInImage->size[0]] >=
                        originalROI_data[1]) && ((double)locInImage->data[i20] <=
        x2));
    }

    emxInit_boolean_T(&r7, 1);
    q1 = locInImage->size[0];
    i20 = r7->size[0];
    r7->size[0] = q1;
    emxEnsureCapacity_boolean_T2(r7, i20);
    for (i20 = 0; i20 < q1; i20++) {
      r7->data[i20] = ((double)locInImage->data[i20 + locInImage->size[0]] <= y2);
    }

    end = r6->size[0] - 1;
    q1 = 0;
    for (x2 = 0; x2 <= end; x2++) {
      if (r6->data[x2] && r7->data[x2]) {
        q1++;
      }
    }

    emxInit_int32_T(&r8, 1);
    i20 = r8->size[0];
    r8->size[0] = q1;
    emxEnsureCapacity_int32_T(r8, i20);
    y2 = 0;
    for (x2 = 0; x2 <= end; x2++) {
      if (r6->data[x2] && r7->data[x2]) {
        r8->data[y2] = x2 + 1;
        y2++;
      }
    }

    i20 = validLocation->size[0] * validLocation->size[1];
    validLocation->size[0] = r8->size[0];
    validLocation->size[1] = 2;
    emxEnsureCapacity_real32_T(validLocation, i20);
    for (i20 = 0; i20 < 2; i20++) {
      q1 = r8->size[0];
      for (y2 = 0; y2 < q1; y2++) {
        validLocation->data[y2 + validLocation->size[0] * i20] =
          locInImage->data[(r8->data[y2] + locInImage->size[0] * i20) - 1];
      }
    }

    emxFree_int32_T(&r8);
    emxFree_real32_T(&locInImage);
    end = r6->size[0] - 1;
    q1 = 0;
    for (x2 = 0; x2 <= end; x2++) {
      if (r6->data[x2] && r7->data[x2]) {
        q1++;
      }
    }

    emxInit_int32_T(&r9, 1);
    i20 = r9->size[0];
    r9->size[0] = q1;
    emxEnsureCapacity_int32_T(r9, i20);
    y2 = 0;
    for (x2 = 0; x2 <= end; x2++) {
      if (r6->data[x2] && r7->data[x2]) {
        r9->data[y2] = x2 + 1;
        y2++;
      }
    }

    emxFree_boolean_T(&r7);
    emxFree_boolean_T(&r6);
    i20 = validMetric->size[0];
    validMetric->size[0] = r9->size[0];
    emxEnsureCapacity_real32_T2(validMetric, i20);
    q1 = r9->size[0];
    for (i20 = 0; i20 < q1; i20++) {
      validMetric->data[i20] = metric->data[r9->data[i20] - 1];
    }

    emxFree_int32_T(&r9);
  }
}

/*
 * File trailer for excludePointsOutsideROI.c
 *
 * [EOF]
 */

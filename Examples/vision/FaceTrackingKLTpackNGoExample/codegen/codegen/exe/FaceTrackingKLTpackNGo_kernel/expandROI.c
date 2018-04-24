/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: expandROI.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "expandROI.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const int originalROI_data[]
 *                const int originalROI_size[2]
 *                int expandedROI_data[]
 *                int expandedROI_size[2]
 * Return Type  : void
 */
void expandROI(const int originalROI_data[], const int originalROI_size[2], int
               expandedROI_data[], int expandedROI_size[2])
{
  int loop_ub;
  int i4;
  int k;
  double d1;
  int b_loop_ub;
  int varargin_2_data[9];
  int x1_data[9];
  int y1_data[9];
  int q1;
  int x2_data[9];
  int y2_data[9];
  if (originalROI_size[0] == 0) {
    expandedROI_size[0] = 0;
    expandedROI_size[1] = 4;
  } else {
    loop_ub = originalROI_size[0];
    for (i4 = 0; i4 < loop_ub; i4++) {
      d1 = (double)originalROI_data[i4] - 2.0;
      if (d1 >= -2.147483648E+9) {
        k = (int)d1;
      } else {
        k = MIN_int32_T;
      }

      varargin_2_data[i4] = k;
    }

    for (k = 0; k < (signed char)loop_ub; k++) {
      if (1 < varargin_2_data[k]) {
        x1_data[k] = varargin_2_data[k];
      } else {
        x1_data[k] = 1;
      }
    }

    b_loop_ub = originalROI_size[0];
    for (i4 = 0; i4 < b_loop_ub; i4++) {
      d1 = (double)originalROI_data[i4 + originalROI_size[0]] - 2.0;
      if (d1 >= -2.147483648E+9) {
        k = (int)d1;
      } else {
        k = MIN_int32_T;
      }

      varargin_2_data[i4] = k;
    }

    for (k = 0; k < (signed char)b_loop_ub; k++) {
      if (1 < varargin_2_data[k]) {
        y1_data[k] = varargin_2_data[k];
      } else {
        y1_data[k] = 1;
      }
    }

    b_loop_ub = originalROI_size[0];
    for (i4 = 0; i4 < b_loop_ub; i4++) {
      k = originalROI_data[i4];
      q1 = originalROI_data[i4 + (originalROI_size[0] << 1)];
      if ((k < 0) && (q1 < MIN_int32_T - k)) {
        k = MIN_int32_T;
      } else if ((k > 0) && (q1 > MAX_int32_T - k)) {
        k = MAX_int32_T;
      } else {
        k += q1;
      }

      if (k < -2147483647) {
        k = MIN_int32_T;
      } else {
        k--;
      }

      d1 = (double)k + 2.0;
      if (d1 < 2.147483648E+9) {
        k = (int)d1;
      } else {
        k = MAX_int32_T;
      }

      varargin_2_data[i4] = k;
    }

    for (k = 0; k < (signed char)b_loop_ub; k++) {
      if (640 > varargin_2_data[k]) {
        x2_data[k] = varargin_2_data[k];
      } else {
        x2_data[k] = 640;
      }
    }

    b_loop_ub = originalROI_size[0];
    for (i4 = 0; i4 < b_loop_ub; i4++) {
      k = originalROI_data[i4 + originalROI_size[0]];
      q1 = originalROI_data[i4 + originalROI_size[0] * 3];
      if ((k < 0) && (q1 < MIN_int32_T - k)) {
        k = MIN_int32_T;
      } else if ((k > 0) && (q1 > MAX_int32_T - k)) {
        k = MAX_int32_T;
      } else {
        k += q1;
      }

      if (k < -2147483647) {
        k = MIN_int32_T;
      } else {
        k--;
      }

      d1 = (double)k + 2.0;
      if (d1 < 2.147483648E+9) {
        k = (int)d1;
      } else {
        k = MAX_int32_T;
      }

      varargin_2_data[i4] = k;
    }

    for (k = 0; k < (signed char)b_loop_ub; k++) {
      if (480 > varargin_2_data[k]) {
        y2_data[k] = varargin_2_data[k];
      } else {
        y2_data[k] = 480;
      }
    }

    expandedROI_size[0] = (signed char)originalROI_size[0];
    expandedROI_size[1] = 4;
    b_loop_ub = (signed char)originalROI_size[0];
    if (0 <= b_loop_ub - 1) {
      memcpy(&expandedROI_data[0], &x1_data[0], (unsigned int)(b_loop_ub * (int)
              sizeof(int)));
    }

    b_loop_ub = (signed char)originalROI_size[0];
    for (i4 = 0; i4 < b_loop_ub; i4++) {
      expandedROI_data[i4 + (signed char)loop_ub] = y1_data[i4];
    }

    b_loop_ub = (signed char)originalROI_size[0];
    for (i4 = 0; i4 < b_loop_ub; i4++) {
      k = x2_data[i4];
      q1 = x1_data[i4];
      if ((k >= 0) && (q1 < k - MAX_int32_T)) {
        k = MAX_int32_T;
      } else if ((k < 0) && (q1 > k - MIN_int32_T)) {
        k = MIN_int32_T;
      } else {
        k -= q1;
      }

      if (k > 2147483646) {
        k = MAX_int32_T;
      } else {
        k++;
      }

      expandedROI_data[i4 + ((signed char)loop_ub << 1)] = k;
    }

    b_loop_ub = (signed char)originalROI_size[0];
    for (i4 = 0; i4 < b_loop_ub; i4++) {
      k = y2_data[i4];
      q1 = y1_data[i4];
      if ((k >= 0) && (q1 < k - MAX_int32_T)) {
        k = MAX_int32_T;
      } else if ((k < 0) && (q1 > k - MIN_int32_T)) {
        k = MIN_int32_T;
      } else {
        k -= q1;
      }

      if (k > 2147483646) {
        k = MAX_int32_T;
      } else {
        k++;
      }

      expandedROI_data[i4 + (signed char)loop_ub * 3] = k;
    }
  }
}

/*
 * File trailer for expandROI.c
 *
 * [EOF]
 */

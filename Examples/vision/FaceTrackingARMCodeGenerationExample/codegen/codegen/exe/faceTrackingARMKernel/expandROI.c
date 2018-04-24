/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: expandROI.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "expandROI.h"

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
  double d3;
  int varargin_2;
  int x1;
  int b_y1;
  int q0;
  int q1;
  int b_varargin_2;
  int b_x1[4];
  d3 = (double)originalROI_data[0] - 2.0;
  if (d3 >= -2.147483648E+9) {
    varargin_2 = (int)d3;
  } else {
    varargin_2 = MIN_int32_T;
  }

  if (1 < varargin_2) {
    x1 = varargin_2;
  } else {
    x1 = 1;
  }

  d3 = (double)originalROI_data[originalROI_size[0]] - 2.0;
  if (d3 >= -2.147483648E+9) {
    varargin_2 = (int)d3;
  } else {
    varargin_2 = MIN_int32_T;
  }

  if (1 < varargin_2) {
    b_y1 = varargin_2;
  } else {
    b_y1 = 1;
  }

  q0 = originalROI_data[0];
  q1 = originalROI_data[originalROI_size[0] << 1];
  if ((q0 < 0) && (q1 < MIN_int32_T - q0)) {
    q1 = MIN_int32_T;
  } else if ((q0 > 0) && (q1 > MAX_int32_T - q0)) {
    q1 = MAX_int32_T;
  } else {
    q1 += q0;
  }

  if (q1 < -2147483647) {
    q1 = MIN_int32_T;
  } else {
    q1--;
  }

  d3 = (double)q1 + 2.0;
  if (d3 < 2.147483648E+9) {
    varargin_2 = (int)d3;
  } else {
    varargin_2 = MAX_int32_T;
  }

  q0 = originalROI_data[originalROI_size[0]];
  q1 = originalROI_data[originalROI_size[0] * 3];
  if ((q0 < 0) && (q1 < MIN_int32_T - q0)) {
    q1 = MIN_int32_T;
  } else if ((q0 > 0) && (q1 > MAX_int32_T - q0)) {
    q1 = MAX_int32_T;
  } else {
    q1 += q0;
  }

  if (q1 < -2147483647) {
    q1 = MIN_int32_T;
  } else {
    q1--;
  }

  d3 = (double)q1 + 2.0;
  if (d3 < 2.147483648E+9) {
    b_varargin_2 = (int)d3;
  } else {
    b_varargin_2 = MAX_int32_T;
  }

  b_x1[0] = x1;
  b_x1[1] = b_y1;
  if (214 > varargin_2) {
    q0 = varargin_2;
  } else {
    q0 = 214;
  }

  if ((q0 >= 0) && (x1 < q0 - MAX_int32_T)) {
    q1 = MAX_int32_T;
  } else if ((q0 < 0) && (x1 > q0 - MIN_int32_T)) {
    q1 = MIN_int32_T;
  } else {
    q1 = q0 - x1;
  }

  b_x1[2] = q1 + 1;
  if (160 > b_varargin_2) {
    q0 = b_varargin_2;
  } else {
    q0 = 160;
  }

  if ((q0 >= 0) && (b_y1 < q0 - MAX_int32_T)) {
    q1 = MAX_int32_T;
  } else if ((q0 < 0) && (b_y1 > q0 - MIN_int32_T)) {
    q1 = MIN_int32_T;
  } else {
    q1 = q0 - b_y1;
  }

  b_x1[3] = q1 + 1;
  expandedROI_size[0] = 1;
  expandedROI_size[1] = 4;
  for (q1 = 0; q1 < 4; q1++) {
    expandedROI_data[q1] = b_x1[q1];
  }
}

/*
 * File trailer for expandROI.c
 *
 * [EOF]
 */

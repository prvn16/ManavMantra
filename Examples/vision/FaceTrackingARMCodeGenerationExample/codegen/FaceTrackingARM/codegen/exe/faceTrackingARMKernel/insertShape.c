/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertShape.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "insertShape.h"
#include "diff.h"
#include "faceTrackingARMKernel_rtwutil.h"
#include "faceTrackingARMKernel_data.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : visioncodegen_ShapeInserter *
 */
visioncodegen_ShapeInserter *getSystemObjects(void)
{
  visioncodegen_ShapeInserter *obj;
  if (!h3412_not_empty) {
    obj = &h3412;
    h3412.isInitialized = 0;

    /* System object Constructor function: vision.ShapeInserter */
    obj->cSFunObject.P0_RTP_LINEWIDTH = 1;
    h3412.LineWidth = 1.0;
    h3412.matlabCodegenIsDeleted = false;
    h3412_not_empty = true;
    h3412.isSetupComplete = false;
    h3412.isInitialized = 1;
    h3412.isSetupComplete = true;
  }

  return &h3412;
}

/*
 * Arguments    : const int position_data[]
 *                const int position_size[2]
 *                int positionOut_data[]
 *                int positionOut_size[1]
 * Return Type  : void
 */
void removeAdjacentSamePts(const int position_data[], const int position_size[2],
  int positionOut_data[], int positionOut_size[1])
{
  double N;
  double varargin_1[2];
  int j;
  int k;
  signed char num[2];
  int ncols;
  int b_position_data[8];
  int b_position_size[2];
  int c_position_data[4];
  int tmp_data[3];
  int tmp_size[2];
  int c_position_size[2];
  int b_tmp_data[3];
  int c_logicalIdx_RepeatedXY_size_id;
  boolean_T logicalIdx_RepeatedXY_data[4];
  boolean_T b1;
  int i;
  int d_position_data[8];
  N = (double)position_size[1] / 2.0;
  varargin_1[0] = 2.0;
  varargin_1[1] = N;
  for (j = 0; j < 2; j++) {
    num[j] = (signed char)(int)varargin_1[j];
  }

  k = (signed char)(int)N;
  ncols = (signed char)(int)N << 1;
  if (0 <= ncols - 1) {
    memcpy(&b_position_data[0], &position_data[0], (unsigned int)(ncols * (int)
            sizeof(int)));
  }

  if (N > 3.0) {
    b_position_size[0] = 1;
    b_position_size[1] = (signed char)(int)N;
    ncols = (signed char)(int)N;
    for (j = 0; j < ncols; j++) {
      c_position_data[j] = position_data[j << 1];
    }

    diff(c_position_data, b_position_size, tmp_data, tmp_size);
    c_position_size[0] = 1;
    c_position_size[1] = (signed char)(int)N;
    ncols = (signed char)(int)N;
    for (j = 0; j < ncols; j++) {
      c_position_data[j] = position_data[1 + (j << 1)];
    }

    diff(c_position_data, c_position_size, b_tmp_data, b_position_size);
    c_logicalIdx_RepeatedXY_size_id = tmp_size[1] + 1;
    ncols = tmp_size[1];
    for (j = 0; j < ncols; j++) {
      logicalIdx_RepeatedXY_data[j] = ((tmp_data[tmp_size[0] * j] == 0) &&
        (b_tmp_data[b_position_size[0] * j] == 0));
    }

    logicalIdx_RepeatedXY_data[tmp_size[1]] = false;
    if (logicalIdx_RepeatedXY_data[tmp_size[1]] || ((position_data[0] ==
          position_data[(num[1] - 1) << 1]) && (position_data[1] ==
          position_data[1 + ((num[1] - 1) << 1)]))) {
      b1 = true;
    } else {
      b1 = false;
    }

    logicalIdx_RepeatedXY_data[tmp_size[1]] = b1;
    ncols = tmp_size[1] + 1;
    j = 0;
    for (i = 0; i < ncols; i++) {
      if (logicalIdx_RepeatedXY_data[i]) {
        j++;
      }
    }

    if (N - (double)j >= 3.0) {
      ncols = 0;
      for (k = 1; k <= c_logicalIdx_RepeatedXY_size_id; k++) {
        ncols += logicalIdx_RepeatedXY_data[k - 1];
      }

      ncols = num[1] - ncols;
      j = 0;
      for (k = 1; k <= (signed char)(int)N; k++) {
        if ((k > c_logicalIdx_RepeatedXY_size_id) ||
            (!logicalIdx_RepeatedXY_data[k - 1])) {
          for (i = 0; i < 2; i++) {
            b_position_data[i + (j << 1)] = b_position_data[i + ((k - 1) << 1)];
          }

          j++;
        }
      }

      if (1 > ncols) {
        k = 0;
      } else {
        k = ncols;
      }

      for (j = 0; j < k; j++) {
        for (ncols = 0; ncols < 2; ncols++) {
          d_position_data[ncols + (j << 1)] = b_position_data[ncols + (j << 1)];
        }
      }

      for (j = 0; j < k; j++) {
        for (ncols = 0; ncols < 2; ncols++) {
          b_position_data[ncols + (j << 1)] = d_position_data[ncols + (j << 1)];
        }
      }
    }
  }

  positionOut_size[0] = k << 1;
  ncols = k << 1;
  if (0 <= ncols - 1) {
    memcpy(&positionOut_data[0], &b_position_data[0], (unsigned int)(ncols *
            (int)sizeof(int)));
  }
}

/*
 * Arguments    : visioncodegen_ShapeInserter *h_ShapeInserter
 * Return Type  : void
 */
void tuneLineWidth(visioncodegen_ShapeInserter *h_ShapeInserter)
{
  if (1.0 != h_ShapeInserter->LineWidth) {
    h_ShapeInserter->cSFunObject.P0_RTP_LINEWIDTH = 1;
    h_ShapeInserter->LineWidth = 1.0;
  }
}

/*
 * Arguments    : const double position_data[]
 *                const int position_size[2]
 *                int positionOut_data[]
 *                int positionOut_size[2]
 * Return Type  : void
 */
void validateAndParseInputs(const double position_data[], const int
  position_size[2], int positionOut_data[], int positionOut_size[2])
{
  int loop_ub;
  int i48;
  double d4;
  int i49;
  positionOut_size[0] = 1;
  positionOut_size[1] = position_size[1];
  loop_ub = position_size[0] * position_size[1];
  for (i48 = 0; i48 < loop_ub; i48++) {
    d4 = rt_roundd_snf(position_data[i48]);
    if (d4 < 2.147483648E+9) {
      if (d4 >= -2.147483648E+9) {
        i49 = (int)d4;
      } else {
        i49 = MIN_int32_T;
      }
    } else if (d4 >= 2.147483648E+9) {
      i49 = MAX_int32_T;
    } else {
      i49 = 0;
    }

    positionOut_data[i48] = i49;
  }
}

/*
 * File trailer for insertShape.c
 *
 * [EOF]
 */

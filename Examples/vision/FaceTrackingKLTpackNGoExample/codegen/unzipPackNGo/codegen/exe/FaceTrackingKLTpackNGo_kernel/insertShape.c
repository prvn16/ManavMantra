/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertShape.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "insertShape.h"
#include "diff.h"
#include "insertMarker.h"
#include "SystemCore.h"
#include "FaceTrackingKLTpackNGo_kernel_rtwutil.h"
#include "FaceTrackingKLTpackNGo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static visioncodegen_ShapeInserter *getSystemObjects(void);
static void tuneLineWidth(visioncodegen_ShapeInserter *h_ShapeInserter);

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : visioncodegen_ShapeInserter *
 */
static visioncodegen_ShapeInserter *getSystemObjects(void)
{
  visioncodegen_ShapeInserter *obj;
  if (!h2111_not_empty) {
    obj = &h2111;
    h2111.isInitialized = 0;

    /* System object Constructor function: vision.ShapeInserter */
    obj->cSFunObject.P0_RTP_LINEWIDTH = 1;
    h2111.LineWidth = 1.0;
    h2111.matlabCodegenIsDeleted = false;
    h2111_not_empty = true;
    h2111.isSetupComplete = false;
    h2111.isInitialized = 1;
    h2111.isSetupComplete = true;
  }

  return &h2111;
}

/*
 * Arguments    : visioncodegen_ShapeInserter *h_ShapeInserter
 * Return Type  : void
 */
static void tuneLineWidth(visioncodegen_ShapeInserter *h_ShapeInserter)
{
  if (1.0 != h_ShapeInserter->LineWidth) {
    h_ShapeInserter->cSFunObject.P0_RTP_LINEWIDTH = 1;
    h_ShapeInserter->LineWidth = 1.0;
  }
}

/*
 * Arguments    : void
 * Return Type  : visioncodegen_ShapeInserter_1 *
 */
visioncodegen_ShapeInserter_1 *b_getSystemObjects(void)
{
  visioncodegen_ShapeInserter_1 *obj;
  if (!h2412_not_empty) {
    obj = &h2412;
    h2412.isInitialized = 0;

    /* System object Constructor function: vision.ShapeInserter */
    obj->cSFunObject.P0_RTP_LINEWIDTH = 1;
    h2412.LineWidth = 1.0;
    h2412.matlabCodegenIsDeleted = false;
    h2412_not_empty = true;
    h2412.isSetupComplete = false;
    h2412.isInitialized = 1;
    h2412.isSetupComplete = true;
  }

  return &h2412;
}

/*
 * Arguments    : visioncodegen_ShapeInserter_1 *h_ShapeInserter
 * Return Type  : void
 */
void b_tuneLineWidth(visioncodegen_ShapeInserter_1 *h_ShapeInserter)
{
  if (2.0 != h_ShapeInserter->LineWidth) {
    h_ShapeInserter->cSFunObject.P0_RTP_LINEWIDTH = 2;
    h_ShapeInserter->LineWidth = 2.0;
  }
}

/*
 * Arguments    : const float I[921600]
 *                const float position_data[]
 *                const int position_size[2]
 *                float RGB[921600]
 * Return Type  : void
 */
void insertShape(const float I[921600], const float position_data[], const int
                 position_size[2], float RGB[921600])
{
  int positionOut_size[2];
  int ntilerows;
  int jcol;
  int color_size[2];
  float f0;
  int ibmat;
  visioncodegen_ShapeInserter *h_ShapeInserter;
  int itilerow;
  int positionOut_data[36];
  float color_data[27];
  static const signed char iv2[3] = { 1, 1, 0 };

  positionOut_size[0] = position_size[0];
  positionOut_size[1] = 4;
  ntilerows = position_size[0] * position_size[1];
  for (jcol = 0; jcol < ntilerows; jcol++) {
    f0 = rt_roundf_snf(position_data[jcol]);
    if (f0 < 2.14748365E+9F) {
      if (f0 >= -2.14748365E+9F) {
        ibmat = (int)f0;
      } else {
        ibmat = MIN_int32_T;
      }
    } else if (f0 >= 2.14748365E+9F) {
      ibmat = MAX_int32_T;
    } else {
      ibmat = 0;
    }

    positionOut_data[jcol] = ibmat;
  }

  color_size[0] = (signed char)position_size[0];
  color_size[1] = 3;
  ntilerows = (signed char)position_size[0];
  for (jcol = 0; jcol < 3; jcol++) {
    ibmat = jcol * ntilerows;
    for (itilerow = 1; itilerow <= ntilerows; itilerow++) {
      color_data[(ibmat + itilerow) - 1] = iv2[jcol];
    }
  }

  h_ShapeInserter = getSystemObjects();
  tuneLineWidth(h_ShapeInserter);
  b_SystemCore_step(h_ShapeInserter, I, positionOut_data, positionOut_size,
                    color_data, color_size, RGB);
}

/*
 * Arguments    : const int position[8]
 *                int positionOut_data[]
 *                int positionOut_size[1]
 * Return Type  : void
 */
void removeAdjacentSamePts(const int position[8], int positionOut_data[], int
  positionOut_size[1])
{
  int j;
  int trueCount;
  int pos_data[8];
  int position_data[4];
  int tmp_data[3];
  int tmp_size[2];
  int b_tmp_data[3];
  int b_tmp_size[2];
  int c_logicalIdx_RepeatedXY_size_id;
  int loop_ub;
  boolean_T logicalIdx_RepeatedXY_data[4];
  boolean_T b2;
  int i;
  int b_pos_data[8];
  j = 4;
  for (trueCount = 0; trueCount < 8; trueCount++) {
    pos_data[trueCount] = position[trueCount];
  }

  for (trueCount = 0; trueCount < 4; trueCount++) {
    position_data[trueCount] = position[2 * trueCount];
  }

  diff(position_data, tmp_data, tmp_size);
  for (trueCount = 0; trueCount < 4; trueCount++) {
    position_data[trueCount] = position[1 + 2 * trueCount];
  }

  diff(position_data, b_tmp_data, b_tmp_size);
  c_logicalIdx_RepeatedXY_size_id = tmp_size[1] + 1;
  loop_ub = tmp_size[1];
  for (trueCount = 0; trueCount < loop_ub; trueCount++) {
    logicalIdx_RepeatedXY_data[trueCount] = ((tmp_data[tmp_size[0] * trueCount] ==
      0) && (b_tmp_data[b_tmp_size[0] * trueCount] == 0));
  }

  logicalIdx_RepeatedXY_data[tmp_size[1]] = false;
  if (logicalIdx_RepeatedXY_data[tmp_size[1]] || ((position[0] == position[6]) &&
       (position[1] == position[7]))) {
    b2 = true;
  } else {
    b2 = false;
  }

  logicalIdx_RepeatedXY_data[tmp_size[1]] = b2;
  loop_ub = tmp_size[1] + 1;
  trueCount = 0;
  for (i = 0; i < loop_ub; i++) {
    if (logicalIdx_RepeatedXY_data[i]) {
      trueCount++;
    }
  }

  if (4.0 - (double)trueCount >= 3.0) {
    loop_ub = 0;
    for (trueCount = 1; trueCount <= c_logicalIdx_RepeatedXY_size_id; trueCount
         ++) {
      loop_ub += logicalIdx_RepeatedXY_data[trueCount - 1];
    }

    j = 0;
    for (trueCount = 0; trueCount < 4; trueCount++) {
      if ((trueCount + 1 > c_logicalIdx_RepeatedXY_size_id) ||
          (!logicalIdx_RepeatedXY_data[trueCount])) {
        for (i = 0; i < 2; i++) {
          pos_data[i + (j << 1)] = pos_data[i + (trueCount << 1)];
        }

        j++;
      }
    }

    if (1 > 4 - loop_ub) {
      j = 0;
    } else {
      j = 4 - loop_ub;
    }

    for (trueCount = 0; trueCount < j; trueCount++) {
      for (loop_ub = 0; loop_ub < 2; loop_ub++) {
        b_pos_data[loop_ub + (trueCount << 1)] = pos_data[loop_ub + (trueCount <<
          1)];
      }
    }

    for (trueCount = 0; trueCount < j; trueCount++) {
      for (loop_ub = 0; loop_ub < 2; loop_ub++) {
        pos_data[loop_ub + (trueCount << 1)] = b_pos_data[loop_ub + (trueCount <<
          1)];
      }
    }
  }

  positionOut_size[0] = j << 1;
  loop_ub = j << 1;
  if (0 <= loop_ub - 1) {
    memcpy(&positionOut_data[0], &pos_data[0], (unsigned int)(loop_ub * (int)
            sizeof(int)));
  }
}

/*
 * Arguments    : const float position[8]
 *                int positionOut[8]
 * Return Type  : void
 */
void validateAndParseInputs(const float position[8], int positionOut[8])
{
  int i43;
  float f4;
  int i44;
  for (i43 = 0; i43 < 8; i43++) {
    f4 = rt_roundf_snf(position[i43]);
    if (f4 < 2.14748365E+9F) {
      if (f4 >= -2.14748365E+9F) {
        i44 = (int)f4;
      } else {
        i44 = MIN_int32_T;
      }
    } else if (f4 >= 2.14748365E+9F) {
      i44 = MAX_int32_T;
    } else {
      i44 = 0;
    }

    positionOut[i43] = i44;
  }
}

/*
 * File trailer for insertShape.c
 *
 * [EOF]
 */

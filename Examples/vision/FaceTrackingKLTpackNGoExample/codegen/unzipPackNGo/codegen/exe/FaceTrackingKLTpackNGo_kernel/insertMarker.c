/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertMarker.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "insertMarker.h"
#include "FaceTrackingKLTpackNGo_kernel_rtwutil.h"
#include "FaceTrackingKLTpackNGo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void getColorMatrix(double numMarkers, float colorOut_data[], int
  colorOut_size[2]);

/* Function Definitions */

/*
 * Arguments    : double numMarkers
 *                float colorOut_data[]
 *                int colorOut_size[2]
 * Return Type  : void
 */
static void getColorMatrix(double numMarkers, float colorOut_data[], int
  colorOut_size[2])
{
  int jcol;
  int ibmat;
  int itilerow;
  colorOut_size[0] = (short)(int)numMarkers;
  colorOut_size[1] = 3;
  for (jcol = 0; jcol < 3; jcol++) {
    ibmat = jcol * (int)numMarkers;
    for (itilerow = 1; itilerow <= (int)numMarkers; itilerow++) {
      colorOut_data[(ibmat + itilerow) - 1] = 255.0F;
    }
  }
}

/*
 * Arguments    : const float points_data[]
 *                const int points_size[2]
 *                int position_data[]
 *                int position_size[2]
 *                float color_data[]
 *                int color_size[2]
 * Return Type  : void
 */
void b_validateAndParseInputs(const float points_data[], const int points_size[2],
  int position_data[], int position_size[2], float color_data[], int color_size
  [2])
{
  int loop_ub;
  int i45;
  float f5;
  int i46;
  position_size[0] = points_size[0];
  position_size[1] = points_size[1];
  loop_ub = points_size[0] * points_size[1];
  for (i45 = 0; i45 < loop_ub; i45++) {
    f5 = rt_roundf_snf(points_data[i45]);
    if (f5 < 2.14748365E+9F) {
      if (f5 >= -2.14748365E+9F) {
        i46 = (int)f5;
      } else {
        i46 = MIN_int32_T;
      }
    } else if (f5 >= 2.14748365E+9F) {
      i46 = MAX_int32_T;
    } else {
      i46 = 0;
    }

    position_data[i45] = i46;
  }

  getColorMatrix(points_size[0], color_data, color_size);
}

/*
 * Arguments    : void
 * Return Type  : visioncodegen_MarkerInserter *
 */
visioncodegen_MarkerInserter *c_getSystemObjects(void)
{
  visioncodegen_MarkerInserter *obj;
  if (!h23_not_empty) {
    obj = &h23;
    h23.isInitialized = 0;

    /* System object Constructor function: vision.MarkerInserter */
    obj->cSFunObject.P0_RTP_SIZE = 3;
    h23.Size = 3.0;
    h23.matlabCodegenIsDeleted = false;
    h23_not_empty = true;
    h23.isSetupComplete = false;
    h23.isInitialized = 1;
    h23.isSetupComplete = true;
  }

  return &h23;
}

/*
 * Arguments    : visioncodegen_MarkerInserter *h_MarkerInserter
 * Return Type  : void
 */
void tuneMarkersize(visioncodegen_MarkerInserter *h_MarkerInserter)
{
  if (3.0 != h_MarkerInserter->Size) {
    h_MarkerInserter->cSFunObject.P0_RTP_SIZE = 3;
    h_MarkerInserter->Size = 3.0;
  }
}

/*
 * File trailer for insertMarker.c
 *
 * [EOF]
 */

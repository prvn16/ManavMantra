/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertMarker.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "insertMarker.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "faceTrackingARMKernel_data.h"

/* Function Declarations */
static void getColorMatrix(double numMarkers, emxArray_uint8_T *colorOut);
static float rt_roundf_snf(float u);

/* Function Definitions */

/*
 * Arguments    : double numMarkers
 *                emxArray_uint8_T *colorOut
 * Return Type  : void
 */
static void getColorMatrix(double numMarkers, emxArray_uint8_T *colorOut)
{
  int jcol;
  int ibmat;
  int itilerow;
  jcol = colorOut->size[0] * colorOut->size[1];
  colorOut->size[0] = (unsigned short)(int)numMarkers;
  colorOut->size[1] = 3;
  emxEnsureCapacity_uint8_T(colorOut, jcol);
  for (jcol = 0; jcol < 3; jcol++) {
    ibmat = jcol * (int)numMarkers;
    for (itilerow = 1; itilerow <= (int)numMarkers; itilerow++) {
      colorOut->data[(ibmat + itilerow) - 1] = MAX_uint8_T;
    }
  }
}

/*
 * Arguments    : float u
 * Return Type  : float
 */
static float rt_roundf_snf(float u)
{
  float y;
  if ((float)fabs(u) < 8.388608E+6F) {
    if (u >= 0.5F) {
      y = (float)floor(u + 0.5F);
    } else if (u > -0.5F) {
      y = u * 0.0F;
    } else {
      y = (float)ceil(u - 0.5F);
    }
  } else {
    y = u;
  }

  return y;
}

/*
 * Arguments    : void
 * Return Type  : visioncodegen_MarkerInserter *
 */
visioncodegen_MarkerInserter *b_getSystemObjects(void)
{
  visioncodegen_MarkerInserter *obj;
  if (!h33_not_empty) {
    obj = &h33;
    h33.isInitialized = 0;

    /* System object Constructor function: vision.MarkerInserter */
    obj->cSFunObject.P0_RTP_SIZE = 3;
    h33.Size = 3.0;
    h33.matlabCodegenIsDeleted = false;
    h33_not_empty = true;
    h33.isSetupComplete = false;
    h33.isInitialized = 1;
    h33.isSetupComplete = true;
  }

  return &h33;
}

/*
 * Arguments    : const emxArray_real32_T *points
 *                emxArray_int32_T *position
 *                emxArray_uint8_T *color
 * Return Type  : void
 */
void b_validateAndParseInputs(const emxArray_real32_T *points, emxArray_int32_T *
  position, emxArray_uint8_T *color)
{
  int i50;
  int loop_ub;
  float f2;
  int i51;
  i50 = position->size[0] * position->size[1];
  position->size[0] = points->size[0];
  position->size[1] = points->size[1];
  emxEnsureCapacity_int32_T1(position, i50);
  loop_ub = points->size[0] * points->size[1];
  for (i50 = 0; i50 < loop_ub; i50++) {
    f2 = rt_roundf_snf(points->data[i50]);
    if (f2 < 2.14748365E+9F) {
      if (f2 >= -2.14748365E+9F) {
        i51 = (int)f2;
      } else {
        i51 = MIN_int32_T;
      }
    } else if (f2 >= 2.14748365E+9F) {
      i51 = MAX_int32_T;
    } else {
      i51 = 0;
    }

    position->data[i50] = i51;
  }

  getColorMatrix(position->size[0], color);
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

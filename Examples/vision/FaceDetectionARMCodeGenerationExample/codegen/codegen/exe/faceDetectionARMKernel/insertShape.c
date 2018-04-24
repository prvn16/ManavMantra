/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertShape.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceDetectionARMKernel.h"
#include "insertShape.h"
#include "faceDetectionARMKernel_data.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : visioncodegen_ShapeInserter *
 */
visioncodegen_ShapeInserter *getSystemObjects(void)
{
  visioncodegen_ShapeInserter *obj;
  if (!h3111_not_empty) {
    obj = &h3111;
    h3111.isInitialized = 0;

    /* System object Constructor function: vision.ShapeInserter */
    obj->cSFunObject.P0_RTP_LINEWIDTH = 1;
    h3111.LineWidth = 1.0;
    h3111.matlabCodegenIsDeleted = false;
    h3111_not_empty = true;
    h3111.isSetupComplete = false;
    h3111.isInitialized = 1;
    h3111.isSetupComplete = true;
  }

  return &h3111;
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
 * File trailer for insertShape.c
 *
 * [EOF]
 */

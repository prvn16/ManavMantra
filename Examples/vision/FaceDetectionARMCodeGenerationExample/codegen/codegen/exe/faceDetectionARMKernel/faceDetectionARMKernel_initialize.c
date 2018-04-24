/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: faceDetectionARMKernel_initialize.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceDetectionARMKernel.h"
#include "faceDetectionARMKernel_initialize.h"
#include "createShapeInserter_cg.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : void
 */
void faceDetectionARMKernel_initialize(void)
{
  rt_InitInfAndNaN(8U);
  faceDetectionARMKernel_init();
  createShapeInserter_cg_init();
}

/*
 * File trailer for faceDetectionARMKernel_initialize.c
 *
 * [EOF]
 */

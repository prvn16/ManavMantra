/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: faceTrackingARMKernel_initialize.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "faceTrackingARMKernel_initialize.h"
#include "eml_rand_mt19937ar_stateful.h"
#include "createMarkerInserter_cg.h"
#include "createShapeInserter_cg.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : void
 */
void faceTrackingARMKernel_initialize(void)
{
  rt_InitInfAndNaN(8U);
  faceTrackingARMKernel_init();
  createShapeInserter_cg_init();
  createMarkerInserter_cg_init();
  c_eml_rand_mt19937ar_stateful_i();
}

/*
 * File trailer for faceTrackingARMKernel_initialize.c
 *
 * [EOF]
 */

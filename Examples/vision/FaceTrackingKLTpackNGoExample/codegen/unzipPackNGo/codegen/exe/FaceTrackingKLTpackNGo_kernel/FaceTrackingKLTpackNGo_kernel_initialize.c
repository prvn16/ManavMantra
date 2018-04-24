/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: FaceTrackingKLTpackNGo_kernel_initialize.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "FaceTrackingKLTpackNGo_kernel_initialize.h"
#include "eml_rand_mt19937ar_stateful.h"
#include "createMarkerInserter_cg.h"
#include "createShapeInserter_cg.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : void
 */
void FaceTrackingKLTpackNGo_kernel_initialize(void)
{
  rt_InitInfAndNaN(8U);
  createShapeInserter_cg_init();
  createMarkerInserter_cg_init();
  c_eml_rand_mt19937ar_stateful_i();
}

/*
 * File trailer for FaceTrackingKLTpackNGo_kernel_initialize.c
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: createMarkerInserter_cg.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "createMarkerInserter_cg.h"
#include "FaceTrackingKLTpackNGo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : void
 */
void createMarkerInserter_cg_init(void)
{
  h23_not_empty = false;
  h23.matlabCodegenIsDeleted = true;
}

/*
 * File trailer for createMarkerInserter_cg.c
 *
 * [EOF]
 */
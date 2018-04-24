/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * createShapeInserter_cg.c
 *
 * Code generation for function 'createShapeInserter_cg'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "createShapeInserter_cg.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
void createShapeInserter_cg_free(void)
{
  if (!h3111.matlabCodegenIsDeleted) {
    h3111.matlabCodegenIsDeleted = true;
    if (h3111.isInitialized == 1) {
      h3111.isInitialized = 2;
    }
  }
}

void createShapeInserter_cg_init(void)
{
  h3111_not_empty = false;
  h3111.matlabCodegenIsDeleted = true;
}

/* End of code generation (createShapeInserter_cg.c) */

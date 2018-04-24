/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * DeployableVideoPlayer.c
 *
 * Code generation for function 'DeployableVideoPlayer'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "DeployableVideoPlayer.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void d_DeployableVideoPlayer_Deploya(c_visioncodegen_DeployableVideo
  **obj);

/* Function Definitions */
static void d_DeployableVideoPlayer_Deploya(c_visioncodegen_DeployableVideo
  **obj)
{
  (*obj)->isInitialized = 0;

  /* System object Constructor function: vision.DeployableVideoPlayer */
  (*obj)->matlabCodegenIsDeleted = false;
}

c_visioncodegen_DeployableVideo *c_DeployableVideoPlayer_Deploya
  (c_visioncodegen_DeployableVideo *obj)
{
  c_visioncodegen_DeployableVideo *b_obj;
  b_obj = obj;
  d_DeployableVideoPlayer_Deploya(&b_obj);
  return b_obj;
}

/* End of code generation (DeployableVideoPlayer.c) */

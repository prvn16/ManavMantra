/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * matlabCodegenHandle.c
 *
 * Code generation for function 'matlabCodegenHandle'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "HOGDescriptorCore_api.hpp"

/* Function Definitions */
void c_matlabCodegenHandle_matlabCod(const emlrtStack *sp,
  c_visioncodegen_DeployableVideo *obj)
{
  char_T *sErr;
  if (!obj->matlabCodegenIsDeleted) {
    obj->matlabCodegenIsDeleted = true;
    if (obj->isInitialized == 1) {
      obj->isInitialized = 2;
      if (obj->isSetupComplete) {
        /* System object Destructor function: vision.DeployableVideoPlayer */
        /* System object Terminate function: vision.DeployableVideoPlayer */
        sErr = GetErrorBuffer(&obj->cSFunObject.W0_ToVideoDevice[0U]);
        LibTerminate(&obj->cSFunObject.W0_ToVideoDevice[0U]);
        if (*sErr != 0) {
          PrintError(sErr);
        }

        LibDestroy(&obj->cSFunObject.W0_ToVideoDevice[0U], 0);
        DestroyHostLibrary(&obj->cSFunObject.W0_ToVideoDevice[0U]);
      }
    }
  }
}

void d_matlabCodegenHandle_matlabCod(const emlrtStack *sp, vision_PeopleDetector
  *obj)
{
  void * ptrObj;
  if (!obj->matlabCodegenIsDeleted) {
    obj->matlabCodegenIsDeleted = true;
    if (obj->isInitialized == 1) {
      obj->isInitialized = 2;
      if (obj->isSetupComplete) {
        ptrObj = obj->pHOGDescriptor;
        HOGDescriptor_deleteObj(ptrObj);
      }
    }
  }
}

/* End of code generation (matlabCodegenHandle.c) */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: cornerPoints_cg.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "cornerPoints_cg.h"
#include "FeaturePointsImpl.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *varargin_1
 *                const emxArray_real32_T *varargin_3
 *                vision_internal_cornerPoints_cg *this
 * Return Type  : void
 */
void cornerPoints_cg_cornerPoints_cg(const emxArray_real32_T *varargin_1, const
  emxArray_real32_T *varargin_3, vision_internal_cornerPoints_cg *this)
{
  int i21;
  i21 = this->pLocation->size[0] * this->pLocation->size[1];
  this->pLocation->size[0] = 0;
  this->pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(this->pLocation, i21);
  i21 = this->pMetric->size[0];
  this->pMetric->size[0] = 0;
  emxEnsureCapacity_real32_T2(this->pMetric, i21);
  c_FeaturePointsImpl_FeaturePoin(this, varargin_1, varargin_3);
}

/*
 * File trailer for cornerPoints_cg.c
 *
 * [EOF]
 */

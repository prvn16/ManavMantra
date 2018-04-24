/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: cornerPoints_cg.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "cornerPoints_cg.h"
#include "FeaturePointsImpl.h"
#include "faceTrackingARMKernel_emxutil.h"

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
  int i30;
  i30 = this->pLocation->size[0] * this->pLocation->size[1];
  this->pLocation->size[0] = 0;
  this->pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(this->pLocation, i30);
  i30 = this->pMetric->size[0];
  this->pMetric->size[0] = 0;
  emxEnsureCapacity_real32_T2(this->pMetric, i30);
  c_FeaturePointsImpl_FeaturePoin(this, varargin_1, varargin_3);
}

/*
 * File trailer for cornerPoints_cg.c
 *
 * [EOF]
 */

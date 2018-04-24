/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: FeaturePointsImpl.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "FeaturePointsImpl.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "repmat.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void FeaturePointsImpl_configure(vision_internal_cornerPoints_cg *this,
  const emxArray_real32_T *inputs_Location, const emxArray_real32_T
  *inputs_Metric);

/* Function Definitions */

/*
 * Arguments    : vision_internal_cornerPoints_cg *this
 *                const emxArray_real32_T *inputs_Location
 *                const emxArray_real32_T *inputs_Metric
 * Return Type  : void
 */
static void FeaturePointsImpl_configure(vision_internal_cornerPoints_cg *this,
  const emxArray_real32_T *inputs_Location, const emxArray_real32_T
  *inputs_Metric)
{
  int i41;
  int loop_ub;
  emxArray_real32_T *r19;
  i41 = this->pLocation->size[0] * this->pLocation->size[1];
  this->pLocation->size[0] = inputs_Location->size[0];
  this->pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(this->pLocation, i41);
  loop_ub = inputs_Location->size[0] * inputs_Location->size[1];
  for (i41 = 0; i41 < loop_ub; i41++) {
    this->pLocation->data[i41] = inputs_Location->data[i41];
  }

  emxInit_real32_T1(&r19, 1);
  if (inputs_Metric->size[0] == 1) {
    b_repmat(inputs_Metric->data, inputs_Location->size[0], r19);
  } else {
    i41 = r19->size[0];
    r19->size[0] = inputs_Metric->size[0];
    emxEnsureCapacity_real32_T2(r19, i41);
    loop_ub = inputs_Metric->size[0];
    for (i41 = 0; i41 < loop_ub; i41++) {
      r19->data[i41] = inputs_Metric->data[i41];
    }
  }

  i41 = this->pMetric->size[0];
  this->pMetric->size[0] = r19->size[0];
  emxEnsureCapacity_real32_T2(this->pMetric, i41);
  loop_ub = r19->size[0];
  for (i41 = 0; i41 < loop_ub; i41++) {
    this->pMetric->data[i41] = r19->data[i41];
  }

  emxFree_real32_T(&r19);
}

/*
 * Arguments    : vision_internal_cornerPoints_cg *this
 *                const emxArray_real32_T *varargin_1
 *                const emxArray_real32_T *varargin_3
 * Return Type  : void
 */
void c_FeaturePointsImpl_FeaturePoin(vision_internal_cornerPoints_cg *this,
  const emxArray_real32_T *varargin_1, const emxArray_real32_T *varargin_3)
{
  emxArray_real32_T *inputs_Location;
  int i40;
  int loop_ub;
  emxArray_real32_T *inputs_Metric;
  emxInit_real32_T(&inputs_Location, 2);
  i40 = inputs_Location->size[0] * inputs_Location->size[1];
  inputs_Location->size[0] = varargin_1->size[0];
  inputs_Location->size[1] = 2;
  emxEnsureCapacity_real32_T(inputs_Location, i40);
  loop_ub = varargin_1->size[0] * varargin_1->size[1];
  for (i40 = 0; i40 < loop_ub; i40++) {
    inputs_Location->data[i40] = varargin_1->data[i40];
  }

  emxInit_real32_T1(&inputs_Metric, 1);
  i40 = inputs_Metric->size[0];
  inputs_Metric->size[0] = varargin_3->size[0];
  emxEnsureCapacity_real32_T2(inputs_Metric, i40);
  loop_ub = varargin_3->size[0];
  for (i40 = 0; i40 < loop_ub; i40++) {
    inputs_Metric->data[i40] = varargin_3->data[i40];
  }

  FeaturePointsImpl_configure(this, inputs_Location, inputs_Metric);
  emxFree_real32_T(&inputs_Metric);
  emxFree_real32_T(&inputs_Location);
}

/*
 * File trailer for FeaturePointsImpl.c
 *
 * [EOF]
 */

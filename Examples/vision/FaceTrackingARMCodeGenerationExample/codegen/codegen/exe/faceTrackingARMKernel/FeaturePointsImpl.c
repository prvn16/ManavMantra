/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: FeaturePointsImpl.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "FeaturePointsImpl.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "repmat.h"

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
  int i47;
  int loop_ub;
  emxArray_real32_T *r17;
  i47 = this->pLocation->size[0] * this->pLocation->size[1];
  this->pLocation->size[0] = inputs_Location->size[0];
  this->pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(this->pLocation, i47);
  loop_ub = inputs_Location->size[0] * inputs_Location->size[1];
  for (i47 = 0; i47 < loop_ub; i47++) {
    this->pLocation->data[i47] = inputs_Location->data[i47];
  }

  emxInit_real32_T1(&r17, 1);
  if (inputs_Metric->size[0] == 1) {
    b_repmat(inputs_Metric->data, inputs_Location->size[0], r17);
  } else {
    i47 = r17->size[0];
    r17->size[0] = inputs_Metric->size[0];
    emxEnsureCapacity_real32_T2(r17, i47);
    loop_ub = inputs_Metric->size[0];
    for (i47 = 0; i47 < loop_ub; i47++) {
      r17->data[i47] = inputs_Metric->data[i47];
    }
  }

  i47 = this->pMetric->size[0];
  this->pMetric->size[0] = r17->size[0];
  emxEnsureCapacity_real32_T2(this->pMetric, i47);
  loop_ub = r17->size[0];
  for (i47 = 0; i47 < loop_ub; i47++) {
    this->pMetric->data[i47] = r17->data[i47];
  }

  emxFree_real32_T(&r17);
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
  int i46;
  int loop_ub;
  emxArray_real32_T *inputs_Metric;
  emxInit_real32_T(&inputs_Location, 2);
  i46 = inputs_Location->size[0] * inputs_Location->size[1];
  inputs_Location->size[0] = varargin_1->size[0];
  inputs_Location->size[1] = 2;
  emxEnsureCapacity_real32_T(inputs_Location, i46);
  loop_ub = varargin_1->size[0] * varargin_1->size[1];
  for (i46 = 0; i46 < loop_ub; i46++) {
    inputs_Location->data[i46] = varargin_1->data[i46];
  }

  emxInit_real32_T1(&inputs_Metric, 1);
  i46 = inputs_Metric->size[0];
  inputs_Metric->size[0] = varargin_3->size[0];
  emxEnsureCapacity_real32_T2(inputs_Metric, i46);
  loop_ub = varargin_3->size[0];
  for (i46 = 0; i46 < loop_ub; i46++) {
    inputs_Metric->data[i46] = varargin_3->data[i46];
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

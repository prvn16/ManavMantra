/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: SystemCore.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <math.h>
#include <string.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "SystemCore.h"
#include "ShapeInserter.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "libmwgrayto8.h"
#include "libmwrgb2gray_tbb.h"
#include "CascadeClassifierCore_api.hpp"
#include "pointTrackerCore_api.hpp"

/* Variable Definitions */
static const short iv0[8] = { 480, 640, 3, 1, 1, 1, 1, 1 };

/* Function Declarations */
static double rt_roundd_snf(double u);

/* Function Definitions */

/*
 * Arguments    : double u
 * Return Type  : double
 */
static double rt_roundd_snf(double u)
{
  double y;
  if (fabs(u) < 4.503599627370496E+15) {
    if (u >= 0.5) {
      y = floor(u + 0.5);
    } else if (u > -0.5) {
      y = u * 0.0;
    } else {
      y = ceil(u - 0.5);
    }
  } else {
    y = u;
  }

  return y;
}

/*
 * Arguments    : vision_PointTracker *obj
 * Return Type  : void
 */
void SystemCore_setup(vision_PointTracker *obj)
{
  int i22;
  cell_wrap_3 varSizes[1];
  obj->isSetupComplete = false;
  obj->isInitialized = 1;
  for (i22 = 0; i22 < 8; i22++) {
    varSizes[0].f1[i22] = (unsigned int)iv0[i22];
  }

  obj->inputVarSize[0] = varSizes[0];
  obj->isSetupComplete = true;
}

/*
 * Arguments    : vision_CascadeObjectDetector *obj
 *                const float varargin_1[921600]
 *                emxArray_real_T *varargout_1
 * Return Type  : void
 */
void SystemCore_step(vision_CascadeObjectDetector *obj, const float varargin_1
                     [921600], emxArray_real_T *varargout_1)
{
  int i0;
  int num_bboxes;
  boolean_T exitg1;
  cell_wrap_3 varSizes[1];
  static unsigned char Iu8[921600];
  static unsigned char grayImage[307200];
  void * ptrObj;
  double ScaleFactor;
  double d0;
  unsigned int MergeThreshold;
  void * ptrDetectedObj;
  int MinSize_[2];
  int MaxSize_[2];
  emxArray_int32_T *bboxes_;
  static unsigned char b_grayImage[307200];
  if (obj->isInitialized != 1) {
    obj->isSetupComplete = false;
    obj->isInitialized = 1;
    for (i0 = 0; i0 < 8; i0++) {
      varSizes[0].f1[i0] = (unsigned int)iv0[i0];
    }

    obj->inputVarSize[0] = varSizes[0];
    obj->isSetupComplete = true;
    obj->TunablePropsChanged = false;
  }

  if (obj->TunablePropsChanged) {
    obj->TunablePropsChanged = false;
  }

  num_bboxes = 0;
  exitg1 = false;
  while ((!exitg1) && (num_bboxes < 8)) {
    if (obj->inputVarSize[0].f1[num_bboxes] != (unsigned int)iv0[num_bboxes]) {
      for (i0 = 0; i0 < 8; i0++) {
        obj->inputVarSize[0].f1[i0] = (unsigned int)iv0[i0];
      }

      exitg1 = true;
    } else {
      num_bboxes++;
    }
  }

  grayto8_real32(varargin_1, Iu8, 921600.0);
  rgb2gray_tbb_uint8(Iu8, 307200.0, grayImage, true);
  ptrObj = obj->pCascadeClassifier;
  ScaleFactor = obj->ScaleFactor;
  d0 = rt_roundd_snf(obj->MergeThreshold);
  if (d0 < 4.294967296E+9) {
    if (d0 >= 0.0) {
      MergeThreshold = (unsigned int)d0;
    } else {
      MergeThreshold = 0U;
    }
  } else if (d0 >= 4.294967296E+9) {
    MergeThreshold = MAX_uint32_T;
  } else {
    MergeThreshold = 0U;
  }

  for (i0 = 0; i0 < 2; i0++) {
    MinSize_[i0] = 0;
    MaxSize_[i0] = 0;
  }

  ptrDetectedObj = NULL;
  for (i0 = 0; i0 < 480; i0++) {
    for (num_bboxes = 0; num_bboxes < 640; num_bboxes++) {
      b_grayImage[num_bboxes + 640 * i0] = grayImage[i0 + 480 * num_bboxes];
    }
  }

  emxInit_int32_T1(&bboxes_, 2);
  num_bboxes = cascadeClassifier_detectMultiScale(ptrObj, &ptrDetectedObj,
    b_grayImage, 480, 640, ScaleFactor, MergeThreshold, MinSize_, MaxSize_);
  i0 = bboxes_->size[0] * bboxes_->size[1];
  bboxes_->size[0] = num_bboxes;
  bboxes_->size[1] = 4;
  emxEnsureCapacity_int32_T1(bboxes_, i0);
  cascadeClassifier_assignOutputDeleteBbox(ptrDetectedObj, &bboxes_->data[0]);
  i0 = varargout_1->size[0] * varargout_1->size[1];
  varargout_1->size[0] = bboxes_->size[0];
  varargout_1->size[1] = bboxes_->size[1];
  emxEnsureCapacity_real_T(varargout_1, i0);
  num_bboxes = bboxes_->size[0] * bboxes_->size[1];
  for (i0 = 0; i0 < num_bboxes; i0++) {
    varargout_1->data[i0] = bboxes_->data[i0];
  }

  emxFree_int32_T(&bboxes_);
}

/*
 * Arguments    : visioncodegen_ShapeInserter *obj
 *                const float varargin_1[921600]
 *                const int varargin_2_data[]
 *                const int varargin_2_size[2]
 *                const float varargin_3_data[]
 *                const int varargin_3_size[2]
 *                float varargout_1[921600]
 * Return Type  : void
 */
void b_SystemCore_step(visioncodegen_ShapeInserter *obj, const float varargin_1
  [921600], const int varargin_2_data[], const int varargin_2_size[2], const
  float varargin_3_data[], const int varargin_3_size[2], float varargout_1
  [921600])
{
  if (obj->isInitialized != 1) {
    obj->isSetupComplete = false;
    obj->isInitialized = 1;
    obj->isSetupComplete = true;
  }

  memcpy(&varargout_1[0], &varargin_1[0], 921600U * sizeof(float));
  ShapeInserter_outputImpl(obj, varargout_1, varargin_2_data, varargin_2_size,
    varargin_3_data, varargin_3_size);
}

/*
 * Arguments    : vision_PointTracker *obj
 *                const float varargin_1[921600]
 *                emxArray_real32_T *varargout_1
 *                emxArray_boolean_T *varargout_2
 * Return Type  : void
 */
void c_SystemCore_step(vision_PointTracker *obj, const float varargin_1[921600],
  emxArray_real32_T *varargout_1, emxArray_boolean_T *varargout_2)
{
  int numPoints;
  boolean_T exitg1;
  int i;
  cell_wrap_3 varSizes[1];
  emxArray_real32_T *pointsTmp;
  emxArray_real_T *scores;
  static unsigned char Iu8[921600];
  static unsigned char Iu8_gray[307200];
  void * ptrObj;
  double num_points;
  static unsigned char Iu8_grayT[307200];
  emxArray_real32_T *x;
  emxArray_real32_T *y;
  emxArray_boolean_T *badPoints;
  emxArray_boolean_T *r10;
  if (obj->isInitialized != 1) {
    obj->isSetupComplete = false;
    obj->isInitialized = 1;
    for (i = 0; i < 8; i++) {
      varSizes[0].f1[i] = (unsigned int)iv0[i];
    }

    obj->inputVarSize[0] = varSizes[0];
    obj->isSetupComplete = true;
  }

  numPoints = 0;
  exitg1 = false;
  while ((!exitg1) && (numPoints < 8)) {
    if (obj->inputVarSize[0].f1[numPoints] != (unsigned int)iv0[numPoints]) {
      for (i = 0; i < 8; i++) {
        obj->inputVarSize[0].f1[i] = (unsigned int)iv0[i];
      }

      exitg1 = true;
    } else {
      numPoints++;
    }
  }

  emxInit_real32_T(&pointsTmp, 2);
  emxInit_real_T1(&scores, 1);
  grayto8_real32(varargin_1, Iu8, 921600.0);
  rgb2gray_tbb_uint8(Iu8, 307200.0, Iu8_gray, true);
  ptrObj = obj->pTracker;
  num_points = obj->NumPoints;
  num_points = rt_roundd_snf(num_points);
  if (num_points < 2.147483648E+9) {
    if (num_points >= -2.147483648E+9) {
      numPoints = (int)num_points;
    } else {
      numPoints = MIN_int32_T;
    }
  } else if (num_points >= 2.147483648E+9) {
    numPoints = MAX_int32_T;
  } else {
    numPoints = 0;
  }

  i = pointsTmp->size[0] * pointsTmp->size[1];
  pointsTmp->size[0] = numPoints;
  pointsTmp->size[1] = 2;
  emxEnsureCapacity_real32_T(pointsTmp, i);
  i = varargout_2->size[0];
  varargout_2->size[0] = numPoints;
  emxEnsureCapacity_boolean_T2(varargout_2, i);
  i = scores->size[0];
  scores->size[0] = numPoints;
  emxEnsureCapacity_real_T1(scores, i);
  for (i = 0; i < 480; i++) {
    for (numPoints = 0; numPoints < 640; numPoints++) {
      Iu8_grayT[numPoints + 640 * i] = Iu8_gray[i + 480 * numPoints];
    }
  }

  pointTracker_step(ptrObj, Iu8_grayT, 480, 640, &pointsTmp->data[0],
                    &varargout_2->data[0], &scores->data[0]);
  i = varargout_1->size[0] * varargout_1->size[1];
  varargout_1->size[0] = pointsTmp->size[0];
  varargout_1->size[1] = pointsTmp->size[1];
  emxEnsureCapacity_real32_T(varargout_1, i);
  numPoints = pointsTmp->size[0] * pointsTmp->size[1];
  emxFree_real_T(&scores);
  for (i = 0; i < numPoints; i++) {
    varargout_1->data[i] = pointsTmp->data[i];
  }

  emxInit_real32_T1(&x, 1);
  numPoints = pointsTmp->size[0];
  i = x->size[0];
  x->size[0] = numPoints;
  emxEnsureCapacity_real32_T2(x, i);
  for (i = 0; i < numPoints; i++) {
    x->data[i] = pointsTmp->data[i];
  }

  emxInit_real32_T1(&y, 1);
  numPoints = pointsTmp->size[0];
  i = y->size[0];
  y->size[0] = numPoints;
  emxEnsureCapacity_real32_T2(y, i);
  for (i = 0; i < numPoints; i++) {
    y->data[i] = pointsTmp->data[i + pointsTmp->size[0]];
  }

  emxFree_real32_T(&pointsTmp);
  emxInit_boolean_T(&badPoints, 1);
  num_points = obj->FrameSize[1];
  i = badPoints->size[0];
  badPoints->size[0] = x->size[0];
  emxEnsureCapacity_boolean_T2(badPoints, i);
  numPoints = x->size[0];
  for (i = 0; i < numPoints; i++) {
    badPoints->data[i] = (x->data[i] > num_points);
  }

  emxInit_boolean_T(&r10, 1);
  num_points = obj->FrameSize[0];
  i = r10->size[0];
  r10->size[0] = y->size[0];
  emxEnsureCapacity_boolean_T2(r10, i);
  numPoints = y->size[0];
  for (i = 0; i < numPoints; i++) {
    r10->data[i] = (y->data[i] > num_points);
  }

  i = badPoints->size[0];
  badPoints->size[0] = x->size[0];
  emxEnsureCapacity_boolean_T2(badPoints, i);
  numPoints = x->size[0];
  for (i = 0; i < numPoints; i++) {
    badPoints->data[i] = ((x->data[i] < 1.0F) || (y->data[i] < 1.0F) ||
                          badPoints->data[i] || r10->data[i]);
  }

  emxFree_boolean_T(&r10);
  emxFree_real32_T(&y);
  emxFree_real32_T(&x);
  numPoints = badPoints->size[0];
  for (i = 0; i < numPoints; i++) {
    if (badPoints->data[i]) {
      varargout_2->data[i] = false;
    }
  }

  emxFree_boolean_T(&badPoints);
}

/*
 * Arguments    : visioncodegen_ShapeInserter_1 *obj
 *                const float varargin_1[921600]
 *                const int varargin_2_data[]
 *                const int varargin_2_size[1]
 *                float varargout_1[921600]
 * Return Type  : void
 */
void d_SystemCore_step(visioncodegen_ShapeInserter_1 *obj, const float
  varargin_1[921600], const int varargin_2_data[], const int varargin_2_size[1],
  float varargout_1[921600])
{
  static const float varargin_3[3] = { 1.0F, 1.0F, 0.0F };

  if (obj->isInitialized != 1) {
    obj->isSetupComplete = false;
    obj->isInitialized = 1;
    obj->isSetupComplete = true;
  }

  memcpy(&varargout_1[0], &varargin_1[0], 921600U * sizeof(float));
  b_ShapeInserter_outputImpl(obj, varargout_1, varargin_2_data, varargin_2_size,
    varargin_3);
}

/*
 * File trailer for SystemCore.c
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: SystemCore.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "SystemCore.h"
#include "ShapeInserter.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "PointTracker.h"
#include "insertShape.h"
#include "faceTrackingARMKernel_rtwutil.h"
#include "CascadeClassifierCore_api.hpp"
#include "pointTrackerCore_api.hpp"

/* Function Definitions */

/*
 * Arguments    : vision_PointTracker *obj
 * Return Type  : void
 */
void SystemCore_setup(vision_PointTracker *obj)
{
  int i2;
  cell_wrap_3 varSizes[1];
  static const unsigned char uv1[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  obj->isSetupComplete = false;
  obj->isInitialized = 1;
  for (i2 = 0; i2 < 8; i2++) {
    varSizes[0].f1[i2] = uv1[i2];
  }

  obj->inputVarSize[0] = varSizes[0];
  obj->isSetupComplete = true;
}

/*
 * Arguments    : vision_CascadeObjectDetector *obj
 *                const unsigned char varargin_1[34240]
 *                emxArray_real_T *varargout_1
 * Return Type  : void
 */
void SystemCore_step(vision_CascadeObjectDetector *obj, const unsigned char
                     varargin_1[34240], emxArray_real_T *varargout_1)
{
  int i4;
  int num_bboxes;
  boolean_T exitg1;
  cell_wrap_3 varSizes[1];
  static const unsigned char inSize[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  void * ptrObj;
  static const unsigned char uv2[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  double ScaleFactor;
  double d1;
  unsigned int MergeThreshold;
  void * ptrDetectedObj;
  int MinSize_[2];
  int MaxSize_[2];
  emxArray_int32_T *bboxes_;
  unsigned char b_varargin_1[34240];
  if (obj->isInitialized != 1) {
    obj->isSetupComplete = false;
    obj->isInitialized = 1;
    for (i4 = 0; i4 < 8; i4++) {
      varSizes[0].f1[i4] = inSize[i4];
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
    if (obj->inputVarSize[0].f1[num_bboxes] != uv2[num_bboxes]) {
      for (i4 = 0; i4 < 8; i4++) {
        obj->inputVarSize[0].f1[i4] = inSize[i4];
      }

      exitg1 = true;
    } else {
      num_bboxes++;
    }
  }

  ptrObj = obj->pCascadeClassifier;
  ScaleFactor = obj->ScaleFactor;
  d1 = rt_roundd_snf(obj->MergeThreshold);
  if (d1 < 4.294967296E+9) {
    if (d1 >= 0.0) {
      MergeThreshold = (unsigned int)d1;
    } else {
      MergeThreshold = 0U;
    }
  } else if (d1 >= 4.294967296E+9) {
    MergeThreshold = MAX_uint32_T;
  } else {
    MergeThreshold = 0U;
  }

  for (i4 = 0; i4 < 2; i4++) {
    MinSize_[i4] = 0;
    MaxSize_[i4] = 0;
  }

  ptrDetectedObj = NULL;
  for (i4 = 0; i4 < 160; i4++) {
    for (num_bboxes = 0; num_bboxes < 214; num_bboxes++) {
      b_varargin_1[num_bboxes + 214 * i4] = varargin_1[i4 + 160 * num_bboxes];
    }
  }

  emxInit_int32_T1(&bboxes_, 2);
  num_bboxes = cascadeClassifier_detectMultiScale(ptrObj, &ptrDetectedObj,
    b_varargin_1, 160, 214, ScaleFactor, MergeThreshold, MinSize_, MaxSize_);
  i4 = bboxes_->size[0] * bboxes_->size[1];
  bboxes_->size[0] = num_bboxes;
  bboxes_->size[1] = 4;
  emxEnsureCapacity_int32_T1(bboxes_, i4);
  cascadeClassifier_assignOutputDeleteBbox(ptrDetectedObj, &bboxes_->data[0]);
  i4 = varargout_1->size[0] * varargout_1->size[1];
  varargout_1->size[0] = bboxes_->size[0];
  varargout_1->size[1] = bboxes_->size[1];
  emxEnsureCapacity_real_T1(varargout_1, i4);
  num_bboxes = bboxes_->size[0] * bboxes_->size[1];
  for (i4 = 0; i4 < num_bboxes; i4++) {
    varargout_1->data[i4] = bboxes_->data[i4];
  }

  emxFree_int32_T(&bboxes_);
}

/*
 * Arguments    : vision_PointTracker *obj
 *                const unsigned char varargin_1[34240]
 * Return Type  : void
 */
void b_SystemCore_step(vision_PointTracker *obj, const unsigned char varargin_1
  [34240])
{
  int numPoints;
  boolean_T exitg1;
  int i;
  cell_wrap_3 varSizes[1];
  static const unsigned char uv5[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  emxArray_real_T *scores;
  static const unsigned char uv6[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  emxArray_boolean_T *pointValidity;
  emxArray_real32_T *pointsTmp;
  void * ptrObj;
  static const unsigned char inSize[8] = { 160U, 214U, 1U, 1U, 1U, 1U, 1U, 1U };

  double num_points;
  emxArray_boolean_T *badPoints;
  unsigned char Iu8_grayT[34240];
  emxArray_real_T *b_obj;
  if (obj->isInitialized != 1) {
    obj->isSetupComplete = false;
    obj->isInitialized = 1;
    for (i = 0; i < 8; i++) {
      varSizes[0].f1[i] = uv5[i];
    }

    obj->inputVarSize[0] = varSizes[0];
    obj->isSetupComplete = true;
  }

  numPoints = 0;
  exitg1 = false;
  while ((!exitg1) && (numPoints < 8)) {
    if (obj->inputVarSize[0].f1[numPoints] != uv6[numPoints]) {
      for (i = 0; i < 8; i++) {
        obj->inputVarSize[0].f1[i] = inSize[i];
      }

      exitg1 = true;
    } else {
      numPoints++;
    }
  }

  emxInit_real_T1(&scores, 1);
  emxInit_boolean_T(&pointValidity, 1);
  emxInit_real32_T(&pointsTmp, 2);
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
  i = pointValidity->size[0];
  pointValidity->size[0] = numPoints;
  emxEnsureCapacity_boolean_T(pointValidity, i);
  i = scores->size[0];
  scores->size[0] = numPoints;
  emxEnsureCapacity_real_T(scores, i);
  for (i = 0; i < 160; i++) {
    for (numPoints = 0; numPoints < 214; numPoints++) {
      Iu8_grayT[numPoints + 214 * i] = varargin_1[i + 160 * numPoints];
    }
  }

  emxInit_boolean_T(&badPoints, 1);
  pointTracker_step(ptrObj, Iu8_grayT, 160, 214, &pointsTmp->data[0],
                    &pointValidity->data[0], &scores->data[0]);
  PointTracker_pointsOutsideImage(obj, pointsTmp, badPoints);
  numPoints = badPoints->size[0];
  emxFree_real32_T(&pointsTmp);
  for (i = 0; i < numPoints; i++) {
    if (badPoints->data[i]) {
      pointValidity->data[i] = false;
    }
  }

  emxFree_boolean_T(&badPoints);
  emxInit_real_T1(&b_obj, 1);
  PointTracker_normalizeScores(scores, pointValidity, b_obj);
  emxFree_real_T(&b_obj);
  emxFree_boolean_T(&pointValidity);
  emxFree_real_T(&scores);
}

/*
 * Arguments    : visioncodegen_ShapeInserter *obj
 *                const unsigned char varargin_1[921600]
 *                const int varargin_2_data[]
 *                const int varargin_2_size[1]
 *                unsigned char varargout_1[921600]
 * Return Type  : void
 */
void c_SystemCore_step(visioncodegen_ShapeInserter *obj, const unsigned char
  varargin_1[921600], const int varargin_2_data[], const int varargin_2_size[1],
  unsigned char varargout_1[921600])
{
  static const unsigned char varargin_3[3] = { MAX_uint8_T, MAX_uint8_T, 0U };

  if (obj->isInitialized != 1) {
    obj->isSetupComplete = false;
    obj->isInitialized = 1;
    obj->isSetupComplete = true;
  }

  memcpy(&varargout_1[0], &varargin_1[0], 921600U * sizeof(unsigned char));
  ShapeInserter_outputImpl(obj, varargout_1, varargin_2_data, varargin_2_size,
    varargin_3);
}

/*
 * File trailer for SystemCore.c
 *
 * [EOF]
 */

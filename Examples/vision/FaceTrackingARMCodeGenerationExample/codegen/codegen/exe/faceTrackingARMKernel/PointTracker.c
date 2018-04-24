/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: PointTracker.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "PointTracker.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "SystemCore.h"
#include "pointTrackerCore_api.hpp"

/* Function Declarations */
static void PointTracker_getKLTParams(const vision_PointTracker *obj, double
  kltParams_BlockSize[2], double *kltParams_NumPyramidLevels, double
  *kltParams_MaxIterations, double *kltParams_Epsilon, double
  *kltParams_MaxBidirectionalError);
static void b_PointTracker_PointTracker(vision_PointTracker **obj);
static void b_PointTracker_normalizeScores(emxArray_real_T *scores, const
  emxArray_boolean_T *validity);

/* Function Definitions */

/*
 * Arguments    : const vision_PointTracker *obj
 *                double kltParams_BlockSize[2]
 *                double *kltParams_NumPyramidLevels
 *                double *kltParams_MaxIterations
 *                double *kltParams_Epsilon
 *                double *kltParams_MaxBidirectionalError
 * Return Type  : void
 */
static void PointTracker_getKLTParams(const vision_PointTracker *obj, double
  kltParams_BlockSize[2], double *kltParams_NumPyramidLevels, double
  *kltParams_MaxIterations, double *kltParams_Epsilon, double
  *kltParams_MaxBidirectionalError)
{
  int i3;
  double varargin_1[2];
  double topOfPyramid;
  int eint;
  for (i3 = 0; i3 < 2; i3++) {
    kltParams_BlockSize[i3] = 31.0;
    varargin_1[i3] = obj->FrameSize[i3];
  }

  if ((varargin_1[0] > varargin_1[1]) || (rtIsNaN(varargin_1[0]) && (!rtIsNaN
        (varargin_1[1])))) {
    topOfPyramid = varargin_1[1];
  } else {
    topOfPyramid = varargin_1[0];
  }

  if (topOfPyramid == 0.0) {
    topOfPyramid = rtMinusInf;
  } else if (topOfPyramid < 0.0) {
    topOfPyramid = rtNaN;
  } else {
    if ((!rtIsInf(topOfPyramid)) && (!rtIsNaN(topOfPyramid))) {
      topOfPyramid = frexp(topOfPyramid, &eint);
      if (topOfPyramid == 0.5) {
        topOfPyramid = (double)eint - 1.0;
      } else if ((eint == 1) && (topOfPyramid < 0.75)) {
        topOfPyramid = log(2.0 * topOfPyramid) / 0.69314718055994529;
      } else {
        topOfPyramid = log(topOfPyramid) / 0.69314718055994529 + (double)eint;
      }
    }
  }

  topOfPyramid = floor(topOfPyramid - 2.0);
  if (!(topOfPyramid < 3.0)) {
    topOfPyramid = 3.0;
  }

  if (0.0 > topOfPyramid) {
    *kltParams_NumPyramidLevels = 0.0;
  } else {
    *kltParams_NumPyramidLevels = (int)topOfPyramid;
  }

  *kltParams_MaxIterations = 30.0;
  *kltParams_Epsilon = 0.01;
  *kltParams_MaxBidirectionalError = 2.0;
}

/*
 * Arguments    : vision_PointTracker **obj
 * Return Type  : void
 */
static void b_PointTracker_PointTracker(vision_PointTracker **obj)
{
  void * ptrObj;
  (*obj)->IsRGB = false;
  (*obj)->isInitialized = 0;
  ptrObj = NULL;
  pointTracker_construct(&ptrObj);
  (*obj)->pTracker = ptrObj;
  (*obj)->matlabCodegenIsDeleted = false;
}

/*
 * Arguments    : emxArray_real_T *scores
 *                const emxArray_boolean_T *validity
 * Return Type  : void
 */
static void b_PointTracker_normalizeScores(emxArray_real_T *scores, const
  emxArray_boolean_T *validity)
{
  int end;
  int loop_ub;
  end = scores->size[0];
  emxEnsureCapacity_real_T(scores, end);
  loop_ub = scores->size[0];
  for (end = 0; end < loop_ub; end++) {
    scores->data[end] = 1.0 - scores->data[end] / 7905.0;
  }

  end = validity->size[0];
  for (loop_ub = 0; loop_ub < end; loop_ub++) {
    if (!validity->data[loop_ub]) {
      scores->data[loop_ub] = 0.0;
    }
  }
}

/*
 * Arguments    : vision_PointTracker *obj
 * Return Type  : vision_PointTracker *
 */
vision_PointTracker *PointTracker_PointTracker(vision_PointTracker *obj)
{
  vision_PointTracker *b_obj;
  b_obj = obj;
  b_PointTracker_PointTracker(&b_obj);
  return b_obj;
}

/*
 * Arguments    : vision_PointTracker *obj
 *                const unsigned char I[34240]
 * Return Type  : void
 */
void PointTracker_initialize(vision_PointTracker *obj, const unsigned char I
  [34240])
{
  int blockH;
  void * ptrObj;
  double expl_temp[2];
  double params_NumPyramidLevels;
  double b_expl_temp;
  double c_expl_temp;
  double d_expl_temp;
  float points[2];
  int blockW;
  cvstPTStruct_T paramStruct;
  unsigned char Iu8_grayT[34240];
  SystemCore_setup(obj);
  obj->FrameClassID = 2.0;
  for (blockH = 0; blockH < 2; blockH++) {
    obj->FrameSize[blockH] = 160.0 + 54.0 * (double)blockH;
  }

  obj->NumPoints = 1.0;
  ptrObj = obj->pTracker;
  PointTracker_getKLTParams(obj, expl_temp, &params_NumPyramidLevels,
    &b_expl_temp, &c_expl_temp, &d_expl_temp);
  for (blockH = 0; blockH < 2; blockH++) {
    points[blockH] = 10.0F;
  }

  blockH = (int32_T)(31.0);
  blockW = (int32_T)(31.0);
  paramStruct.blockSize[0] = blockH;
  paramStruct.blockSize[1] = blockW;
  paramStruct.numPyramidLevels = (int32_T)(params_NumPyramidLevels);
  paramStruct.maxIterations = (double)(30.0);
  paramStruct.epsilon = 0.01;
  paramStruct.maxBidirectionalError = 2.0;
  for (blockH = 0; blockH < 160; blockH++) {
    for (blockW = 0; blockW < 214; blockW++) {
      Iu8_grayT[blockW + 214 * blockH] = I[blockH + 160 * blockW];
    }
  }

  pointTracker_initialize(ptrObj, Iu8_grayT, 160, 214, points, 1, &paramStruct);
}

/*
 * Arguments    : const emxArray_real_T *scores
 *                const emxArray_boolean_T *validity
 *                emxArray_real_T *b_scores
 * Return Type  : void
 */
void PointTracker_normalizeScores(const emxArray_real_T *scores, const
  emxArray_boolean_T *validity, emxArray_real_T *b_scores)
{
  int i32;
  int loop_ub;
  i32 = b_scores->size[0];
  b_scores->size[0] = scores->size[0];
  emxEnsureCapacity_real_T(b_scores, i32);
  loop_ub = scores->size[0];
  for (i32 = 0; i32 < loop_ub; i32++) {
    b_scores->data[i32] = scores->data[i32];
  }

  b_PointTracker_normalizeScores(b_scores, validity);
}

/*
 * Arguments    : const vision_PointTracker *obj
 *                const emxArray_real32_T *points
 *                emxArray_boolean_T *inds
 * Return Type  : void
 */
void PointTracker_pointsOutsideImage(const vision_PointTracker *obj, const
  emxArray_real32_T *points, emxArray_boolean_T *inds)
{
  emxArray_real32_T *x;
  int loop_ub;
  int i31;
  emxArray_real32_T *y;
  double b_obj;
  double c_obj;
  emxInit_real32_T1(&x, 1);
  loop_ub = points->size[0];
  i31 = x->size[0];
  x->size[0] = loop_ub;
  emxEnsureCapacity_real32_T2(x, i31);
  for (i31 = 0; i31 < loop_ub; i31++) {
    x->data[i31] = points->data[i31];
  }

  emxInit_real32_T1(&y, 1);
  loop_ub = points->size[0];
  i31 = y->size[0];
  y->size[0] = loop_ub;
  emxEnsureCapacity_real32_T2(y, i31);
  for (i31 = 0; i31 < loop_ub; i31++) {
    y->data[i31] = points->data[i31 + points->size[0]];
  }

  b_obj = obj->FrameSize[1];
  c_obj = obj->FrameSize[0];
  i31 = inds->size[0];
  inds->size[0] = x->size[0];
  emxEnsureCapacity_boolean_T(inds, i31);
  loop_ub = x->size[0];
  for (i31 = 0; i31 < loop_ub; i31++) {
    inds->data[i31] = ((x->data[i31] < 1.0F) || (y->data[i31] < 1.0F) ||
                       (x->data[i31] > b_obj) || (y->data[i31] > c_obj));
  }

  emxFree_real32_T(&y);
  emxFree_real32_T(&x);
}

/*
 * Arguments    : vision_PointTracker *obj
 *                const emxArray_real32_T *points
 *                const unsigned char I[34240]
 * Return Type  : void
 */
void b_PointTracker_initialize(vision_PointTracker *obj, const emxArray_real32_T
  *points, const unsigned char I[34240])
{
  int blockW;
  emxArray_real32_T *b_points;
  void * ptrObj;
  double expl_temp[2];
  double params_NumPyramidLevels;
  double b_expl_temp;
  double c_expl_temp;
  double d_expl_temp;
  int blockH;
  cvstPTStruct_T paramStruct;
  unsigned char Iu8_grayT[34240];
  SystemCore_setup(obj);
  obj->FrameClassID = 2.0;
  for (blockW = 0; blockW < 2; blockW++) {
    obj->FrameSize[blockW] = 160.0 + 54.0 * (double)blockW;
  }

  emxInit_real32_T(&b_points, 2);
  obj->NumPoints = points->size[0];
  ptrObj = obj->pTracker;
  PointTracker_getKLTParams(obj, expl_temp, &params_NumPyramidLevels,
    &b_expl_temp, &c_expl_temp, &d_expl_temp);
  blockW = b_points->size[0] * b_points->size[1];
  b_points->size[0] = points->size[0];
  b_points->size[1] = 2;
  emxEnsureCapacity_real32_T(b_points, blockW);
  blockH = points->size[0] * points->size[1];
  for (blockW = 0; blockW < blockH; blockW++) {
    b_points->data[blockW] = points->data[blockW];
  }

  blockH = (int32_T)(31.0);
  blockW = (int32_T)(31.0);
  paramStruct.blockSize[0] = blockH;
  paramStruct.blockSize[1] = blockW;
  paramStruct.numPyramidLevels = (int32_T)(params_NumPyramidLevels);
  paramStruct.maxIterations = (double)(30.0);
  paramStruct.epsilon = 0.01;
  paramStruct.maxBidirectionalError = 2.0;
  for (blockW = 0; blockW < 160; blockW++) {
    for (blockH = 0; blockH < 214; blockH++) {
      Iu8_grayT[blockH + 214 * blockW] = I[blockW + 160 * blockH];
    }
  }

  pointTracker_initialize(ptrObj, Iu8_grayT, 160, 214, &b_points->data[0],
    points->size[0], &paramStruct);
  emxFree_real32_T(&b_points);
}

/*
 * File trailer for PointTracker.c
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * depthEstimationFromStereoVideo_kernel_emxutil.h
 *
 * Code generation for function 'depthEstimationFromStereoVideo_kernel_emxutil'
 *
 */

#ifndef DEPTHESTIMATIONFROMSTEREOVIDEO_KERNEL_EMXUTIL_H
#define DEPTHESTIMATIONFROMSTEREOVIDEO_KERNEL_EMXUTIL_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "depthEstimationFromStereoVideo_kernel_types.h"

/* Function Declarations */
extern void c_emxFreeStruct_vision_internal(const emlrtStack *sp,
  c_vision_internal_calibration_I *pStruct);
extern void c_emxInitStruct_vision_internal(const emlrtStack *sp,
  c_vision_internal_calibration_S *pStruct, const emlrtRTEInfo *srcLocation,
  boolean_T doPush);
extern void d_emxFreeStruct_vision_internal(const emlrtStack *sp,
  c_vision_internal_calibration_S *pStruct);
extern void d_emxInitStruct_vision_internal(const emlrtStack *sp,
  c_vision_internal_calibration_I *pStruct, const emlrtRTEInfo *srcLocation,
  boolean_T doPush);
extern void emxCopyStruct_struct_T(const emlrtStack *sp, c_struct_T *dst, const
  c_struct_T *src, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_boolean_T(const emlrtStack *sp, emxArray_boolean_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_boolean_T1(const emlrtStack *sp,
  emxArray_boolean_T *emxArray, int32_T oldNumel, const emlrtRTEInfo
  *srcLocation);
extern void emxEnsureCapacity_char_T(const emlrtStack *sp, emxArray_char_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_int32_T(const emlrtStack *sp, emxArray_int32_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_int32_T1(const emlrtStack *sp, emxArray_int32_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real32_T(const emlrtStack *sp, emxArray_real32_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real32_T1(const emlrtStack *sp, emxArray_real32_T *
  emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real32_T2(const emlrtStack *sp, emxArray_real32_T *
  emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real_T(const emlrtStack *sp, emxArray_real_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real_T1(const emlrtStack *sp, emxArray_real_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_struct_T(const emlrtStack *sp, b_emxArray_struct_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_struct_T1(const emlrtStack *sp, emxArray_struct_T *
  emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_uint8_T(const emlrtStack *sp, emxArray_uint8_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_uint8_T1(const emlrtStack *sp, emxArray_uint8_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxFreeStruct_struct_T(const emlrtStack *sp, c_struct_T *pStruct);
extern void emxFree_boolean_T(const emlrtStack *sp, emxArray_boolean_T
  **pEmxArray);
extern void emxFree_char_T(const emlrtStack *sp, emxArray_char_T **pEmxArray);
extern void emxFree_int32_T(const emlrtStack *sp, emxArray_int32_T **pEmxArray);
extern void emxFree_real32_T(const emlrtStack *sp, emxArray_real32_T **pEmxArray);
extern void emxFree_real_T(const emlrtStack *sp, emxArray_real_T **pEmxArray);
extern void emxFree_struct_T(const emlrtStack *sp, emxArray_struct_T **pEmxArray);
extern void emxFree_struct_T1(const emlrtStack *sp, b_emxArray_struct_T
  **pEmxArray);
extern void emxFree_uint8_T(const emlrtStack *sp, emxArray_uint8_T **pEmxArray);
extern void emxInitStruct_struct_T(const emlrtStack *sp, c_struct_T *pStruct,
  const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_boolean_T(const emlrtStack *sp, emxArray_boolean_T
  **pEmxArray, int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T
  doPush);
extern void emxInit_boolean_T1(const emlrtStack *sp, emxArray_boolean_T
  **pEmxArray, int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T
  doPush);
extern void emxInit_char_T(const emlrtStack *sp, emxArray_char_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_int32_T(const emlrtStack *sp, emxArray_int32_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_int32_T1(const emlrtStack *sp, emxArray_int32_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_real32_T(const emlrtStack *sp, emxArray_real32_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_real32_T1(const emlrtStack *sp, emxArray_real32_T
  **pEmxArray, int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T
  doPush);
extern void emxInit_real32_T2(const emlrtStack *sp, emxArray_real32_T
  **pEmxArray, int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T
  doPush);
extern void emxInit_real_T(const emlrtStack *sp, emxArray_real_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_real_T1(const emlrtStack *sp, emxArray_real_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_struct_T(const emlrtStack *sp, emxArray_struct_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_struct_T1(const emlrtStack *sp, b_emxArray_struct_T
  **pEmxArray, int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T
  doPush);
extern void emxInit_uint8_T(const emlrtStack *sp, emxArray_uint8_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_uint8_T1(const emlrtStack *sp, emxArray_uint8_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);

#endif

/* End of code generation (depthEstimationFromStereoVideo_kernel_emxutil.h) */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * visionRecovertformCodeGeneration_kernel_emxutil.h
 *
 * Code generation for function 'visionRecovertformCodeGeneration_kernel_emxutil'
 *
 */

#ifndef VISIONRECOVERTFORMCODEGENERATION_KERNEL_EMXUTIL_H
#define VISIONRECOVERTFORMCODEGENERATION_KERNEL_EMXUTIL_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "visionRecovertformCodeGeneration_kernel_types.h"

/* Function Declarations */
extern void c_emxFreeStruct_vision_internal(const emlrtStack *sp,
  vision_internal_SURFPoints_cg *pStruct);
extern void c_emxInitStruct_vision_internal(const emlrtStack *sp,
  vision_internal_SURFPoints_cg *pStruct, const emlrtRTEInfo *srcLocation,
  boolean_T doPush);
extern void emxEnsureCapacity_boolean_T(const emlrtStack *sp, emxArray_boolean_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_boolean_T1(const emlrtStack *sp,
  emxArray_boolean_T *emxArray, int32_T oldNumel, const emlrtRTEInfo
  *srcLocation);
extern void emxEnsureCapacity_int32_T(const emlrtStack *sp, emxArray_int32_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_int32_T1(const emlrtStack *sp, emxArray_int32_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_int8_T(const emlrtStack *sp, emxArray_int8_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_int8_T1(const emlrtStack *sp, emxArray_int8_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real32_T(const emlrtStack *sp, emxArray_real32_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real32_T1(const emlrtStack *sp, emxArray_real32_T *
  emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real32_T2(const emlrtStack *sp, emxArray_real32_T *
  emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_real_T(const emlrtStack *sp, emxArray_real_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_uint32_T(const emlrtStack *sp, emxArray_uint32_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxEnsureCapacity_uint8_T(const emlrtStack *sp, emxArray_uint8_T
  *emxArray, int32_T oldNumel, const emlrtRTEInfo *srcLocation);
extern void emxFreeMatrix_cell_wrap_26(const emlrtStack *sp, cell_wrap_26
  pMatrix[2]);
extern void emxFree_boolean_T(const emlrtStack *sp, emxArray_boolean_T
  **pEmxArray);
extern void emxFree_int32_T(const emlrtStack *sp, emxArray_int32_T **pEmxArray);
extern void emxFree_int8_T(const emlrtStack *sp, emxArray_int8_T **pEmxArray);
extern void emxFree_real32_T(const emlrtStack *sp, emxArray_real32_T **pEmxArray);
extern void emxFree_real_T(const emlrtStack *sp, emxArray_real_T **pEmxArray);
extern void emxFree_uint32_T(const emlrtStack *sp, emxArray_uint32_T **pEmxArray);
extern void emxFree_uint8_T(const emlrtStack *sp, emxArray_uint8_T **pEmxArray);
extern void emxInitMatrix_cell_wrap_26(const emlrtStack *sp, cell_wrap_26
  pMatrix[2], const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_boolean_T(const emlrtStack *sp, emxArray_boolean_T
  **pEmxArray, int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T
  doPush);
extern void emxInit_boolean_T1(const emlrtStack *sp, emxArray_boolean_T
  **pEmxArray, int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T
  doPush);
extern void emxInit_int32_T(const emlrtStack *sp, emxArray_int32_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_int32_T1(const emlrtStack *sp, emxArray_int32_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_int8_T(const emlrtStack *sp, emxArray_int8_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_int8_T1(const emlrtStack *sp, emxArray_int8_T **pEmxArray,
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
extern void emxInit_uint32_T(const emlrtStack *sp, emxArray_uint32_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);
extern void emxInit_uint8_T(const emlrtStack *sp, emxArray_uint8_T **pEmxArray,
  int32_T numDimensions, const emlrtRTEInfo *srcLocation, boolean_T doPush);

#endif

/* End of code generation (visionRecovertformCodeGeneration_kernel_emxutil.h) */

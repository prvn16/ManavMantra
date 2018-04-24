/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * SURFPointsImpl.h
 *
 * Code generation for function 'SURFPointsImpl'
 *
 */

#ifndef SURFPOINTSIMPL_H
#define SURFPOINTSIMPL_H

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
extern void SURFPointsImpl_checkScale(const emlrtStack *sp, const
  emxArray_real32_T *scale);
extern void SURFPointsImpl_configure(const emlrtStack *sp,
  vision_internal_SURFPoints_cg *this, const emxArray_real32_T *inputs_Location,
  const emxArray_real32_T *inputs_Metric, const emxArray_real32_T *inputs_Scale,
  const emxArray_int8_T *inputs_SignOfLaplacian);
extern void b_SURFPointsImpl_configure(const emlrtStack *sp,
  vision_internal_SURFPoints_cg *this, const emxArray_real32_T *inputs_Location,
  const emxArray_real32_T *inputs_Metric, const emxArray_real32_T *inputs_Scale,
  const emxArray_int8_T *inputs_SignOfLaplacian, const emxArray_real32_T
  *inputs_Orientation);

#endif

/* End of code generation (SURFPointsImpl.h) */

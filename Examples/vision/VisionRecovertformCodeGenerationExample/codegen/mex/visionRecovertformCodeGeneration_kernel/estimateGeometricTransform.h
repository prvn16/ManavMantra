/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * estimateGeometricTransform.h
 *
 * Code generation for function 'estimateGeometricTransform'
 *
 */

#ifndef ESTIMATEGEOMETRICTRANSFORM_H
#define ESTIMATEGEOMETRICTRANSFORM_H

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
extern void computeSimilarity(const emlrtStack *sp, const emxArray_real32_T
  *points, real32_T T[9]);
extern void estimateGeometricTransform(const emlrtStack *sp, const
  emxArray_real32_T *matchedPoints1, const emxArray_real32_T *matchedPoints2,
  real_T *tform_Dimensionality, real32_T tform_T_data[], int32_T tform_T_size[2],
  emxArray_real32_T *inlierPoints1, emxArray_real32_T *inlierPoints2);
extern void evaluateTForm(const emlrtStack *sp, const real32_T tform[9], const
  emxArray_real32_T *points, emxArray_real32_T *dis);

#endif

/* End of code generation (estimateGeometricTransform.h) */

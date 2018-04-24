/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * extractFeatures.h
 *
 * Code generation for function 'extractFeatures'
 *
 */

#ifndef EXTRACTFEATURES_H
#define EXTRACTFEATURES_H

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
extern void extractFeatures(const emlrtStack *sp, const emxArray_uint8_T *I,
  const emxArray_real32_T *points_pLocation, const emxArray_real32_T
  *points_pMetric, const emxArray_real32_T *points_pScale, const emxArray_int8_T
  *points_pSignOfLaplacian, emxArray_real32_T *features,
  vision_internal_SURFPoints_cg *valid_points);

#endif

/* End of code generation (extractFeatures.h) */

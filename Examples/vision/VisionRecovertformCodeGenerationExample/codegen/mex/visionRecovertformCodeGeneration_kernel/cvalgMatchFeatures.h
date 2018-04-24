/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * cvalgMatchFeatures.h
 *
 * Code generation for function 'cvalgMatchFeatures'
 *
 */

#ifndef CVALGMATCHFEATURES_H
#define CVALGMATCHFEATURES_H

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
extern void findMatchesExhaustive(const emlrtStack *sp, const emxArray_real32_T *
  features1, const emxArray_real32_T *features2, real32_T matchThreshold,
  emxArray_uint32_T *indexPairs, emxArray_real32_T *matchMetric);
extern void normalizeX(const emlrtStack *sp, emxArray_real32_T *X);

#endif

/* End of code generation (cvalgMatchFeatures.h) */

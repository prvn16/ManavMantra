/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * FeaturePointsImpl.h
 *
 * Code generation for function 'FeaturePointsImpl'
 *
 */

#ifndef FEATUREPOINTSIMPL_H
#define FEATUREPOINTSIMPL_H

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
extern void FeaturePointsImpl_checkLocation(const emlrtStack *sp, const
  emxArray_real32_T *location);
extern void FeaturePointsImpl_checkMetric(const emlrtStack *sp, const
  emxArray_real32_T *metric);

#endif

/* End of code generation (FeaturePointsImpl.h) */

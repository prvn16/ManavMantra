/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * unaryMinOrMax.h
 *
 * Code generation for function 'unaryMinOrMax'
 *
 */

#ifndef UNARYMINORMAX_H
#define UNARYMINORMAX_H

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
extern int32_T b_findFirst(const emlrtStack *sp, const emxArray_real_T *x);
extern real_T b_minOrMaxRealFloatVector(const emlrtStack *sp, const
  emxArray_real_T *x);
extern real_T minOrMaxRealFloatVector(const emlrtStack *sp, const
  emxArray_real_T *x);
extern void minOrMaxRealFloatVectorKernel(const emlrtStack *sp, const
  emxArray_real_T *x, int32_T first, int32_T last, real_T *ex, int32_T *idx);

#endif

/* End of code generation (unaryMinOrMax.h) */

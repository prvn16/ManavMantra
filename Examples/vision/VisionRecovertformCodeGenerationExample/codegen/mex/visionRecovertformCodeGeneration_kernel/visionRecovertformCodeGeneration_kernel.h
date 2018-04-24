/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * visionRecovertformCodeGeneration_kernel.h
 *
 * Code generation for function 'visionRecovertformCodeGeneration_kernel'
 *
 */

#ifndef VISIONRECOVERTFORMCODEGENERATION_KERNEL_H
#define VISIONRECOVERTFORMCODEGENERATION_KERNEL_H

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
extern void visionRecovertformCodeGeneration_kernel(const emlrtStack *sp, const
  emxArray_uint8_T *original, const emxArray_uint8_T *distorted,
  emxArray_real32_T *matchedOriginal, emxArray_real32_T *matchedDistorted,
  real32_T *thetaRecovered, real32_T *scaleRecovered, emxArray_uint8_T
  *recovered);

#endif

/* End of code generation (visionRecovertformCodeGeneration_kernel.h) */

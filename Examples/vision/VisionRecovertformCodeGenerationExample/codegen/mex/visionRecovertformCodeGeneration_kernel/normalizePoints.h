/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * normalizePoints.h
 *
 * Code generation for function 'normalizePoints'
 *
 */

#ifndef NORMALIZEPOINTS_H
#define NORMALIZEPOINTS_H

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
extern void b_normalizePoints(const emlrtStack *sp, const emxArray_real32_T *p,
  emxArray_real32_T *normPoints, real32_T T[9]);

#endif

/* End of code generation (normalizePoints.h) */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * partialSort.h
 *
 * Code generation for function 'partialSort'
 *
 */

#ifndef PARTIALSORT_H
#define PARTIALSORT_H

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
extern void partialSort(const emlrtStack *sp, emxArray_real32_T *x,
  emxArray_real32_T *values, emxArray_uint32_T *indices);

#endif

/* End of code generation (partialSort.h) */

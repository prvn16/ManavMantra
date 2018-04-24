/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * msac.h
 *
 * Code generation for function 'msac'
 *
 */

#ifndef MSAC_H
#define MSAC_H

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
extern void msac(const emlrtStack *sp, const emxArray_real32_T *allPoints,
                 boolean_T *isFound, real32_T bestModelParams_data[], int32_T
                 bestModelParams_size[2], emxArray_boolean_T *inliers);

#endif

/* End of code generation (msac.h) */

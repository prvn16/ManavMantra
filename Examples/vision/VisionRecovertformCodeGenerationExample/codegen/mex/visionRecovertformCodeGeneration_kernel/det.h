/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * det.h
 *
 * Code generation for function 'det'
 *
 */

#ifndef DET_H
#define DET_H

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
extern real32_T b_det(const emlrtStack *sp, const real32_T x[9]);
extern real32_T det(const emlrtStack *sp, const real32_T x_data[], const int32_T
                    x_size[2]);

#endif

/* End of code generation (det.h) */

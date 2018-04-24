/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * sum.h
 *
 * Code generation for function 'sum'
 *
 */

#ifndef SUM_H
#define SUM_H

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
extern real_T b_sum(const emlrtStack *sp, const int16_T x_data[], const int32_T
                    x_size[2]);
extern real_T c_sum(const emlrtStack *sp, const boolean_T x_data[], const
                    int32_T x_size[2]);
extern real_T sum(const uint8_T x[307200]);

#endif

/* End of code generation (sum.h) */

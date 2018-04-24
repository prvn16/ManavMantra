/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * ceil.h
 *
 * Code generation for function 'ceil'
 *
 */

#ifndef CEIL_H
#define CEIL_H

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
extern void b_ceil(real_T x[307200]);
extern void c_ceil(real_T x[614400]);
extern void d_ceil(const emlrtStack *sp, emxArray_real_T *x);
extern void e_ceil(const emlrtStack *sp, emxArray_real_T *x);

#endif

/* End of code generation (ceil.h) */

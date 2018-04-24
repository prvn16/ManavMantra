/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * floor.h
 *
 * Code generation for function 'floor'
 *
 */

#ifndef FLOOR_H
#define FLOOR_H

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
extern void b_floor(real_T x[614400]);
extern void c_floor(real_T x[307200]);
extern void d_floor(const emlrtStack *sp, emxArray_real_T *x);
extern void e_floor(const emlrtStack *sp, emxArray_real_T *x);

#endif

/* End of code generation (floor.h) */

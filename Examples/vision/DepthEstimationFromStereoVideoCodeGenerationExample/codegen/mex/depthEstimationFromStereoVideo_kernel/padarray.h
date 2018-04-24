/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * padarray.h
 *
 * Code generation for function 'padarray'
 *
 */

#ifndef PADARRAY_H
#define PADARRAY_H

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
extern void b_padarray(const emlrtStack *sp, const emxArray_real_T *varargin_1,
  emxArray_real_T *b);
extern void padarray(const emlrtStack *sp, const emxArray_boolean_T *varargin_1,
                     emxArray_boolean_T *b);

#endif

/* End of code generation (padarray.h) */

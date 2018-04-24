/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * bwtraceboundary.h
 *
 * Code generation for function 'bwtraceboundary'
 *
 */

#ifndef BWTRACEBOUNDARY_H
#define BWTRACEBOUNDARY_H

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
extern void bwtraceboundary(const emlrtStack *sp, const emxArray_uint8_T
  *varargin_1, const real_T varargin_2[2], emxArray_real_T *B);

#endif

/* End of code generation (bwtraceboundary.h) */

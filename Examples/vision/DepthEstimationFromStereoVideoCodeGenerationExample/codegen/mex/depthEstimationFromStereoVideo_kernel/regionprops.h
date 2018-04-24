/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * regionprops.h
 *
 * Code generation for function 'regionprops'
 *
 */

#ifndef REGIONPROPS_H
#define REGIONPROPS_H

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
extern void regionprops(const emlrtStack *sp, const emxArray_boolean_T
  *varargin_1, emxArray_struct_T *outstats);

#endif

/* End of code generation (regionprops.h) */

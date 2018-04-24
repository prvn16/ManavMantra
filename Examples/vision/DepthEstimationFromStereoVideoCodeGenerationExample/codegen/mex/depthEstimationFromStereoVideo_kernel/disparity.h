/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * disparity.h
 *
 * Code generation for function 'disparity'
 *
 */

#ifndef DISPARITY_H
#define DISPARITY_H

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
extern void disparity(const emlrtStack *sp, const emxArray_uint8_T *I1, const
                      emxArray_uint8_T *I2, emxArray_real32_T *disparityMap);

#endif

/* End of code generation (disparity.h) */

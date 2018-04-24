/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * rgb2gray.h
 *
 * Code generation for function 'rgb2gray'
 *
 */

#ifndef RGB2GRAY_H
#define RGB2GRAY_H

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
extern void rgb2gray(const emlrtStack *sp, const emxArray_uint8_T *X,
                     emxArray_uint8_T *I);

#endif

/* End of code generation (rgb2gray.h) */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * bsxfun.h
 *
 * Code generation for function 'bsxfun'
 *
 */

#ifndef BSXFUN_H
#define BSXFUN_H

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
extern void b_bsxfun(const emlrtStack *sp, const emxArray_real32_T *a, const
                     emxArray_real32_T *b, emxArray_real32_T *c);
extern void bsxfun(const real_T a[614400], const real_T b[2], real_T c[614400]);

#endif

/* End of code generation (bsxfun.h) */

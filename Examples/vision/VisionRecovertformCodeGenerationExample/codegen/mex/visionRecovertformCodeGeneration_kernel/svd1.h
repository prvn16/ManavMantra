/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * svd1.h
 *
 * Code generation for function 'svd1'
 *
 */

#ifndef SVD1_H
#define SVD1_H

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
extern void svd(const emlrtStack *sp, const emxArray_real32_T *A,
                emxArray_real32_T *U, real32_T s_data[], int32_T s_size[1],
                real32_T V[25]);

#endif

/* End of code generation (svd1.h) */

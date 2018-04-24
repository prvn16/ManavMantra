/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * imwarp.h
 *
 * Code generation for function 'imwarp'
 *
 */

#ifndef IMWARP_H
#define IMWARP_H

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
extern void imwarp(const emlrtStack *sp, const emxArray_uint8_T *varargin_1,
                   const real32_T varargin_2_T_data[], const int32_T
                   varargin_2_T_size[2], const real_T varargin_4_ImageSizeAlias
                   [2], emxArray_uint8_T *outputImage);

#endif

/* End of code generation (imwarp.h) */

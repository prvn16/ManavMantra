/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * insertText.h
 *
 * Code generation for function 'insertText'
 *
 */

#ifndef INSERTTEXT_H
#define INSERTTEXT_H

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
extern void insertText(const emlrtStack *sp, const uint8_T I[1108698], const
  int32_T position_data[], const int32_T position_size[2], const real32_T
  text_data[], const int32_T text_size[2], const uint8_T varargin_6_data[],
  const int32_T varargin_6_size[2], const uint8_T varargin_8_data[], const
  int32_T varargin_8_size[2], const int32_T varargin_14_data[], const int32_T
  varargin_14_size[1], const int32_T varargin_16_data[], const int32_T
  varargin_16_size[1], uint8_T RGB[1108698]);

#endif

/* End of code generation (insertText.h) */

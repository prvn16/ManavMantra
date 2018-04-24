/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * insertShape.h
 *
 * Code generation for function 'insertShape'
 *
 */

#ifndef INSERTSHAPE_H
#define INSERTSHAPE_H

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
extern void insertShape(e_depthEstimationFromStereoVide *SD, const emlrtStack
  *sp, const uint8_T I[1108698], const int32_T position_data[], const int32_T
  position_size[2], const uint8_T varargin_4_data[], const int32_T
  varargin_4_size[2], uint8_T RGB[1108698]);

#endif

/* End of code generation (insertShape.h) */

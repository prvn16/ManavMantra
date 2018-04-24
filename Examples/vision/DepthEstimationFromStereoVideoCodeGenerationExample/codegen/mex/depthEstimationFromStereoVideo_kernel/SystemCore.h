/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * SystemCore.h
 *
 * Code generation for function 'SystemCore'
 *
 */

#ifndef SYSTEMCORE_H
#define SYSTEMCORE_H

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
extern void SystemCore_step(const emlrtStack *sp, vision_PeopleDetector *obj,
  const emxArray_uint8_T *varargin_1, emxArray_real_T *varargout_1);
extern void b_SystemCore_step(const emlrtStack *sp, visioncodegen_ShapeInserter *
  obj, const uint8_T varargin_1[1108698], const int32_T varargin_2_data[], const
  int32_T varargin_2_size[2], const uint8_T varargin_3_data[], const int32_T
  varargin_3_size[2], uint8_T varargout_1[1108698]);

#endif

/* End of code generation (SystemCore.h) */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * matlabCodegenHandle.h
 *
 * Code generation for function 'matlabCodegenHandle'
 *
 */

#ifndef MATLABCODEGENHANDLE_H
#define MATLABCODEGENHANDLE_H

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
extern void c_matlabCodegenHandle_matlabCod(const emlrtStack *sp,
  c_visioncodegen_DeployableVideo *obj);
extern void d_matlabCodegenHandle_matlabCod(const emlrtStack *sp,
  vision_PeopleDetector *obj);

#endif

/* End of code generation (matlabCodegenHandle.h) */

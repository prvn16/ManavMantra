/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * CameraParametersImpl.h
 *
 * Code generation for function 'CameraParametersImpl'
 *
 */

#ifndef CAMERAPARAMETERSIMPL_H
#define CAMERAPARAMETERSIMPL_H

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
extern void c_CameraParametersImpl_CameraPa(const emlrtStack *sp,
  c_vision_internal_calibration_C **this, const real_T
  varargin_1_RadialDistortion[2], const real_T varargin_1_TangentialDistortion[2],
  const char_T varargin_1_WorldUnits[2], real_T c_varargin_1_NumRadialDistortio,
  const real_T varargin_1_RotationVectors[36], const real_T
  varargin_1_TranslationVectors[36], const real_T varargin_1_IntrinsicMatrix[9]);
extern void c_CameraParametersImpl_computeU(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_C *this, real_T
  xBounds[2], real_T yBounds[2]);
extern void d_CameraParametersImpl_computeU(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_C *this, real_T
  xBounds[2], real_T yBounds[2]);

#endif

/* End of code generation (CameraParametersImpl.h) */

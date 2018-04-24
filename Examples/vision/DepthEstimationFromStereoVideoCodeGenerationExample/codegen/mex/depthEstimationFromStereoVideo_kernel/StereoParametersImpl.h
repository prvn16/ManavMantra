/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * StereoParametersImpl.h
 *
 * Code generation for function 'StereoParametersImpl'
 *
 */

#ifndef STEREOPARAMETERSIMPL_H
#define STEREOPARAMETERSIMPL_H

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
extern c_vision_internal_calibration_S *c_StereoParametersImpl_StereoPa(const
  emlrtStack *sp, c_vision_internal_calibration_S *this, const real_T
  c_varargin_1_CameraParameters1_[2], const real_T
  d_varargin_1_CameraParameters1_[2], const char_T
  e_varargin_1_CameraParameters1_[2], real_T f_varargin_1_CameraParameters1_,
  const real_T g_varargin_1_CameraParameters1_[36], const real_T
  h_varargin_1_CameraParameters1_[36], const real_T
  i_varargin_1_CameraParameters1_[9], const real_T
  c_varargin_1_CameraParameters2_[2], const real_T
  d_varargin_1_CameraParameters2_[2], const char_T
  e_varargin_1_CameraParameters2_[2], real_T f_varargin_1_CameraParameters2_,
  const real_T g_varargin_1_CameraParameters2_[36], const real_T
  h_varargin_1_CameraParameters2_[36], const real_T
  i_varargin_1_CameraParameters2_[9], const real_T varargin_1_RotationOfCamera2
  [9], const real_T varargin_1_TranslationOfCamera2[3], const struct3_T
  *varargin_1_RectificationParams, c_vision_internal_calibration_C *iobj_0,
  c_vision_internal_calibration_C *iobj_1);
extern void c_StereoParametersImpl_computeH(const emlrtStack *sp, const
  c_vision_internal_calibration_S *this, real_T Rl[9], real_T Rr[9]);
extern void c_StereoParametersImpl_computeN(const
  c_vision_internal_calibration_S *this, real_T K_new[9]);
extern void c_StereoParametersImpl_computeO(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_S *this, const
  real_T Hleft_T[9], const real_T Hright_T[9], real_T xBounds[2], real_T
  yBounds[2], boolean_T *success);
extern void c_StereoParametersImpl_computeR(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_S *this, real_T
  Hleft_T[9], real_T Hright_T[9], real_T Q[16], real_T xBounds[2], real_T
  yBounds[2], boolean_T *success);
extern void c_StereoParametersImpl_reconstr(const emlrtStack *sp, const
  c_vision_internal_calibration_S *this, const emxArray_real32_T *disparityMap,
  emxArray_real32_T *points3D);
extern void computeRowAlignmentRotation(const emlrtStack *sp, const real_T t[3],
  real_T RrowAlign[9]);

#endif

/* End of code generation (StereoParametersImpl.h) */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * ImageTransformer.h
 *
 * Code generation for function 'ImageTransformer'
 *
 */

#ifndef IMAGETRANSFORMER_H
#define IMAGETRANSFORMER_H

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
extern void ImageTransformer_computeMap(const emlrtStack *sp,
  c_vision_internal_calibration_I *this, const real_T intrinsicMatrix[9], const
  real_T radialDist[2], const real_T tangentialDist[2]);
extern boolean_T ImageTransformer_needToUpdate(const emlrtStack *sp, const
  c_vision_internal_calibration_I *this);
extern void ImageTransformer_transformImage(e_depthEstimationFromStereoVide *SD,
  const emlrtStack *sp, const c_vision_internal_calibration_I *this,
  emxArray_uint8_T *J);
extern void b_ImageTransformer_computeMap(const emlrtStack *sp,
  c_vision_internal_calibration_I *this, const real_T intrinsicMatrix[9], const
  real_T radialDist[2], const real_T tangentialDist[2], const real_T H_T[9]);
extern void b_ImageTransformer_transformIma(const emlrtStack *sp, const
  c_vision_internal_calibration_I *this, const uint8_T I[921600],
  emxArray_uint8_T *J);
extern c_vision_internal_calibration_I *c_ImageTransformer_ImageTransfo(const
  emlrtStack *sp, c_vision_internal_calibration_I *this);

#endif

/* End of code generation (ImageTransformer.h) */

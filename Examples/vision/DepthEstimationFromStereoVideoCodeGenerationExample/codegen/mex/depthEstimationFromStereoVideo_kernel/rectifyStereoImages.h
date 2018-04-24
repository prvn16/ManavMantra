/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * rectifyStereoImages.h
 *
 * Code generation for function 'rectifyStereoImages'
 *
 */

#ifndef RECTIFYSTEREOIMAGES_H
#define RECTIFYSTEREOIMAGES_H

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
extern void rectifyStereoImages(e_depthEstimationFromStereoVide *SD, const
  emlrtStack *sp, const uint8_T I1[921600], const uint8_T I2[921600],
  c_vision_internal_calibration_S *stereoParams, emxArray_uint8_T
  *rectifiedImage1, emxArray_uint8_T *rectifiedImage2);

#endif

/* End of code generation (rectifyStereoImages.h) */

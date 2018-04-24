/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * insertObjectAnnotation.h
 *
 * Code generation for function 'insertObjectAnnotation'
 *
 */

#ifndef INSERTOBJECTANNOTATION_H
#define INSERTOBJECTANNOTATION_H

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
extern void getTextLocAndWidth(const emlrtStack *sp, const int32_T
  position_data[], const int32_T position_size[2], int32_T textLocAndWidth_data[],
  int32_T textLocAndWidth_size[2]);
extern void validateAndParseInputs(const emlrtStack *sp, const real_T
  position_data[], const int32_T position_size[2], const real32_T label_data[],
  const int32_T label_size[2], int32_T b_position_data[], int32_T
  b_position_size[2], uint8_T color_data[], int32_T color_size[2], uint8_T
  textColor_data[], int32_T textColor_size[2], boolean_T *isEmpty);

#endif

/* End of code generation (insertObjectAnnotation.h) */

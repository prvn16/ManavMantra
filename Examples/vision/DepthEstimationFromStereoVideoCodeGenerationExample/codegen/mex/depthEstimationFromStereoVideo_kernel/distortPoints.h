/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * distortPoints.h
 *
 * Code generation for function 'distortPoints'
 *
 */

#ifndef DISTORTPOINTS_H
#define DISTORTPOINTS_H

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
extern void b_distortPoints(const emlrtStack *sp, const emxArray_real_T *points,
  const real_T intrinsicMatrix[9], const real_T radialDistortion[2], const
  real_T tangentialDistortion[2], emxArray_real_T *distortedPoints);
extern void distortPoints(e_depthEstimationFromStereoVide *SD, const real_T
  points[614400], const real_T intrinsicMatrix[9], const real_T
  radialDistortion[2], const real_T tangentialDistortion[2], real_T
  distortedPoints[614400]);

#endif

/* End of code generation (distortPoints.h) */

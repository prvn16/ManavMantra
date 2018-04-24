/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: harrisMinEigen.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef HARRISMINEIGEN_H
#define HARRISMINEIGEN_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern void computeMetric(const emxArray_real32_T *metric, const
  emxArray_real32_T *loc, emxArray_real32_T *values);
extern void cornerMetric(const emxArray_real32_T *I, emxArray_real32_T *metric);
extern void parseInputs(const double varargin_2_data[], float *params_MinQuality,
  double *params_FilterSize, boolean_T *params_usingROI, int params_ROI_data[],
  int params_ROI_size[2]);
extern void subPixelLocation(const emxArray_real32_T *metric, emxArray_real32_T *
  loc);

#endif

/*
 * File trailer for harrisMinEigen.h
 *
 * [EOF]
 */

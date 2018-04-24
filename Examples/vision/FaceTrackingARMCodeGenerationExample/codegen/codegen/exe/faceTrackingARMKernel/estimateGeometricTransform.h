/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: estimateGeometricTransform.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef ESTIMATEGEOMETRICTRANSFORM_H
#define ESTIMATEGEOMETRICTRANSFORM_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern boolean_T checkTForm(const float tform_data[], const int tform_size[2]);
extern void computeSimilarity(const emxArray_real32_T *points, float T[9]);
extern void estimateGeometricTransform(const emxArray_real32_T *matchedPoints1,
  const emxArray_real32_T *matchedPoints2, float tform_T_data[], int
  tform_T_size[2], emxArray_real32_T *inlierPoints1, emxArray_real32_T
  *inlierPoints2);
extern void evaluateTForm(const float tform[9], const emxArray_real32_T *points,
  emxArray_real32_T *dis);

#endif

/*
 * File trailer for estimateGeometricTransform.h
 *
 * [EOF]
 */

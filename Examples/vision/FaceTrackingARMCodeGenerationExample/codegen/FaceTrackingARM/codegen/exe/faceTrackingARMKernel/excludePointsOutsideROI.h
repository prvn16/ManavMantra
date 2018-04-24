/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: excludePointsOutsideROI.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef EXCLUDEPOINTSOUTSIDEROI_H
#define EXCLUDEPOINTSOUTSIDEROI_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern void excludePointsOutsideROI(const int originalROI_data[], const int
  expandedROI_data[], const emxArray_real32_T *locInExpandedROI, const
  emxArray_real32_T *metric, emxArray_real32_T *validLocation, emxArray_real32_T
  *validMetric);

#endif

/*
 * File trailer for excludePointsOutsideROI.h
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: PointTracker.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

#ifndef POINTTRACKER_H
#define POINTTRACKER_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "FaceTrackingKLTpackNGo_kernel_types.h"

/* Function Declarations */
extern void PointTracker_getKLTParams(const vision_PointTracker *obj, double
  kltParams_BlockSize[2], double *kltParams_NumPyramidLevels, double
  *kltParams_MaxIterations, double *kltParams_Epsilon, double
  *kltParams_MaxBidirectionalError);

#endif

/*
 * File trailer for PointTracker.h
 *
 * [EOF]
 */

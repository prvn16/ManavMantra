/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: PointTracker.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef POINTTRACKER_H
#define POINTTRACKER_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern vision_PointTracker *PointTracker_PointTracker(vision_PointTracker *obj);
extern void PointTracker_initialize(vision_PointTracker *obj, const unsigned
  char I[34240]);
extern void PointTracker_normalizeScores(const emxArray_real_T *scores, const
  emxArray_boolean_T *validity, emxArray_real_T *b_scores);
extern void PointTracker_pointsOutsideImage(const vision_PointTracker *obj,
  const emxArray_real32_T *points, emxArray_boolean_T *inds);
extern void b_PointTracker_initialize(vision_PointTracker *obj, const
  emxArray_real32_T *points, const unsigned char I[34240]);

#endif

/*
 * File trailer for PointTracker.h
 *
 * [EOF]
 */

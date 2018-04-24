/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: SystemCore.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef SYSTEMCORE_H
#define SYSTEMCORE_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern void SystemCore_setup(vision_PointTracker *obj);
extern void SystemCore_step(vision_CascadeObjectDetector *obj, const unsigned
  char varargin_1[34240], emxArray_real_T *varargout_1);
extern void b_SystemCore_step(vision_PointTracker *obj, const unsigned char
  varargin_1[34240]);
extern void c_SystemCore_step(visioncodegen_ShapeInserter *obj, const unsigned
  char varargin_1[921600], const int varargin_2_data[], const int
  varargin_2_size[1], unsigned char varargout_1[921600]);

#endif

/*
 * File trailer for SystemCore.h
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertMarker.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef INSERTMARKER_H
#define INSERTMARKER_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern visioncodegen_MarkerInserter *b_getSystemObjects(void);
extern void b_validateAndParseInputs(const emxArray_real32_T *points,
  emxArray_int32_T *position, emxArray_uint8_T *color);
extern void tuneMarkersize(visioncodegen_MarkerInserter *h_MarkerInserter);

#endif

/*
 * File trailer for insertMarker.h
 *
 * [EOF]
 */

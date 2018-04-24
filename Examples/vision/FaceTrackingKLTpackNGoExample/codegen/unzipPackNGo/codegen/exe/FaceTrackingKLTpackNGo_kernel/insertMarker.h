/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertMarker.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

#ifndef INSERTMARKER_H
#define INSERTMARKER_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "FaceTrackingKLTpackNGo_kernel_types.h"

/* Function Declarations */
extern void b_validateAndParseInputs(const float points_data[], const int
  points_size[2], int position_data[], int position_size[2], float color_data[],
  int color_size[2]);
extern visioncodegen_MarkerInserter *c_getSystemObjects(void);
extern void tuneMarkersize(visioncodegen_MarkerInserter *h_MarkerInserter);

#endif

/*
 * File trailer for insertMarker.h
 *
 * [EOF]
 */

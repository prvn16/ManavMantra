/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertShape.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

#ifndef INSERTSHAPE_H
#define INSERTSHAPE_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "FaceTrackingKLTpackNGo_kernel_types.h"

/* Function Declarations */
extern visioncodegen_ShapeInserter_1 *b_getSystemObjects(void);
extern void b_tuneLineWidth(visioncodegen_ShapeInserter_1 *h_ShapeInserter);
extern void insertShape(const float I[921600], const float position_data[],
  const int position_size[2], float RGB[921600]);
extern void removeAdjacentSamePts(const int position[8], int positionOut_data[],
  int positionOut_size[1]);
extern void validateAndParseInputs(const float position[8], int positionOut[8]);

#endif

/*
 * File trailer for insertShape.h
 *
 * [EOF]
 */

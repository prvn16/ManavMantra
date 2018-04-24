/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: insertShape.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef INSERTSHAPE_H
#define INSERTSHAPE_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern visioncodegen_ShapeInserter *getSystemObjects(void);
extern void removeAdjacentSamePts(const int position_data[], const int
  position_size[2], int positionOut_data[], int positionOut_size[1]);
extern void tuneLineWidth(visioncodegen_ShapeInserter *h_ShapeInserter);
extern void validateAndParseInputs(const double position_data[], const int
  position_size[2], int positionOut_data[], int positionOut_size[2]);

#endif

/*
 * File trailer for insertShape.h
 *
 * [EOF]
 */

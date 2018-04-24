/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: expandROI.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef EXPANDROI_H
#define EXPANDROI_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern void expandROI(const int originalROI_data[], const int originalROI_size[2],
                      int expandedROI_data[], int expandedROI_size[2]);

#endif

/*
 * File trailer for expandROI.h
 *
 * [EOF]
 */

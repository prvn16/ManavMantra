/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: msac.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

#ifndef MSAC_H
#define MSAC_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "FaceTrackingKLTpackNGo_kernel_types.h"

/* Function Declarations */
extern void msac(const emxArray_real32_T *allPoints, boolean_T *isFound, float
                 bestModelParams_data[], int bestModelParams_size[2],
                 emxArray_boolean_T *inliers);

#endif

/*
 * File trailer for msac.h
 *
 * [EOF]
 */

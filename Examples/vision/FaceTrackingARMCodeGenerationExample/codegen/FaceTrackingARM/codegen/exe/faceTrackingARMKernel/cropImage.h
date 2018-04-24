/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: cropImage.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef CROPIMAGE_H
#define CROPIMAGE_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern void cropImage(const float I[34240], const int roi_data[],
                      emxArray_real32_T *Iroi);

#endif

/*
 * File trailer for cropImage.h
 *
 * [EOF]
 */

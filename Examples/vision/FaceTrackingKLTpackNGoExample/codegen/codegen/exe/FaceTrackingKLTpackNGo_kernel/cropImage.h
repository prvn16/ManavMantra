/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: cropImage.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

#ifndef CROPIMAGE_H
#define CROPIMAGE_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "FaceTrackingKLTpackNGo_kernel_types.h"

/* Function Declarations */
extern void cropImage(const float I[307200], const int roi_data[], const int
                      roi_size[2], emxArray_real32_T *Iroi);

#endif

/*
 * File trailer for cropImage.h
 *
 * [EOF]
 */

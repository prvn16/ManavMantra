/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: faceDetectionARMKernel.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

#ifndef FACEDETECTIONARMKERNEL_H
#define FACEDETECTIONARMKERNEL_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceDetectionARMKernel_types.h"

/* Function Declarations */
extern void faceDetectionARMKernel(const unsigned char inRGB[921600], unsigned
  char outRGB[921600]);
extern void faceDetectionARMKernel_free(void);
extern void faceDetectionARMKernel_init(void);

#endif

/*
 * File trailer for faceDetectionARMKernel.h
 *
 * [EOF]
 */

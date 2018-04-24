/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: faceTrackingARMKernel.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef FACETRACKINGARMKERNEL_H
#define FACETRACKINGARMKERNEL_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern void faceTrackingARMKernel(const unsigned char videoFrame[921600],
  unsigned char videoFrameOut[921600]);
extern void faceTrackingARMKernel_free(void);
extern void faceTrackingARMKernel_init(void);

#endif

/*
 * File trailer for faceTrackingARMKernel.h
 *
 * [EOF]
 */

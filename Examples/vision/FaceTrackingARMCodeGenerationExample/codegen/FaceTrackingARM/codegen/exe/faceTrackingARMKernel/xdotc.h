/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xdotc.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef XDOTC_H
#define XDOTC_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern float b_xdotc(int n, const emxArray_real32_T *x, int ix0, const
                     emxArray_real32_T *y, int iy0);
extern float c_xdotc(int n, const float x[25], int ix0, const float y[25], int
                     iy0);
extern float xdotc(int n, const emxArray_real32_T *x, int ix0, const
                   emxArray_real32_T *y, int iy0);

#endif

/*
 * File trailer for xdotc.h
 *
 * [EOF]
 */

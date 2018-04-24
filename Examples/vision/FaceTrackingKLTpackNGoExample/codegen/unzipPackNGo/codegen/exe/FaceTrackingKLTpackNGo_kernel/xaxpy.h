/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xaxpy.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

#ifndef XAXPY_H
#define XAXPY_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "FaceTrackingKLTpackNGo_kernel_types.h"

/* Function Declarations */
extern void b_xaxpy(int n, float a, const emxArray_real32_T *x, int ix0,
                    emxArray_real32_T *y, int iy0);
extern void c_xaxpy(int n, float a, const emxArray_real32_T *x, int ix0,
                    emxArray_real32_T *y, int iy0);
extern void d_xaxpy(int n, float a, int ix0, emxArray_real32_T *y, int iy0);
extern void e_xaxpy(int n, float a, int ix0, float y[25], int iy0);
extern void xaxpy(int n, float a, int ix0, emxArray_real32_T *y, int iy0);

#endif

/*
 * File trailer for xaxpy.h
 *
 * [EOF]
 */

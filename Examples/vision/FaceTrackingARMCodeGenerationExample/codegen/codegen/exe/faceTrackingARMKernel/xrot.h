/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xrot.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef XROT_H
#define XROT_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern void b_xrot(int n, emxArray_real32_T *x, int ix0, int iy0, float c, float
                   s);
extern void xrot(float x[25], int ix0, int iy0, float c, float s);

#endif

/*
 * File trailer for xrot.h
 *
 * [EOF]
 */

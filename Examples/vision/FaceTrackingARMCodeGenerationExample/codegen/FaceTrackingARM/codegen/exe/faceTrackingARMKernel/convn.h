/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: convn.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

#ifndef CONVN_H
#define CONVN_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceTrackingARMKernel_types.h"

/* Function Declarations */
extern void b_convn(const emxArray_real_T *A, emxArray_real_T *C);
extern void c_convn(const emxArray_real_T *A, emxArray_real_T *C);
extern void convn(const emxArray_real_T *A, emxArray_real_T *C);

#endif

/*
 * File trailer for convn.h
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: faceDetectionARMKernel_emxutil.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

#ifndef FACEDETECTIONARMKERNEL_EMXUTIL_H
#define FACEDETECTIONARMKERNEL_EMXUTIL_H

/* Include Files */
#include <stddef.h>
#include <stdlib.h>
#include "rtwtypes.h"
#include "faceDetectionARMKernel_types.h"

/* Function Declarations */
extern void emxEnsureCapacity_int32_T(emxArray_int32_T *emxArray, int oldNumel);
extern void emxFree_int32_T(emxArray_int32_T **pEmxArray);
extern void emxInit_int32_T(emxArray_int32_T **pEmxArray, int numDimensions);

#endif

/*
 * File trailer for faceDetectionARMKernel_emxutil.h
 *
 * [EOF]
 */

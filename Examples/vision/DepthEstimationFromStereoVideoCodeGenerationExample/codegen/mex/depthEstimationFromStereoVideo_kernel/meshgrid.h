/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * meshgrid.h
 *
 * Code generation for function 'meshgrid'
 *
 */

#ifndef MESHGRID_H
#define MESHGRID_H

/* Include files */
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include "rtwtypes.h"
#include "depthEstimationFromStereoVideo_kernel_types.h"

/* Function Declarations */
extern void b_meshgrid(const emlrtStack *sp, const emxArray_real_T *x, const
  emxArray_real_T *y, emxArray_real_T *xx, emxArray_real_T *yy);
extern void c_meshgrid(const emlrtStack *sp, const emxArray_real32_T *x, const
  emxArray_real32_T *y, emxArray_real32_T *xx, emxArray_real32_T *yy);
extern void meshgrid(const real_T x[640], const real_T y[480], real_T xx[307200],
                     real_T yy[307200]);

#endif

/* End of code generation (meshgrid.h) */

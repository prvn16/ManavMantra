/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_use_shape_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 25-Apr-2018 11:54:23
 */

#ifndef _CODER_USE_SHAPE_API_H
#define _CODER_USE_SHAPE_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_use_shape_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void use_shape(real_T *TotalArea, real_T *Distance);
extern void use_shape_api(int32_T nlhs, const mxArray *plhs[2]);
extern void use_shape_atexit(void);
extern void use_shape_initialize(void);
extern void use_shape_terminate(void);
extern void use_shape_xil_terminate(void);

#endif

/*
 * File trailer for _coder_use_shape_api.h
 *
 * [EOF]
 */

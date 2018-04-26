/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_kalman02_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 26-Apr-2018 11:06:36
 */

#ifndef _CODER_KALMAN02_API_H
#define _CODER_KALMAN02_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_kalman02_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void kalman02(real_T z[2], real_T y[2]);
extern void kalman02_api(const mxArray * const prhs[1], int32_T nlhs, const
  mxArray *plhs[1]);
extern void kalman02_atexit(void);
extern void kalman02_initialize(void);
extern void kalman02_terminate(void);
extern void kalman02_xil_terminate(void);

#endif

/*
 * File trailer for _coder_kalman02_api.h
 *
 * [EOF]
 */

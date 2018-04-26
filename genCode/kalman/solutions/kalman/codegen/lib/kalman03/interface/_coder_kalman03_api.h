/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_kalman03_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 26-Apr-2018 11:07:25
 */

#ifndef _CODER_KALMAN03_API_H
#define _CODER_KALMAN03_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_kalman03_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void kalman03(real_T z_data[], int32_T z_size[2], real_T y_data[],
                     int32_T y_size[2]);
extern void kalman03_api(const mxArray * const prhs[1], int32_T nlhs, const
  mxArray *plhs[1]);
extern void kalman03_atexit(void);
extern void kalman03_initialize(void);
extern void kalman03_terminate(void);
extern void kalman03_xil_terminate(void);

#endif

/*
 * File trailer for _coder_kalman03_api.h
 *
 * [EOF]
 */

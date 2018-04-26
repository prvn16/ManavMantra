/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_coderand_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 26-Apr-2018 10:39:55
 */

#ifndef _CODER_CODERAND_API_H
#define _CODER_CODERAND_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_coderand_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern real_T coderand(void);
extern void coderand_api(int32_T nlhs, const mxArray *plhs[1]);
extern void coderand_atexit(void);
extern void coderand_initialize(void);
extern void coderand_terminate(void);
extern void coderand_xil_terminate(void);

#endif

/*
 * File trailer for _coder_coderand_api.h
 *
 * [EOF]
 */

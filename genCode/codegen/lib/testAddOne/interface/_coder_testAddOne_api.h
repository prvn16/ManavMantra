/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_testAddOne_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 25-Apr-2018 12:35:20
 */

#ifndef _CODER_TESTADDONE_API_H
#define _CODER_TESTADDONE_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_testAddOne_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern real_T testAddOne(real_T x);
extern void testAddOne_api(const mxArray * const prhs[1], int32_T nlhs, const
  mxArray *plhs[1]);
extern void testAddOne_atexit(void);
extern void testAddOne_initialize(void);
extern void testAddOne_terminate(void);
extern void testAddOne_xil_terminate(void);

#endif

/*
 * File trailer for _coder_testAddOne_api.h
 *
 * [EOF]
 */

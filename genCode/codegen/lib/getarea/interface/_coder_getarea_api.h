/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_getarea_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 25-Apr-2018 12:55:30
 */

#ifndef _CODER_GETAREA_API_H
#define _CODER_GETAREA_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_getarea_api.h"

/* Type Definitions */
#ifndef typedef_myRectangle
#define typedef_myRectangle

typedef struct {
  real_T length;
  real_T width;
} myRectangle;

#endif                                 /*typedef_myRectangle*/

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern real_T getarea(myRectangle r);
extern void getarea_api(const mxArray * const prhs[1], int32_T nlhs, const
  mxArray *plhs[1]);
extern void getarea_atexit(void);
extern void getarea_initialize(void);
extern void getarea_terminate(void);
extern void getarea_xil_terminate(void);

#endif

/*
 * File trailer for _coder_getarea_api.h
 *
 * [EOF]
 */

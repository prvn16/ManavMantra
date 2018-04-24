/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_faceDetectionARMKernel_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:21:46
 */

#ifndef _CODER_FACEDETECTIONARMKERNEL_API_H
#define _CODER_FACEDETECTIONARMKERNEL_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_faceDetectionARMKernel_api.h"

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern void faceDetectionARMKernel(uint8_T inRGB[921600], uint8_T outRGB[921600]);
extern void faceDetectionARMKernel_api(const mxArray * const prhs[1], int32_T
  nlhs, const mxArray *plhs[1]);
extern void faceDetectionARMKernel_atexit(void);
extern void faceDetectionARMKernel_initialize(void);
extern void faceDetectionARMKernel_terminate(void);
extern void faceDetectionARMKernel_xil_terminate(void);

#endif

/*
 * File trailer for _coder_faceDetectionARMKernel_api.h
 *
 * [EOF]
 */

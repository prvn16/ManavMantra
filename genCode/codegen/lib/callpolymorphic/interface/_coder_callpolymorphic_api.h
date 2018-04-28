/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_callpolymorphic_api.h
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 27-Apr-2018 21:18:23
 */

#ifndef _CODER_CALLPOLYMORPHIC_API_H
#define _CODER_CALLPOLYMORPHIC_API_H

/* Include Files */
#include "tmwtypes.h"
#include "mex.h"
#include "emlrt.h"
#include <stddef.h>
#include <stdlib.h>
#include "_coder_callpolymorphic_api.h"

/* Type Definitions */
#ifndef typedef_MakePolymorphic
#define typedef_MakePolymorphic

typedef struct {
  real_T Property1;
  char_T fn[2];
  char_T gentype[3];
  int16_T u[10];
} MakePolymorphic;

#endif                                 /*typedef_MakePolymorphic*/

/* Variable Declarations */
extern emlrtCTX emlrtRootTLSGlobal;
extern emlrtContext emlrtContextGlobal;

/* Function Declarations */
extern int32_T callpolymorphic(MakePolymorphic mp);
extern void callpolymorphic_api(const mxArray * const prhs[1], int32_T nlhs,
  const mxArray *plhs[1]);
extern void callpolymorphic_atexit(void);
extern void callpolymorphic_initialize(void);
extern void callpolymorphic_terminate(void);
extern void callpolymorphic_xil_terminate(void);

#endif

/*
 * File trailer for _coder_callpolymorphic_api.h
 *
 * [EOF]
 */

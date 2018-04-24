/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_FaceTrackingKLTpackNGo_kernel_api.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "tmwtypes.h"
#include "_coder_FaceTrackingKLTpackNGo_kernel_api.h"
#include "_coder_FaceTrackingKLTpackNGo_kernel_mex.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;
emlrtContext emlrtContextGlobal = { true,/* bFirstTime */
  false,                               /* bInitialized */
  131466U,                             /* fVersionInfo */
  NULL,                                /* fErrorFunction */
  "FaceTrackingKLTpackNGo_kernel",     /* fFunctionName */
  NULL,                                /* fRTCallStack */
  false,                               /* bDebugMode */
  { 2045744189U, 2170104910U, 2743257031U, 4284093946U },/* fSigWrd */
  NULL                                 /* fSigMem */
};

/* Function Definitions */

/*
 * Arguments    : int32_T nlhs
 * Return Type  : void
 */
void FaceTrackingKLTpackNGo_kernel_api(int32_T nlhs)
{
  (void)nlhs;

  /* Invoke the target function */
  FaceTrackingKLTpackNGo_kernel();
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void FaceTrackingKLTpackNGo_kernel_atexit(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtEnterRtStackR2012b(&st);
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
  FaceTrackingKLTpackNGo_kernel_xil_terminate();
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void FaceTrackingKLTpackNGo_kernel_initialize(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  emlrtFirstTimeR2012b(emlrtRootTLSGlobal);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void FaceTrackingKLTpackNGo_kernel_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/*
 * File trailer for _coder_FaceTrackingKLTpackNGo_kernel_api.c
 *
 * [EOF]
 */

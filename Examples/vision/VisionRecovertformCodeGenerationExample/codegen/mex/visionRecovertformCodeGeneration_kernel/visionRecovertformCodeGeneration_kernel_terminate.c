/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * visionRecovertformCodeGeneration_kernel_terminate.c
 *
 * Code generation for function 'visionRecovertformCodeGeneration_kernel_terminate'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "visionRecovertformCodeGeneration_kernel_terminate.h"
#include "_coder_visionRecovertformCodeGeneration_kernel_mex.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Function Definitions */
void visionRecovertformCodeGeneration_kernel_atexit(void)
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
}

void visionRecovertformCodeGeneration_kernel_terminate(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;
  emlrtLeaveRtStackR2012b(&st);
  emlrtDestroyRootTLS(&emlrtRootTLSGlobal);
}

/* End of code generation (visionRecovertformCodeGeneration_kernel_terminate.c) */

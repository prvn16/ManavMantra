/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_visionRecovertformCodeGeneration_kernel_mex.c
 *
 * Code generation for function '_coder_visionRecovertformCodeGeneration_kernel_mex'
 *
 */

/* Include files */
#include "visionRecovertformCodeGeneration_kernel.h"
#include "_coder_visionRecovertformCodeGeneration_kernel_mex.h"
#include "visionRecovertformCodeGeneration_kernel_terminate.h"
#include "_coder_visionRecovertformCodeGeneration_kernel_api.h"
#include "visionRecovertformCodeGeneration_kernel_initialize.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Function Declarations */
static void d_visionRecovertformCodeGenerat(int32_T nlhs, mxArray *plhs[5],
  int32_T nrhs, const mxArray *prhs[2]);

/* Function Definitions */
static void d_visionRecovertformCodeGenerat(int32_T nlhs, mxArray *plhs[5],
  int32_T nrhs, const mxArray *prhs[2])
{
  const mxArray *outputs[5];
  int32_T b_nlhs;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 2, 4,
                        39, "visionRecovertformCodeGeneration_kernel");
  }

  if (nlhs > 5) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 39,
                        "visionRecovertformCodeGeneration_kernel");
  }

  /* Call the function. */
  visionRecovertformCodeGeneration_kernel_api(prhs, nlhs, outputs);

  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }

  emlrtReturnArrays(b_nlhs, plhs, outputs);

  /* Module termination. */
  visionRecovertformCodeGeneration_kernel_terminate();
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  mexAtExit(visionRecovertformCodeGeneration_kernel_atexit);

  /* Initialize the memory manager. */
  /* Module initialization. */
  visionRecovertformCodeGeneration_kernel_initialize();

  /* Dispatch the entry-point. */
  d_visionRecovertformCodeGenerat(nlhs, plhs, nrhs, prhs);
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_visionRecovertformCodeGeneration_kernel_mex.c) */

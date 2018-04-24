/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_depthEstimationFromStereoVideo_kernel_mex.c
 *
 * Code generation for function '_coder_depthEstimationFromStereoVideo_kernel_mex'
 *
 */

/* Include files */
#include "depthEstimationFromStereoVideo_kernel.h"
#include "_coder_depthEstimationFromStereoVideo_kernel_mex.h"
#include "depthEstimationFromStereoVideo_kernel_terminate.h"
#include "matlabCodegenHandle.h"
#include "_coder_depthEstimationFromStereoVideo_kernel_api.h"
#include "depthEstimationFromStereoVideo_kernel_initialize.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void d_depthEstimationFromStereoVide(e_depthEstimationFromStereoVide *SD,
  int32_T nlhs, int32_T nrhs, const mxArray *prhs[1]);

/* Function Definitions */
static void d_depthEstimationFromStereoVide(e_depthEstimationFromStereoVide *SD,
  int32_T nlhs, int32_T nrhs, const mxArray *prhs[1])
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 1) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 1, 4,
                        37, "depthEstimationFromStereoVideo_kernel");
  }

  if (nlhs > 0) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 37,
                        "depthEstimationFromStereoVideo_kernel");
  }

  /* Call the function. */
  depthEstimationFromStereoVideo_kernel_api(SD, prhs, nlhs);

  /* Module termination. */
  depthEstimationFromStereoVideo_kernel_terminate();
}

void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  e_depthEstimationFromStereoVide *f_depthEstimationFromStereoVide = NULL;
  (void)plhs;
  f_depthEstimationFromStereoVide = (e_depthEstimationFromStereoVide *)
    emlrtMxCalloc(1, 1U * sizeof(e_depthEstimationFromStereoVide));
  mexAtExit(depthEstimationFromStereoVideo_kernel_atexit);

  /* Initialize the memory manager. */
  /* Module initialization. */
  depthEstimationFromStereoVideo_kernel_initialize();

  /* Dispatch the entry-point. */
  d_depthEstimationFromStereoVide(f_depthEstimationFromStereoVide, nlhs, nrhs,
    prhs);
  emlrtMxFree(f_depthEstimationFromStereoVide);
}

emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/* End of code generation (_coder_depthEstimationFromStereoVideo_kernel_mex.c) */

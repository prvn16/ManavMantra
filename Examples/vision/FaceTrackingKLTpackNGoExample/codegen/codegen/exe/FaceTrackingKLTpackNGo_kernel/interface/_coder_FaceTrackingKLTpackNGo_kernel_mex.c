/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_FaceTrackingKLTpackNGo_kernel_mex.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "_coder_FaceTrackingKLTpackNGo_kernel_api.h"
#include "_coder_FaceTrackingKLTpackNGo_kernel_mex.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void c_FaceTrackingKLTpackNGo_kernel(int32_T nlhs, int32_T nrhs);

/* Function Definitions */

/*
 * Arguments    : int32_T nlhs
 *                int32_T nrhs
 * Return Type  : void
 */
static void c_FaceTrackingKLTpackNGo_kernel(int32_T nlhs, int32_T nrhs)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 0) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 0, 4,
                        29, "FaceTrackingKLTpackNGo_kernel");
  }

  if (nlhs > 0) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 29,
                        "FaceTrackingKLTpackNGo_kernel");
  }

  /* Call the function. */
  FaceTrackingKLTpackNGo_kernel_api(nlhs);

  /* Module termination. */
  FaceTrackingKLTpackNGo_kernel_terminate();
}

/*
 * Arguments    : int32_T nlhs
 *                mxArray * const plhs[]
 *                int32_T nrhs
 *                const mxArray * const prhs[]
 * Return Type  : void
 */
void mexFunction(int32_T nlhs, mxArray *plhs[], int32_T nrhs, const mxArray
                 *prhs[])
{
  (void)plhs;
  (void)prhs;
  mexAtExit(FaceTrackingKLTpackNGo_kernel_atexit);

  /* Initialize the memory manager. */
  /* Module initialization. */
  FaceTrackingKLTpackNGo_kernel_initialize();

  /* Dispatch the entry-point. */
  c_FaceTrackingKLTpackNGo_kernel(nlhs, nrhs);
}

/*
 * Arguments    : void
 * Return Type  : emlrtCTX
 */
emlrtCTX mexFunctionCreateRootTLS(void)
{
  emlrtCreateRootTLS(&emlrtRootTLSGlobal, &emlrtContextGlobal, NULL, 1);
  return emlrtRootTLSGlobal;
}

/*
 * File trailer for _coder_FaceTrackingKLTpackNGo_kernel_mex.c
 *
 * [EOF]
 */

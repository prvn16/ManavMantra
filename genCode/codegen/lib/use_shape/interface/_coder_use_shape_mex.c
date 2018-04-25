/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_use_shape_mex.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 25-Apr-2018 11:54:23
 */

/* Include Files */
#include "_coder_use_shape_api.h"
#include "_coder_use_shape_mex.h"

/* Function Declarations */
static void use_shape_mexFunction(int32_T nlhs, mxArray *plhs[2], int32_T nrhs);

/* Function Definitions */

/*
 * Arguments    : int32_T nlhs
 *                mxArray *plhs[2]
 *                int32_T nrhs
 * Return Type  : void
 */
static void use_shape_mexFunction(int32_T nlhs, mxArray *plhs[2], int32_T nrhs)
{
  const mxArray *outputs[2];
  int32_T b_nlhs;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  st.tls = emlrtRootTLSGlobal;

  /* Check for proper number of arguments. */
  if (nrhs != 0) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:WrongNumberOfInputs", 5, 12, 0, 4, 9,
                        "use_shape");
  }

  if (nlhs > 2) {
    emlrtErrMsgIdAndTxt(&st, "EMLRT:runTime:TooManyOutputArguments", 3, 4, 9,
                        "use_shape");
  }

  /* Call the function. */
  use_shape_api(nlhs, outputs);

  /* Copy over outputs to the caller. */
  if (nlhs < 1) {
    b_nlhs = 1;
  } else {
    b_nlhs = nlhs;
  }

  emlrtReturnArrays(b_nlhs, plhs, outputs);

  /* Module termination. */
  use_shape_terminate();
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
  (void)prhs;
  mexAtExit(use_shape_atexit);

  /* Initialize the memory manager. */
  /* Module initialization. */
  use_shape_initialize();

  /* Dispatch the entry-point. */
  use_shape_mexFunction(nlhs, plhs, nrhs);
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
 * File trailer for _coder_use_shape_mex.c
 *
 * [EOF]
 */

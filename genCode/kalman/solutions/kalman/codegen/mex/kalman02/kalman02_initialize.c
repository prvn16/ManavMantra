/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * kalman02_initialize.c
 *
 * Code generation for function 'kalman02_initialize'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "kalman02.h"
#include "kalman02_initialize.h"
#include "_coder_kalman02_mex.h"
#include "kalman02_data.h"

/* Variable Definitions */
static const volatile char_T *emlrtBreakCheckR2012bFlagVar = NULL;

/* Function Declarations */
static void kalman02_once(void);

/* Function Definitions */
static void kalman02_once(void)
{
  kalman02_init();
}

void kalman02_initialize(void)
{
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  mexFunctionCreateRootTLS();
  emlrtBreakCheckR2012bFlagVar = emlrtGetBreakCheckFlagAddressR2012b();
  st.tls = emlrtRootTLSGlobal;
  emlrtClearAllocCountR2012b(&st, false, 0U, 0);
  emlrtEnterRtStackR2012b(&st);
  if (emlrtFirstTimeR2012b(emlrtRootTLSGlobal)) {
    kalman02_once();
  }
}

/* End of code generation (kalman02_initialize.c) */

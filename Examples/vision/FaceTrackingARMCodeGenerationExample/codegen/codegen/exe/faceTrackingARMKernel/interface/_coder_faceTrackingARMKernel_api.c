/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_faceTrackingARMKernel_api.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "tmwtypes.h"
#include "_coder_faceTrackingARMKernel_api.h"
#include "_coder_faceTrackingARMKernel_mex.h"

/* Variable Definitions */
emlrtCTX emlrtRootTLSGlobal = NULL;
emlrtContext emlrtContextGlobal = { true,/* bFirstTime */
  false,                               /* bInitialized */
  131466U,                             /* fVersionInfo */
  NULL,                                /* fErrorFunction */
  "faceTrackingARMKernel",             /* fFunctionName */
  NULL,                                /* fRTCallStack */
  false,                               /* bDebugMode */
  { 2045744189U, 2170104910U, 2743257031U, 4284093946U },/* fSigWrd */
  NULL                                 /* fSigMem */
};

static const int32_T iv0[3] = { 480, 640, 3 };

/* Function Declarations */
static uint8_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId))[921600];
static uint8_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[921600];
static uint8_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray
  *videoFrame, const char_T *identifier))[921600];
static const mxArray *emlrt_marshallOut(const uint8_T u[921600]);

/* Function Definitions */

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *u
 *                const emlrtMsgIdentifier *parentId
 * Return Type  : uint8_T (*)[921600]
 */
static uint8_T (*b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId))[921600]
{
  uint8_T (*y)[921600];
  y = c_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}
/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *src
 *                const emlrtMsgIdentifier *msgId
 * Return Type  : uint8_T (*)[921600]
 */
  static uint8_T (*c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src,
  const emlrtMsgIdentifier *msgId))[921600]
{
  uint8_T (*ret)[921600];
  emlrtCheckBuiltInR2012b(sp, msgId, src, "uint8", false, 3U, iv0);
  ret = (uint8_T (*)[921600])emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

/*
 * Arguments    : const emlrtStack *sp
 *                const mxArray *videoFrame
 *                const char_T *identifier
 * Return Type  : uint8_T (*)[921600]
 */
static uint8_T (*emlrt_marshallIn(const emlrtStack *sp, const mxArray
  *videoFrame, const char_T *identifier))[921600]
{
  uint8_T (*y)[921600];
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(videoFrame), &thisId);
  emlrtDestroyArray(&videoFrame);
  return y;
}
/*
 * Arguments    : const uint8_T u[921600]
 * Return Type  : const mxArray *
 */
  static const mxArray *emlrt_marshallOut(const uint8_T u[921600])
{
  const mxArray *y;
  const mxArray *m0;
  static const int32_T iv1[3] = { 0, 0, 0 };

  y = NULL;
  m0 = emlrtCreateNumericArray(3, iv1, mxUINT8_CLASS, mxREAL);
  emlrtMxSetData((mxArray *)m0, (void *)&u[0]);
  emlrtSetDimensions((mxArray *)m0, iv0, 3);
  emlrtAssign(&y, m0);
  return y;
}

/*
 * Arguments    : const mxArray * const prhs[1]
 *                int32_T nlhs
 *                const mxArray *plhs[1]
 * Return Type  : void
 */
void faceTrackingARMKernel_api(const mxArray * const prhs[1], int32_T nlhs,
  const mxArray *plhs[1])
{
  uint8_T (*videoFrameOut)[921600];
  uint8_T (*videoFrame)[921600];
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  (void)nlhs;
  st.tls = emlrtRootTLSGlobal;
  videoFrameOut = (uint8_T (*)[921600])mxMalloc(sizeof(uint8_T [921600]));

  /* Marshall function inputs */
  videoFrame = emlrt_marshallIn(&st, emlrtAlias(prhs[0]), "videoFrame");

  /* Invoke the target function */
  faceTrackingARMKernel(*videoFrame, *videoFrameOut);

  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(*videoFrameOut);
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void faceTrackingARMKernel_atexit(void)
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
  faceTrackingARMKernel_xil_terminate();
}

/*
 * Arguments    : void
 * Return Type  : void
 */
void faceTrackingARMKernel_initialize(void)
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
void faceTrackingARMKernel_terminate(void)
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
 * File trailer for _coder_faceTrackingARMKernel_api.c
 *
 * [EOF]
 */

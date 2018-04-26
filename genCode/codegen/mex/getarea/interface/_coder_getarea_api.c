/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_getarea_api.c
 *
 * Code generation for function '_coder_getarea_api'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "getarea.h"
#include "_coder_getarea_api.h"
#include "getarea_data.h"

/* Function Declarations */
static myRectangle b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId);
static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId);
static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId);
static myRectangle emlrt_marshallIn(const emlrtStack *sp, const mxArray *r,
  const char_T *identifier);
static const mxArray *emlrt_marshallOut(const real_T u);

/* Function Definitions */
static myRectangle b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u,
  const emlrtMsgIdentifier *parentId)
{
  myRectangle y;
  int32_T i;
  emlrtMsgIdentifier thisId;
  const mxArray *propValues[2];
  const char * propNames[2] = { "length", "width" };

  const char * propClasses[2] = { "myRectangle", "myRectangle" };

  for (i = 0; i < 2; i++) {
    propValues[i] = NULL;
  }

  thisId.fParent = parentId;
  thisId.bParentIsCell = false;
  emlrtCheckMcosClass2017a(sp, parentId, u, "myRectangle");
  emlrtGetAllProperties(sp, u, 0, 2, propNames, propClasses, propValues);
  thisId.fIdentifier = "length";
  y.length = c_emlrt_marshallIn(sp, emlrtAlias(propValues[0]), &thisId);
  thisId.fIdentifier = "width";
  y.width = c_emlrt_marshallIn(sp, emlrtAlias(propValues[1]), &thisId);
  emlrtDestroyArrays(2, (const mxArray **)&propValues);
  emlrtDestroyArray(&u);
  return y;
}

static real_T c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId)
{
  real_T y;
  y = d_emlrt_marshallIn(sp, emlrtAlias(u), parentId);
  emlrtDestroyArray(&u);
  return y;
}

static real_T d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId)
{
  real_T ret;
  static const int32_T dims = 0;
  emlrtCheckBuiltInR2012b(sp, msgId, src, "double", false, 0U, &dims);
  ret = *(real_T *)emlrtMxGetData(src);
  emlrtDestroyArray(&src);
  return ret;
}

static myRectangle emlrt_marshallIn(const emlrtStack *sp, const mxArray *r,
  const char_T *identifier)
{
  myRectangle y;
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  y = b_emlrt_marshallIn(sp, emlrtAlias(r), &thisId);
  emlrtDestroyArray(&r);
  return y;
}

static const mxArray *emlrt_marshallOut(const real_T u)
{
  const mxArray *y;
  const mxArray *m0;
  y = NULL;
  m0 = emlrtCreateDoubleScalar(u);
  emlrtAssign(&y, m0);
  return y;
}

void getarea_api(const mxArray * const prhs[1], int32_T nlhs, const mxArray
                 *plhs[1])
{
  myRectangle r;
  emlrtStack st = { NULL,              /* site */
    NULL,                              /* tls */
    NULL                               /* prev */
  };

  (void)nlhs;
  st.tls = emlrtRootTLSGlobal;

  /* Marshall function inputs */
  r = emlrt_marshallIn(&st, emlrtAliasP(prhs[0]), "r");

  /* Invoke the target function */
  /* Marshall function outputs */
  plhs[0] = emlrt_marshallOut(getarea(r));
}

/* End of code generation (_coder_getarea_api.c) */

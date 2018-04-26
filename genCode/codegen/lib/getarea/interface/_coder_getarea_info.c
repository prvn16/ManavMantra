/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: _coder_getarea_info.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 25-Apr-2018 12:55:30
 */

/* Include Files */
#include "_coder_getarea_info.h"

/* Function Definitions */

/*
 * Arguments    : void
 * Return Type  : const mxArray *
 */
const mxArray *emlrtMexFcnResolvedFunctionsInfo(void)
{
  const mxArray *nameCaptureInfo;
  const char * data[4] = {
    "789c6360f4f465646060e0036210bd828d010c7881b87b43dd0d01089781890115a0cb33e2a06180958105ae0f597e0e944ececf2b49ad2881707232f352fd4a"
    "7393528b809cbcc4dc54b83129f9b99979897925219505a90c45a9c5f93965a9296099b4cc9cd490ccdc549f7c248e47269093eb862405e780a4406ce78cd4e4",
    "ece0d25c86a28c6284737390390c48e19380e47f1080f99f054bf820cba303f4f0415747c83e3602f6118a0f4e060e24de87fd30fb0a709847c87f30f3b971d8"
    "2780269f5b19949a5c9298979e0389dc810adf0d64da0733df87807d30f968e758672bfdd0e2d4a2627defa2cce28cbc4405a78cc492cc447d5fc7101f4727fd",
    "80a2fc2c609014ebfb26e62596018992a244fdf4d43ce7fc94547da4e0d2cb45767f020ef7512f7d1cc8d2d971cd91bee991dee97fe0ecabc0611eb1e94f0c87"
    "7d0268f2862619853901c9213ef941fede1ec569b9eeeea5c1ce08770410b087903b1870f0696d3e0092e465de",
    "" };

  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(data, 1728U, &nameCaptureInfo);
  return nameCaptureInfo;
}

/*
 * Arguments    : void
 * Return Type  : mxArray *
 */
mxArray *emlrtMexFcnProperties(void)
{
  mxArray *xResult;
  mxArray *xEntryPoints;
  const char * fldNames[6] = { "Name", "NumberOfInputs", "NumberOfOutputs",
    "ConstantInputs", "FullPath", "TimeStamp" };

  mxArray *xInputs;
  const char * b_fldNames[4] = { "Version", "ResolvedFunctions", "EntryPoints",
    "CoverageInfo" };

  xEntryPoints = emlrtCreateStructMatrix(1, 1, 6, fldNames);
  xInputs = emlrtCreateLogicalMatrix(1, 1);
  emlrtSetField(xEntryPoints, 0, "Name", emlrtMxCreateString("getarea"));
  emlrtSetField(xEntryPoints, 0, "NumberOfInputs", emlrtMxCreateDoubleScalar(1.0));
  emlrtSetField(xEntryPoints, 0, "NumberOfOutputs", emlrtMxCreateDoubleScalar
                (1.0));
  emlrtSetField(xEntryPoints, 0, "ConstantInputs", xInputs);
  emlrtSetField(xEntryPoints, 0, "FullPath", emlrtMxCreateString(
    "C:\\Users\\Krishna Bhatia\\MATLAB\\Projects\\ManavMantra\\genCode\\getarea.m"));
  emlrtSetField(xEntryPoints, 0, "TimeStamp", emlrtMxCreateDoubleScalar
                (737175.53556712961));
  xResult = emlrtCreateStructMatrix(1, 1, 4, b_fldNames);
  emlrtSetField(xResult, 0, "Version", emlrtMxCreateString(
    "9.4.0.813654 (R2018a)"));
  emlrtSetField(xResult, 0, "ResolvedFunctions", (mxArray *)
                emlrtMexFcnResolvedFunctionsInfo());
  emlrtSetField(xResult, 0, "EntryPoints", xEntryPoints);
  return xResult;
}

/*
 * File trailer for _coder_getarea_info.c
 *
 * [EOF]
 */

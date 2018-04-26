/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * _coder_getarea_info.c
 *
 * Code generation for function '_coder_getarea_info'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "getarea.h"
#include "_coder_getarea_info.h"

/* Function Definitions */
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

const mxArray *emlrtMexFcnResolvedFunctionsInfo(void)
{
  const mxArray *nameCaptureInfo;
  const char * data[4] = {
    "789cc552c14ec240105d0c128dd170f2ec071837269ebc4113c15094403d1913d632d0c5ee2eee1602277fc40ff0e8d19b7e85dfe10778b0580a6be3668d5198"
    "a49dbebe76deccdb41b9d37a0e21b48392782824793bbedeef102acedeafa1af91e573869cc63acacfffd3f9fb59f6058f601c2520a41cce86ec1a640c386130",
    "2fd3118c72c2236f320024418970049d4fa64b43f028035768a04a63c04e346a0ea6d4f4d909c0bf690d1992815ab41bea0069feb4b5f9a791ce9fffc61f9dcf"
    "46d69fec7736bd8245cf761e9b6843436fcfa9dec050cf365f5a7fcba057ccf06cd2043f22bc172687bb2a7f1f7fa997d6772d7a297fe95c39c7f8428154b826",
    "a90a38d92b0724a204d74b9e5b2ae38614fdd81285eb8493517c8b24c13de08ee800d6ec3a607aff6d437f7fb71f2ffdfda7d7d272f771d9fbbf3abdb1a1de4f"
    "f76fd7a057ccf08747c16dd8f03d5734cf6b55d56595cab0e52cfa6858746c7d2003feeffa1f262863a5",
    "" };

  nameCaptureInfo = NULL;
  emlrtNameCaptureMxArrayR2016a(data, 1728U, &nameCaptureInfo);
  return nameCaptureInfo;
}

/* End of code generation (_coder_getarea_info.c) */

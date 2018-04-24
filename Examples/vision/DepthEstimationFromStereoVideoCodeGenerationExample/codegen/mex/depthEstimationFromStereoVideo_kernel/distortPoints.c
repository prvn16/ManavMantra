/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * distortPoints.c
 *
 * Code generation for function 'distortPoints'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "distortPoints.h"
#include "power.h"
#include "bsxfun.h"
#include "matlabCodegenHandle.h"
#include "rdivide.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo th_emlrtRSI = { 22, /* lineNo */
  "distortPoints",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pathName */
};

static emlrtRSInfo uh_emlrtRSI = { 39, /* lineNo */
  "distortPoints",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pathName */
};

static emlrtRSInfo vh_emlrtRSI = { 40, /* lineNo */
  "distortPoints",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pathName */
};

static emlrtRSInfo wh_emlrtRSI = { 43, /* lineNo */
  "distortPoints",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pathName */
};

static emlrtRSInfo xh_emlrtRSI = { 44, /* lineNo */
  "distortPoints",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pathName */
};

static emlrtRSInfo yh_emlrtRSI = { 45, /* lineNo */
  "distortPoints",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pathName */
};

static emlrtRSInfo ai_emlrtRSI = { 53, /* lineNo */
  "distortPoints",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pathName */
};

static emlrtRTEInfo eb_emlrtRTEI = { 15,/* lineNo */
  18,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo fb_emlrtRTEI = { 1,/* lineNo */
  28,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo gb_emlrtRTEI = { 15,/* lineNo */
  1,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo hb_emlrtRTEI = { 18,/* lineNo */
  1,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo ib_emlrtRTEI = { 19,/* lineNo */
  1,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo jb_emlrtRTEI = { 22,/* lineNo */
  1,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo kb_emlrtRTEI = { 23,/* lineNo */
  1,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo lb_emlrtRTEI = { 34,/* lineNo */
  1,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo mb_emlrtRTEI = { 38,/* lineNo */
  1,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtRTEInfo nb_emlrtRTEI = { 39,/* lineNo */
  1,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo f_emlrtECI = { -1,  /* nDims */
  19,                                  /* lineNo */
  10,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo g_emlrtECI = { -1,  /* nDims */
  22,                                  /* lineNo */
  6,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo h_emlrtECI = { -1,  /* nDims */
  24,                                  /* lineNo */
  6,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo i_emlrtECI = { -1,  /* nDims */
  34,                                  /* lineNo */
  9,                                   /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo j_emlrtECI = { -1,  /* nDims */
  38,                                  /* lineNo */
  13,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo k_emlrtECI = { -1,  /* nDims */
  39,                                  /* lineNo */
  47,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo l_emlrtECI = { -1,  /* nDims */
  39,                                  /* lineNo */
  16,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo m_emlrtECI = { -1,  /* nDims */
  40,                                  /* lineNo */
  24,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo n_emlrtECI = { -1,  /* nDims */
  40,                                  /* lineNo */
  16,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo o_emlrtECI = { 2,   /* nDims */
  44,                                  /* lineNo */
  48,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo p_emlrtECI = { 2,   /* nDims */
  44,                                  /* lineNo */
  29,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

static emlrtECInfo q_emlrtECI = { -1,  /* nDims */
  48,                                  /* lineNo */
  20,                                  /* colNo */
  "distortPoints",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\distortPoints.m"/* pName */
};

/* Function Definitions */
void b_distortPoints(const emlrtStack *sp, const emxArray_real_T *points, const
                     real_T intrinsicMatrix[9], const real_T radialDistortion[2],
                     const real_T tangentialDistortion[2], emxArray_real_T
                     *distortedPoints)
{
  emxArray_real_T *centeredPoints;
  real_T center[2];
  int32_T csz_idx_0;
  int32_T acoef;
  emxArray_real_T *r2;
  int32_T szc;
  int32_T k;
  emxArray_real_T *yNorm;
  emxArray_real_T *dxTangential;
  emxArray_real_T *xNorm;
  emxArray_real_T *r4;
  real_T b_k[3];
  emxArray_real_T *alpha;
  emxArray_real_T *xyProduct;
  real_T a;
  boolean_T b1;
  emxArray_real_T *r17;
  int32_T b_centeredPoints[2];
  int32_T iv11[2];
  emxArray_real_T *r18;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T(sp, &centeredPoints, 2, &gb_emlrtRTEI, true);
  center[0] = intrinsicMatrix[2];
  center[1] = intrinsicMatrix[5];
  csz_idx_0 = points->size[0];
  acoef = centeredPoints->size[0] * centeredPoints->size[1];
  centeredPoints->size[0] = csz_idx_0;
  centeredPoints->size[1] = 2;
  emxEnsureCapacity_real_T1(sp, centeredPoints, acoef, &eb_emlrtRTEI);
  if (centeredPoints->size[0] != 0) {
    for (csz_idx_0 = 0; csz_idx_0 < 2; csz_idx_0++) {
      szc = centeredPoints->size[0];
      acoef = (points->size[0] != 1);
      for (k = 0; k < szc; k++) {
        centeredPoints->data[k + centeredPoints->size[0] * csz_idx_0] =
          points->data[acoef * k + points->size[0] * csz_idx_0] -
          center[csz_idx_0];
      }
    }
  }

  emxInit_real_T1(sp, &r2, 1, &jb_emlrtRTEI, true);
  csz_idx_0 = centeredPoints->size[0];
  szc = centeredPoints->size[0];
  acoef = r2->size[0];
  r2->size[0] = szc;
  emxEnsureCapacity_real_T(sp, r2, acoef, &fb_emlrtRTEI);
  for (acoef = 0; acoef < szc; acoef++) {
    r2->data[acoef] = centeredPoints->data[acoef + csz_idx_0];
  }

  emxInit_real_T1(sp, &yNorm, 1, &hb_emlrtRTEI, true);
  emxInit_real_T1(sp, &dxTangential, 1, &nb_emlrtRTEI, true);
  rdivide(sp, r2, intrinsicMatrix[4], yNorm);
  acoef = dxTangential->size[0];
  dxTangential->size[0] = yNorm->size[0];
  emxEnsureCapacity_real_T(sp, dxTangential, acoef, &fb_emlrtRTEI);
  szc = yNorm->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    dxTangential->data[acoef] = intrinsicMatrix[1] * yNorm->data[acoef];
  }

  acoef = centeredPoints->size[0];
  csz_idx_0 = dxTangential->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &f_emlrtECI, sp);
  }

  szc = centeredPoints->size[0];
  acoef = r2->size[0];
  r2->size[0] = szc;
  emxEnsureCapacity_real_T(sp, r2, acoef, &fb_emlrtRTEI);
  for (acoef = 0; acoef < szc; acoef++) {
    r2->data[acoef] = centeredPoints->data[acoef] - dxTangential->data[acoef];
  }

  emxInit_real_T1(sp, &xNorm, 1, &ib_emlrtRTEI, true);
  rdivide(sp, r2, intrinsicMatrix[0], xNorm);
  st.site = &th_emlrtRSI;
  b_power(&st, xNorm, r2);
  st.site = &th_emlrtRSI;
  b_power(&st, yNorm, dxTangential);
  acoef = r2->size[0];
  csz_idx_0 = dxTangential->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &g_emlrtECI, sp);
  }

  acoef = r2->size[0];
  emxEnsureCapacity_real_T(sp, r2, acoef, &fb_emlrtRTEI);
  szc = r2->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r2->data[acoef] += dxTangential->data[acoef];
  }

  emxInit_real_T1(sp, &r4, 1, &kb_emlrtRTEI, true);
  acoef = r4->size[0];
  r4->size[0] = r2->size[0];
  emxEnsureCapacity_real_T(sp, r4, acoef, &fb_emlrtRTEI);
  szc = r2->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r4->data[acoef] = r2->data[acoef] * r2->data[acoef];
  }

  acoef = r2->size[0];
  csz_idx_0 = r4->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &h_emlrtECI, sp);
  }

  for (acoef = 0; acoef < 3; acoef++) {
    b_k[acoef] = 0.0;
  }

  for (acoef = 0; acoef < 2; acoef++) {
    b_k[acoef] = radialDistortion[acoef];
  }

  emxInit_real_T1(sp, &alpha, 1, &lb_emlrtRTEI, true);
  acoef = alpha->size[0];
  alpha->size[0] = r2->size[0];
  emxEnsureCapacity_real_T(sp, alpha, acoef, &fb_emlrtRTEI);
  szc = r2->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    alpha->data[acoef] = b_k[0] * r2->data[acoef];
  }

  acoef = dxTangential->size[0];
  dxTangential->size[0] = r4->size[0];
  emxEnsureCapacity_real_T(sp, dxTangential, acoef, &fb_emlrtRTEI);
  szc = r4->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    dxTangential->data[acoef] = b_k[1] * r4->data[acoef];
  }

  acoef = alpha->size[0];
  csz_idx_0 = dxTangential->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &i_emlrtECI, sp);
  }

  acoef = r4->size[0];
  r4->size[0] = r2->size[0];
  emxEnsureCapacity_real_T(sp, r4, acoef, &fb_emlrtRTEI);
  szc = r2->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r4->data[acoef] = 0.0 * (r2->data[acoef] * r4->data[acoef]);
  }

  acoef = alpha->size[0];
  csz_idx_0 = r4->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &i_emlrtECI, sp);
  }

  acoef = alpha->size[0];
  emxEnsureCapacity_real_T(sp, alpha, acoef, &fb_emlrtRTEI);
  szc = alpha->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    alpha->data[acoef] = (alpha->data[acoef] + dxTangential->data[acoef]) +
      r4->data[acoef];
  }

  emxInit_real_T1(sp, &xyProduct, 1, &mb_emlrtRTEI, true);
  acoef = xNorm->size[0];
  csz_idx_0 = yNorm->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &j_emlrtECI, sp);
  }

  acoef = xyProduct->size[0];
  xyProduct->size[0] = xNorm->size[0];
  emxEnsureCapacity_real_T(sp, xyProduct, acoef, &fb_emlrtRTEI);
  szc = xNorm->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    xyProduct->data[acoef] = xNorm->data[acoef] * yNorm->data[acoef];
  }

  st.site = &uh_emlrtRSI;
  b_power(&st, xNorm, r4);
  acoef = r4->size[0];
  emxEnsureCapacity_real_T(sp, r4, acoef, &fb_emlrtRTEI);
  szc = r4->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r4->data[acoef] *= 2.0;
  }

  acoef = r2->size[0];
  csz_idx_0 = r4->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &k_emlrtECI, sp);
  }

  a = 2.0 * tangentialDistortion[0];
  acoef = dxTangential->size[0];
  dxTangential->size[0] = xyProduct->size[0];
  emxEnsureCapacity_real_T(sp, dxTangential, acoef, &fb_emlrtRTEI);
  szc = xyProduct->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    dxTangential->data[acoef] = a * xyProduct->data[acoef];
  }

  acoef = r4->size[0];
  r4->size[0] = r2->size[0];
  emxEnsureCapacity_real_T(sp, r4, acoef, &fb_emlrtRTEI);
  szc = r2->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r4->data[acoef] = tangentialDistortion[1] * (r2->data[acoef] + r4->
      data[acoef]);
  }

  acoef = dxTangential->size[0];
  csz_idx_0 = r4->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &l_emlrtECI, sp);
  }

  acoef = dxTangential->size[0];
  emxEnsureCapacity_real_T(sp, dxTangential, acoef, &fb_emlrtRTEI);
  szc = dxTangential->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    dxTangential->data[acoef] += r4->data[acoef];
  }

  st.site = &vh_emlrtRSI;
  b_power(&st, yNorm, r4);
  acoef = r4->size[0];
  emxEnsureCapacity_real_T(sp, r4, acoef, &fb_emlrtRTEI);
  szc = r4->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r4->data[acoef] *= 2.0;
  }

  acoef = r2->size[0];
  csz_idx_0 = r4->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &m_emlrtECI, sp);
  }

  acoef = r2->size[0];
  emxEnsureCapacity_real_T(sp, r2, acoef, &fb_emlrtRTEI);
  szc = r2->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r2->data[acoef] = tangentialDistortion[0] * (r2->data[acoef] + r4->
      data[acoef]);
  }

  a = 2.0 * tangentialDistortion[1];
  acoef = xyProduct->size[0];
  emxEnsureCapacity_real_T(sp, xyProduct, acoef, &fb_emlrtRTEI);
  szc = xyProduct->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    xyProduct->data[acoef] *= a;
  }

  acoef = r2->size[0];
  csz_idx_0 = xyProduct->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &n_emlrtECI, sp);
  }

  acoef = r2->size[0];
  emxEnsureCapacity_real_T(sp, r2, acoef, &fb_emlrtRTEI);
  szc = r2->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r2->data[acoef] += xyProduct->data[acoef];
  }

  st.site = &wh_emlrtRSI;
  b_st.site = &rh_emlrtRSI;
  c_st.site = &sh_emlrtRSI;
  b1 = true;
  if (yNorm->size[0] != xNorm->size[0]) {
    b1 = false;
  }

  if (!b1) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  acoef = centeredPoints->size[0] * centeredPoints->size[1];
  centeredPoints->size[0] = xNorm->size[0];
  centeredPoints->size[1] = 2;
  emxEnsureCapacity_real_T1(&b_st, centeredPoints, acoef, &fb_emlrtRTEI);
  szc = xNorm->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    centeredPoints->data[acoef] = xNorm->data[acoef];
  }

  emxFree_real_T(&b_st, &xNorm);
  szc = yNorm->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    centeredPoints->data[acoef + centeredPoints->size[0]] = yNorm->data[acoef];
  }

  emxFree_real_T(&b_st, &yNorm);
  emxInit_real_T(&b_st, &r17, 2, &fb_emlrtRTEI, true);
  st.site = &xh_emlrtRSI;
  b_st.site = &rh_emlrtRSI;
  c_st.site = &sh_emlrtRSI;
  acoef = r17->size[0] * r17->size[1];
  r17->size[0] = alpha->size[0];
  r17->size[1] = 2;
  emxEnsureCapacity_real_T1(&b_st, r17, acoef, &fb_emlrtRTEI);
  szc = alpha->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r17->data[acoef] = alpha->data[acoef];
  }

  szc = alpha->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r17->data[acoef + r17->size[0]] = alpha->data[acoef];
  }

  emxFree_real_T(&b_st, &alpha);
  for (acoef = 0; acoef < 2; acoef++) {
    b_centeredPoints[acoef] = centeredPoints->size[acoef];
  }

  for (acoef = 0; acoef < 2; acoef++) {
    iv11[acoef] = r17->size[acoef];
  }

  if ((b_centeredPoints[0] != iv11[0]) || (b_centeredPoints[1] != iv11[1])) {
    emlrtSizeEqCheckNDR2012b(&b_centeredPoints[0], &iv11[0], &o_emlrtECI, sp);
  }

  szc = centeredPoints->size[0] * centeredPoints->size[1] - 1;
  acoef = r17->size[0] * r17->size[1];
  r17->size[0] = centeredPoints->size[0];
  r17->size[1] = 2;
  emxEnsureCapacity_real_T1(sp, r17, acoef, &fb_emlrtRTEI);
  for (acoef = 0; acoef <= szc; acoef++) {
    r17->data[acoef] *= centeredPoints->data[acoef];
  }

  for (acoef = 0; acoef < 2; acoef++) {
    b_centeredPoints[acoef] = centeredPoints->size[acoef];
  }

  for (acoef = 0; acoef < 2; acoef++) {
    iv11[acoef] = r17->size[acoef];
  }

  if ((b_centeredPoints[0] != iv11[0]) || (b_centeredPoints[1] != iv11[1])) {
    emlrtSizeEqCheckNDR2012b(&b_centeredPoints[0], &iv11[0], &p_emlrtECI, sp);
  }

  st.site = &yh_emlrtRSI;
  b_st.site = &rh_emlrtRSI;
  c_st.site = &sh_emlrtRSI;
  b1 = true;
  if (r2->size[0] != dxTangential->size[0]) {
    b1 = false;
  }

  if (!b1) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  emxInit_real_T(&c_st, &r18, 2, &fb_emlrtRTEI, true);
  acoef = r18->size[0] * r18->size[1];
  r18->size[0] = dxTangential->size[0];
  r18->size[1] = 2;
  emxEnsureCapacity_real_T1(&b_st, r18, acoef, &fb_emlrtRTEI);
  szc = dxTangential->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r18->data[acoef] = dxTangential->data[acoef];
  }

  szc = r2->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    r18->data[acoef + r18->size[0]] = r2->data[acoef];
  }

  emxFree_real_T(&b_st, &r2);
  for (acoef = 0; acoef < 2; acoef++) {
    b_centeredPoints[acoef] = centeredPoints->size[acoef];
  }

  for (acoef = 0; acoef < 2; acoef++) {
    iv11[acoef] = r18->size[acoef];
  }

  if ((b_centeredPoints[0] != iv11[0]) || (b_centeredPoints[1] != iv11[1])) {
    emlrtSizeEqCheckNDR2012b(&b_centeredPoints[0], &iv11[0], &p_emlrtECI, sp);
  }

  szc = centeredPoints->size[0] * centeredPoints->size[1] - 1;
  acoef = centeredPoints->size[0] * centeredPoints->size[1];
  centeredPoints->size[1] = 2;
  emxEnsureCapacity_real_T1(sp, centeredPoints, acoef, &fb_emlrtRTEI);
  for (acoef = 0; acoef <= szc; acoef++) {
    centeredPoints->data[acoef] = (centeredPoints->data[acoef] + r17->data[acoef])
      + r18->data[acoef];
  }

  emxFree_real_T(sp, &r18);
  emxFree_real_T(sp, &r17);
  szc = centeredPoints->size[0];
  acoef = xyProduct->size[0];
  xyProduct->size[0] = szc;
  emxEnsureCapacity_real_T(sp, xyProduct, acoef, &fb_emlrtRTEI);
  for (acoef = 0; acoef < szc; acoef++) {
    xyProduct->data[acoef] = centeredPoints->data[acoef] * intrinsicMatrix[0];
  }

  szc = centeredPoints->size[0];
  acoef = dxTangential->size[0];
  dxTangential->size[0] = szc;
  emxEnsureCapacity_real_T(sp, dxTangential, acoef, &fb_emlrtRTEI);
  for (acoef = 0; acoef < szc; acoef++) {
    dxTangential->data[acoef] = intrinsicMatrix[1] * centeredPoints->data[acoef
      + centeredPoints->size[0]];
  }

  acoef = xyProduct->size[0];
  csz_idx_0 = dxTangential->size[0];
  if (acoef != csz_idx_0) {
    emlrtSizeEqCheck1DR2012b(acoef, csz_idx_0, &q_emlrtECI, sp);
  }

  acoef = xyProduct->size[0];
  emxEnsureCapacity_real_T(sp, xyProduct, acoef, &fb_emlrtRTEI);
  szc = xyProduct->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    xyProduct->data[acoef] = (xyProduct->data[acoef] + intrinsicMatrix[2]) +
      dxTangential->data[acoef];
  }

  emxFree_real_T(sp, &dxTangential);
  szc = centeredPoints->size[0];
  acoef = r4->size[0];
  r4->size[0] = szc;
  emxEnsureCapacity_real_T(sp, r4, acoef, &fb_emlrtRTEI);
  for (acoef = 0; acoef < szc; acoef++) {
    r4->data[acoef] = centeredPoints->data[acoef + centeredPoints->size[0]] *
      intrinsicMatrix[4] + intrinsicMatrix[5];
  }

  emxFree_real_T(sp, &centeredPoints);
  st.site = &ai_emlrtRSI;
  b_st.site = &rh_emlrtRSI;
  c_st.site = &sh_emlrtRSI;
  b1 = true;
  if (r4->size[0] != xyProduct->size[0]) {
    b1 = false;
  }

  if (!b1) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  acoef = distortedPoints->size[0] * distortedPoints->size[1];
  distortedPoints->size[0] = xyProduct->size[0];
  distortedPoints->size[1] = 2;
  emxEnsureCapacity_real_T1(&b_st, distortedPoints, acoef, &fb_emlrtRTEI);
  szc = xyProduct->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    distortedPoints->data[acoef] = xyProduct->data[acoef];
  }

  emxFree_real_T(&b_st, &xyProduct);
  szc = r4->size[0];
  for (acoef = 0; acoef < szc; acoef++) {
    distortedPoints->data[acoef + distortedPoints->size[0]] = r4->data[acoef];
  }

  emxFree_real_T(&b_st, &r4);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void distortPoints(e_depthEstimationFromStereoVide *SD, const real_T points
                   [614400], const real_T intrinsicMatrix[9], const real_T
                   radialDistortion[2], const real_T tangentialDistortion[2],
                   real_T distortedPoints[614400])
{
  real_T b_intrinsicMatrix[2];
  int32_T i;
  real_T yNorm;
  real_T k[3];
  real_T a;
  int32_T i8;
  b_intrinsicMatrix[0] = intrinsicMatrix[2];
  b_intrinsicMatrix[1] = intrinsicMatrix[5];
  bsxfun(points, b_intrinsicMatrix, SD->u1.f2.centeredPoints);
  for (i = 0; i < 307200; i++) {
    yNorm = SD->u1.f2.centeredPoints[307200 + i] / intrinsicMatrix[4];
    SD->u1.f2.xNorm[i] = (SD->u1.f2.centeredPoints[i] - intrinsicMatrix[1] *
                          yNorm) / intrinsicMatrix[0];
    SD->u1.f2.yNorm[i] = yNorm;
  }

  power(SD->u1.f2.xNorm, SD->u1.f2.r2);
  power(SD->u1.f2.yNorm, SD->u1.f2.dv0);
  for (i = 0; i < 307200; i++) {
    yNorm = SD->u1.f2.r2[i] + SD->u1.f2.dv0[i];
    SD->u1.f2.b_r4[i] = yNorm * yNorm;
    SD->u1.f2.r2[i] = yNorm;
  }

  for (i = 0; i < 3; i++) {
    k[i] = 0.0;
  }

  for (i = 0; i < 2; i++) {
    k[i] = radialDistortion[i];
  }

  yNorm = 2.0 * tangentialDistortion[0];
  a = 2.0 * tangentialDistortion[1];
  for (i = 0; i < 307200; i++) {
    SD->u1.f2.xyProduct[i] = SD->u1.f2.xNorm[i] * SD->u1.f2.yNorm[i];
    SD->u1.f2.centeredPoints[i] = SD->u1.f2.xNorm[i];
    SD->u1.f2.centeredPoints[307200 + i] = SD->u1.f2.yNorm[i];
    SD->u1.f2.b_r4[i] = (k[0] * SD->u1.f2.r2[i] + k[1] * SD->u1.f2.b_r4[i]) +
      0.0 * (SD->u1.f2.r2[i] * SD->u1.f2.b_r4[i]);
  }

  power(SD->u1.f2.xNorm, SD->u1.f2.dv0);
  power(SD->u1.f2.yNorm, SD->u1.f2.xNorm);
  for (i = 0; i < 307200; i++) {
    SD->u1.f2.r4[i] = SD->u1.f2.b_r4[i];
    SD->u1.f2.r4[307200 + i] = SD->u1.f2.b_r4[i];
    SD->u1.f2.a[i] = yNorm * SD->u1.f2.xyProduct[i] + tangentialDistortion[1] *
      (SD->u1.f2.r2[i] + 2.0 * SD->u1.f2.dv0[i]);
    SD->u1.f2.a[307200 + i] = tangentialDistortion[0] * (SD->u1.f2.r2[i] + 2.0 *
      SD->u1.f2.xNorm[i]) + a * SD->u1.f2.xyProduct[i];
  }

  for (i = 0; i < 2; i++) {
    for (i8 = 0; i8 < 307200; i8++) {
      SD->u1.f2.distortedNormalizedPoints[i8 + 307200 * i] =
        (SD->u1.f2.centeredPoints[i8 + 307200 * i] + SD->u1.f2.centeredPoints[i8
         + 307200 * i] * SD->u1.f2.r4[i8 + 307200 * i]) + SD->u1.f2.a[i8 +
        307200 * i];
    }
  }

  for (i = 0; i < 307200; i++) {
    distortedPoints[i] = (SD->u1.f2.distortedNormalizedPoints[i] *
                          intrinsicMatrix[0] + intrinsicMatrix[2]) +
      intrinsicMatrix[1] * SD->u1.f2.distortedNormalizedPoints[307200 + i];
    distortedPoints[307200 + i] = SD->u1.f2.distortedNormalizedPoints[307200 + i]
      * intrinsicMatrix[4] + intrinsicMatrix[5];
  }
}

/* End of code generation (distortPoints.c) */

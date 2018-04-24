/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * detectSURFFeatures.c
 *
 * Code generation for function 'detectSURFFeatures'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "detectSURFFeatures.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "SURFPointsImpl.h"
#include "all1.h"
#include "FeaturePointsImpl.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"
#include "fastHessianDetectorCore_api.hpp"

/* Variable Definitions */
static emlrtRSInfo k_emlrtRSI = { 81,  /* lineNo */
  "detectSURFFeatures",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pathName */
};

static emlrtRSInfo l_emlrtRSI = { 111, /* lineNo */
  "detectSURFFeatures",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pathName */
};

static emlrtRSInfo m_emlrtRSI = { 124, /* lineNo */
  "detectSURFFeatures",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pathName */
};

static emlrtRTEInfo w_emlrtRTEI = { 99,/* lineNo */
  9,                                   /* colNo */
  "detectSURFFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pName */
};

static emlrtRTEInfo x_emlrtRTEI = { 111,/* lineNo */
  5,                                   /* colNo */
  "detectSURFFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pName */
};

static emlrtRTEInfo y_emlrtRTEI = { 124,/* lineNo */
  1,                                   /* colNo */
  "detectSURFFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pName */
};

static emlrtRTEInfo ab_emlrtRTEI = { 124,/* lineNo */
  7,                                   /* colNo */
  "detectSURFFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pName */
};

static emlrtRTEInfo eb_emlrtRTEI = { 83,/* lineNo */
  1,                                   /* colNo */
  "detectSURFFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pName */
};

static emlrtRTEInfo fb_emlrtRTEI = { 1,/* lineNo */
  14,                                  /* colNo */
  "detectSURFFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\detectSURFFeatures.m"/* pName */
};

static emlrtDCInfo emlrtDCI = { 72,    /* lineNo */
  45,                                  /* colNo */
  "fastHessianDetectorBuildable",      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\fastHessianDetectorBuildable.m",/* pName */
  4                                    /* checkKind */
};

static emlrtDCInfo b_emlrtDCI = { 73,  /* lineNo */
  45,                                  /* colNo */
  "fastHessianDetectorBuildable",      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\fastHessianDetectorBuildable.m",/* pName */
  4                                    /* checkKind */
};

static emlrtDCInfo c_emlrtDCI = { 74,  /* lineNo */
  45,                                  /* colNo */
  "fastHessianDetectorBuildable",      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\fastHessianDetectorBuildable.m",/* pName */
  4                                    /* checkKind */
};

static emlrtDCInfo d_emlrtDCI = { 75,  /* lineNo */
  52,                                  /* colNo */
  "fastHessianDetectorBuildable",      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\fastHessianDetectorBuildable.m",/* pName */
  4                                    /* checkKind */
};

/* Function Definitions */
void detectSURFFeatures(const emlrtStack *sp, const emxArray_uint8_T *I,
  vision_internal_SURFPoints_cg *Pts)
{
  emxArray_uint8_T *Iu8;
  int32_T i3;
  int32_T outNumRows;
  emxArray_real32_T *PtsStruct_Scale;
  int32_T loop_ub;
  emxArray_real32_T *PtsStruct_Metric;
  int32_T i4;
  emxArray_int8_T *PtsStruct_SignOfLaplacian;
  emxArray_real32_T *PtsStruct_Location;
  emxArray_real32_T *inputs_Location;
  void * ptrKeypoint;
  emxArray_real32_T *inputs_Metric;
  emxArray_real32_T *inputs_Scale;
  emxArray_int8_T *inputs_SignOfLaplacian;
  boolean_T b0;
  emxArray_boolean_T *b_PtsStruct_SignOfLaplacian;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &k_emlrtRSI;
  b_st.site = &n_emlrtRSI;
  c_st.site = &o_emlrtRSI;
  d_st.site = &p_emlrtRSI;
  e_st.site = &q_emlrtRSI;
  if ((I->size[0] == 0) || (I->size[1] == 0)) {
    emlrtErrorWithMessageIdR2018a(&e_st, &hi_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonempty",
      "MATLAB:validateImage:expectedNonempty", 3, 4, 1, "I");
  }

  emxInit_uint8_T(&e_st, &Iu8, 2, &eb_emlrtRTEI, true);
  i3 = Iu8->size[0] * Iu8->size[1];
  Iu8->size[0] = I->size[1];
  Iu8->size[1] = I->size[0];
  emxEnsureCapacity_uint8_T(sp, Iu8, i3, &w_emlrtRTEI);
  outNumRows = I->size[0];
  for (i3 = 0; i3 < outNumRows; i3++) {
    loop_ub = I->size[1];
    for (i4 = 0; i4 < loop_ub; i4++) {
      Iu8->data[i4 + Iu8->size[0] * i3] = I->data[i3 + I->size[0] * i4];
    }
  }

  emxInit_real32_T1(sp, &PtsStruct_Scale, 1, &fb_emlrtRTEI, true);
  emxInit_real32_T1(sp, &PtsStruct_Metric, 1, &fb_emlrtRTEI, true);
  emxInit_int8_T(sp, &PtsStruct_SignOfLaplacian, 1, &fb_emlrtRTEI, true);
  emxInit_real32_T(sp, &PtsStruct_Location, 2, &fb_emlrtRTEI, true);
  emxInit_real32_T(sp, &inputs_Location, 2, &bb_emlrtRTEI, true);
  st.site = &l_emlrtRSI;
  ptrKeypoint = NULL;
  outNumRows = fastHessianDetector_uint8(&Iu8->data[0], I->size[0], I->size[1],
    2, 2, 3, 1000, &ptrKeypoint);
  i3 = PtsStruct_Location->size[0] * PtsStruct_Location->size[1];
  if (!(outNumRows >= 0)) {
    emlrtNonNegativeCheckR2012b(outNumRows, &emlrtDCI, &st);
  }

  PtsStruct_Location->size[0] = outNumRows;
  PtsStruct_Location->size[1] = 2;
  emxEnsureCapacity_real32_T(&st, PtsStruct_Location, i3, &x_emlrtRTEI);
  i3 = PtsStruct_Scale->size[0];
  if (!(outNumRows >= 0)) {
    emlrtNonNegativeCheckR2012b(outNumRows, &b_emlrtDCI, &st);
  }

  PtsStruct_Scale->size[0] = outNumRows;
  emxEnsureCapacity_real32_T1(&st, PtsStruct_Scale, i3, &x_emlrtRTEI);
  i3 = PtsStruct_Metric->size[0];
  if (!(outNumRows >= 0)) {
    emlrtNonNegativeCheckR2012b(outNumRows, &c_emlrtDCI, &st);
  }

  PtsStruct_Metric->size[0] = outNumRows;
  emxEnsureCapacity_real32_T1(&st, PtsStruct_Metric, i3, &x_emlrtRTEI);
  i3 = PtsStruct_SignOfLaplacian->size[0];
  if (!(outNumRows >= 0)) {
    emlrtNonNegativeCheckR2012b(outNumRows, &d_emlrtDCI, &st);
  }

  PtsStruct_SignOfLaplacian->size[0] = outNumRows;
  emxEnsureCapacity_int8_T(&st, PtsStruct_SignOfLaplacian, i3, &x_emlrtRTEI);
  fastHessianDetector_keyPoints2field(ptrKeypoint, &PtsStruct_Location->data[0],
    &PtsStruct_Scale->data[0], &PtsStruct_Metric->data[0],
    &PtsStruct_SignOfLaplacian->data[0]);
  fastHessianDetector_deleteKeypoint(ptrKeypoint);
  st.site = &m_emlrtRSI;
  i3 = Pts->pLocation->size[0] * Pts->pLocation->size[1];
  Pts->pLocation->size[0] = 0;
  Pts->pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(&st, Pts->pLocation, i3, &y_emlrtRTEI);
  i3 = Pts->pMetric->size[0];
  Pts->pMetric->size[0] = 0;
  emxEnsureCapacity_real32_T1(&st, Pts->pMetric, i3, &ab_emlrtRTEI);
  i3 = Pts->pScale->size[0];
  Pts->pScale->size[0] = 0;
  emxEnsureCapacity_real32_T1(&st, Pts->pScale, i3, &ab_emlrtRTEI);
  i3 = Pts->pSignOfLaplacian->size[0];
  Pts->pSignOfLaplacian->size[0] = 0;
  emxEnsureCapacity_int8_T(&st, Pts->pSignOfLaplacian, i3, &ab_emlrtRTEI);
  i3 = Pts->pOrientation->size[0];
  Pts->pOrientation->size[0] = 0;
  emxEnsureCapacity_real32_T1(&st, Pts->pOrientation, i3, &ab_emlrtRTEI);
  b_st.site = &r_emlrtRSI;
  i3 = inputs_Location->size[0] * inputs_Location->size[1];
  inputs_Location->size[0] = PtsStruct_Location->size[0];
  inputs_Location->size[1] = PtsStruct_Location->size[1];
  emxEnsureCapacity_real32_T(&b_st, inputs_Location, i3, &bb_emlrtRTEI);
  outNumRows = PtsStruct_Location->size[0] * PtsStruct_Location->size[1];
  emxFree_uint8_T(&b_st, &Iu8);
  for (i3 = 0; i3 < outNumRows; i3++) {
    inputs_Location->data[i3] = PtsStruct_Location->data[i3];
  }

  emxInit_real32_T1(&b_st, &inputs_Metric, 1, &bb_emlrtRTEI, true);
  i3 = inputs_Metric->size[0];
  inputs_Metric->size[0] = PtsStruct_Metric->size[0];
  emxEnsureCapacity_real32_T1(&b_st, inputs_Metric, i3, &bb_emlrtRTEI);
  outNumRows = PtsStruct_Metric->size[0];
  for (i3 = 0; i3 < outNumRows; i3++) {
    inputs_Metric->data[i3] = PtsStruct_Metric->data[i3];
  }

  emxInit_real32_T1(&b_st, &inputs_Scale, 1, &bb_emlrtRTEI, true);
  i3 = inputs_Scale->size[0];
  inputs_Scale->size[0] = PtsStruct_Scale->size[0];
  emxEnsureCapacity_real32_T1(&b_st, inputs_Scale, i3, &bb_emlrtRTEI);
  outNumRows = PtsStruct_Scale->size[0];
  for (i3 = 0; i3 < outNumRows; i3++) {
    inputs_Scale->data[i3] = PtsStruct_Scale->data[i3];
  }

  emxInit_int8_T(&b_st, &inputs_SignOfLaplacian, 1, &bb_emlrtRTEI, true);
  i3 = inputs_SignOfLaplacian->size[0];
  inputs_SignOfLaplacian->size[0] = PtsStruct_SignOfLaplacian->size[0];
  emxEnsureCapacity_int8_T(&b_st, inputs_SignOfLaplacian, i3, &bb_emlrtRTEI);
  outNumRows = PtsStruct_SignOfLaplacian->size[0];
  for (i3 = 0; i3 < outNumRows; i3++) {
    inputs_SignOfLaplacian->data[i3] = PtsStruct_SignOfLaplacian->data[i3];
  }

  c_st.site = &s_emlrtRSI;
  d_st.site = &u_emlrtRSI;
  e_st.site = &bb_emlrtRSI;
  FeaturePointsImpl_checkLocation(&e_st, PtsStruct_Location);
  e_st.site = &cb_emlrtRSI;
  FeaturePointsImpl_checkMetric(&e_st, PtsStruct_Metric);
  e_st.site = &db_emlrtRSI;
  if ((PtsStruct_Metric->size[0] == 1) || (PtsStruct_Metric->size[0] ==
       PtsStruct_Location->size[0])) {
    b0 = true;
  } else {
    b0 = false;
  }

  emxFree_real32_T(&e_st, &PtsStruct_Metric);
  if (!b0) {
    emlrtErrorWithMessageIdR2018a(&e_st, &fi_emlrtRTEI,
      "vision:FeaturePoints:invalidParamLength",
      "vision:FeaturePoints:invalidParamLength", 3, 4, 6, "Metric");
  }

  emxInit_boolean_T(&e_st, &b_PtsStruct_SignOfLaplacian, 1, &cb_emlrtRTEI, true);
  d_st.site = &v_emlrtRSI;
  SURFPointsImpl_checkScale(&d_st, PtsStruct_Scale);
  d_st.site = &w_emlrtRSI;
  e_st.site = &ib_emlrtRSI;
  d_st.site = &x_emlrtRSI;
  i3 = b_PtsStruct_SignOfLaplacian->size[0];
  b_PtsStruct_SignOfLaplacian->size[0] = PtsStruct_SignOfLaplacian->size[0];
  emxEnsureCapacity_boolean_T(&d_st, b_PtsStruct_SignOfLaplacian, i3,
    &cb_emlrtRTEI);
  outNumRows = PtsStruct_SignOfLaplacian->size[0];
  for (i3 = 0; i3 < outNumRows; i3++) {
    b_PtsStruct_SignOfLaplacian->data[i3] = (PtsStruct_SignOfLaplacian->data[i3]
      >= -1);
  }

  e_st.site = &jb_emlrtRSI;
  if (c_all(&e_st, b_PtsStruct_SignOfLaplacian)) {
    i3 = b_PtsStruct_SignOfLaplacian->size[0];
    b_PtsStruct_SignOfLaplacian->size[0] = PtsStruct_SignOfLaplacian->size[0];
    emxEnsureCapacity_boolean_T(&d_st, b_PtsStruct_SignOfLaplacian, i3,
      &db_emlrtRTEI);
    outNumRows = PtsStruct_SignOfLaplacian->size[0];
    for (i3 = 0; i3 < outNumRows; i3++) {
      b_PtsStruct_SignOfLaplacian->data[i3] = (PtsStruct_SignOfLaplacian->
        data[i3] <= 1);
    }

    e_st.site = &jb_emlrtRSI;
    if (c_all(&e_st, b_PtsStruct_SignOfLaplacian)) {
      b0 = true;
    } else {
      b0 = false;
    }
  } else {
    b0 = false;
  }

  emxFree_boolean_T(&d_st, &b_PtsStruct_SignOfLaplacian);
  if (!b0) {
    emlrtErrorWithMessageIdR2018a(&d_st, &gi_emlrtRTEI,
      "vision:SURFPoints:invalidSignOfLaplacian",
      "vision:SURFPoints:invalidSignOfLaplacian", 0);
  }

  d_st.site = &y_emlrtRSI;
  if ((PtsStruct_Scale->size[0] == 1) || (PtsStruct_Scale->size[0] ==
       PtsStruct_Location->size[0])) {
    b0 = true;
  } else {
    b0 = false;
  }

  emxFree_real32_T(&d_st, &PtsStruct_Scale);
  if (!b0) {
    emlrtErrorWithMessageIdR2018a(&d_st, &fi_emlrtRTEI,
      "vision:FeaturePoints:invalidParamLength",
      "vision:FeaturePoints:invalidParamLength", 3, 4, 5, "Scale");
  }

  d_st.site = &ab_emlrtRSI;
  if ((PtsStruct_SignOfLaplacian->size[0] == 1) ||
      (PtsStruct_SignOfLaplacian->size[0] == PtsStruct_Location->size[0])) {
    b0 = true;
  } else {
    b0 = false;
  }

  emxFree_real32_T(&d_st, &PtsStruct_Location);
  emxFree_int8_T(&d_st, &PtsStruct_SignOfLaplacian);
  if (!b0) {
    emlrtErrorWithMessageIdR2018a(&d_st, &fi_emlrtRTEI,
      "vision:FeaturePoints:invalidParamLength",
      "vision:FeaturePoints:invalidParamLength", 3, 4, 15, "SignOfLaplacian");
  }

  c_st.site = &t_emlrtRSI;
  SURFPointsImpl_configure(&c_st, Pts, inputs_Location, inputs_Metric,
    inputs_Scale, inputs_SignOfLaplacian);
  emxFree_int8_T(sp, &inputs_SignOfLaplacian);
  emxFree_real32_T(sp, &inputs_Scale);
  emxFree_real32_T(sp, &inputs_Metric);
  emxFree_real32_T(sp, &inputs_Location);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (detectSURFFeatures.c) */

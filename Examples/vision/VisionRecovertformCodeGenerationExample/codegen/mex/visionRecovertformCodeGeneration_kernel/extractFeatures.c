/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * extractFeatures.c
 *
 * Code generation for function 'extractFeatures'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "extractFeatures.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "SURFPointsImpl.h"
#include "all1.h"
#include "all.h"
#include "FeaturePointsImpl.h"
#include "validatesize.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"
#include "extractSurfCore_api.hpp"

/* Variable Definitions */
static emlrtRSInfo wb_emlrtRSI = { 173,/* lineNo */
  "extractFeatures",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pathName */
};

static emlrtRSInfo xb_emlrtRSI = { 179,/* lineNo */
  "extractFeatures",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pathName */
};

static emlrtRSInfo yb_emlrtRSI = { 212,/* lineNo */
  "extractFeatures",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pathName */
};

static emlrtRSInfo ac_emlrtRSI = { 243,/* lineNo */
  "extractFeatures",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pathName */
};

static emlrtRSInfo bc_emlrtRSI = { 18, /* lineNo */
  "checkPoints",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkPoints.m"/* pathName */
};

static emlrtRSInfo cc_emlrtRSI = { 42, /* lineNo */
  "checkPoints",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\checkPoints.m"/* pathName */
};

static emlrtRSInfo ec_emlrtRSI = { 663,/* lineNo */
  "extractFeatures",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pathName */
};

static emlrtRSInfo fc_emlrtRSI = { 679,/* lineNo */
  "extractFeatures",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pathName */
};

static emlrtRSInfo gc_emlrtRSI = { 704,/* lineNo */
  "extractFeatures",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pathName */
};

static emlrtRSInfo hc_emlrtRSI = { 206,/* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

static emlrtRTEInfo hb_emlrtRTEI = { 663,/* lineNo */
  1,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo ib_emlrtRTEI = { 440,/* lineNo */
  17,                                  /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo jb_emlrtRTEI = { 441,/* lineNo */
  14,                                  /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo kb_emlrtRTEI = { 442,/* lineNo */
  15,                                  /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo lb_emlrtRTEI = { 443,/* lineNo */
  24,                                  /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo mb_emlrtRTEI = { 673,/* lineNo */
  9,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo nb_emlrtRTEI = { 681,/* lineNo */
  9,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo ob_emlrtRTEI = { 679,/* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo pb_emlrtRTEI = { 679,/* lineNo */
  76,                                  /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo qb_emlrtRTEI = { 693,/* lineNo */
  1,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo rb_emlrtRTEI = { 704,/* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo sb_emlrtRTEI = { 704,/* lineNo */
  20,                                  /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo tb_emlrtRTEI = { 669,/* lineNo */
  6,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo ub_emlrtRTEI = { 1,/* lineNo */
  37,                                  /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo vb_emlrtRTEI = { 435,/* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo wb_emlrtRTEI = { 436,/* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo xb_emlrtRTEI = { 437,/* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtRTEInfo yb_emlrtRTEI = { 438,/* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtBCInfo g_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  440,                                 /* lineNo */
  19,                                  /* colNo */
  "",                                  /* aName */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m",/* pName */
  0                                    /* checkKind */
};

static emlrtECInfo b_emlrtECI = { -1,  /* nDims */
  440,                                 /* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtBCInfo h_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  441,                                 /* lineNo */
  14,                                  /* colNo */
  "",                                  /* aName */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo i_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  441,                                 /* lineNo */
  16,                                  /* colNo */
  "",                                  /* aName */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m",/* pName */
  0                                    /* checkKind */
};

static emlrtECInfo c_emlrtECI = { -1,  /* nDims */
  441,                                 /* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtBCInfo j_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  442,                                 /* lineNo */
  15,                                  /* colNo */
  "",                                  /* aName */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo k_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  442,                                 /* lineNo */
  17,                                  /* colNo */
  "",                                  /* aName */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m",/* pName */
  0                                    /* checkKind */
};

static emlrtECInfo d_emlrtECI = { -1,  /* nDims */
  442,                                 /* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtBCInfo l_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  443,                                 /* lineNo */
  24,                                  /* colNo */
  "",                                  /* aName */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m",/* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo m_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  443,                                 /* lineNo */
  26,                                  /* colNo */
  "",                                  /* aName */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m",/* pName */
  0                                    /* checkKind */
};

static emlrtECInfo e_emlrtECI = { -1,  /* nDims */
  443,                                 /* lineNo */
  5,                                   /* colNo */
  "extractFeatures",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\extractFeatures.m"/* pName */
};

static emlrtDCInfo e_emlrtDCI = { 90,  /* lineNo */
  48,                                  /* colNo */
  "extractSurfBuildable",              /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+buildable\\extractSurfBuildable.m",/* pName */
  4                                    /* checkKind */
};

/* Function Definitions */
void extractFeatures(const emlrtStack *sp, const emxArray_uint8_T *I, const
                     emxArray_real32_T *points_pLocation, const
                     emxArray_real32_T *points_pMetric, const emxArray_real32_T *
                     points_pScale, const emxArray_int8_T
                     *points_pSignOfLaplacian, emxArray_real32_T *features,
                     vision_internal_SURFPoints_cg *valid_points)
{
  emxArray_real32_T *valLocation;
  emxArray_real32_T *valScale;
  emxArray_real32_T *valMetric;
  emxArray_int8_T *valSignOfLaplacian;
  int32_T i7;
  int32_T out_numel;
  int32_T loop_ub;
  emxArray_int32_T *r0;
  int32_T iv3[2];
  int32_T iv4[1];
  emxArray_uint8_T *Iu8T;
  emxArray_real32_T *inLocation;
  int32_T b_loop_ub;
  emxArray_real32_T *outOrientation;
  emxArray_real32_T *b_features;
  void * ptrKeypoints;
  void * ptrDescriptors;
  emxArray_real32_T *vPts_Orientation;
  emxArray_real32_T *inputs_Location;
  emxArray_real32_T *inputs_Metric;
  emxArray_real32_T *inputs_Scale;
  emxArray_int8_T *inputs_SignOfLaplacian;
  emxArray_real32_T *inputs_Orientation;
  boolean_T p;
  boolean_T exitg1;
  emxArray_boolean_T *b_valSignOfLaplacian;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  emlrtStack h_st;
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
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  h_st.prev = &g_st;
  h_st.tls = g_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &wb_emlrtRSI;
  b_st.site = &yb_emlrtRSI;
  c_st.site = &n_emlrtRSI;
  d_st.site = &o_emlrtRSI;
  e_st.site = &p_emlrtRSI;
  f_st.site = &q_emlrtRSI;
  if ((I->size[0] == 0) || (I->size[1] == 0)) {
    emlrtErrorWithMessageIdR2018a(&f_st, &hi_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonempty",
      "MATLAB:validateImage:expectedNonempty", 3, 4, 1, "I");
  }

  b_st.site = &ac_emlrtRSI;
  c_st.site = &bc_emlrtRSI;
  d_st.site = &cc_emlrtRSI;
  e_st.site = &dc_emlrtRSI;
  f_st.site = &q_emlrtRSI;
  if (!size_check(points_pLocation)) {
    emlrtErrorWithMessageIdR2018a(&f_st, &ji_emlrtRTEI,
      "Coder:toolbox:ValidateattributesincorrectSize",
      "MATLAB:extractFeatures:incorrectSize", 3, 4, 6, "POINTS");
  }

  emxInit_real32_T(&f_st, &valLocation, 2, &vb_emlrtRTEI, true);
  emxInit_real32_T1(&f_st, &valScale, 1, &wb_emlrtRTEI, true);
  emxInit_real32_T1(&f_st, &valMetric, 1, &xb_emlrtRTEI, true);
  emxInit_int8_T(&f_st, &valSignOfLaplacian, 1, &yb_emlrtRTEI, true);
  st.site = &xb_emlrtRSI;
  b_st.site = &ec_emlrtRSI;
  i7 = valLocation->size[0] * valLocation->size[1];
  valLocation->size[0] = points_pLocation->size[0];
  valLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(&b_st, valLocation, i7, &hb_emlrtRTEI);
  i7 = valScale->size[0];
  valScale->size[0] = points_pLocation->size[0];
  emxEnsureCapacity_real32_T1(&b_st, valScale, i7, &hb_emlrtRTEI);
  i7 = valMetric->size[0];
  valMetric->size[0] = points_pLocation->size[0];
  emxEnsureCapacity_real32_T1(&b_st, valMetric, i7, &hb_emlrtRTEI);
  i7 = valSignOfLaplacian->size[0];
  valSignOfLaplacian->size[0] = points_pLocation->size[0];
  emxEnsureCapacity_int8_T(&b_st, valSignOfLaplacian, i7, &hb_emlrtRTEI);
  if (1 > points_pLocation->size[0]) {
    loop_ub = 0;
  } else {
    out_numel = points_pLocation->size[0];
    loop_ub = points_pLocation->size[0];
    if (!((loop_ub >= 1) && (loop_ub <= out_numel))) {
      emlrtDynamicBoundsCheckR2012b(loop_ub, 1, out_numel, &g_emlrtBCI, &b_st);
    }
  }

  emxInit_int32_T(&b_st, &r0, 1, &ub_emlrtRTEI, true);
  i7 = r0->size[0];
  r0->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&b_st, r0, i7, &ib_emlrtRTEI);
  for (i7 = 0; i7 < loop_ub; i7++) {
    r0->data[i7] = i7;
  }

  iv3[0] = r0->size[0];
  iv3[1] = 2;
  emlrtSubAssignSizeCheckR2012b(&iv3[0], 2, &(*(int32_T (*)[2])
    points_pLocation->size)[0], 2, &b_emlrtECI, &b_st);
  for (i7 = 0; i7 < 2; i7++) {
    loop_ub = points_pLocation->size[0];
    for (out_numel = 0; out_numel < loop_ub; out_numel++) {
      valLocation->data[r0->data[out_numel] + valLocation->size[0] * i7] =
        points_pLocation->data[out_numel + points_pLocation->size[0] * i7];
    }
  }

  if (1 > points_pLocation->size[0]) {
    loop_ub = 0;
  } else {
    i7 = valScale->size[0];
    if (!(1 <= i7)) {
      emlrtDynamicBoundsCheckR2012b(1, 1, i7, &h_emlrtBCI, &b_st);
    }

    i7 = valScale->size[0];
    loop_ub = points_pLocation->size[0];
    if (!((loop_ub >= 1) && (loop_ub <= i7))) {
      emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i7, &i_emlrtBCI, &b_st);
    }
  }

  i7 = r0->size[0];
  r0->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&b_st, r0, i7, &jb_emlrtRTEI);
  for (i7 = 0; i7 < loop_ub; i7++) {
    r0->data[i7] = i7;
  }

  iv4[0] = r0->size[0];
  emlrtSubAssignSizeCheckR2012b(&iv4[0], 1, &(*(int32_T (*)[1])
    points_pScale->size)[0], 1, &c_emlrtECI, &b_st);
  loop_ub = points_pScale->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    valScale->data[r0->data[i7]] = points_pScale->data[i7];
  }

  if (1 > points_pLocation->size[0]) {
    loop_ub = 0;
  } else {
    i7 = valMetric->size[0];
    if (!(1 <= i7)) {
      emlrtDynamicBoundsCheckR2012b(1, 1, i7, &j_emlrtBCI, &b_st);
    }

    i7 = valMetric->size[0];
    loop_ub = points_pLocation->size[0];
    if (!((loop_ub >= 1) && (loop_ub <= i7))) {
      emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i7, &k_emlrtBCI, &b_st);
    }
  }

  i7 = r0->size[0];
  r0->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&b_st, r0, i7, &kb_emlrtRTEI);
  for (i7 = 0; i7 < loop_ub; i7++) {
    r0->data[i7] = i7;
  }

  iv4[0] = r0->size[0];
  emlrtSubAssignSizeCheckR2012b(&iv4[0], 1, &(*(int32_T (*)[1])
    points_pMetric->size)[0], 1, &d_emlrtECI, &b_st);
  loop_ub = points_pMetric->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    valMetric->data[r0->data[i7]] = points_pMetric->data[i7];
  }

  if (1 > points_pLocation->size[0]) {
    loop_ub = 0;
  } else {
    i7 = valSignOfLaplacian->size[0];
    if (!(1 <= i7)) {
      emlrtDynamicBoundsCheckR2012b(1, 1, i7, &l_emlrtBCI, &b_st);
    }

    i7 = valSignOfLaplacian->size[0];
    loop_ub = points_pLocation->size[0];
    if (!((loop_ub >= 1) && (loop_ub <= i7))) {
      emlrtDynamicBoundsCheckR2012b(loop_ub, 1, i7, &m_emlrtBCI, &b_st);
    }
  }

  i7 = r0->size[0];
  r0->size[0] = loop_ub;
  emxEnsureCapacity_int32_T(&b_st, r0, i7, &lb_emlrtRTEI);
  for (i7 = 0; i7 < loop_ub; i7++) {
    r0->data[i7] = i7;
  }

  iv4[0] = r0->size[0];
  emlrtSubAssignSizeCheckR2012b(&iv4[0], 1, &(*(int32_T (*)[1])
    points_pSignOfLaplacian->size)[0], 1, &e_emlrtECI, &b_st);
  loop_ub = points_pSignOfLaplacian->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    valSignOfLaplacian->data[r0->data[i7]] = points_pSignOfLaplacian->data[i7];
  }

  emxFree_int32_T(&b_st, &r0);
  emxInit_uint8_T(&b_st, &Iu8T, 2, &mb_emlrtRTEI, true);
  i7 = Iu8T->size[0] * Iu8T->size[1];
  Iu8T->size[0] = I->size[1];
  Iu8T->size[1] = I->size[0];
  emxEnsureCapacity_uint8_T(&st, Iu8T, i7, &mb_emlrtRTEI);
  loop_ub = I->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    b_loop_ub = I->size[1];
    for (out_numel = 0; out_numel < b_loop_ub; out_numel++) {
      Iu8T->data[out_numel + Iu8T->size[0] * i7] = I->data[i7 + I->size[0] *
        out_numel];
    }
  }

  emxInit_real32_T(&st, &inLocation, 2, &nb_emlrtRTEI, true);
  b_st.site = &fc_emlrtRSI;
  i7 = inLocation->size[0] * inLocation->size[1];
  inLocation->size[0] = valLocation->size[0];
  inLocation->size[1] = valLocation->size[1];
  emxEnsureCapacity_real32_T(&b_st, inLocation, i7, &nb_emlrtRTEI);
  loop_ub = valLocation->size[0] * valLocation->size[1];
  for (i7 = 0; i7 < loop_ub; i7++) {
    inLocation->data[i7] = valLocation->data[i7];
  }

  emxInit_real32_T1(&b_st, &outOrientation, 1, &ub_emlrtRTEI, true);
  emxInit_real32_T(&b_st, &b_features, 2, &ub_emlrtRTEI, true);
  ptrKeypoints = NULL;
  ptrDescriptors = NULL;
  out_numel = extractSurf_compute(&Iu8T->data[0], Iu8T->size[1], Iu8T->size[0],
    2, &inLocation->data[0], &valScale->data[0], &valMetric->data[0],
    &valSignOfLaplacian->data[0], valLocation->size[0], false, false,
    &ptrKeypoints, &ptrDescriptors);
  i7 = valLocation->size[0] * valLocation->size[1];
  if (!(out_numel >= 0)) {
    emlrtNonNegativeCheckR2012b(out_numel, &e_emlrtDCI, &b_st);
  }

  valLocation->size[0] = out_numel;
  valLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(&b_st, valLocation, i7, &ob_emlrtRTEI);
  i7 = valScale->size[0];
  valScale->size[0] = out_numel;
  emxEnsureCapacity_real32_T1(&b_st, valScale, i7, &ob_emlrtRTEI);
  i7 = valMetric->size[0];
  valMetric->size[0] = out_numel;
  emxEnsureCapacity_real32_T1(&b_st, valMetric, i7, &ob_emlrtRTEI);
  i7 = valSignOfLaplacian->size[0];
  valSignOfLaplacian->size[0] = out_numel;
  emxEnsureCapacity_int8_T(&b_st, valSignOfLaplacian, i7, &ob_emlrtRTEI);
  i7 = outOrientation->size[0];
  outOrientation->size[0] = out_numel;
  emxEnsureCapacity_real32_T1(&b_st, outOrientation, i7, &ob_emlrtRTEI);
  i7 = b_features->size[0] * b_features->size[1];
  b_features->size[0] = out_numel;
  b_features->size[1] = 64;
  emxEnsureCapacity_real32_T(&b_st, b_features, i7, &ob_emlrtRTEI);
  extractSurf_assignOutput(ptrKeypoints, ptrDescriptors, &valLocation->data[0],
    &valScale->data[0], &valMetric->data[0], &valSignOfLaplacian->data[0],
    &outOrientation->data[0], &b_features->data[0]);
  i7 = features->size[0] * features->size[1];
  features->size[0] = b_features->size[0];
  features->size[1] = b_features->size[1];
  emxEnsureCapacity_real32_T(&st, features, i7, &pb_emlrtRTEI);
  loop_ub = b_features->size[0] * b_features->size[1];
  emxFree_real32_T(&st, &inLocation);
  emxFree_uint8_T(&st, &Iu8T);
  for (i7 = 0; i7 < loop_ub; i7++) {
    features->data[i7] = b_features->data[i7];
  }

  emxFree_real32_T(&st, &b_features);
  emxInit_real32_T1(&st, &vPts_Orientation, 1, &tb_emlrtRTEI, true);
  i7 = vPts_Orientation->size[0];
  vPts_Orientation->size[0] = outOrientation->size[0];
  emxEnsureCapacity_real32_T1(&st, vPts_Orientation, i7, &qb_emlrtRTEI);
  loop_ub = outOrientation->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    vPts_Orientation->data[i7] = 6.28318548F - outOrientation->data[i7];
  }

  emxFree_real32_T(&st, &outOrientation);
  emxInit_real32_T(&st, &inputs_Location, 2, &bb_emlrtRTEI, true);
  b_st.site = &gc_emlrtRSI;
  i7 = valid_points->pLocation->size[0] * valid_points->pLocation->size[1];
  valid_points->pLocation->size[0] = 0;
  valid_points->pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(&b_st, valid_points->pLocation, i7, &rb_emlrtRTEI);
  i7 = valid_points->pMetric->size[0];
  valid_points->pMetric->size[0] = 0;
  emxEnsureCapacity_real32_T1(&b_st, valid_points->pMetric, i7, &sb_emlrtRTEI);
  i7 = valid_points->pScale->size[0];
  valid_points->pScale->size[0] = 0;
  emxEnsureCapacity_real32_T1(&b_st, valid_points->pScale, i7, &sb_emlrtRTEI);
  i7 = valid_points->pSignOfLaplacian->size[0];
  valid_points->pSignOfLaplacian->size[0] = 0;
  emxEnsureCapacity_int8_T(&b_st, valid_points->pSignOfLaplacian, i7,
    &sb_emlrtRTEI);
  i7 = valid_points->pOrientation->size[0];
  valid_points->pOrientation->size[0] = 0;
  emxEnsureCapacity_real32_T1(&b_st, valid_points->pOrientation, i7,
    &sb_emlrtRTEI);
  c_st.site = &r_emlrtRSI;
  i7 = inputs_Location->size[0] * inputs_Location->size[1];
  inputs_Location->size[0] = valLocation->size[0];
  inputs_Location->size[1] = valLocation->size[1];
  emxEnsureCapacity_real32_T(&c_st, inputs_Location, i7, &bb_emlrtRTEI);
  loop_ub = valLocation->size[0] * valLocation->size[1];
  for (i7 = 0; i7 < loop_ub; i7++) {
    inputs_Location->data[i7] = valLocation->data[i7];
  }

  emxInit_real32_T1(&c_st, &inputs_Metric, 1, &bb_emlrtRTEI, true);
  i7 = inputs_Metric->size[0];
  inputs_Metric->size[0] = valMetric->size[0];
  emxEnsureCapacity_real32_T1(&c_st, inputs_Metric, i7, &bb_emlrtRTEI);
  loop_ub = valMetric->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    inputs_Metric->data[i7] = valMetric->data[i7];
  }

  emxInit_real32_T1(&c_st, &inputs_Scale, 1, &bb_emlrtRTEI, true);
  i7 = inputs_Scale->size[0];
  inputs_Scale->size[0] = valScale->size[0];
  emxEnsureCapacity_real32_T1(&c_st, inputs_Scale, i7, &bb_emlrtRTEI);
  loop_ub = valScale->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    inputs_Scale->data[i7] = valScale->data[i7];
  }

  emxInit_int8_T(&c_st, &inputs_SignOfLaplacian, 1, &bb_emlrtRTEI, true);
  i7 = inputs_SignOfLaplacian->size[0];
  inputs_SignOfLaplacian->size[0] = valSignOfLaplacian->size[0];
  emxEnsureCapacity_int8_T(&c_st, inputs_SignOfLaplacian, i7, &bb_emlrtRTEI);
  loop_ub = valSignOfLaplacian->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    inputs_SignOfLaplacian->data[i7] = valSignOfLaplacian->data[i7];
  }

  emxInit_real32_T1(&c_st, &inputs_Orientation, 1, &bb_emlrtRTEI, true);
  i7 = inputs_Orientation->size[0];
  inputs_Orientation->size[0] = vPts_Orientation->size[0];
  emxEnsureCapacity_real32_T1(&c_st, inputs_Orientation, i7, &bb_emlrtRTEI);
  loop_ub = vPts_Orientation->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    inputs_Orientation->data[i7] = vPts_Orientation->data[i7];
  }

  d_st.site = &s_emlrtRSI;
  e_st.site = &u_emlrtRSI;
  f_st.site = &bb_emlrtRSI;
  FeaturePointsImpl_checkLocation(&f_st, valLocation);
  f_st.site = &cb_emlrtRSI;
  FeaturePointsImpl_checkMetric(&f_st, valMetric);
  f_st.site = &db_emlrtRSI;
  if ((valMetric->size[0] == 1) || (valMetric->size[0] == valLocation->size[0]))
  {
    p = true;
  } else {
    p = false;
  }

  emxFree_real32_T(&f_st, &valMetric);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&f_st, &fi_emlrtRTEI,
      "vision:FeaturePoints:invalidParamLength",
      "vision:FeaturePoints:invalidParamLength", 3, 4, 6, "Metric");
  }

  e_st.site = &v_emlrtRSI;
  SURFPointsImpl_checkScale(&e_st, valScale);
  e_st.site = &w_emlrtRSI;
  f_st.site = &ib_emlrtRSI;
  g_st.site = &gb_emlrtRSI;
  h_st.site = &q_emlrtRSI;
  p = true;
  out_numel = 0;
  exitg1 = false;
  while ((!exitg1) && (out_numel <= vPts_Orientation->size[0] - 1)) {
    if (!muSingleScalarIsNaN(vPts_Orientation->data[out_numel])) {
      out_numel++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&h_st, &ii_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:vision.internal.SURFPoints_cg:expectedNonNaN", 3, 4, 11,
      "Orientation");
  }

  h_st.site = &q_emlrtRSI;
  p = b_all(vPts_Orientation);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&h_st, &ci_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:vision.internal.SURFPoints_cg:expectedFinite", 3, 4, 11,
      "Orientation");
  }

  emxInit_boolean_T(&h_st, &b_valSignOfLaplacian, 1, &cb_emlrtRTEI, true);
  e_st.site = &x_emlrtRSI;
  i7 = b_valSignOfLaplacian->size[0];
  b_valSignOfLaplacian->size[0] = valSignOfLaplacian->size[0];
  emxEnsureCapacity_boolean_T(&e_st, b_valSignOfLaplacian, i7, &cb_emlrtRTEI);
  loop_ub = valSignOfLaplacian->size[0];
  for (i7 = 0; i7 < loop_ub; i7++) {
    b_valSignOfLaplacian->data[i7] = (valSignOfLaplacian->data[i7] >= -1);
  }

  f_st.site = &jb_emlrtRSI;
  if (c_all(&f_st, b_valSignOfLaplacian)) {
    i7 = b_valSignOfLaplacian->size[0];
    b_valSignOfLaplacian->size[0] = valSignOfLaplacian->size[0];
    emxEnsureCapacity_boolean_T(&e_st, b_valSignOfLaplacian, i7, &db_emlrtRTEI);
    loop_ub = valSignOfLaplacian->size[0];
    for (i7 = 0; i7 < loop_ub; i7++) {
      b_valSignOfLaplacian->data[i7] = (valSignOfLaplacian->data[i7] <= 1);
    }

    f_st.site = &jb_emlrtRSI;
    if (c_all(&f_st, b_valSignOfLaplacian)) {
      p = true;
    } else {
      p = false;
    }
  } else {
    p = false;
  }

  emxFree_boolean_T(&e_st, &b_valSignOfLaplacian);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&e_st, &gi_emlrtRTEI,
      "vision:SURFPoints:invalidSignOfLaplacian",
      "vision:SURFPoints:invalidSignOfLaplacian", 0);
  }

  e_st.site = &y_emlrtRSI;
  if ((valScale->size[0] == 1) || (valScale->size[0] == valLocation->size[0])) {
    p = true;
  } else {
    p = false;
  }

  emxFree_real32_T(&e_st, &valScale);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&e_st, &fi_emlrtRTEI,
      "vision:FeaturePoints:invalidParamLength",
      "vision:FeaturePoints:invalidParamLength", 3, 4, 5, "Scale");
  }

  e_st.site = &ab_emlrtRSI;
  if ((valSignOfLaplacian->size[0] == 1) || (valSignOfLaplacian->size[0] ==
       valLocation->size[0])) {
    p = true;
  } else {
    p = false;
  }

  emxFree_int8_T(&e_st, &valSignOfLaplacian);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&e_st, &fi_emlrtRTEI,
      "vision:FeaturePoints:invalidParamLength",
      "vision:FeaturePoints:invalidParamLength", 3, 4, 15, "SignOfLaplacian");
  }

  e_st.site = &hc_emlrtRSI;
  if ((vPts_Orientation->size[0] == 1) || (vPts_Orientation->size[0] ==
       valLocation->size[0])) {
    p = true;
  } else {
    p = false;
  }

  emxFree_real32_T(&e_st, &valLocation);
  emxFree_real32_T(&e_st, &vPts_Orientation);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&e_st, &fi_emlrtRTEI,
      "vision:FeaturePoints:invalidParamLength",
      "vision:FeaturePoints:invalidParamLength", 3, 4, 11, "Orientation");
  }

  d_st.site = &t_emlrtRSI;
  b_SURFPointsImpl_configure(&d_st, valid_points, inputs_Location, inputs_Metric,
    inputs_Scale, inputs_SignOfLaplacian, inputs_Orientation);
  emxFree_real32_T(sp, &inputs_Orientation);
  emxFree_int8_T(sp, &inputs_SignOfLaplacian);
  emxFree_real32_T(sp, &inputs_Scale);
  emxFree_real32_T(sp, &inputs_Metric);
  emxFree_real32_T(sp, &inputs_Location);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (extractFeatures.c) */

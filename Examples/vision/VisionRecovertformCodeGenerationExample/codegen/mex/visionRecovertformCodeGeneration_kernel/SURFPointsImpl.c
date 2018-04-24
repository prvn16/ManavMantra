/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * SURFPointsImpl.c
 *
 * Code generation for function 'SURFPointsImpl'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "SURFPointsImpl.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "xgetrf.h"
#include "eml_int_forloop_overflow_check.h"
#include "all.h"
#include "visionRecovertformCodeGeneration_kernel_mexutil.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo hb_emlrtRSI = { 221,/* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

static emlrtRSInfo nb_emlrtRSI = { 173,/* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

static emlrtRSInfo ob_emlrtRSI = { 182,/* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

static emlrtRSInfo pb_emlrtRSI = { 185,/* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

static emlrtRSInfo qb_emlrtRSI = { 188,/* lineNo */
  "SURFPointsImpl",                    /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pathName */
};

static emlrtRSInfo rb_emlrtRSI = { 283,/* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

static emlrtRSInfo sb_emlrtRSI = { 343,/* lineNo */
  "FeaturePointsImpl",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pathName */
};

static emlrtRSInfo ub_emlrtRSI = { 63, /* lineNo */
  "repmat",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pathName */
};

static emlrtRSInfo vb_emlrtRSI = { 65, /* lineNo */
  "repmat",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\repmat.m"/* pathName */
};

static emlrtRTEInfo gb_emlrtRTEI = { 171,/* lineNo */
  25,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo ah_emlrtRTEI = { 278,/* lineNo */
  13,                                  /* colNo */
  "FeaturePointsImpl",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pName */
};

static emlrtRTEInfo bh_emlrtRTEI = { 173,/* lineNo */
  20,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo ch_emlrtRTEI = { 283,/* lineNo */
  17,                                  /* colNo */
  "FeaturePointsImpl",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pName */
};

static emlrtRTEInfo dh_emlrtRTEI = { 173,/* lineNo */
  13,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo eh_emlrtRTEI = { 343,/* lineNo */
  21,                                  /* colNo */
  "FeaturePointsImpl",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pName */
};

static emlrtRTEInfo fh_emlrtRTEI = { 182,/* lineNo */
  17,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo gh_emlrtRTEI = { 181,/* lineNo */
  13,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo hh_emlrtRTEI = { 184,/* lineNo */
  13,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo ih_emlrtRTEI = { 188,/* lineNo */
  63,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo jh_emlrtRTEI = { 345,/* lineNo */
  17,                                  /* colNo */
  "FeaturePointsImpl",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pName */
};

static emlrtRTEInfo kh_emlrtRTEI = { 187,/* lineNo */
  13,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo lh_emlrtRTEI = { 188,/* lineNo */
  17,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo mh_emlrtRTEI = { 185,/* lineNo */
  17,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtRTEInfo ki_emlrtRTEI = { 27,/* lineNo */
  27,                                  /* colNo */
  "validatege",                        /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatege.m"/* pName */
};

static emlrtECInfo k_emlrtECI = { -1,  /* nDims */
  282,                                 /* lineNo */
  13,                                  /* colNo */
  "FeaturePointsImpl",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\FeaturePointsImpl.m"/* pName */
};

static emlrtECInfo l_emlrtECI = { -1,  /* nDims */
  187,                                 /* lineNo */
  13,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtECInfo m_emlrtECI = { -1,  /* nDims */
  184,                                 /* lineNo */
  13,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

static emlrtECInfo n_emlrtECI = { -1,  /* nDims */
  181,                                 /* lineNo */
  13,                                  /* colNo */
  "SURFPointsImpl",                    /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\SURFPointsImpl.m"/* pName */
};

/* Function Definitions */
void SURFPointsImpl_checkScale(const emlrtStack *sp, const emxArray_real32_T
  *scale)
{
  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  st.site = &hb_emlrtRSI;
  b_st.prev = &st;
  b_st.tls = st.tls;
  b_st.site = &q_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= scale->size[0] - 1)) {
    if (!muSingleScalarIsNaN(scale->data[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ii_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonNaN",
      "MATLAB:vision.internal.SURFPoints_cg:expectedNonNaN", 3, 4, 5, "Scale");
  }

  b_st.site = &q_emlrtRSI;
  p = b_all(scale);
  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ci_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedFinite",
      "MATLAB:vision.internal.SURFPoints_cg:expectedFinite", 3, 4, 5, "Scale");
  }

  b_st.site = &q_emlrtRSI;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= scale->size[0] - 1)) {
    if (scale->data[k] >= 1.6) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ki_emlrtRTEI,
      "MATLAB:validateattributes:expectedArray",
      "MATLAB:vision.internal.SURFPoints_cg:notGreaterEqual", 9, 4, 5, "Scale",
      4, 2, ">=", 4, 3, "1.6");
  }
}

void SURFPointsImpl_configure(const emlrtStack *sp,
  vision_internal_SURFPoints_cg *this, const emxArray_real32_T *inputs_Location,
  const emxArray_real32_T *inputs_Metric, const emxArray_real32_T *inputs_Scale,
  const emxArray_int8_T *inputs_SignOfLaplacian)
{
  int32_T i26;
  int32_T outsize_idx_0;
  emxArray_real32_T *v;
  const mxArray *y;
  const mxArray *m16;
  static const int32_T iv29[2] = { 1, 15 };

  boolean_T overflow;
  int32_T n;
  static const int32_T iv30[2] = { 1, 15 };

  static const int32_T iv31[2] = { 1, 15 };

  emxArray_int8_T *x;
  static const int32_T iv32[2] = { 1, 15 };

  emxArray_int8_T *r20;
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
  st.site = &nb_emlrtRSI;
  i26 = this->pLocation->size[0] * this->pLocation->size[1];
  this->pLocation->size[0] = inputs_Location->size[0];
  this->pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(&st, this->pLocation, i26, &ah_emlrtRTEI);
  outsize_idx_0 = inputs_Location->size[0] * inputs_Location->size[1];
  for (i26 = 0; i26 < outsize_idx_0; i26++) {
    this->pLocation->data[i26] = inputs_Location->data[i26];
  }

  i26 = this->pMetric->size[0];
  this->pMetric->size[0] = inputs_Location->size[0];
  emxEnsureCapacity_real32_T1(&st, this->pMetric, i26, &bh_emlrtRTEI);
  b_st.site = &rb_emlrtRSI;
  emxInit_real32_T1(&b_st, &v, 1, &lh_emlrtRTEI, true);
  if (inputs_Metric->size[0] == 1) {
    c_st.site = &sb_emlrtRSI;
    d_st.site = &tb_emlrtRSI;
    outsize_idx_0 = inputs_Location->size[0];
    if (outsize_idx_0 != inputs_Location->size[0]) {
      y = NULL;
      m16 = emlrtCreateCharArray(2, iv29);
      emlrtInitCharArrayR2013a(&c_st, 15, m16, &cv0[0]);
      emlrtAssign(&y, m16);
      d_st.site = &sm_emlrtRSI;
      i_error(&d_st, y, &b_emlrtMCI);
    }

    i26 = v->size[0];
    v->size[0] = outsize_idx_0;
    emxEnsureCapacity_real32_T1(&c_st, v, i26, &eh_emlrtRTEI);
    d_st.site = &ub_emlrtRSI;
    overflow = ((!(1 > inputs_Location->size[0])) && (inputs_Location->size[0] >
      2147483646));
    if (overflow) {
      e_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&e_st);
    }

    for (outsize_idx_0 = 1; outsize_idx_0 <= inputs_Location->size[0];
         outsize_idx_0++) {
      d_st.site = &vb_emlrtRSI;
      v->data[outsize_idx_0 - 1] = inputs_Metric->data[0];
    }
  } else {
    i26 = v->size[0];
    v->size[0] = inputs_Metric->size[0];
    emxEnsureCapacity_real32_T1(&b_st, v, i26, &ch_emlrtRTEI);
    outsize_idx_0 = inputs_Metric->size[0];
    for (i26 = 0; i26 < outsize_idx_0; i26++) {
      v->data[i26] = inputs_Metric->data[i26];
    }
  }

  i26 = this->pMetric->size[0];
  outsize_idx_0 = v->size[0];
  if (i26 != outsize_idx_0) {
    emlrtSubAssignSizeCheck1dR2017a(i26, outsize_idx_0, &k_emlrtECI, &st);
  }

  i26 = this->pMetric->size[0];
  this->pMetric->size[0] = v->size[0];
  emxEnsureCapacity_real32_T1(&st, this->pMetric, i26, &dh_emlrtRTEI);
  outsize_idx_0 = v->size[0];
  for (i26 = 0; i26 < outsize_idx_0; i26++) {
    this->pMetric->data[i26] = v->data[i26];
  }

  n = inputs_Location->size[0];
  i26 = this->pScale->size[0];
  this->pScale->size[0] = inputs_Location->size[0];
  emxEnsureCapacity_real32_T1(sp, this->pScale, i26, &gb_emlrtRTEI);
  i26 = this->pOrientation->size[0];
  this->pOrientation->size[0] = inputs_Location->size[0];
  emxEnsureCapacity_real32_T1(sp, this->pOrientation, i26, &gb_emlrtRTEI);
  i26 = this->pSignOfLaplacian->size[0];
  this->pSignOfLaplacian->size[0] = inputs_Location->size[0];
  emxEnsureCapacity_int8_T(sp, this->pSignOfLaplacian, i26, &gb_emlrtRTEI);
  st.site = &ob_emlrtRSI;
  if (inputs_Scale->size[0] == 1) {
    b_st.site = &sb_emlrtRSI;
    c_st.site = &tb_emlrtRSI;
    outsize_idx_0 = inputs_Location->size[0];
    if (outsize_idx_0 != inputs_Location->size[0]) {
      y = NULL;
      m16 = emlrtCreateCharArray(2, iv30);
      emlrtInitCharArrayR2013a(&b_st, 15, m16, &cv0[0]);
      emlrtAssign(&y, m16);
      c_st.site = &sm_emlrtRSI;
      i_error(&c_st, y, &b_emlrtMCI);
    }

    i26 = v->size[0];
    v->size[0] = outsize_idx_0;
    emxEnsureCapacity_real32_T1(&b_st, v, i26, &eh_emlrtRTEI);
    c_st.site = &ub_emlrtRSI;
    overflow = ((!(1 > inputs_Location->size[0])) && (inputs_Location->size[0] >
      2147483646));
    if (overflow) {
      d_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }

    for (outsize_idx_0 = 1; outsize_idx_0 <= n; outsize_idx_0++) {
      c_st.site = &vb_emlrtRSI;
      v->data[outsize_idx_0 - 1] = inputs_Scale->data[0];
    }
  } else {
    i26 = v->size[0];
    v->size[0] = inputs_Scale->size[0];
    emxEnsureCapacity_real32_T1(&st, v, i26, &fh_emlrtRTEI);
    outsize_idx_0 = inputs_Scale->size[0];
    for (i26 = 0; i26 < outsize_idx_0; i26++) {
      v->data[i26] = inputs_Scale->data[i26];
    }
  }

  i26 = this->pScale->size[0];
  outsize_idx_0 = v->size[0];
  if (i26 != outsize_idx_0) {
    emlrtSubAssignSizeCheck1dR2017a(i26, outsize_idx_0, &n_emlrtECI, sp);
  }

  i26 = this->pScale->size[0];
  this->pScale->size[0] = v->size[0];
  emxEnsureCapacity_real32_T1(sp, this->pScale, i26, &gh_emlrtRTEI);
  outsize_idx_0 = v->size[0];
  for (i26 = 0; i26 < outsize_idx_0; i26++) {
    this->pScale->data[i26] = v->data[i26];
  }

  st.site = &pb_emlrtRSI;
  b_st.site = &sb_emlrtRSI;
  c_st.site = &tb_emlrtRSI;
  outsize_idx_0 = inputs_Location->size[0];
  if (outsize_idx_0 != inputs_Location->size[0]) {
    y = NULL;
    m16 = emlrtCreateCharArray(2, iv31);
    emlrtInitCharArrayR2013a(&b_st, 15, m16, &cv0[0]);
    emlrtAssign(&y, m16);
    c_st.site = &sm_emlrtRSI;
    i_error(&c_st, y, &b_emlrtMCI);
  }

  i26 = this->pOrientation->size[0];
  if (i26 != outsize_idx_0) {
    emlrtSubAssignSizeCheck1dR2017a(i26, outsize_idx_0, &m_emlrtECI, sp);
  }

  i26 = this->pOrientation->size[0];
  this->pOrientation->size[0] = outsize_idx_0;
  emxEnsureCapacity_real32_T1(sp, this->pOrientation, i26, &hh_emlrtRTEI);
  for (i26 = 0; i26 < outsize_idx_0; i26++) {
    this->pOrientation->data[i26] = 0.0F;
  }

  emxInit_int8_T(sp, &x, 1, &ih_emlrtRTEI, true);
  st.site = &qb_emlrtRSI;
  i26 = x->size[0];
  x->size[0] = inputs_SignOfLaplacian->size[0];
  emxEnsureCapacity_int8_T(&st, x, i26, &ih_emlrtRTEI);
  outsize_idx_0 = inputs_SignOfLaplacian->size[0];
  for (i26 = 0; i26 < outsize_idx_0; i26++) {
    x->data[i26] = inputs_SignOfLaplacian->data[i26];
  }

  if (x->size[0] == 1) {
    b_st.site = &sb_emlrtRSI;
    c_st.site = &tb_emlrtRSI;
    outsize_idx_0 = inputs_Location->size[0];
    if (outsize_idx_0 != inputs_Location->size[0]) {
      y = NULL;
      m16 = emlrtCreateCharArray(2, iv32);
      emlrtInitCharArrayR2013a(&b_st, 15, m16, &cv0[0]);
      emlrtAssign(&y, m16);
      c_st.site = &sm_emlrtRSI;
      i_error(&c_st, y, &b_emlrtMCI);
    }

    i26 = v->size[0];
    v->size[0] = outsize_idx_0;
    emxEnsureCapacity_real32_T1(&b_st, v, i26, &eh_emlrtRTEI);
    c_st.site = &ub_emlrtRSI;
    overflow = ((!(1 > inputs_Location->size[0])) && (inputs_Location->size[0] >
      2147483646));
    if (overflow) {
      d_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }

    for (outsize_idx_0 = 1; outsize_idx_0 <= n; outsize_idx_0++) {
      c_st.site = &vb_emlrtRSI;
      v->data[outsize_idx_0 - 1] = x->data[0];
    }
  } else {
    i26 = v->size[0];
    v->size[0] = x->size[0];
    emxEnsureCapacity_real32_T1(&st, v, i26, &jh_emlrtRTEI);
    outsize_idx_0 = x->size[0];
    for (i26 = 0; i26 < outsize_idx_0; i26++) {
      v->data[i26] = x->data[i26];
    }
  }

  emxFree_int8_T(&st, &x);
  emxInit_int8_T(&st, &r20, 1, &gb_emlrtRTEI, true);
  i26 = r20->size[0];
  r20->size[0] = v->size[0];
  emxEnsureCapacity_int8_T(sp, r20, i26, &kh_emlrtRTEI);
  outsize_idx_0 = v->size[0];
  for (i26 = 0; i26 < outsize_idx_0; i26++) {
    r20->data[i26] = (int8_T)v->data[i26];
  }

  emxFree_real32_T(sp, &v);
  i26 = this->pSignOfLaplacian->size[0];
  outsize_idx_0 = r20->size[0];
  if (i26 != outsize_idx_0) {
    emlrtSubAssignSizeCheck1dR2017a(i26, outsize_idx_0, &l_emlrtECI, sp);
  }

  i26 = this->pSignOfLaplacian->size[0];
  this->pSignOfLaplacian->size[0] = r20->size[0];
  emxEnsureCapacity_int8_T(sp, this->pSignOfLaplacian, i26, &kh_emlrtRTEI);
  outsize_idx_0 = r20->size[0];
  for (i26 = 0; i26 < outsize_idx_0; i26++) {
    this->pSignOfLaplacian->data[i26] = r20->data[i26];
  }

  emxFree_int8_T(sp, &r20);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void b_SURFPointsImpl_configure(const emlrtStack *sp,
  vision_internal_SURFPoints_cg *this, const emxArray_real32_T *inputs_Location,
  const emxArray_real32_T *inputs_Metric, const emxArray_real32_T *inputs_Scale,
  const emxArray_int8_T *inputs_SignOfLaplacian, const emxArray_real32_T
  *inputs_Orientation)
{
  int32_T i27;
  int32_T outsize_idx_0;
  emxArray_real32_T *v;
  const mxArray *y;
  const mxArray *m17;
  static const int32_T iv33[2] = { 1, 15 };

  boolean_T overflow;
  int32_T n;
  static const int32_T iv34[2] = { 1, 15 };

  static const int32_T iv35[2] = { 1, 15 };

  emxArray_int8_T *x;
  static const int32_T iv36[2] = { 1, 15 };

  emxArray_int8_T *r21;
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
  st.site = &nb_emlrtRSI;
  i27 = this->pLocation->size[0] * this->pLocation->size[1];
  this->pLocation->size[0] = inputs_Location->size[0];
  this->pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(&st, this->pLocation, i27, &ah_emlrtRTEI);
  outsize_idx_0 = inputs_Location->size[0] * inputs_Location->size[1];
  for (i27 = 0; i27 < outsize_idx_0; i27++) {
    this->pLocation->data[i27] = inputs_Location->data[i27];
  }

  i27 = this->pMetric->size[0];
  this->pMetric->size[0] = inputs_Location->size[0];
  emxEnsureCapacity_real32_T1(&st, this->pMetric, i27, &bh_emlrtRTEI);
  b_st.site = &rb_emlrtRSI;
  emxInit_real32_T1(&b_st, &v, 1, &lh_emlrtRTEI, true);
  if (inputs_Metric->size[0] == 1) {
    c_st.site = &sb_emlrtRSI;
    d_st.site = &tb_emlrtRSI;
    outsize_idx_0 = inputs_Location->size[0];
    if (outsize_idx_0 != inputs_Location->size[0]) {
      y = NULL;
      m17 = emlrtCreateCharArray(2, iv33);
      emlrtInitCharArrayR2013a(&c_st, 15, m17, &cv0[0]);
      emlrtAssign(&y, m17);
      d_st.site = &sm_emlrtRSI;
      i_error(&d_st, y, &b_emlrtMCI);
    }

    i27 = v->size[0];
    v->size[0] = outsize_idx_0;
    emxEnsureCapacity_real32_T1(&c_st, v, i27, &eh_emlrtRTEI);
    d_st.site = &ub_emlrtRSI;
    overflow = ((!(1 > inputs_Location->size[0])) && (inputs_Location->size[0] >
      2147483646));
    if (overflow) {
      e_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&e_st);
    }

    for (outsize_idx_0 = 1; outsize_idx_0 <= inputs_Location->size[0];
         outsize_idx_0++) {
      d_st.site = &vb_emlrtRSI;
      v->data[outsize_idx_0 - 1] = inputs_Metric->data[0];
    }
  } else {
    i27 = v->size[0];
    v->size[0] = inputs_Metric->size[0];
    emxEnsureCapacity_real32_T1(&b_st, v, i27, &ch_emlrtRTEI);
    outsize_idx_0 = inputs_Metric->size[0];
    for (i27 = 0; i27 < outsize_idx_0; i27++) {
      v->data[i27] = inputs_Metric->data[i27];
    }
  }

  i27 = this->pMetric->size[0];
  outsize_idx_0 = v->size[0];
  if (i27 != outsize_idx_0) {
    emlrtSubAssignSizeCheck1dR2017a(i27, outsize_idx_0, &k_emlrtECI, &st);
  }

  i27 = this->pMetric->size[0];
  this->pMetric->size[0] = v->size[0];
  emxEnsureCapacity_real32_T1(&st, this->pMetric, i27, &dh_emlrtRTEI);
  outsize_idx_0 = v->size[0];
  for (i27 = 0; i27 < outsize_idx_0; i27++) {
    this->pMetric->data[i27] = v->data[i27];
  }

  n = inputs_Location->size[0];
  i27 = this->pScale->size[0];
  this->pScale->size[0] = inputs_Location->size[0];
  emxEnsureCapacity_real32_T1(sp, this->pScale, i27, &gb_emlrtRTEI);
  i27 = this->pOrientation->size[0];
  this->pOrientation->size[0] = inputs_Location->size[0];
  emxEnsureCapacity_real32_T1(sp, this->pOrientation, i27, &gb_emlrtRTEI);
  i27 = this->pSignOfLaplacian->size[0];
  this->pSignOfLaplacian->size[0] = inputs_Location->size[0];
  emxEnsureCapacity_int8_T(sp, this->pSignOfLaplacian, i27, &gb_emlrtRTEI);
  st.site = &ob_emlrtRSI;
  if (inputs_Scale->size[0] == 1) {
    b_st.site = &sb_emlrtRSI;
    c_st.site = &tb_emlrtRSI;
    outsize_idx_0 = inputs_Location->size[0];
    if (outsize_idx_0 != inputs_Location->size[0]) {
      y = NULL;
      m17 = emlrtCreateCharArray(2, iv34);
      emlrtInitCharArrayR2013a(&b_st, 15, m17, &cv0[0]);
      emlrtAssign(&y, m17);
      c_st.site = &sm_emlrtRSI;
      i_error(&c_st, y, &b_emlrtMCI);
    }

    i27 = v->size[0];
    v->size[0] = outsize_idx_0;
    emxEnsureCapacity_real32_T1(&b_st, v, i27, &eh_emlrtRTEI);
    c_st.site = &ub_emlrtRSI;
    overflow = ((!(1 > inputs_Location->size[0])) && (inputs_Location->size[0] >
      2147483646));
    if (overflow) {
      d_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }

    for (outsize_idx_0 = 1; outsize_idx_0 <= n; outsize_idx_0++) {
      c_st.site = &vb_emlrtRSI;
      v->data[outsize_idx_0 - 1] = inputs_Scale->data[0];
    }
  } else {
    i27 = v->size[0];
    v->size[0] = inputs_Scale->size[0];
    emxEnsureCapacity_real32_T1(&st, v, i27, &fh_emlrtRTEI);
    outsize_idx_0 = inputs_Scale->size[0];
    for (i27 = 0; i27 < outsize_idx_0; i27++) {
      v->data[i27] = inputs_Scale->data[i27];
    }
  }

  i27 = this->pScale->size[0];
  outsize_idx_0 = v->size[0];
  if (i27 != outsize_idx_0) {
    emlrtSubAssignSizeCheck1dR2017a(i27, outsize_idx_0, &n_emlrtECI, sp);
  }

  i27 = this->pScale->size[0];
  this->pScale->size[0] = v->size[0];
  emxEnsureCapacity_real32_T1(sp, this->pScale, i27, &gh_emlrtRTEI);
  outsize_idx_0 = v->size[0];
  for (i27 = 0; i27 < outsize_idx_0; i27++) {
    this->pScale->data[i27] = v->data[i27];
  }

  st.site = &pb_emlrtRSI;
  if (inputs_Orientation->size[0] == 1) {
    b_st.site = &sb_emlrtRSI;
    c_st.site = &tb_emlrtRSI;
    outsize_idx_0 = inputs_Location->size[0];
    if (outsize_idx_0 != inputs_Location->size[0]) {
      y = NULL;
      m17 = emlrtCreateCharArray(2, iv35);
      emlrtInitCharArrayR2013a(&b_st, 15, m17, &cv0[0]);
      emlrtAssign(&y, m17);
      c_st.site = &sm_emlrtRSI;
      i_error(&c_st, y, &b_emlrtMCI);
    }

    i27 = v->size[0];
    v->size[0] = outsize_idx_0;
    emxEnsureCapacity_real32_T1(&b_st, v, i27, &eh_emlrtRTEI);
    c_st.site = &ub_emlrtRSI;
    overflow = ((!(1 > inputs_Location->size[0])) && (inputs_Location->size[0] >
      2147483646));
    if (overflow) {
      d_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }

    for (outsize_idx_0 = 1; outsize_idx_0 <= n; outsize_idx_0++) {
      c_st.site = &vb_emlrtRSI;
      v->data[outsize_idx_0 - 1] = inputs_Orientation->data[0];
    }
  } else {
    i27 = v->size[0];
    v->size[0] = inputs_Orientation->size[0];
    emxEnsureCapacity_real32_T1(&st, v, i27, &mh_emlrtRTEI);
    outsize_idx_0 = inputs_Orientation->size[0];
    for (i27 = 0; i27 < outsize_idx_0; i27++) {
      v->data[i27] = inputs_Orientation->data[i27];
    }
  }

  i27 = this->pOrientation->size[0];
  outsize_idx_0 = v->size[0];
  if (i27 != outsize_idx_0) {
    emlrtSubAssignSizeCheck1dR2017a(i27, outsize_idx_0, &m_emlrtECI, sp);
  }

  i27 = this->pOrientation->size[0];
  this->pOrientation->size[0] = v->size[0];
  emxEnsureCapacity_real32_T1(sp, this->pOrientation, i27, &hh_emlrtRTEI);
  outsize_idx_0 = v->size[0];
  for (i27 = 0; i27 < outsize_idx_0; i27++) {
    this->pOrientation->data[i27] = v->data[i27];
  }

  emxInit_int8_T(sp, &x, 1, &ih_emlrtRTEI, true);
  st.site = &qb_emlrtRSI;
  i27 = x->size[0];
  x->size[0] = inputs_SignOfLaplacian->size[0];
  emxEnsureCapacity_int8_T(&st, x, i27, &ih_emlrtRTEI);
  outsize_idx_0 = inputs_SignOfLaplacian->size[0];
  for (i27 = 0; i27 < outsize_idx_0; i27++) {
    x->data[i27] = inputs_SignOfLaplacian->data[i27];
  }

  if (x->size[0] == 1) {
    b_st.site = &sb_emlrtRSI;
    c_st.site = &tb_emlrtRSI;
    outsize_idx_0 = inputs_Location->size[0];
    if (outsize_idx_0 != inputs_Location->size[0]) {
      y = NULL;
      m17 = emlrtCreateCharArray(2, iv36);
      emlrtInitCharArrayR2013a(&b_st, 15, m17, &cv0[0]);
      emlrtAssign(&y, m17);
      c_st.site = &sm_emlrtRSI;
      i_error(&c_st, y, &b_emlrtMCI);
    }

    i27 = v->size[0];
    v->size[0] = outsize_idx_0;
    emxEnsureCapacity_real32_T1(&b_st, v, i27, &eh_emlrtRTEI);
    c_st.site = &ub_emlrtRSI;
    overflow = ((!(1 > inputs_Location->size[0])) && (inputs_Location->size[0] >
      2147483646));
    if (overflow) {
      d_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&d_st);
    }

    for (outsize_idx_0 = 1; outsize_idx_0 <= n; outsize_idx_0++) {
      c_st.site = &vb_emlrtRSI;
      v->data[outsize_idx_0 - 1] = x->data[0];
    }
  } else {
    i27 = v->size[0];
    v->size[0] = x->size[0];
    emxEnsureCapacity_real32_T1(&st, v, i27, &jh_emlrtRTEI);
    outsize_idx_0 = x->size[0];
    for (i27 = 0; i27 < outsize_idx_0; i27++) {
      v->data[i27] = x->data[i27];
    }
  }

  emxFree_int8_T(&st, &x);
  emxInit_int8_T(&st, &r21, 1, &gb_emlrtRTEI, true);
  i27 = r21->size[0];
  r21->size[0] = v->size[0];
  emxEnsureCapacity_int8_T(sp, r21, i27, &kh_emlrtRTEI);
  outsize_idx_0 = v->size[0];
  for (i27 = 0; i27 < outsize_idx_0; i27++) {
    r21->data[i27] = (int8_T)v->data[i27];
  }

  emxFree_real32_T(sp, &v);
  i27 = this->pSignOfLaplacian->size[0];
  outsize_idx_0 = r21->size[0];
  if (i27 != outsize_idx_0) {
    emlrtSubAssignSizeCheck1dR2017a(i27, outsize_idx_0, &l_emlrtECI, sp);
  }

  i27 = this->pSignOfLaplacian->size[0];
  this->pSignOfLaplacian->size[0] = r21->size[0];
  emxEnsureCapacity_int8_T(sp, this->pSignOfLaplacian, i27, &kh_emlrtRTEI);
  outsize_idx_0 = r21->size[0];
  for (i27 = 0; i27 < outsize_idx_0; i27++) {
    this->pSignOfLaplacian->data[i27] = r21->data[i27];
  }

  emxFree_int8_T(sp, &r21);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (SURFPointsImpl.c) */

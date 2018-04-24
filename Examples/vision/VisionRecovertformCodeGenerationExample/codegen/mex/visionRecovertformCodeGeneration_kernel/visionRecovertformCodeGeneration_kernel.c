/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * visionRecovertformCodeGeneration_kernel.c
 *
 * Code generation for function 'visionRecovertformCodeGeneration_kernel'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "imwarp.h"
#include "error.h"
#include "isequal.h"
#include "det.h"
#include "validateattributes.h"
#include "inv.h"
#include "estimateGeometricTransform.h"
#include "cvalgMatchFeatures.h"
#include "extractFeatures.h"
#include "detectSURFFeatures.h"
#include "visionRecovertformCodeGeneration_kernel_mexutil.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo emlrtRSI = { 11,    /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo b_emlrtRSI = { 12,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo c_emlrtRSI = { 15,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo d_emlrtRSI = { 16,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo e_emlrtRSI = { 19,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo f_emlrtRSI = { 29,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo g_emlrtRSI = { 33,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo h_emlrtRSI = { 37,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo i_emlrtRSI = { 42,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo j_emlrtRSI = { 41,  /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

static emlrtRSInfo ic_emlrtRSI = { 186,/* lineNo */
  "matchFeatures",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pathName */
};

static emlrtRSInfo jc_emlrtRSI = { 32, /* lineNo */
  "cvalgMatchFeatures",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\cvalgMatchFeatures.m"/* pathName */
};

static emlrtRSInfo kc_emlrtRSI = { 52, /* lineNo */
  "cvalgMatchFeatures",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\cvalgMatchFeatures.m"/* pathName */
};

static emlrtRSInfo lc_emlrtRSI = { 350,/* lineNo */
  "cvalgMatchFeatures",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\cvalgMatchFeatures.m"/* pathName */
};

static emlrtRSInfo mc_emlrtRSI = { 351,/* lineNo */
  "cvalgMatchFeatures",                /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\cvalgMatchFeatures.m"/* pathName */
};

static emlrtMCInfo emlrtMCI = { 45,    /* lineNo */
  1,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo emlrtRTEI = { 11,  /* lineNo */
  1,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo b_emlrtRTEI = { 12,/* lineNo */
  1,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo c_emlrtRTEI = { 15,/* lineNo */
  1,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo d_emlrtRTEI = { 16,/* lineNo */
  1,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo e_emlrtRTEI = { 184,/* lineNo */
  14,                                  /* colNo */
  "matchFeatures",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pName */
};

static emlrtRTEInfo f_emlrtRTEI = { 184,/* lineNo */
  2,                                   /* colNo */
  "matchFeatures",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pName */
};

static emlrtRTEInfo g_emlrtRTEI = { 185,/* lineNo */
  14,                                  /* colNo */
  "matchFeatures",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pName */
};

static emlrtRTEInfo h_emlrtRTEI = { 185,/* lineNo */
  2,                                   /* colNo */
  "matchFeatures",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pName */
};

static emlrtRTEInfo i_emlrtRTEI = { 21,/* lineNo */
  5,                                   /* colNo */
  "cvalgMatchFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\cvalgMatchFeatures.m"/* pName */
};

static emlrtRTEInfo j_emlrtRTEI = { 350,/* lineNo */
  1,                                   /* colNo */
  "cvalgMatchFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\cvalgMatchFeatures.m"/* pName */
};

static emlrtRTEInfo k_emlrtRTEI = { 19,/* lineNo */
  1,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo l_emlrtRTEI = { 351,/* lineNo */
  1,                                   /* colNo */
  "cvalgMatchFeatures",                /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\cvalgMatchFeatures.m"/* pName */
};

static emlrtRTEInfo m_emlrtRTEI = { 24,/* lineNo */
  1,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo n_emlrtRTEI = { 25,/* lineNo */
  1,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo o_emlrtRTEI = { 15,/* lineNo */
  2,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo p_emlrtRTEI = { 15,/* lineNo */
  21,                                  /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo q_emlrtRTEI = { 16,/* lineNo */
  2,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo r_emlrtRTEI = { 5, /* lineNo */
  5,                                   /* colNo */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pName */
};

static emlrtRTEInfo s_emlrtRTEI = { 164,/* lineNo */
  6,                                   /* colNo */
  "matchFeatures",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pName */
};

static emlrtRTEInfo t_emlrtRTEI = { 164,/* lineNo */
  17,                                  /* colNo */
  "matchFeatures",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pName */
};

static emlrtRTEInfo u_emlrtRTEI = { 187,/* lineNo */
  22,                                  /* colNo */
  "matchFeatures",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pName */
};

static emlrtRTEInfo v_emlrtRTEI = { 187,/* lineNo */
  33,                                  /* colNo */
  "matchFeatures",                     /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\matchFeatures.m"/* pName */
};

static emlrtBCInfo emlrtBCI = { -1,    /* iFirst */
  -1,                                  /* iLast */
  35,                                  /* lineNo */
  11,                                  /* colNo */
  "Tinv",                              /* aName */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m",                              /* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo b_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  36,                                  /* lineNo */
  11,                                  /* colNo */
  "Tinv",                              /* aName */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m",                              /* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo c_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  381,                                 /* lineNo */
  20,                                  /* colNo */
  "",                                  /* aName */
  "affine2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m",/* pName */
  0                                    /* checkKind */
};

static emlrtECInfo emlrtECI = { -1,    /* nDims */
  381,                                 /* lineNo */
  13,                                  /* colNo */
  "affine2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\affine2d.m"/* pName */
};

static emlrtRTEInfo di_emlrtRTEI = { 360,/* lineNo */
  17,                                  /* colNo */
  "imref2d",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\imref2d.m"/* pName */
};

static emlrtRTEInfo ei_emlrtRTEI = { 382,/* lineNo */
  17,                                  /* colNo */
  "imref2d",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\imref2d.m"/* pName */
};

static emlrtBCInfo e_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  24,                                  /* lineNo */
  46,                                  /* colNo */
  "validPtsOriginal.Location",         /* aName */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m",                              /* pName */
  0                                    /* checkKind */
};

static emlrtBCInfo f_emlrtBCI = { -1,  /* iFirst */
  -1,                                  /* iLast */
  25,                                  /* lineNo */
  47,                                  /* colNo */
  "validPtsDistorted.Location",        /* aName */
  "visionRecovertformCodeGeneration_kernel",/* fName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m",                              /* pName */
  0                                    /* checkKind */
};

static emlrtRSInfo rm_emlrtRSI = { 45, /* lineNo */
  "visionRecovertformCodeGeneration_kernel",/* fcnName */
  "C:\\Sumpurn\\Projects\\ManavYantraLib\\Examples\\vision\\VisionRecovertformCodeGenerationExample\\visionRecovertformCodeGeneration_kern"
  "el.m"                               /* pathName */
};

/* Function Declarations */
static const mxArray *b_emlrt_marshallOut(const emxArray_real32_T *u);
static const mxArray *c_emlrt_marshallOut(const emxArray_real32_T *u);
static void c_featureMatchingVisualization_(const emlrtStack *sp, const mxArray *
  b, const mxArray *c, const mxArray *d, const mxArray *e, const mxArray *f,
  const mxArray *g, const mxArray *h, const mxArray *i, const mxArray *j,
  emlrtMCInfo *location);
static const mxArray *emlrt_marshallOut(const emxArray_uint8_T *u);

/* Function Definitions */
static const mxArray *b_emlrt_marshallOut(const emxArray_real32_T *u)
{
  const mxArray *y;
  const mxArray *m7;
  real32_T *pData;
  int32_T i24;
  int32_T i;
  int32_T b_i;
  y = NULL;
  m7 = emlrtCreateNumericArray(2, *(int32_T (*)[2])u->size, mxSINGLE_CLASS,
    mxREAL);
  pData = (real32_T *)emlrtMxGetData(m7);
  i24 = 0;
  for (i = 0; i < u->size[1]; i++) {
    for (b_i = 0; b_i < u->size[0]; b_i++) {
      pData[i24] = u->data[b_i + u->size[0] * i];
      i24++;
    }
  }

  emlrtAssign(&y, m7);
  return y;
}

static const mxArray *c_emlrt_marshallOut(const emxArray_real32_T *u)
{
  const mxArray *y;
  const mxArray *m8;
  real32_T *pData;
  int32_T i25;
  int32_T i;
  int32_T b_i;
  y = NULL;
  m8 = emlrtCreateNumericArray(2, *(int32_T (*)[2])u->size, mxSINGLE_CLASS,
    mxREAL);
  pData = (real32_T *)emlrtMxGetData(m8);
  i25 = 0;
  for (i = 0; i < 2; i++) {
    for (b_i = 0; b_i < u->size[0]; b_i++) {
      pData[i25] = u->data[b_i + u->size[0] * i];
      i25++;
    }
  }

  emlrtAssign(&y, m8);
  return y;
}

static void c_featureMatchingVisualization_(const emlrtStack *sp, const mxArray *
  b, const mxArray *c, const mxArray *d, const mxArray *e, const mxArray *f,
  const mxArray *g, const mxArray *h, const mxArray *i, const mxArray *j,
  emlrtMCInfo *location)
{
  const mxArray *pArrays[9];
  pArrays[0] = b;
  pArrays[1] = c;
  pArrays[2] = d;
  pArrays[3] = e;
  pArrays[4] = f;
  pArrays[5] = g;
  pArrays[6] = h;
  pArrays[7] = i;
  pArrays[8] = j;
  emlrtCallMATLABR2012b(sp, 0, NULL, 9, pArrays,
                        "featureMatchingVisualization_extrinsic", true, location);
}

static const mxArray *emlrt_marshallOut(const emxArray_uint8_T *u)
{
  const mxArray *y;
  const mxArray *m6;
  uint8_T *pData;
  int32_T i23;
  int32_T i;
  int32_T b_i;
  y = NULL;
  m6 = emlrtCreateNumericArray(2, *(int32_T (*)[2])u->size, mxUINT8_CLASS,
    mxREAL);
  pData = (uint8_T *)emlrtMxGetData(m6);
  i23 = 0;
  for (i = 0; i < u->size[1]; i++) {
    for (b_i = 0; b_i < u->size[0]; b_i++) {
      pData[i23] = u->data[b_i + u->size[0] * i];
      i23++;
    }
  }

  emlrtAssign(&y, m6);
  return y;
}

void visionRecovertformCodeGeneration_kernel(const emlrtStack *sp, const
  emxArray_uint8_T *original, const emxArray_uint8_T *distorted,
  emxArray_real32_T *matchedOriginal, emxArray_real32_T *matchedDistorted,
  real32_T *thetaRecovered, real32_T *scaleRecovered, emxArray_uint8_T
  *recovered)
{
  emxArray_real32_T *ptsOriginal_pLocation;
  vision_internal_SURFPoints_cg expl_temp;
  int32_T i0;
  int32_T loop_ub;
  emxArray_real32_T *ptsOriginal_pMetric;
  emxArray_real32_T *ptsOriginal_pScale;
  emxArray_int8_T *ptsOriginal_pSignOfLaplacian;
  emxArray_real32_T *ptsDistorted_pLocation;
  emxArray_real32_T *ptsDistorted_pMetric;
  emxArray_real32_T *ptsDistorted_pScale;
  emxArray_int8_T *ptsDistorted_pSignOfLaplacian;
  emxArray_real32_T *featuresOriginal;
  emxArray_real32_T *validPtsOriginal_pLocation;
  emxArray_real32_T *featuresDistorted;
  emxArray_real32_T *b_featuresOriginal;
  emxArray_real32_T *features1;
  int32_T i1;
  int32_T unnamed_idx_1;
  emxArray_real32_T *features2;
  emxArray_real32_T *features1in;
  emxArray_real32_T *features2in;
  emxArray_uint32_T *indexPairs;
  emxArray_real32_T *matchMetric;
  emxArray_uint32_T *b_indexPairs;
  int32_T i2;
  emxArray_real32_T *inlierDistorted;
  emxArray_real32_T *inlierOriginal;
  real_T tform_Dimensionality;
  real32_T tform_T_data[12];
  int32_T tform_T_size[2];
  real32_T tinv_data[9];
  int32_T tinv_size[2];
  int8_T tmp_data[3];
  int32_T iv0[1];
  int32_T iv1[1];
  static const int8_T iv2[3] = { 0, 0, 1 };

  boolean_T p;
  int32_T varargin_1[2];
  boolean_T b_p;
  boolean_T exitg1;
  int32_T t_size[2];
  real32_T t_data[12];
  real32_T b_varargin_1;
  int32_T b_t_size[1];
  real32_T b_t_data[3];
  int16_T imageSizeIn[2];
  real_T outputView_ImageSizeAlias[2];
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
  emxInit_real32_T(sp, &ptsOriginal_pLocation, 2, &emlrtRTEI, true);
  c_emxInitStruct_vision_internal(sp, &expl_temp, &emlrtRTEI, true);

  /*  Kernel for Feature Matching and Registration */
  /*  Step 1: Find Matching Features Between Images */
  st.site = &emlrtRSI;
  detectSURFFeatures(&st, original, &expl_temp);
  i0 = ptsOriginal_pLocation->size[0] * ptsOriginal_pLocation->size[1];
  ptsOriginal_pLocation->size[0] = expl_temp.pLocation->size[0];
  ptsOriginal_pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, ptsOriginal_pLocation, i0, &emlrtRTEI);
  loop_ub = expl_temp.pLocation->size[0] * expl_temp.pLocation->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsOriginal_pLocation->data[i0] = expl_temp.pLocation->data[i0];
  }

  emxInit_real32_T1(sp, &ptsOriginal_pMetric, 1, &emlrtRTEI, true);
  i0 = ptsOriginal_pMetric->size[0];
  ptsOriginal_pMetric->size[0] = expl_temp.pMetric->size[0];
  emxEnsureCapacity_real32_T1(sp, ptsOriginal_pMetric, i0, &emlrtRTEI);
  loop_ub = expl_temp.pMetric->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsOriginal_pMetric->data[i0] = expl_temp.pMetric->data[i0];
  }

  emxInit_real32_T1(sp, &ptsOriginal_pScale, 1, &emlrtRTEI, true);
  i0 = ptsOriginal_pScale->size[0];
  ptsOriginal_pScale->size[0] = expl_temp.pScale->size[0];
  emxEnsureCapacity_real32_T1(sp, ptsOriginal_pScale, i0, &emlrtRTEI);
  loop_ub = expl_temp.pScale->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsOriginal_pScale->data[i0] = expl_temp.pScale->data[i0];
  }

  emxInit_int8_T(sp, &ptsOriginal_pSignOfLaplacian, 1, &emlrtRTEI, true);
  i0 = ptsOriginal_pSignOfLaplacian->size[0];
  ptsOriginal_pSignOfLaplacian->size[0] = expl_temp.pSignOfLaplacian->size[0];
  emxEnsureCapacity_int8_T(sp, ptsOriginal_pSignOfLaplacian, i0, &emlrtRTEI);
  loop_ub = expl_temp.pSignOfLaplacian->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsOriginal_pSignOfLaplacian->data[i0] = expl_temp.pSignOfLaplacian->data[i0];
  }

  emxInit_real32_T(sp, &ptsDistorted_pLocation, 2, &b_emlrtRTEI, true);
  st.site = &b_emlrtRSI;
  detectSURFFeatures(&st, distorted, &expl_temp);
  i0 = ptsDistorted_pLocation->size[0] * ptsDistorted_pLocation->size[1];
  ptsDistorted_pLocation->size[0] = expl_temp.pLocation->size[0];
  ptsDistorted_pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, ptsDistorted_pLocation, i0, &b_emlrtRTEI);
  loop_ub = expl_temp.pLocation->size[0] * expl_temp.pLocation->size[1];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsDistorted_pLocation->data[i0] = expl_temp.pLocation->data[i0];
  }

  emxInit_real32_T1(sp, &ptsDistorted_pMetric, 1, &b_emlrtRTEI, true);
  i0 = ptsDistorted_pMetric->size[0];
  ptsDistorted_pMetric->size[0] = expl_temp.pMetric->size[0];
  emxEnsureCapacity_real32_T1(sp, ptsDistorted_pMetric, i0, &b_emlrtRTEI);
  loop_ub = expl_temp.pMetric->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsDistorted_pMetric->data[i0] = expl_temp.pMetric->data[i0];
  }

  emxInit_real32_T1(sp, &ptsDistorted_pScale, 1, &b_emlrtRTEI, true);
  i0 = ptsDistorted_pScale->size[0];
  ptsDistorted_pScale->size[0] = expl_temp.pScale->size[0];
  emxEnsureCapacity_real32_T1(sp, ptsDistorted_pScale, i0, &b_emlrtRTEI);
  loop_ub = expl_temp.pScale->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsDistorted_pScale->data[i0] = expl_temp.pScale->data[i0];
  }

  emxInit_int8_T(sp, &ptsDistorted_pSignOfLaplacian, 1, &b_emlrtRTEI, true);
  i0 = ptsDistorted_pSignOfLaplacian->size[0];
  ptsDistorted_pSignOfLaplacian->size[0] = expl_temp.pSignOfLaplacian->size[0];
  emxEnsureCapacity_int8_T(sp, ptsDistorted_pSignOfLaplacian, i0, &b_emlrtRTEI);
  loop_ub = expl_temp.pSignOfLaplacian->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsDistorted_pSignOfLaplacian->data[i0] = expl_temp.pSignOfLaplacian->
      data[i0];
  }

  emxInit_real32_T(sp, &featuresOriginal, 2, &o_emlrtRTEI, true);
  emxInit_real32_T(sp, &validPtsOriginal_pLocation, 2, &p_emlrtRTEI, true);

  /*  Extract feature descriptors. */
  st.site = &c_emlrtRSI;
  extractFeatures(&st, original, ptsOriginal_pLocation, ptsOriginal_pMetric,
                  ptsOriginal_pScale, ptsOriginal_pSignOfLaplacian,
                  featuresOriginal, &expl_temp);
  i0 = validPtsOriginal_pLocation->size[0] * validPtsOriginal_pLocation->size[1];
  validPtsOriginal_pLocation->size[0] = expl_temp.pLocation->size[0];
  validPtsOriginal_pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, validPtsOriginal_pLocation, i0, &c_emlrtRTEI);
  loop_ub = expl_temp.pLocation->size[0] * expl_temp.pLocation->size[1];
  emxFree_int8_T(sp, &ptsOriginal_pSignOfLaplacian);
  emxFree_real32_T(sp, &ptsOriginal_pScale);
  emxFree_real32_T(sp, &ptsOriginal_pMetric);
  for (i0 = 0; i0 < loop_ub; i0++) {
    validPtsOriginal_pLocation->data[i0] = expl_temp.pLocation->data[i0];
  }

  emxInit_real32_T(sp, &featuresDistorted, 2, &q_emlrtRTEI, true);
  st.site = &d_emlrtRSI;
  extractFeatures(&st, distorted, ptsDistorted_pLocation, ptsDistorted_pMetric,
                  ptsDistorted_pScale, ptsDistorted_pSignOfLaplacian,
                  featuresDistorted, &expl_temp);
  i0 = ptsOriginal_pLocation->size[0] * ptsOriginal_pLocation->size[1];
  ptsOriginal_pLocation->size[0] = expl_temp.pLocation->size[0];
  ptsOriginal_pLocation->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, ptsOriginal_pLocation, i0, &d_emlrtRTEI);
  loop_ub = expl_temp.pLocation->size[0] * expl_temp.pLocation->size[1];
  emxFree_int8_T(sp, &ptsDistorted_pSignOfLaplacian);
  emxFree_real32_T(sp, &ptsDistorted_pScale);
  emxFree_real32_T(sp, &ptsDistorted_pMetric);
  emxFree_real32_T(sp, &ptsDistorted_pLocation);
  for (i0 = 0; i0 < loop_ub; i0++) {
    ptsOriginal_pLocation->data[i0] = expl_temp.pLocation->data[i0];
  }

  c_emxFreeStruct_vision_internal(sp, &expl_temp);
  emxInit_real32_T(sp, &b_featuresOriginal, 2, &e_emlrtRTEI, true);

  /*  Match features by using their descriptors. */
  st.site = &e_emlrtRSI;
  i0 = b_featuresOriginal->size[0] * b_featuresOriginal->size[1];
  b_featuresOriginal->size[0] = 64;
  b_featuresOriginal->size[1] = featuresOriginal->size[0];
  emxEnsureCapacity_real32_T(&st, b_featuresOriginal, i0, &e_emlrtRTEI);
  loop_ub = featuresOriginal->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    for (i1 = 0; i1 < 64; i1++) {
      b_featuresOriginal->data[i1 + b_featuresOriginal->size[0] * i0] =
        featuresOriginal->data[i0 + featuresOriginal->size[0] * i1];
    }
  }

  emxInit_real32_T(&st, &features1, 2, &s_emlrtRTEI, true);
  unnamed_idx_1 = featuresOriginal->size[0];
  i0 = features1->size[0] * features1->size[1];
  features1->size[0] = 64;
  features1->size[1] = unnamed_idx_1;
  emxEnsureCapacity_real32_T(&st, features1, i0, &f_emlrtRTEI);
  emxFree_real32_T(&st, &featuresOriginal);
  for (i0 = 0; i0 < unnamed_idx_1; i0++) {
    for (i1 = 0; i1 < 64; i1++) {
      features1->data[i1 + features1->size[0] * i0] = b_featuresOriginal->
        data[i1 + (i0 << 6)];
    }
  }

  i0 = b_featuresOriginal->size[0] * b_featuresOriginal->size[1];
  b_featuresOriginal->size[0] = 64;
  b_featuresOriginal->size[1] = featuresDistorted->size[0];
  emxEnsureCapacity_real32_T(&st, b_featuresOriginal, i0, &g_emlrtRTEI);
  loop_ub = featuresDistorted->size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    for (i1 = 0; i1 < 64; i1++) {
      b_featuresOriginal->data[i1 + b_featuresOriginal->size[0] * i0] =
        featuresDistorted->data[i0 + featuresDistorted->size[0] * i1];
    }
  }

  emxInit_real32_T(&st, &features2, 2, &t_emlrtRTEI, true);
  unnamed_idx_1 = featuresDistorted->size[0];
  i0 = features2->size[0] * features2->size[1];
  features2->size[0] = 64;
  features2->size[1] = unnamed_idx_1;
  emxEnsureCapacity_real32_T(&st, features2, i0, &h_emlrtRTEI);
  emxFree_real32_T(&st, &featuresDistorted);
  for (i0 = 0; i0 < unnamed_idx_1; i0++) {
    for (i1 = 0; i1 < 64; i1++) {
      features2->data[i1 + features2->size[0] * i0] = b_featuresOriginal->
        data[i1 + (i0 << 6)];
    }
  }

  emxFree_real32_T(&st, &b_featuresOriginal);
  b_st.site = &ic_emlrtRSI;
  emxInit_real32_T(&b_st, &features1in, 2, &u_emlrtRTEI, true);
  emxInit_real32_T(&b_st, &features2in, 2, &v_emlrtRTEI, true);
  emxInit_uint32_T(&b_st, &indexPairs, 2, &r_emlrtRTEI, true);
  emxInit_real32_T(&b_st, &matchMetric, 2, &r_emlrtRTEI, true);
  if ((features1->size[1] == 0) || (features2->size[1] == 0)) {
    i0 = indexPairs->size[0] * indexPairs->size[1];
    indexPairs->size[0] = 2;
    indexPairs->size[1] = 0;
    emxEnsureCapacity_uint32_T(&b_st, indexPairs, i0, &i_emlrtRTEI);
  } else {
    c_st.site = &jc_emlrtRSI;
    i0 = features1in->size[0] * features1in->size[1];
    features1in->size[0] = features1->size[0];
    features1in->size[1] = features1->size[1];
    emxEnsureCapacity_real32_T(&c_st, features1in, i0, &j_emlrtRTEI);
    loop_ub = features1->size[0] * features1->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      features1in->data[i0] = features1->data[i0];
    }

    d_st.site = &lc_emlrtRSI;
    normalizeX(&d_st, features1in);
    i0 = features2in->size[0] * features2in->size[1];
    features2in->size[0] = features2->size[0];
    features2in->size[1] = features2->size[1];
    emxEnsureCapacity_real32_T(&c_st, features2in, i0, &l_emlrtRTEI);
    loop_ub = features2->size[0] * features2->size[1];
    for (i0 = 0; i0 < loop_ub; i0++) {
      features2in->data[i0] = features2->data[i0];
    }

    d_st.site = &mc_emlrtRSI;
    normalizeX(&d_st, features2in);
    c_st.site = &kc_emlrtRSI;
    findMatchesExhaustive(&c_st, features1in, features2in, 0.04F, indexPairs,
                          matchMetric);
  }

  emxFree_real32_T(&b_st, &matchMetric);
  emxFree_real32_T(&b_st, &features2in);
  emxFree_real32_T(&b_st, &features1in);
  emxFree_real32_T(&b_st, &features2);
  emxFree_real32_T(&b_st, &features1);
  emxInit_uint32_T(&b_st, &b_indexPairs, 2, &k_emlrtRTEI, true);
  i0 = b_indexPairs->size[0] * b_indexPairs->size[1];
  b_indexPairs->size[0] = indexPairs->size[1];
  b_indexPairs->size[1] = 2;
  emxEnsureCapacity_uint32_T(&st, b_indexPairs, i0, &k_emlrtRTEI);
  for (i0 = 0; i0 < 2; i0++) {
    loop_ub = indexPairs->size[1];
    for (i1 = 0; i1 < loop_ub; i1++) {
      b_indexPairs->data[i1 + b_indexPairs->size[0] * i0] = indexPairs->data[i0
        + indexPairs->size[0] * i1];
    }
  }

  emxFree_uint32_T(&st, &indexPairs);

  /*  Retrieve locations of corresponding points for each image. */
  /*  Note that indexing into the object is not supported in code-generation mode. */
  /*  Instead, you can directly access the Location property. */
  loop_ub = b_indexPairs->size[0];
  unnamed_idx_1 = validPtsOriginal_pLocation->size[0];
  i0 = matchedOriginal->size[0] * matchedOriginal->size[1];
  matchedOriginal->size[0] = loop_ub;
  matchedOriginal->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, matchedOriginal, i0, &m_emlrtRTEI);
  for (i0 = 0; i0 < 2; i0++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      i2 = (int32_T)b_indexPairs->data[i1];
      if (!((i2 >= 1) && (i2 <= unnamed_idx_1))) {
        emlrtDynamicBoundsCheckR2012b(i2, 1, unnamed_idx_1, &e_emlrtBCI, sp);
      }

      matchedOriginal->data[i1 + matchedOriginal->size[0] * i0] =
        validPtsOriginal_pLocation->data[(i2 + validPtsOriginal_pLocation->size
        [0] * i0) - 1];
    }
  }

  emxFree_real32_T(sp, &validPtsOriginal_pLocation);
  loop_ub = b_indexPairs->size[0];
  unnamed_idx_1 = ptsOriginal_pLocation->size[0];
  i0 = matchedDistorted->size[0] * matchedDistorted->size[1];
  matchedDistorted->size[0] = loop_ub;
  matchedDistorted->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, matchedDistorted, i0, &n_emlrtRTEI);
  for (i0 = 0; i0 < 2; i0++) {
    for (i1 = 0; i1 < loop_ub; i1++) {
      i2 = (int32_T)b_indexPairs->data[i1 + b_indexPairs->size[0]];
      if (!((i2 >= 1) && (i2 <= unnamed_idx_1))) {
        emlrtDynamicBoundsCheckR2012b(i2, 1, unnamed_idx_1, &f_emlrtBCI, sp);
      }

      matchedDistorted->data[i1 + matchedDistorted->size[0] * i0] =
        ptsOriginal_pLocation->data[(i2 + ptsOriginal_pLocation->size[0] * i0) -
        1];
    }
  }

  emxFree_uint32_T(sp, &b_indexPairs);
  emxFree_real32_T(sp, &ptsOriginal_pLocation);
  emxInit_real32_T(sp, &inlierDistorted, 2, &r_emlrtRTEI, true);
  emxInit_real32_T(sp, &inlierOriginal, 2, &r_emlrtRTEI, true);

  /*  Step 2: Estimate Transformation */
  /*  Defaults to RANSAC */
  st.site = &f_emlrtRSI;
  estimateGeometricTransform(&st, matchedDistorted, matchedOriginal,
    &tform_Dimensionality, tform_T_data, tform_T_size, inlierDistorted,
    inlierOriginal);

  /*  Step 3: Solve for Scale and Angle */
  st.site = &g_emlrtRSI;
  b_st.site = &jk_emlrtRSI;
  c_st.site = &kk_emlrtRSI;
  inv(&c_st, tform_T_data, tform_T_size, tinv_data, tinv_size);
  loop_ub = (int8_T)tinv_size[0] - 1;
  for (i0 = 0; i0 <= loop_ub; i0++) {
    tmp_data[i0] = (int8_T)i0;
  }

  i0 = tinv_size[1];
  if (!((i0 >= 1) && (i0 <= tinv_size[1]))) {
    emlrtDynamicBoundsCheckR2012b(i0, 1, tinv_size[1], &c_emlrtBCI, &b_st);
  }

  iv0[0] = (int8_T)tinv_size[0];
  iv1[0] = 3;
  emlrtSubAssignSizeCheckR2012b(&iv0[0], 1, &iv1[0], 1, &emlrtECI, &b_st);
  loop_ub = (int8_T)tinv_size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    tinv_data[tmp_data[i0] + tinv_size[0] * (tinv_size[1] - 1)] = iv2[i0];
  }

  b_st.site = &jk_emlrtRSI;
  for (i0 = 0; i0 < 2; i0++) {
    varargin_1[i0] = tinv_size[i0];
  }

  p = false;
  b_p = true;
  unnamed_idx_1 = 0;
  exitg1 = false;
  while ((!exitg1) && (unnamed_idx_1 < 2)) {
    if (!((int8_T)varargin_1[unnamed_idx_1] == 3 - unnamed_idx_1)) {
      b_p = false;
      exitg1 = true;
    } else {
      unnamed_idx_1++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (p) {
    c_st.site = &gk_emlrtRSI;
    d_st.site = &fh_emlrtRSI;
    e_st.site = &if_emlrtRSI;
    if ((tinv_size[0] == 3) || (tinv_size[0] == 0)) {
    } else {
      emlrtErrorWithMessageIdR2018a(&e_st, &ai_emlrtRTEI,
        "MATLAB:catenate:matrixDimensionMismatch",
        "MATLAB:catenate:matrixDimensionMismatch", 0);
    }

    if (!(tinv_size[0] == 0)) {
      unnamed_idx_1 = tinv_size[1];
    } else {
      unnamed_idx_1 = 0;
    }

    t_size[0] = 3;
    t_size[1] = unnamed_idx_1 + 1;
    for (i0 = 0; i0 < unnamed_idx_1; i0++) {
      for (i1 = 0; i1 < 3; i1++) {
        t_data[i1 + 3 * i0] = tinv_data[i1 + 3 * i0];
      }
    }

    for (i0 = 0; i0 < 3; i0++) {
      t_data[i0 + 3 * unnamed_idx_1] = iv2[i0];
    }
  } else {
    t_size[0] = tinv_size[0];
    t_size[1] = tinv_size[1];
    loop_ub = tinv_size[0] * tinv_size[1];
    if (0 <= loop_ub - 1) {
      memcpy(&t_data[0], &tinv_data[0], (uint32_T)(loop_ub * (int32_T)sizeof
              (real32_T)));
    }
  }

  c_st.site = &hk_emlrtRSI;
  validateattributes(&c_st, t_data, t_size);
  c_st.site = &ik_emlrtRSI;
  b_varargin_1 = det(&c_st, t_data, t_size);
  p = false;
  b_p = true;
  if (!(b_varargin_1 == 0.0F)) {
    b_p = false;
  }

  if (b_p) {
    p = true;
  }

  if (p) {
    emlrtErrorWithMessageIdR2018a(&b_st, &xh_emlrtRTEI,
      "images:geotrans:singularTransformationMatrix",
      "images:geotrans:singularTransformationMatrix", 0);
  }

  if (!(3 <= t_size[1])) {
    emlrtDynamicBoundsCheckR2012b(3, 1, t_size[1], &d_emlrtBCI, &b_st);
  }

  loop_ub = t_size[0];
  b_t_size[0] = t_size[0];
  for (i0 = 0; i0 < loop_ub; i0++) {
    b_t_data[i0] = t_data[i0 + (t_size[0] << 1)];
  }

  if (!isequal(b_t_data, b_t_size, dv0)) {
    emlrtErrorWithMessageIdR2018a(&b_st, &yh_emlrtRTEI,
      "images:geotrans:invalidAffineMatrix",
      "images:geotrans:invalidAffineMatrix", 0);
  }

  if (!(2 <= t_size[0])) {
    emlrtDynamicBoundsCheckR2012b(2, 1, t_size[0], &emlrtBCI, sp);
  }

  if (!(1 <= t_size[0])) {
    emlrtDynamicBoundsCheckR2012b(1, 1, t_size[0], &b_emlrtBCI, sp);
  }

  st.site = &h_emlrtRSI;
  b_varargin_1 = t_data[1] * t_data[1] + t_data[0] * t_data[0];
  if (b_varargin_1 < 0.0F) {
    b_st.site = &dd_emlrtRSI;
    error(&b_st);
  }

  *scaleRecovered = muSingleScalarSqrt(b_varargin_1);
  *thetaRecovered = muSingleScalarAtan2(t_data[1], t_data[0]) * 180.0F /
    3.14159274F;

  /*  Step 4: Recover the original image by transforming the distorted image. */
  st.site = &j_emlrtRSI;
  for (i0 = 0; i0 < 2; i0++) {
    imageSizeIn[i0] = (int16_T)original->size[i0];
  }

  b_st.site = &al_emlrtRSI;
  c_st.site = &q_emlrtRSI;
  p = true;
  unnamed_idx_1 = 0;
  exitg1 = false;
  while ((!exitg1) && (unnamed_idx_1 < 2)) {
    if (!(imageSizeIn[unnamed_idx_1] <= 0)) {
      unnamed_idx_1++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&c_st, &bi_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedPositive",
      "MATLAB:imref2d:expectedPositive", 3, 4, 9, "ImageSize");
  }

  c_st.site = &q_emlrtRSI;
  c_st.site = &q_emlrtRSI;
  outputView_ImageSizeAlias[0] = imageSizeIn[0];
  outputView_ImageSizeAlias[1] = imageSizeIn[1];
  b_st.site = &bl_emlrtRSI;
  c_st.site = &dl_emlrtRSI;
  d_st.site = &q_emlrtRSI;
  if (0.5 + (real_T)imageSizeIn[1] <= 0.5) {
    emlrtErrorWithMessageIdR2018a(&b_st, &di_emlrtRTEI,
      "images:spatialref:expectedAscendingLimits",
      "images:spatialref:expectedAscendingLimits", 3, 4, 12, "XWorldLimits");
  }

  b_st.site = &cl_emlrtRSI;
  c_st.site = &el_emlrtRSI;
  d_st.site = &q_emlrtRSI;
  if (0.5 + (real_T)imageSizeIn[0] <= 0.5) {
    emlrtErrorWithMessageIdR2018a(&b_st, &ei_emlrtRTEI,
      "images:spatialref:expectedAscendingLimits",
      "images:spatialref:expectedAscendingLimits", 3, 4, 12, "YWorldLimits");
  }

  st.site = &i_emlrtRSI;
  imwarp(&st, distorted, tform_T_data, tform_T_size, outputView_ImageSizeAlias,
         recovered);

  /*  Step 5: Display results */
  st.site = &rm_emlrtRSI;
  c_featureMatchingVisualization_(&st, emlrt_marshallOut(original),
    emlrt_marshallOut(distorted), emlrt_marshallOut(recovered),
    b_emlrt_marshallOut(inlierOriginal), b_emlrt_marshallOut(inlierDistorted),
    c_emlrt_marshallOut(matchedOriginal), c_emlrt_marshallOut(matchedDistorted),
    d_emlrt_marshallOut(*scaleRecovered), d_emlrt_marshallOut(*thetaRecovered),
    &emlrtMCI);
  emxFree_real32_T(sp, &inlierOriginal);
  emxFree_real32_T(sp, &inlierDistorted);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (visionRecovertformCodeGeneration_kernel.c) */

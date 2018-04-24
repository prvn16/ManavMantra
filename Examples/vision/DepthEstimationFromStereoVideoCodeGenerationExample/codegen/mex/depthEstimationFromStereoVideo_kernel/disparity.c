/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * disparity.c
 *
 * Code generation for function 'disparity'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "disparity.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "ImageTransformer.h"
#include "depthEstimationFromStereoVideo_kernel_mexutil.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "disparitySGBMCore_api.hpp"

/* Variable Definitions */
static emlrtRSInfo kn_emlrtRSI = { 40, /* lineNo */
  "mpower",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\mpower.m"/* pathName */
};

static emlrtRSInfo fo_emlrtRSI = { 140,/* lineNo */
  "disparity",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\disparity.m"/* pathName */
};

static emlrtRSInfo go_emlrtRSI = { 154,/* lineNo */
  "disparity",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\disparity.m"/* pathName */
};

static emlrtRSInfo ho_emlrtRSI = { 212,/* lineNo */
  "disparity",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\disparity.m"/* pathName */
};

static emlrtRSInfo io_emlrtRSI = { 225,/* lineNo */
  "disparity",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\disparity.m"/* pathName */
};

static emlrtRSInfo jo_emlrtRSI = { 228,/* lineNo */
  "disparity",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\disparity.m"/* pathName */
};

static emlrtRSInfo ko_emlrtRSI = { 18, /* lineNo */
  "validateImagePair",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\validateImagePair.m"/* pathName */
};

static emlrtRSInfo lo_emlrtRSI = { 24, /* lineNo */
  "validateImagePair",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\validateImagePair.m"/* pathName */
};

static emlrtRSInfo mo_emlrtRSI = { 25, /* lineNo */
  "validateImagePair",                 /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\validateImagePair.m"/* pathName */
};

static emlrtRSInfo no_emlrtRSI = { 39, /* lineNo */
  "validateImage",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\validateImage.m"/* pathName */
};

static emlrtRSInfo oo_emlrtRSI = { 49, /* lineNo */
  "validateImage",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\validateImage.m"/* pathName */
};

static emlrtRSInfo po_emlrtRSI = { 346,/* lineNo */
  "disparity",                         /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\disparity.m"/* pathName */
};

static emlrtRSInfo qo_emlrtRSI = { 21, /* lineNo */
  "validatele",                        /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\validatele.m"/* pathName */
};

static emlrtRSInfo ro_emlrtRSI = { 17, /* lineNo */
  "local_num2str",                     /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\+valattr\\private\\local_num2str.m"/* pathName */
};

static emlrtRSInfo so_emlrtRSI = { 15, /* lineNo */
  "num2str",                           /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\eml\\+coder\\+internal\\num2str.m"/* pathName */
};

static emlrtRTEInfo fd_emlrtRTEI = { 1,/* lineNo */
  25,                                  /* colNo */
  "disparity",                         /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\disparity.m"/* pName */
};

static emlrtRTEInfo gd_emlrtRTEI = { 212,/* lineNo */
  24,                                  /* colNo */
  "disparity",                         /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\disparity.m"/* pName */
};

static emlrtRTEInfo rf_emlrtRTEI = { 27,/* lineNo */
  1,                                   /* colNo */
  "validateImagePair",                 /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+inputValidation\\validateImagePair.m"/* pName */
};

/* Function Declarations */
static void bb_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[23]);
static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *c_sprintf,
  const char_T *identifier, char_T y[23]);
static void d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[23]);

/* Function Definitions */
static void bb_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[23])
{
  static const int32_T dims[2] = { 1, 23 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "char", false, 2U, dims);
  emlrtImportCharArrayR2015b(sp, src, &ret[0], 23);
  emlrtDestroyArray(&src);
}

static void c_emlrt_marshallIn(const emlrtStack *sp, const mxArray *c_sprintf,
  const char_T *identifier, char_T y[23])
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  d_emlrt_marshallIn(sp, emlrtAlias(c_sprintf), &thisId, y);
  emlrtDestroyArray(&c_sprintf);
}

static void d_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[23])
{
  bb_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

void disparity(const emlrtStack *sp, const emxArray_uint8_T *I1, const
               emxArray_uint8_T *I2, emxArray_real32_T *disparityMap)
{
  int32_T i41;
  boolean_T p;
  uint32_T varargin_1[2];
  boolean_T b_p;
  uint32_T varargin_2[2];
  int32_T outSize_idx_0;
  boolean_T exitg1;
  uint32_T b_varargin_1[3];
  int32_T outSize_idx_1;
  emxArray_uint8_T *image1_u8;
  const mxArray *y;
  const mxArray *m8;
  static const int32_T iv27[2] = { 1, 7 };

  static const char_T rfmt[7] = { '%', '2', '3', '.', '1', '5', 'e' };

  const mxArray *b_y;
  char_T numstr[23];
  emxArray_uint8_T *image2_u8;
  cvstDSGBMStruct_T paramStruct;
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
  st.site = &fo_emlrtRSI;
  b_st.site = &io_emlrtRSI;
  c_st.site = &ko_emlrtRSI;
  d_st.site = &lo_emlrtRSI;
  e_st.site = &no_emlrtRSI;
  f_st.site = &oo_emlrtRSI;
  g_st.site = &ic_emlrtRSI;
  if ((I1->size[0] == 0) || (I1->size[1] == 0)) {
    emlrtErrorWithMessageIdR2018a(&g_st, &kf_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonempty",
      "MATLAB:validateImage:expectedNonempty", 3, 4, 2, "I1");
  }

  d_st.site = &mo_emlrtRSI;
  e_st.site = &no_emlrtRSI;
  f_st.site = &oo_emlrtRSI;
  g_st.site = &ic_emlrtRSI;
  if ((I2->size[0] == 0) || (I2->size[1] == 0)) {
    emlrtErrorWithMessageIdR2018a(&g_st, &kf_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonempty",
      "MATLAB:validateImage:expectedNonempty", 3, 4, 2, "I2");
  }

  for (i41 = 0; i41 < 2; i41++) {
    varargin_1[i41] = (uint32_T)I1->size[i41];
    varargin_2[i41] = (uint32_T)I2->size[i41];
  }

  p = false;
  b_p = true;
  outSize_idx_0 = 0;
  exitg1 = false;
  while ((!exitg1) && (outSize_idx_0 < 2)) {
    if (!((int32_T)varargin_1[outSize_idx_0] == (int32_T)
          varargin_2[outSize_idx_0])) {
      b_p = false;
      exitg1 = true;
    } else {
      outSize_idx_0++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&c_st, &rf_emlrtRTEI,
      "vision:dims:inputsMismatch", "vision:dims:inputsMismatch", 0);
  }

  b_st.site = &jo_emlrtRSI;
  for (i41 = 0; i41 < 2; i41++) {
    b_varargin_1[i41] = (uint32_T)I1->size[i41];
  }

  b_varargin_1[2] = 255U;
  outSize_idx_1 = (int32_T)b_varargin_1[0];
  for (outSize_idx_0 = 1; outSize_idx_0 + 1 < 4; outSize_idx_0++) {
    if (outSize_idx_1 > (int32_T)b_varargin_1[outSize_idx_0]) {
      outSize_idx_1 = (int32_T)b_varargin_1[outSize_idx_0];
    }
  }

  c_st.site = &po_emlrtRSI;
  d_st.site = &ic_emlrtRSI;
  p = true;
  if (!(15 <= outSize_idx_1)) {
    p = false;
  }

  if (!p) {
    e_st.site = &qo_emlrtRSI;
    f_st.site = &ro_emlrtRSI;
    g_st.site = &so_emlrtRSI;
    y = NULL;
    m8 = emlrtCreateCharArray(2, iv27);
    emlrtInitCharArrayR2013a(&g_st, 7, m8, &rfmt[0]);
    emlrtAssign(&y, m8);
    b_y = NULL;
    m8 = emlrtCreateDoubleScalar(outSize_idx_1);
    emlrtAssign(&b_y, m8);
    h_st.site = &ss_emlrtRSI;
    c_emlrt_marshallIn(&h_st, b_sprintf(&h_st, y, b_y, &f_emlrtMCI), "sprintf",
                       numstr);
    emlrtErrorWithMessageIdR2018a(&d_st, &qf_emlrtRTEI,
      "MATLAB:validateattributes:expectedScalar",
      "MATLAB:disparity:notLessEqual", 9, 4, 9, "BlockSize", 4, 2, "<=", 4, 23,
      numstr);
  }

  emxInit_uint8_T(&d_st, &image1_u8, 2, &fd_emlrtRTEI, true);
  st.site = &go_emlrtRSI;
  b_st.site = &kn_emlrtRSI;
  c_st.site = &bi_emlrtRSI;
  st.site = &ho_emlrtRSI;
  i41 = image1_u8->size[0] * image1_u8->size[1];
  image1_u8->size[0] = I1->size[0];
  image1_u8->size[1] = I1->size[1];
  emxEnsureCapacity_uint8_T(&st, image1_u8, i41, &fd_emlrtRTEI);
  outSize_idx_0 = I1->size[0] * I1->size[1];
  for (i41 = 0; i41 < outSize_idx_0; i41++) {
    image1_u8->data[i41] = I1->data[i41];
  }

  emxInit_uint8_T(&st, &image2_u8, 2, &fd_emlrtRTEI, true);
  i41 = image2_u8->size[0] * image2_u8->size[1];
  image2_u8->size[0] = I2->size[0];
  image2_u8->size[1] = I2->size[1];
  emxEnsureCapacity_uint8_T(&st, image2_u8, i41, &fd_emlrtRTEI);
  outSize_idx_0 = I2->size[0] * I2->size[1];
  for (i41 = 0; i41 < outSize_idx_0; i41++) {
    image2_u8->data[i41] = I2->data[i41];
  }

  outSize_idx_0 = I1->size[0];
  outSize_idx_1 = I1->size[1];
  i41 = disparityMap->size[0] * disparityMap->size[1];
  disparityMap->size[0] = outSize_idx_0;
  disparityMap->size[1] = outSize_idx_1;
  emxEnsureCapacity_real32_T(&st, disparityMap, i41, &gd_emlrtRTEI);
  paramStruct.preFilterCap = 31;
  paramStruct.SADWindowSize = 15;
  paramStruct.minDisparity = 0;
  paramStruct.numberOfDisparities = 64;
  paramStruct.uniquenessRatio = 15;
  paramStruct.disp12MaxDiff = -107;
  paramStruct.speckleWindowSize = 0;
  paramStruct.speckleRange = 0;
  paramStruct.P1 = 1800;
  paramStruct.P2 = 7200;
  paramStruct.fullDP = 0;
  disparitySGBM_compute(&image1_u8->data[0], &image2_u8->data[0], I1->size[0],
                        I1->size[1], &disparityMap->data[0], &paramStruct);
  emxFree_uint8_T(sp, &image2_u8);
  emxFree_uint8_T(sp, &image1_u8);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (disparity.c) */

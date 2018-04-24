/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * imwarp.c
 *
 * Code generation for function 'imwarp'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "imwarp.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "det.h"
#include "validateattributes.h"
#include "warning.h"
#include "norm.h"
#include "mrdivide.h"
#include "visionRecovertformCodeGeneration_kernel_mexutil.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"
#include "libmwippgeotrans.h"

/* Variable Definitions */
static emlrtRSInfo fl_emlrtRSI = { 13, /* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo gl_emlrtRSI = { 111,/* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo hl_emlrtRSI = { 136,/* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo il_emlrtRSI = { 58, /* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo jl_emlrtRSI = { 397,/* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo kl_emlrtRSI = { 164,/* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo ll_emlrtRSI = { 521,/* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo ml_emlrtRSI = { 522,/* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo nl_emlrtRSI = { 546,/* lineNo */
  "imwarp",                            /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pathName */
};

static emlrtRSInfo pm_emlrtRSI = { 31, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo qm_emlrtRSI = { 31, /* lineNo */
  "ippgeotrans",                       /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\ippgeotrans.m"/* pathName */
};

static emlrtRTEInfo wg_emlrtRTEI = { 546,/* lineNo */
  23,                                  /* colNo */
  "imwarp",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pName */
};

static emlrtRTEInfo ej_emlrtRTEI = { 294,/* lineNo */
  70,                                  /* colNo */
  "imwarp",                            /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\eml\\imwarp.m"/* pName */
};

/* Function Definitions */
void imwarp(const emlrtStack *sp, const emxArray_uint8_T *varargin_1, const
            real32_T varargin_2_T_data[], const int32_T varargin_2_T_size[2],
            const real_T varargin_4_ImageSizeAlias[2], emxArray_uint8_T
            *outputImage)
{
  int32_T p1;
  int16_T imageSizeIn[2];
  boolean_T p;
  int32_T imageSize[2];
  boolean_T b_p;
  boolean_T guard1 = false;
  static const real_T dv2[9] = { 1.0, 0.0, 1.0, 0.0, 1.0, 1.0, 0.0, 0.0, 1.0 };

  real32_T a_data[9];
  int32_T p2;
  real32_T tinv[9];
  int32_T p3;
  real32_T t[9];
  static const int8_T iv17[3] = { 0, 0, 1 };

  real32_T a[9];
  real32_T absx11;
  static const int8_T iv18[9] = { 1, 0, 0, 0, 1, 0, 0, 0, 1 };

  static const int8_T iv19[9] = { 1, 0, -1, 0, 1, -1, 0, 0, 1 };

  boolean_T exitg1;
  static const int8_T varargin_2[3] = { 0, 0, 1 };

  real32_T absx21;
  real32_T absx31;
  int32_T itmp;
  const mxArray *y;
  const mxArray *m3;
  static const int32_T iv20[2] = { 1, 6 };

  static const char_T rfmt[6] = { '%', '1', '4', '.', '6', 'e' };

  char_T cv2[14];
  real_T fillVal;
  real_T b_varargin_4_ImageSizeAlias[2];
  real_T b_varargin_1[2];
  real_T b_tinv[6];
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
  st.site = &fl_emlrtRSI;
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
  b_st.site = &jl_emlrtRSI;
  c_st.site = &q_emlrtRSI;
  if ((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0)) {
    emlrtErrorWithMessageIdR2018a(&c_st, &hi_emlrtRTEI,
      "Coder:toolbox:ValidateattributesexpectedNonempty",
      "MATLAB:imwarp:expectedNonempty", 3, 4, 18, "input number 1, A,");
  }

  st.site = &il_emlrtRSI;
  for (p1 = 0; p1 < 2; p1++) {
    imageSizeIn[p1] = (int16_T)varargin_1->size[p1];
  }

  b_st.site = &al_emlrtRSI;
  c_st.site = &q_emlrtRSI;
  c_st.site = &q_emlrtRSI;
  c_st.site = &q_emlrtRSI;
  b_st.site = &bl_emlrtRSI;
  c_st.site = &dl_emlrtRSI;
  d_st.site = &q_emlrtRSI;
  b_st.site = &cl_emlrtRSI;
  c_st.site = &el_emlrtRSI;
  d_st.site = &q_emlrtRSI;
  st.site = &gl_emlrtRSI;
  for (p1 = 0; p1 < 2; p1++) {
    imageSize[p1] = varargin_1->size[p1];
  }

  p = false;
  b_p = true;
  if (!((int16_T)imageSize[0] == imageSizeIn[0])) {
    b_p = false;
  }

  if (b_p) {
    p = true;
  }

  guard1 = false;
  if (p) {
    p = false;
    b_p = true;
    if (!((int16_T)imageSize[1] == imageSizeIn[1])) {
      b_p = false;
    }

    if (b_p) {
      p = true;
    }

    if (p) {
    } else {
      guard1 = true;
    }
  } else {
    guard1 = true;
  }

  if (guard1) {
    emlrtErrorWithMessageIdR2018a(&st, &ej_emlrtRTEI,
      "images:imwarp:spatialRefDimsDisagreeWithInputImage",
      "images:imwarp:spatialRefDimsDisagreeWithInputImage", 9, 4, 9, "ImageSize",
      4, 2, "RA", 4, 1, "A");
  }

  st.site = &hl_emlrtRSI;
  b_st.site = &kl_emlrtRSI;
  c_st.site = &ll_emlrtRSI;
  mrdivide(&c_st, dv2, varargin_2_T_data, varargin_2_T_size, a_data, imageSize);
  c_st.site = &ll_emlrtRSI;
  d_st.site = &ch_emlrtRSI;
  if (!(imageSize[1] == 3)) {
    emlrtErrorWithMessageIdR2018a(&d_st, &aj_emlrtRTEI, "Coder:MATLAB:innerdim",
      "Coder:MATLAB:innerdim", 0);
  }

  c_st.site = &ml_emlrtRSI;
  d_st.site = &fk_emlrtRSI;
  for (p1 = 0; p1 < 3; p1++) {
    for (p2 = 0; p2 < 3; p2++) {
      tinv[p1 + 3 * p2] = 0.0F;
      for (p3 = 0; p3 < 3; p3++) {
        tinv[p1 + 3 * p2] += a_data[p1 + 3 * p3] * (real32_T)iv18[p3 + 3 * p2];
      }
    }

    for (p2 = 0; p2 < 3; p2++) {
      a[p1 + 3 * p2] = 0.0F;
      for (p3 = 0; p3 < 3; p3++) {
        a[p1 + 3 * p2] += tinv[p1 + 3 * p3] * (real32_T)iv19[p3 + 3 * p2];
      }
    }
  }

  for (p1 = 0; p1 < 2; p1++) {
    for (p2 = 0; p2 < 3; p2++) {
      t[p2 + 3 * p1] = a[p2 + 3 * p1];
    }
  }

  for (p1 = 0; p1 < 3; p1++) {
    t[6 + p1] = iv17[p1];
  }

  e_st.site = &hk_emlrtRSI;
  b_validateattributes(&e_st, t);
  e_st.site = &ik_emlrtRSI;
  absx11 = b_det(&e_st, t);
  p = false;
  b_p = true;
  if (!(absx11 == 0.0F)) {
    b_p = false;
  }

  if (b_p) {
    p = true;
  }

  if (p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &xh_emlrtRTEI,
      "images:geotrans:singularTransformationMatrix",
      "images:geotrans:singularTransformationMatrix", 0);
  }

  p = false;
  b_p = true;
  p1 = 0;
  exitg1 = false;
  while ((!exitg1) && (p1 < 3)) {
    if (!((int32_T)t[6 + p1] == varargin_2[p1])) {
      b_p = false;
      exitg1 = true;
    } else {
      p1++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &yh_emlrtRTEI,
      "images:geotrans:invalidAffineMatrix",
      "images:geotrans:invalidAffineMatrix", 0);
  }

  c_st.site = &ml_emlrtRSI;
  d_st.site = &jk_emlrtRSI;
  e_st.site = &kk_emlrtRSI;
  for (p1 = 0; p1 < 9; p1++) {
    a_data[p1] = t[p1];
  }

  p1 = 0;
  p2 = 3;
  p3 = 6;
  absx11 = muSingleScalarAbs(t[0]);
  absx21 = muSingleScalarAbs(t[1]);
  absx31 = muSingleScalarAbs(t[2]);
  if ((absx21 > absx11) && (absx21 > absx31)) {
    p1 = 3;
    p2 = 0;
    a_data[0] = t[1];
    a_data[1] = t[0];
    a_data[3] = t[4];
    a_data[4] = t[3];
    a_data[6] = 0.0F;
  } else {
    if (absx31 > absx11) {
      p1 = 6;
      p3 = 0;
      a_data[0] = t[2];
      a_data[2] = t[0];
      a_data[3] = t[5];
      a_data[5] = t[3];
      a_data[6] = 1.0F;
      a_data[8] = 0.0F;
    }
  }

  absx11 = a_data[1] / a_data[0];
  a_data[1] /= a_data[0];
  absx21 = a_data[2] / a_data[0];
  a_data[2] /= a_data[0];
  a_data[4] -= absx11 * a_data[3];
  a_data[5] -= absx21 * a_data[3];
  a_data[7] = 0.0F - absx11 * a_data[6];
  a_data[8] -= absx21 * a_data[6];
  if (muSingleScalarAbs(a_data[5]) > muSingleScalarAbs(a_data[4])) {
    itmp = p2;
    p2 = p3;
    p3 = itmp;
    a_data[1] = absx21;
    a_data[2] = absx11;
    absx11 = a_data[4];
    a_data[4] = a_data[5];
    a_data[5] = absx11;
    absx11 = a_data[7];
    a_data[7] = a_data[8];
    a_data[8] = absx11;
  }

  absx11 = a_data[5] / a_data[4];
  a_data[5] /= a_data[4];
  a_data[8] -= absx11 * a_data[7];
  absx11 = (a_data[5] * a_data[1] - a_data[2]) / a_data[8];
  absx21 = -(a_data[1] + a_data[7] * absx11) / a_data[4];
  tinv[p1] = ((1.0F - a_data[3] * absx21) - a_data[6] * absx11) / a_data[0];
  tinv[p1 + 1] = absx21;
  tinv[p1 + 2] = absx11;
  absx11 = -a_data[5] / a_data[8];
  absx21 = (1.0F - a_data[7] * absx11) / a_data[4];
  tinv[p2] = -(a_data[3] * absx21 + a_data[6] * absx11) / a_data[0];
  tinv[p2 + 1] = absx21;
  tinv[p2 + 2] = absx11;
  absx11 = 1.0F / a_data[8];
  absx21 = -a_data[7] * absx11 / a_data[4];
  tinv[p3] = -(a_data[3] * absx21 + a_data[6] * absx11) / a_data[0];
  tinv[p3 + 1] = absx21;
  tinv[p3 + 2] = absx11;
  f_st.site = &pm_emlrtRSI;
  absx11 = b_norm(t);
  absx21 = b_norm(tinv);
  absx31 = 1.0F / (absx11 * absx21);
  if ((absx11 == 0.0F) || (absx21 == 0.0F) || (absx31 == 0.0F)) {
    g_st.site = &xk_emlrtRSI;
    warning(&g_st);
  } else {
    if (muSingleScalarIsNaN(absx31) || (absx31 < 1.1920929E-7F)) {
      g_st.site = &yk_emlrtRSI;
      y = NULL;
      m3 = emlrtCreateCharArray(2, iv20);
      emlrtInitCharArrayR2013a(&g_st, 6, m3, &rfmt[0]);
      emlrtAssign(&y, m3);
      h_st.site = &um_emlrtRSI;
      emlrt_marshallIn(&h_st, b_sprintf(&h_st, y, d_emlrt_marshallOut(absx31),
        &e_emlrtMCI), "sprintf", cv2);
      g_st.site = &yk_emlrtRSI;
      b_warning(&g_st, cv2);
    }
  }

  for (p1 = 0; p1 < 3; p1++) {
    tinv[6 + p1] = iv17[p1];
  }

  d_st.site = &jk_emlrtRSI;
  e_st.site = &hk_emlrtRSI;
  b_validateattributes(&e_st, tinv);
  e_st.site = &ik_emlrtRSI;
  absx11 = b_det(&e_st, tinv);
  p = false;
  b_p = true;
  if (!(absx11 == 0.0F)) {
    b_p = false;
  }

  if (b_p) {
    p = true;
  }

  if (p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &xh_emlrtRTEI,
      "images:geotrans:singularTransformationMatrix",
      "images:geotrans:singularTransformationMatrix", 0);
  }

  p = false;
  b_p = true;
  p1 = 0;
  exitg1 = false;
  while ((!exitg1) && (p1 < 3)) {
    if (!((real_T)tinv[6 + p1] == varargin_2[p1])) {
      b_p = false;
      exitg1 = true;
    } else {
      p1++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&d_st, &yh_emlrtRTEI,
      "images:geotrans:invalidAffineMatrix",
      "images:geotrans:invalidAffineMatrix", 0);
  }

  c_st.site = &nl_emlrtRSI;
  p1 = outputImage->size[0] * outputImage->size[1];
  outputImage->size[0] = (int32_T)varargin_4_ImageSizeAlias[0];
  outputImage->size[1] = (int32_T)varargin_4_ImageSizeAlias[1];
  emxEnsureCapacity_uint8_T(&c_st, outputImage, p1, &wg_emlrtRTEI);
  d_st.site = &qm_emlrtRSI;
  fillVal = 0.0;
  for (p1 = 0; p1 < 2; p1++) {
    b_varargin_4_ImageSizeAlias[p1] = varargin_4_ImageSizeAlias[p1];
    b_varargin_1[p1] = varargin_1->size[p1];
    for (p2 = 0; p2 < 3; p2++) {
      b_tinv[p2 + 3 * p1] = tinv[p2 + 3 * p1];
    }
  }

  ippgeotransCaller_uint8(&outputImage->data[0], b_varargin_4_ImageSizeAlias,
    2.0, &varargin_1->data[0], b_varargin_1, (real_T)(varargin_1->size[0] *
    varargin_1->size[1]), b_tinv, 2, &fillVal, true);
}

/* End of code generation (imwarp.c) */

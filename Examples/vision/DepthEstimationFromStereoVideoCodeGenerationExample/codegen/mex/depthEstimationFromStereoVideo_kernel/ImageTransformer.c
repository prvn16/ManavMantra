/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * ImageTransformer.c
 *
 * Code generation for function 'ImageTransformer'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include <string.h>
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "ImageTransformer.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "matlabCodegenHandle.h"
#include "validateattributes.h"
#include "error.h"
#include "assertValidSizeArg.h"
#include "strcmp.h"
#include "distortPoints.h"
#include "meshgrid.h"
#include "bwtraceboundary.h"
#include "eml_int_forloop_overflow_check.h"
#include "warning.h"
#include "norm.h"
#include "padarray.h"
#include "depthEstimationFromStereoVideo_kernel_mexutil.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "libmwremaptbb.h"
#include "blas.h"

/* Variable Definitions */
static emlrtRSInfo qh_emlrtRSI = { 290,/* lineNo */
  "colon",                             /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\colon.m"/* pathName */
};

static emlrtRSInfo ki_emlrtRSI = { 124,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo li_emlrtRSI = { 125,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo mi_emlrtRSI = { 126,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo ni_emlrtRSI = { 136,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo oi_emlrtRSI = { 156,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo pi_emlrtRSI = { 157,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo qi_emlrtRSI = { 159,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo ri_emlrtRSI = { 161,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo wi_emlrtRSI = { 110,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo xi_emlrtRSI = { 32, /* lineNo */
  "interp2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\interp2d.m"/* pathName */
};

static emlrtRSInfo yi_emlrtRSI = { 34, /* lineNo */
  "interp2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\interp2d.m"/* pathName */
};

static emlrtRSInfo aj_emlrtRSI = { 169,/* lineNo */
  "interp2d",                          /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\interp2d.m"/* pathName */
};

static emlrtRSInfo qn_emlrtRSI = { 129,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRSInfo rn_emlrtRSI = { 216,/* lineNo */
  "projective2d",                      /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\projective2d.m"/* pathName */
};

static emlrtRSInfo sn_emlrtRSI = { 218,/* lineNo */
  "projective2d",                      /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\projective2d.m"/* pathName */
};

static emlrtRSInfo tn_emlrtRSI = { 222,/* lineNo */
  "projective2d",                      /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\projective2d.m"/* pathName */
};

static emlrtRSInfo vn_emlrtRSI = { 336,/* lineNo */
  "projective2d",                      /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\projective2d.m"/* pathName */
};

static emlrtRSInfo wn_emlrtRSI = { 31, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo xn_emlrtRSI = { 42, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtRSInfo yn_emlrtRSI = { 46, /* lineNo */
  "inv",                               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\matfun\\inv.m"/* pathName */
};

static emlrtMCInfo c_emlrtMCI = { 140, /* lineNo */
  13,                                  /* colNo */
  "ImageTransformer",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pName */
};

static emlrtRTEInfo p_emlrtRTEI = { 61,/* lineNo */
  23,                                  /* colNo */
  "ImageTransformer",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pName */
};

static emlrtRTEInfo rb_emlrtRTEI = { 123,/* lineNo */
  18,                                  /* colNo */
  "ImageTransformer",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pName */
};

static emlrtRTEInfo sb_emlrtRTEI = { 133,/* lineNo */
  17,                                  /* colNo */
  "ImageTransformer",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pName */
};

static emlrtRTEInfo ub_emlrtRTEI = { 96,/* lineNo */
  35,                                  /* colNo */
  "ImageTransformer",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pName */
};

static emlrtRTEInfo vb_emlrtRTEI = { 169,/* lineNo */
  27,                                  /* colNo */
  "interp2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\interp2d.m"/* pName */
};

static emlrtRTEInfo wb_emlrtRTEI = { 156,/* lineNo */
  32,                                  /* colNo */
  "interp2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\interp2d.m"/* pName */
};

static emlrtRTEInfo xb_emlrtRTEI = { 156,/* lineNo */
  34,                                  /* colNo */
  "interp2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\interp2d.m"/* pName */
};

static emlrtRTEInfo yc_emlrtRTEI = { 222,/* lineNo */
  42,                                  /* colNo */
  "projective2d",                      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\projective2d.m"/* pName */
};

static emlrtRTEInfo ad_emlrtRTEI = { 126,/* lineNo */
  13,                                  /* colNo */
  "ImageTransformer",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pName */
};

static emlrtRTEInfo bd_emlrtRTEI = { 218,/* lineNo */
  17,                                  /* colNo */
  "projective2d",                      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\projective2d.m"/* pName */
};

static emlrtRTEInfo cd_emlrtRTEI = { 207,/* lineNo */
  17,                                  /* colNo */
  "projective2d",                      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\projective2d.m"/* pName */
};

static emlrtRTEInfo fe_emlrtRTEI = { 43,/* lineNo */
  25,                                  /* colNo */
  "ImageTransformer",                  /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pName */
};

static emlrtRTEInfo ef_emlrtRTEI = { 59,/* lineNo */
  23,                                  /* colNo */
  "reshape",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\elmat\\reshape.m"/* pName */
};

static emlrtRTEInfo if_emlrtRTEI = { 44,/* lineNo */
  1,                                   /* colNo */
  "interp2d",                          /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\+images\\+internal\\+coder\\interp2d.m"/* pName */
};

static emlrtRTEInfo pf_emlrtRTEI = { 13,/* lineNo */
  15,                                  /* colNo */
  "rdivide",                           /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\eml\\lib\\matlab\\ops\\rdivide.m"/* pName */
};

static emlrtECInfo r_emlrtECI = { -1,  /* nDims */
  222,                                 /* lineNo */
  21,                                  /* colNo */
  "projective2d",                      /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\images\\images\\projective2d.m"/* pName */
};

static emlrtRSInfo ps_emlrtRSI = { 140,/* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

/* Function Declarations */
static void ab_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[14]);
static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[14]);
static void clear(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location);
static void d_ImageTransformer_ImageTransfo(const emlrtStack *sp,
  c_vision_internal_calibration_I **this);
static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *c_sprintf,
  const char_T *identifier, char_T y[14]);

/* Function Definitions */
static void ab_emlrt_marshallIn(const emlrtStack *sp, const mxArray *src, const
  emlrtMsgIdentifier *msgId, char_T ret[14])
{
  static const int32_T dims[2] = { 1, 14 };

  emlrtCheckBuiltInR2012b(sp, msgId, src, "char", false, 2U, dims);
  emlrtImportCharArrayR2015b(sp, src, &ret[0], 14);
  emlrtDestroyArray(&src);
}

static void b_emlrt_marshallIn(const emlrtStack *sp, const mxArray *u, const
  emlrtMsgIdentifier *parentId, char_T y[14])
{
  ab_emlrt_marshallIn(sp, emlrtAlias(u), parentId, y);
  emlrtDestroyArray(&u);
}

static void clear(const emlrtStack *sp, const mxArray *b, emlrtMCInfo *location)
{
  const mxArray *pArray;
  pArray = b;
  emlrtCallMATLABR2012b(sp, 0, NULL, 1, &pArray, "clear", true, location);
}

static void d_ImageTransformer_ImageTransfo(const emlrtStack *sp,
  c_vision_internal_calibration_I **this)
{
  int32_T i73;
  static const char_T cv18[5] = { 'u', 'i', 'n', 't', '8' };

  static const char_T cv19[4] = { 's', 'a', 'm', 'e' };

  for (i73 = 0; i73 < 2; i73++) {
    (*this)->XBounds[i73] = -1.0;
  }

  for (i73 = 0; i73 < 2; i73++) {
    (*this)->YBounds[i73] = -1.0;
  }

  i73 = (*this)->SizeOfImage->size[0] * (*this)->SizeOfImage->size[1];
  (*this)->SizeOfImage->size[0] = 1;
  (*this)->SizeOfImage->size[1] = 2;
  emxEnsureCapacity_real_T1(sp, (*this)->SizeOfImage, i73, &fe_emlrtRTEI);
  for (i73 = 0; i73 < 2; i73++) {
    (*this)->SizeOfImage->data[i73] = 0.0;
  }

  i73 = (*this)->SizeOfImage->size[0] * (*this)->SizeOfImage->size[1];
  (*this)->SizeOfImage->size[0] = 1;
  (*this)->SizeOfImage->size[1] = 3;
  emxEnsureCapacity_real_T1(sp, (*this)->SizeOfImage, i73, &fe_emlrtRTEI);
  for (i73 = 0; i73 < 3; i73++) {
    (*this)->SizeOfImage->data[i73] = 0.0;
  }

  i73 = (*this)->ClassOfImage->size[0] * (*this)->ClassOfImage->size[1];
  (*this)->ClassOfImage->size[0] = 1;
  (*this)->ClassOfImage->size[1] = 1;
  emxEnsureCapacity_char_T(sp, (*this)->ClassOfImage, i73, &fe_emlrtRTEI);
  (*this)->ClassOfImage->data[0] = 'a';
  i73 = (*this)->ClassOfImage->size[0] * (*this)->ClassOfImage->size[1];
  (*this)->ClassOfImage->size[0] = 1;
  (*this)->ClassOfImage->size[1] = 5;
  emxEnsureCapacity_char_T(sp, (*this)->ClassOfImage, i73, &fe_emlrtRTEI);
  for (i73 = 0; i73 < 5; i73++) {
    (*this)->ClassOfImage->data[i73] = cv18[i73];
  }

  i73 = (*this)->OutputView->size[0] * (*this)->OutputView->size[1];
  (*this)->OutputView->size[0] = 1;
  (*this)->OutputView->size[1] = 1;
  emxEnsureCapacity_char_T(sp, (*this)->OutputView, i73, &fe_emlrtRTEI);
  (*this)->OutputView->data[0] = 'a';
  i73 = (*this)->OutputView->size[0] * (*this)->OutputView->size[1];
  (*this)->OutputView->size[0] = 1;
  (*this)->OutputView->size[1] = 4;
  emxEnsureCapacity_char_T(sp, (*this)->OutputView, i73, &fe_emlrtRTEI);
  for (i73 = 0; i73 < 4; i73++) {
    (*this)->OutputView->data[i73] = cv19[i73];
  }

  i73 = (*this)->XmapSingle->size[0] * (*this)->XmapSingle->size[1];
  (*this)->XmapSingle->size[0] = 2;
  (*this)->XmapSingle->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, (*this)->XmapSingle, i73, &fe_emlrtRTEI);
  for (i73 = 0; i73 < 4; i73++) {
    (*this)->XmapSingle->data[i73] = 0.0F;
  }

  i73 = (*this)->YmapSingle->size[0] * (*this)->YmapSingle->size[1];
  (*this)->YmapSingle->size[0] = 2;
  (*this)->YmapSingle->size[1] = 2;
  emxEnsureCapacity_real32_T(sp, (*this)->YmapSingle, i73, &fe_emlrtRTEI);
  for (i73 = 0; i73 < 4; i73++) {
    (*this)->YmapSingle->data[i73] = 0.0F;
  }
}

static void emlrt_marshallIn(const emlrtStack *sp, const mxArray *c_sprintf,
  const char_T *identifier, char_T y[14])
{
  emlrtMsgIdentifier thisId;
  thisId.fIdentifier = (const char *)identifier;
  thisId.fParent = NULL;
  thisId.bParentIsCell = false;
  b_emlrt_marshallIn(sp, emlrtAlias(c_sprintf), &thisId, y);
  emlrtDestroyArray(&c_sprintf);
}

void ImageTransformer_computeMap(const emlrtStack *sp,
  c_vision_internal_calibration_I *this, const real_T intrinsicMatrix[9], const
  real_T radialDist[2], const real_T tangentialDist[2])
{
  real_T m;
  real_T n;
  emxArray_real_T *r19;
  int32_T i15;
  real_T ndbl;
  real_T apnd;
  real_T cdiff;
  real_T absa;
  int32_T nm1d2;
  real_T absb;
  emxArray_real_T *r20;
  int32_T b_n;
  emxArray_real_T *X;
  emxArray_real_T *Y;
  boolean_T out;
  int32_T k;
  emxArray_real_T *b_X;
  emxArray_real_T *ptsOut;
  const mxArray *y;
  const mxArray *m2;
  static const int32_T iv12[2] = { 1, 5 };

  static const char_T u[5] = { 'p', 't', 's', 'I', 'n' };

  real_T varargin_1[2];
  int32_T i16;
  int32_T num[2];
  emxArray_real_T *b_ptsOut;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &b_st;
  c_st.tls = b_st.tls;
  d_st.prev = &c_st;
  d_st.tls = c_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &ki_emlrtRSI;
  m = this->XBounds[0];
  n = this->XBounds[1];
  b_st.site = &nh_emlrtRSI;
  emxInit_real_T(&b_st, &r19, 2, &rb_emlrtRTEI, true);
  if (muDoubleScalarIsNaN(m) || muDoubleScalarIsNaN(n)) {
    i15 = r19->size[0] * r19->size[1];
    r19->size[0] = 1;
    r19->size[1] = 1;
    emxEnsureCapacity_real_T1(&b_st, r19, i15, &rb_emlrtRTEI);
    r19->data[0] = rtNaN;
  } else if (n < m) {
    i15 = r19->size[0] * r19->size[1];
    r19->size[0] = 1;
    r19->size[1] = 0;
    emxEnsureCapacity_real_T1(&b_st, r19, i15, &rb_emlrtRTEI);
  } else if ((muDoubleScalarIsInf(m) || muDoubleScalarIsInf(n)) && (m == n)) {
    i15 = r19->size[0] * r19->size[1];
    r19->size[0] = 1;
    r19->size[1] = 1;
    emxEnsureCapacity_real_T1(&b_st, r19, i15, &rb_emlrtRTEI);
    r19->data[0] = rtNaN;
  } else if (muDoubleScalarFloor(m) == m) {
    i15 = r19->size[0] * r19->size[1];
    r19->size[0] = 1;
    r19->size[1] = (int32_T)muDoubleScalarFloor(n - m) + 1;
    emxEnsureCapacity_real_T1(&b_st, r19, i15, &rb_emlrtRTEI);
    nm1d2 = (int32_T)muDoubleScalarFloor(n - m);
    for (i15 = 0; i15 <= nm1d2; i15++) {
      r19->data[r19->size[0] * i15] = m + (real_T)i15;
    }
  } else {
    c_st.site = &oh_emlrtRSI;
    ndbl = muDoubleScalarFloor((n - m) + 0.5);
    apnd = m + ndbl;
    cdiff = apnd - n;
    absa = muDoubleScalarAbs(m);
    absb = muDoubleScalarAbs(n);
    if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 * muDoubleScalarMax
        (absa, absb)) {
      ndbl++;
      apnd = n;
    } else if (cdiff > 0.0) {
      apnd = m + (ndbl - 1.0);
    } else {
      ndbl++;
    }

    if (ndbl >= 0.0) {
      b_n = (int32_T)ndbl;
    } else {
      b_n = 0;
    }

    d_st.site = &ph_emlrtRSI;
    if (ndbl > 2.147483647E+9) {
      emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
        "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
    }

    i15 = r19->size[0] * r19->size[1];
    r19->size[0] = 1;
    r19->size[1] = b_n;
    emxEnsureCapacity_real_T1(&c_st, r19, i15, &ab_emlrtRTEI);
    if (b_n > 0) {
      r19->data[0] = m;
      if (b_n > 1) {
        r19->data[b_n - 1] = apnd;
        nm1d2 = (b_n - 1) / 2;
        for (k = 1; k < nm1d2; k++) {
          r19->data[k] = m + (real_T)k;
          r19->data[(b_n - k) - 1] = apnd - (real_T)k;
        }

        if (nm1d2 << 1 == b_n - 1) {
          r19->data[nm1d2] = (m + apnd) / 2.0;
        } else {
          r19->data[nm1d2] = m + (real_T)nm1d2;
          r19->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
        }
      }
    }
  }

  st.site = &li_emlrtRSI;
  m = this->YBounds[0];
  n = this->YBounds[1];
  b_st.site = &nh_emlrtRSI;
  emxInit_real_T(&b_st, &r20, 2, &rb_emlrtRTEI, true);
  if (muDoubleScalarIsNaN(m) || muDoubleScalarIsNaN(n)) {
    i15 = r20->size[0] * r20->size[1];
    r20->size[0] = 1;
    r20->size[1] = 1;
    emxEnsureCapacity_real_T1(&b_st, r20, i15, &rb_emlrtRTEI);
    r20->data[0] = rtNaN;
  } else if (n < m) {
    i15 = r20->size[0] * r20->size[1];
    r20->size[0] = 1;
    r20->size[1] = 0;
    emxEnsureCapacity_real_T1(&b_st, r20, i15, &rb_emlrtRTEI);
  } else if ((muDoubleScalarIsInf(m) || muDoubleScalarIsInf(n)) && (m == n)) {
    i15 = r20->size[0] * r20->size[1];
    r20->size[0] = 1;
    r20->size[1] = 1;
    emxEnsureCapacity_real_T1(&b_st, r20, i15, &rb_emlrtRTEI);
    r20->data[0] = rtNaN;
  } else if (muDoubleScalarFloor(m) == m) {
    i15 = r20->size[0] * r20->size[1];
    r20->size[0] = 1;
    r20->size[1] = (int32_T)muDoubleScalarFloor(n - m) + 1;
    emxEnsureCapacity_real_T1(&b_st, r20, i15, &rb_emlrtRTEI);
    nm1d2 = (int32_T)muDoubleScalarFloor(n - m);
    for (i15 = 0; i15 <= nm1d2; i15++) {
      r20->data[r20->size[0] * i15] = m + (real_T)i15;
    }
  } else {
    c_st.site = &oh_emlrtRSI;
    ndbl = muDoubleScalarFloor((n - m) + 0.5);
    apnd = m + ndbl;
    cdiff = apnd - n;
    absa = muDoubleScalarAbs(m);
    absb = muDoubleScalarAbs(n);
    if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 * muDoubleScalarMax
        (absa, absb)) {
      ndbl++;
      apnd = n;
    } else if (cdiff > 0.0) {
      apnd = m + (ndbl - 1.0);
    } else {
      ndbl++;
    }

    if (ndbl >= 0.0) {
      b_n = (int32_T)ndbl;
    } else {
      b_n = 0;
    }

    d_st.site = &ph_emlrtRSI;
    if (ndbl > 2.147483647E+9) {
      emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
        "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
    }

    i15 = r20->size[0] * r20->size[1];
    r20->size[0] = 1;
    r20->size[1] = b_n;
    emxEnsureCapacity_real_T1(&c_st, r20, i15, &ab_emlrtRTEI);
    if (b_n > 0) {
      r20->data[0] = m;
      if (b_n > 1) {
        r20->data[b_n - 1] = apnd;
        nm1d2 = (b_n - 1) / 2;
        for (k = 1; k < nm1d2; k++) {
          r20->data[k] = m + (real_T)k;
          r20->data[(b_n - k) - 1] = apnd - (real_T)k;
        }

        if (nm1d2 << 1 == b_n - 1) {
          r20->data[nm1d2] = (m + apnd) / 2.0;
        } else {
          r20->data[nm1d2] = m + (real_T)nm1d2;
          r20->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
        }
      }
    }
  }

  emxInit_real_T(&b_st, &X, 2, &rb_emlrtRTEI, true);
  emxInit_real_T(&b_st, &Y, 2, &rb_emlrtRTEI, true);
  st.site = &ki_emlrtRSI;
  b_meshgrid(&st, r19, r20, X, Y);
  st.site = &mi_emlrtRSI;
  b_st.site = &rh_emlrtRSI;
  c_st.site = &sh_emlrtRSI;
  out = true;
  emxFree_real_T(&c_st, &r20);
  emxFree_real_T(&c_st, &r19);
  if (Y->size[0] * Y->size[1] != X->size[0] * X->size[1]) {
    out = false;
  }

  if (!out) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  emxInit_real_T(&c_st, &b_X, 2, &rb_emlrtRTEI, true);
  nm1d2 = X->size[0] * X->size[1];
  k = Y->size[0] * Y->size[1];
  i15 = b_X->size[0] * b_X->size[1];
  b_X->size[0] = nm1d2;
  b_X->size[1] = 2;
  emxEnsureCapacity_real_T1(sp, b_X, i15, &rb_emlrtRTEI);
  for (i15 = 0; i15 < nm1d2; i15++) {
    b_X->data[i15] = X->data[i15];
  }

  emxFree_real_T(sp, &X);
  for (i15 = 0; i15 < k; i15++) {
    b_X->data[i15 + b_X->size[0]] = Y->data[i15];
  }

  emxFree_real_T(sp, &Y);
  emxInit_real_T(sp, &ptsOut, 2, &sb_emlrtRTEI, true);
  st.site = &ni_emlrtRSI;
  b_distortPoints(&st, b_X, intrinsicMatrix, radialDist, tangentialDist, ptsOut);
  y = NULL;
  m2 = emlrtCreateCharArray(2, iv12);
  emlrtInitCharArrayR2013a(sp, 5, m2, &u[0]);
  emlrtAssign(&y, m2);
  st.site = &ps_emlrtRSI;
  clear(&st, y, &c_emlrtMCI);
  m = (this->YBounds[1] - this->YBounds[0]) + 1.0;
  n = (this->XBounds[1] - this->XBounds[0]) + 1.0;
  emxFree_real_T(sp, &b_X);
  if (b_strcmp(this->ClassOfImage)) {
    st.site = &oi_emlrtRSI;
    varargin_1[0] = m;
    varargin_1[1] = n;
    i15 = ptsOut->size[0];
    b_st.site = &ui_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    for (i16 = 0; i16 < 2; i16++) {
      num[i16] = (int32_T)varargin_1[i16];
    }

    b_n = ptsOut->size[0];
    i16 = ptsOut->size[0];
    if (1 > i16) {
      b_n = 1;
    }

    nm1d2 = muIntScalarMax_sint32(i15, b_n);
    if (num[0] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    if (num[1] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    out = (num[0] >= 0);
    if (out && (num[1] >= 0)) {
    } else {
      out = false;
    }

    if (!out) {
      emlrtErrorWithMessageIdR2018a(&st, &ef_emlrtRTEI,
        "MATLAB:checkDimCommon:nonnegativeSize",
        "MATLAB:checkDimCommon:nonnegativeSize", 0);
    }

    i15 = ptsOut->size[0];
    if (num[0] * num[1] != i15) {
      emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
        "Coder:MATLAB:getReshapeDims_notSameNumel",
        "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }

    st.site = &pi_emlrtRSI;
    varargin_1[0] = m;
    varargin_1[1] = n;
    i15 = ptsOut->size[0];
    b_st.site = &ui_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    for (i16 = 0; i16 < 2; i16++) {
      num[i16] = (int32_T)varargin_1[i16];
    }

    b_n = ptsOut->size[0];
    i16 = ptsOut->size[0];
    if (1 > i16) {
      b_n = 1;
    }

    nm1d2 = muIntScalarMax_sint32(i15, b_n);
    if (num[0] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    if (num[1] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    out = (num[0] >= 0);
    if (out && (num[1] >= 0)) {
    } else {
      out = false;
    }

    if (!out) {
      emlrtErrorWithMessageIdR2018a(&st, &ef_emlrtRTEI,
        "MATLAB:checkDimCommon:nonnegativeSize",
        "MATLAB:checkDimCommon:nonnegativeSize", 0);
    }

    i15 = ptsOut->size[0];
    if (num[0] * num[1] != i15) {
      emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
        "Coder:MATLAB:getReshapeDims_notSameNumel",
        "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }
  } else {
    st.site = &qi_emlrtRSI;
    varargin_1[0] = m;
    varargin_1[1] = n;
    i15 = ptsOut->size[0];
    b_st.site = &ui_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    for (i16 = 0; i16 < 2; i16++) {
      num[i16] = (int32_T)varargin_1[i16];
    }

    b_n = ptsOut->size[0];
    i16 = ptsOut->size[0];
    if (1 > i16) {
      b_n = 1;
    }

    nm1d2 = muIntScalarMax_sint32(i15, b_n);
    if (num[0] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    if (num[1] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    out = (num[0] >= 0);
    if (out && (num[1] >= 0)) {
    } else {
      out = false;
    }

    if (!out) {
      emlrtErrorWithMessageIdR2018a(&st, &ef_emlrtRTEI,
        "MATLAB:checkDimCommon:nonnegativeSize",
        "MATLAB:checkDimCommon:nonnegativeSize", 0);
    }

    i15 = ptsOut->size[0];
    if (num[0] * num[1] != i15) {
      emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
        "Coder:MATLAB:getReshapeDims_notSameNumel",
        "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }

    emxInit_real_T1(&st, &b_ptsOut, 1, &rb_emlrtRTEI, true);
    nm1d2 = ptsOut->size[0];
    i15 = b_ptsOut->size[0];
    b_ptsOut->size[0] = nm1d2;
    emxEnsureCapacity_real_T(sp, b_ptsOut, i15, &rb_emlrtRTEI);
    for (i15 = 0; i15 < nm1d2; i15++) {
      b_ptsOut->data[i15] = ptsOut->data[i15];
    }

    k = num[0];
    i15 = this->XmapSingle->size[0] * this->XmapSingle->size[1];
    this->XmapSingle->size[0] = num[0];
    this->XmapSingle->size[1] = num[1];
    emxEnsureCapacity_real32_T(sp, this->XmapSingle, i15, &rb_emlrtRTEI);
    nm1d2 = num[1];
    for (i15 = 0; i15 < nm1d2; i15++) {
      for (i16 = 0; i16 < k; i16++) {
        this->XmapSingle->data[i16 + this->XmapSingle->size[0] * i15] =
          (real32_T)b_ptsOut->data[i16 + k * i15];
      }
    }

    st.site = &ri_emlrtRSI;
    varargin_1[0] = m;
    varargin_1[1] = n;
    i15 = ptsOut->size[0];
    b_st.site = &ui_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    for (i16 = 0; i16 < 2; i16++) {
      num[i16] = (int32_T)varargin_1[i16];
    }

    b_n = ptsOut->size[0];
    i16 = ptsOut->size[0];
    if (1 > i16) {
      b_n = 1;
    }

    nm1d2 = muIntScalarMax_sint32(i15, b_n);
    if (num[0] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    if (num[1] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    out = (num[0] >= 0);
    if (out && (num[1] >= 0)) {
    } else {
      out = false;
    }

    if (!out) {
      emlrtErrorWithMessageIdR2018a(&st, &ef_emlrtRTEI,
        "MATLAB:checkDimCommon:nonnegativeSize",
        "MATLAB:checkDimCommon:nonnegativeSize", 0);
    }

    i15 = ptsOut->size[0];
    if (num[0] * num[1] != i15) {
      emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
        "Coder:MATLAB:getReshapeDims_notSameNumel",
        "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }

    nm1d2 = ptsOut->size[0];
    i15 = b_ptsOut->size[0];
    b_ptsOut->size[0] = nm1d2;
    emxEnsureCapacity_real_T(sp, b_ptsOut, i15, &rb_emlrtRTEI);
    for (i15 = 0; i15 < nm1d2; i15++) {
      b_ptsOut->data[i15] = ptsOut->data[i15 + ptsOut->size[0]];
    }

    k = num[0];
    i15 = this->YmapSingle->size[0] * this->YmapSingle->size[1];
    this->YmapSingle->size[0] = num[0];
    this->YmapSingle->size[1] = num[1];
    emxEnsureCapacity_real32_T(sp, this->YmapSingle, i15, &rb_emlrtRTEI);
    nm1d2 = num[1];
    for (i15 = 0; i15 < nm1d2; i15++) {
      for (i16 = 0; i16 < k; i16++) {
        this->YmapSingle->data[i16 + this->YmapSingle->size[0] * i15] =
          (real32_T)b_ptsOut->data[i16 + k * i15];
      }
    }

    emxFree_real_T(sp, &b_ptsOut);
  }

  emxFree_real_T(sp, &ptsOut);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

boolean_T ImageTransformer_needToUpdate(const emlrtStack *sp, const
  c_vision_internal_calibration_I *this)
{
  boolean_T tf;
  emxArray_real_T *varargin_1;
  int32_T k;
  int32_T loop_ub;
  boolean_T sameSize;
  boolean_T p;
  boolean_T exitg1;
  emxArray_char_T *b;
  static const int16_T iv4[3] = { 480, 640, 3 };

  boolean_T sameClass;
  int32_T exitg2;
  static const char_T cv8[5] = { 'u', 'i', 'n', 't', '8' };

  boolean_T sameOutputView;
  static const char_T cv9[5] = { 'v', 'a', 'l', 'i', 'd' };

  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real_T(sp, &varargin_1, 2, &p_emlrtRTEI, true);
  k = varargin_1->size[0] * varargin_1->size[1];
  varargin_1->size[0] = 1;
  varargin_1->size[1] = this->SizeOfImage->size[1];
  emxEnsureCapacity_real_T1(sp, varargin_1, k, &p_emlrtRTEI);
  loop_ub = this->SizeOfImage->size[0] * this->SizeOfImage->size[1];
  for (k = 0; k < loop_ub; k++) {
    varargin_1->data[k] = this->SizeOfImage->data[k];
  }

  sameSize = false;
  p = false;
  if (varargin_1->size[1] == 3) {
    p = true;
  }

  if (p && (!(varargin_1->size[1] == 0))) {
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 3)) {
      if (!(varargin_1->data[k] == iv4[k])) {
        p = false;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  emxFree_real_T(sp, &varargin_1);
  if (p) {
    sameSize = true;
  }

  emxInit_char_T(sp, &b, 2, &p_emlrtRTEI, true);
  k = b->size[0] * b->size[1];
  b->size[0] = 1;
  b->size[1] = this->ClassOfImage->size[1];
  emxEnsureCapacity_char_T(sp, b, k, &p_emlrtRTEI);
  loop_ub = this->ClassOfImage->size[0] * this->ClassOfImage->size[1];
  for (k = 0; k < loop_ub; k++) {
    b->data[k] = this->ClassOfImage->data[k];
  }

  sameClass = false;
  if (5 == b->size[1]) {
    k = 0;
    do {
      exitg2 = 0;
      if (k + 1 < 6) {
        if (cv8[k] != b->data[k]) {
          exitg2 = 1;
        } else {
          k++;
        }
      } else {
        sameClass = true;
        exitg2 = 1;
      }
    } while (exitg2 == 0);
  }

  k = b->size[0] * b->size[1];
  b->size[0] = 1;
  b->size[1] = this->OutputView->size[1];
  emxEnsureCapacity_char_T(sp, b, k, &p_emlrtRTEI);
  loop_ub = this->OutputView->size[0] * this->OutputView->size[1];
  for (k = 0; k < loop_ub; k++) {
    b->data[k] = this->OutputView->data[k];
  }

  sameOutputView = false;
  p = false;
  if (b->size[1] == 5) {
    p = true;
  }

  if (p && (!(b->size[1] == 0))) {
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 5)) {
      if (!(b->data[k] == cv9[k])) {
        p = false;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  emxFree_char_T(sp, &b);
  if (p) {
    sameOutputView = true;
  }

  if (sameSize && sameClass && sameOutputView) {
    sameSize = true;
  } else {
    sameSize = false;
  }

  tf = !sameSize;
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
  return tf;
}

void ImageTransformer_transformImage(e_depthEstimationFromStereoVide *SD, const
  emlrtStack *sp, const c_vision_internal_calibration_I *this, emxArray_uint8_T *
  J)
{
  emxArray_real32_T *X;
  int32_T i18;
  int32_T outputImageSize_idx_0;
  emxArray_real32_T *Y;
  int32_T varargin_1[2];
  boolean_T p;
  int32_T varargin_2[2];
  boolean_T b_p;
  boolean_T exitg1;
  int32_T outputImageSize_idx_1;
  uint8_T fillValues;
  real_T dv4[2];
  real_T b_J[2];
  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real32_T(sp, &X, 2, &wb_emlrtRTEI, true);
  st.site = &wi_emlrtRSI;
  i18 = X->size[0] * X->size[1];
  X->size[0] = this->XmapSingle->size[0];
  X->size[1] = this->XmapSingle->size[1];
  emxEnsureCapacity_real32_T(&st, X, i18, &ub_emlrtRTEI);
  outputImageSize_idx_0 = this->XmapSingle->size[0] * this->XmapSingle->size[1];
  for (i18 = 0; i18 < outputImageSize_idx_0; i18++) {
    X->data[i18] = this->XmapSingle->data[i18];
  }

  emxInit_real32_T(&st, &Y, 2, &xb_emlrtRTEI, true);
  i18 = Y->size[0] * Y->size[1];
  Y->size[0] = this->YmapSingle->size[0];
  Y->size[1] = this->YmapSingle->size[1];
  emxEnsureCapacity_real32_T(&st, Y, i18, &ub_emlrtRTEI);
  outputImageSize_idx_0 = this->YmapSingle->size[0] * this->YmapSingle->size[1];
  for (i18 = 0; i18 < outputImageSize_idx_0; i18++) {
    Y->data[i18] = this->YmapSingle->data[i18];
  }

  b_st.site = &xi_emlrtRSI;
  validateattributes(&b_st, X);
  b_st.site = &yi_emlrtRSI;
  b_validateattributes(&b_st, Y);
  for (i18 = 0; i18 < 2; i18++) {
    varargin_1[i18] = X->size[i18];
  }

  for (i18 = 0; i18 < 2; i18++) {
    varargin_2[i18] = Y->size[i18];
  }

  p = false;
  b_p = true;
  outputImageSize_idx_0 = 0;
  exitg1 = false;
  while ((!exitg1) && (outputImageSize_idx_0 < 2)) {
    if (!(varargin_1[outputImageSize_idx_0] == varargin_2[outputImageSize_idx_0]))
    {
      b_p = false;
      exitg1 = true;
    } else {
      outputImageSize_idx_0++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&st, &if_emlrtRTEI,
      "images:interp2d:inconsistentXYSize", "images:interp2d:inconsistentXYSize",
      0);
  }

  outputImageSize_idx_0 = X->size[0] * X->size[1] - 1;
  i18 = X->size[0] * X->size[1];
  emxEnsureCapacity_real32_T(&st, X, i18, &ub_emlrtRTEI);
  for (i18 = 0; i18 <= outputImageSize_idx_0; i18++) {
    X->data[i18]--;
  }

  outputImageSize_idx_0 = Y->size[0] * Y->size[1] - 1;
  i18 = Y->size[0] * Y->size[1];
  emxEnsureCapacity_real32_T(&st, Y, i18, &ub_emlrtRTEI);
  for (i18 = 0; i18 <= outputImageSize_idx_0; i18++) {
    Y->data[i18]--;
  }

  b_st.site = &aj_emlrtRSI;
  outputImageSize_idx_0 = X->size[0];
  outputImageSize_idx_1 = X->size[1];
  i18 = J->size[0] * J->size[1];
  J->size[0] = outputImageSize_idx_0;
  J->size[1] = outputImageSize_idx_1;
  emxEnsureCapacity_uint8_T(&b_st, J, i18, &vb_emlrtRTEI);
  memset(&SD->u1.f1.inputImage[0], 1, 307200U * sizeof(uint8_T));
  fillValues = 0U;
  for (i18 = 0; i18 < 2; i18++) {
    dv4[i18] = 480.0 + 160.0 * (real_T)i18;
    b_J[i18] = J->size[i18];
  }

  remaptbb_uint8(SD->u1.f1.inputImage, dv4, 2.0, &Y->data[0], &X->data[0], 1,
                 &fillValues, &J->data[0], b_J, (real_T)(J->size[0] * J->size[1]));
  emxFree_real32_T(sp, &Y);
  emxFree_real32_T(sp, &X);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void b_ImageTransformer_computeMap(const emlrtStack *sp,
  c_vision_internal_calibration_I *this, const real_T intrinsicMatrix[9], const
  real_T radialDist[2], const real_T tangentialDist[2], const real_T H_T[9])
{
  real_T absx11;
  real_T absx21;
  emxArray_real_T *r28;
  int32_T itmp;
  real_T ndbl;
  real_T apnd;
  real_T cdiff;
  real_T absa;
  int32_T nm1d2;
  real_T absb;
  emxArray_real_T *r29;
  int32_T p2;
  emxArray_real_T *X;
  emxArray_real_T *Y;
  boolean_T overflow;
  int32_T p3;
  emxArray_real_T *b_X;
  emxArray_real_T *c_X;
  real_T x[9];
  real_T xinv[9];
  const mxArray *y;
  const mxArray *m5;
  static const int32_T iv19[2] = { 1, 6 };

  static const char_T rfmt[6] = { '%', '1', '4', '.', '6', 'e' };

  const mxArray *b_y;
  emxArray_real_T *U;
  char_T cv13[14];
  char_T TRANSA;
  char_T TRANSB;
  ptrdiff_t m_t;
  emxArray_real_T *ptsIn;
  ptrdiff_t n_t;
  emxArray_real_T *ptsOut;
  ptrdiff_t k_t;
  ptrdiff_t lda_t;
  emxArray_int32_T *r30;
  ptrdiff_t ldb_t;
  ptrdiff_t ldc_t;
  static const int32_T iv20[2] = { 1, 5 };

  static const char_T u[5] = { 'p', 't', 's', 'I', 'n' };

  static const int32_T iv21[2] = { 1, 15 };

  real_T varargin_1[2];
  int32_T outsize[2];
  uint32_T varargin_2[2];
  boolean_T p;
  boolean_T exitg1;
  emxArray_real_T *b_ptsOut;
  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &ki_emlrtRSI;
  absx11 = this->XBounds[0];
  absx21 = this->XBounds[1];
  b_st.site = &nh_emlrtRSI;
  emxInit_real_T(&b_st, &r28, 2, &rb_emlrtRTEI, true);
  if (muDoubleScalarIsNaN(absx11) || muDoubleScalarIsNaN(absx21)) {
    itmp = r28->size[0] * r28->size[1];
    r28->size[0] = 1;
    r28->size[1] = 1;
    emxEnsureCapacity_real_T1(&b_st, r28, itmp, &rb_emlrtRTEI);
    r28->data[0] = rtNaN;
  } else if (absx21 < absx11) {
    itmp = r28->size[0] * r28->size[1];
    r28->size[0] = 1;
    r28->size[1] = 0;
    emxEnsureCapacity_real_T1(&b_st, r28, itmp, &rb_emlrtRTEI);
  } else if ((muDoubleScalarIsInf(absx11) || muDoubleScalarIsInf(absx21)) &&
             (absx11 == absx21)) {
    itmp = r28->size[0] * r28->size[1];
    r28->size[0] = 1;
    r28->size[1] = 1;
    emxEnsureCapacity_real_T1(&b_st, r28, itmp, &rb_emlrtRTEI);
    r28->data[0] = rtNaN;
  } else if (muDoubleScalarFloor(absx11) == absx11) {
    itmp = r28->size[0] * r28->size[1];
    r28->size[0] = 1;
    r28->size[1] = (int32_T)muDoubleScalarFloor(absx21 - absx11) + 1;
    emxEnsureCapacity_real_T1(&b_st, r28, itmp, &rb_emlrtRTEI);
    nm1d2 = (int32_T)muDoubleScalarFloor(absx21 - absx11);
    for (itmp = 0; itmp <= nm1d2; itmp++) {
      r28->data[r28->size[0] * itmp] = absx11 + (real_T)itmp;
    }
  } else {
    c_st.site = &oh_emlrtRSI;
    ndbl = muDoubleScalarFloor((absx21 - absx11) + 0.5);
    apnd = absx11 + ndbl;
    cdiff = apnd - absx21;
    absa = muDoubleScalarAbs(absx11);
    absb = muDoubleScalarAbs(absx21);
    if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 * muDoubleScalarMax
        (absa, absb)) {
      ndbl++;
      apnd = absx21;
    } else if (cdiff > 0.0) {
      apnd = absx11 + (ndbl - 1.0);
    } else {
      ndbl++;
    }

    if (ndbl >= 0.0) {
      p2 = (int32_T)ndbl;
    } else {
      p2 = 0;
    }

    d_st.site = &ph_emlrtRSI;
    if (ndbl > 2.147483647E+9) {
      emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
        "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
    }

    itmp = r28->size[0] * r28->size[1];
    r28->size[0] = 1;
    r28->size[1] = p2;
    emxEnsureCapacity_real_T1(&c_st, r28, itmp, &ab_emlrtRTEI);
    if (p2 > 0) {
      r28->data[0] = absx11;
      if (p2 > 1) {
        r28->data[p2 - 1] = apnd;
        nm1d2 = (p2 - 1) / 2;
        d_st.site = &qh_emlrtRSI;
        for (p3 = 1; p3 < nm1d2; p3++) {
          r28->data[p3] = absx11 + (real_T)p3;
          r28->data[(p2 - p3) - 1] = apnd - (real_T)p3;
        }

        if (nm1d2 << 1 == p2 - 1) {
          r28->data[nm1d2] = (absx11 + apnd) / 2.0;
        } else {
          r28->data[nm1d2] = absx11 + (real_T)nm1d2;
          r28->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
        }
      }
    }
  }

  st.site = &li_emlrtRSI;
  absx11 = this->YBounds[0];
  absx21 = this->YBounds[1];
  b_st.site = &nh_emlrtRSI;
  emxInit_real_T(&b_st, &r29, 2, &rb_emlrtRTEI, true);
  if (muDoubleScalarIsNaN(absx11) || muDoubleScalarIsNaN(absx21)) {
    itmp = r29->size[0] * r29->size[1];
    r29->size[0] = 1;
    r29->size[1] = 1;
    emxEnsureCapacity_real_T1(&b_st, r29, itmp, &rb_emlrtRTEI);
    r29->data[0] = rtNaN;
  } else if (absx21 < absx11) {
    itmp = r29->size[0] * r29->size[1];
    r29->size[0] = 1;
    r29->size[1] = 0;
    emxEnsureCapacity_real_T1(&b_st, r29, itmp, &rb_emlrtRTEI);
  } else if ((muDoubleScalarIsInf(absx11) || muDoubleScalarIsInf(absx21)) &&
             (absx11 == absx21)) {
    itmp = r29->size[0] * r29->size[1];
    r29->size[0] = 1;
    r29->size[1] = 1;
    emxEnsureCapacity_real_T1(&b_st, r29, itmp, &rb_emlrtRTEI);
    r29->data[0] = rtNaN;
  } else if (muDoubleScalarFloor(absx11) == absx11) {
    itmp = r29->size[0] * r29->size[1];
    r29->size[0] = 1;
    r29->size[1] = (int32_T)muDoubleScalarFloor(absx21 - absx11) + 1;
    emxEnsureCapacity_real_T1(&b_st, r29, itmp, &rb_emlrtRTEI);
    nm1d2 = (int32_T)muDoubleScalarFloor(absx21 - absx11);
    for (itmp = 0; itmp <= nm1d2; itmp++) {
      r29->data[r29->size[0] * itmp] = absx11 + (real_T)itmp;
    }
  } else {
    c_st.site = &oh_emlrtRSI;
    ndbl = muDoubleScalarFloor((absx21 - absx11) + 0.5);
    apnd = absx11 + ndbl;
    cdiff = apnd - absx21;
    absa = muDoubleScalarAbs(absx11);
    absb = muDoubleScalarAbs(absx21);
    if (muDoubleScalarAbs(cdiff) < 4.4408920985006262E-16 * muDoubleScalarMax
        (absa, absb)) {
      ndbl++;
      apnd = absx21;
    } else if (cdiff > 0.0) {
      apnd = absx11 + (ndbl - 1.0);
    } else {
      ndbl++;
    }

    if (ndbl >= 0.0) {
      p2 = (int32_T)ndbl;
    } else {
      p2 = 0;
    }

    d_st.site = &ph_emlrtRSI;
    if (ndbl > 2.147483647E+9) {
      emlrtErrorWithMessageIdR2018a(&d_st, &df_emlrtRTEI,
        "Coder:MATLAB:pmaxsize", "Coder:MATLAB:pmaxsize", 0);
    }

    itmp = r29->size[0] * r29->size[1];
    r29->size[0] = 1;
    r29->size[1] = p2;
    emxEnsureCapacity_real_T1(&c_st, r29, itmp, &ab_emlrtRTEI);
    if (p2 > 0) {
      r29->data[0] = absx11;
      if (p2 > 1) {
        r29->data[p2 - 1] = apnd;
        nm1d2 = (p2 - 1) / 2;
        d_st.site = &qh_emlrtRSI;
        for (p3 = 1; p3 < nm1d2; p3++) {
          r29->data[p3] = absx11 + (real_T)p3;
          r29->data[(p2 - p3) - 1] = apnd - (real_T)p3;
        }

        if (nm1d2 << 1 == p2 - 1) {
          r29->data[nm1d2] = (absx11 + apnd) / 2.0;
        } else {
          r29->data[nm1d2] = absx11 + (real_T)nm1d2;
          r29->data[nm1d2 + 1] = apnd - (real_T)nm1d2;
        }
      }
    }
  }

  emxInit_real_T(&b_st, &X, 2, &rb_emlrtRTEI, true);
  emxInit_real_T(&b_st, &Y, 2, &rb_emlrtRTEI, true);
  st.site = &ki_emlrtRSI;
  b_meshgrid(&st, r28, r29, X, Y);
  st.site = &mi_emlrtRSI;
  b_st.site = &rh_emlrtRSI;
  c_st.site = &sh_emlrtRSI;
  overflow = true;
  emxFree_real_T(&c_st, &r29);
  emxFree_real_T(&c_st, &r28);
  if (Y->size[0] * Y->size[1] != X->size[0] * X->size[1]) {
    overflow = false;
  }

  if (!overflow) {
    emlrtErrorWithMessageIdR2018a(&c_st, &ke_emlrtRTEI,
      "MATLAB:catenate:matrixDimensionMismatch",
      "MATLAB:catenate:matrixDimensionMismatch", 0);
  }

  emxInit_real_T(&c_st, &b_X, 2, &rb_emlrtRTEI, true);
  st.site = &qn_emlrtRSI;
  nm1d2 = X->size[0] * X->size[1];
  p2 = Y->size[0] * Y->size[1];
  itmp = b_X->size[0] * b_X->size[1];
  b_X->size[0] = nm1d2;
  b_X->size[1] = 2;
  emxEnsureCapacity_real_T1(&st, b_X, itmp, &rb_emlrtRTEI);
  for (itmp = 0; itmp < nm1d2; itmp++) {
    b_X->data[itmp] = X->data[itmp];
  }

  emxFree_real_T(&st, &X);
  for (itmp = 0; itmp < p2; itmp++) {
    b_X->data[itmp + b_X->size[0]] = Y->data[itmp];
  }

  emxFree_real_T(&st, &Y);
  emxInit_real_T(&st, &c_X, 2, &cd_emlrtRTEI, true);
  b_st.site = &rn_emlrtRSI;
  b_padarray(&b_st, b_X, c_X);
  b_st.site = &sn_emlrtRSI;
  c_st.site = &vn_emlrtRSI;
  emxFree_real_T(&c_st, &b_X);
  memcpy(&x[0], &H_T[0], 9U * sizeof(real_T));
  nm1d2 = 0;
  p2 = 3;
  p3 = 6;
  absx11 = muDoubleScalarAbs(H_T[0]);
  absx21 = muDoubleScalarAbs(H_T[1]);
  ndbl = muDoubleScalarAbs(H_T[2]);
  if ((absx21 > absx11) && (absx21 > ndbl)) {
    nm1d2 = 3;
    p2 = 0;
    x[0] = H_T[1];
    x[1] = H_T[0];
    x[3] = H_T[4];
    x[4] = H_T[3];
    x[6] = H_T[7];
    x[7] = H_T[6];
  } else {
    if (ndbl > absx11) {
      nm1d2 = 6;
      p3 = 0;
      x[0] = H_T[2];
      x[2] = H_T[0];
      x[3] = H_T[5];
      x[5] = H_T[3];
      x[6] = H_T[8];
      x[8] = H_T[6];
    }
  }

  absx11 = x[1] / x[0];
  x[1] /= x[0];
  absx21 = x[2] / x[0];
  x[2] /= x[0];
  x[4] -= absx11 * x[3];
  x[5] -= absx21 * x[3];
  x[7] -= absx11 * x[6];
  x[8] -= absx21 * x[6];
  if (muDoubleScalarAbs(x[5]) > muDoubleScalarAbs(x[4])) {
    itmp = p2;
    p2 = p3;
    p3 = itmp;
    x[1] = absx21;
    x[2] = absx11;
    absx11 = x[4];
    x[4] = x[5];
    x[5] = absx11;
    absx11 = x[7];
    x[7] = x[8];
    x[8] = absx11;
  }

  absx11 = x[5] / x[4];
  x[5] /= x[4];
  x[8] -= absx11 * x[7];
  absx11 = (x[5] * x[1] - x[2]) / x[8];
  absx21 = -(x[1] + x[7] * absx11) / x[4];
  xinv[nm1d2] = ((1.0 - x[3] * absx21) - x[6] * absx11) / x[0];
  xinv[nm1d2 + 1] = absx21;
  xinv[nm1d2 + 2] = absx11;
  absx11 = -x[5] / x[8];
  absx21 = (1.0 - x[7] * absx11) / x[4];
  xinv[p2] = -(x[3] * absx21 + x[6] * absx11) / x[0];
  xinv[p2 + 1] = absx21;
  xinv[p2 + 2] = absx11;
  absx11 = 1.0 / x[8];
  absx21 = -x[7] * absx11 / x[4];
  xinv[p3] = -(x[3] * absx21 + x[6] * absx11) / x[0];
  xinv[p3 + 1] = absx21;
  xinv[p3 + 2] = absx11;
  d_st.site = &wn_emlrtRSI;
  absx11 = b_norm(H_T);
  absx21 = b_norm(xinv);
  ndbl = 1.0 / (absx11 * absx21);
  if ((absx11 == 0.0) || (absx21 == 0.0) || (ndbl == 0.0)) {
    e_st.site = &xn_emlrtRSI;
    warning(&e_st);
  } else {
    if (muDoubleScalarIsNaN(ndbl) || (ndbl < 2.2204460492503131E-16)) {
      e_st.site = &yn_emlrtRSI;
      y = NULL;
      m5 = emlrtCreateCharArray(2, iv19);
      emlrtInitCharArrayR2013a(&e_st, 6, m5, &rfmt[0]);
      emlrtAssign(&y, m5);
      b_y = NULL;
      m5 = emlrtCreateDoubleScalar(ndbl);
      emlrtAssign(&b_y, m5);
      f_st.site = &ss_emlrtRSI;
      emlrt_marshallIn(&f_st, b_sprintf(&f_st, y, b_y, &f_emlrtMCI), "sprintf",
                       cv13);
      e_st.site = &yn_emlrtRSI;
      c_warning(&e_st, cv13);
    }
  }

  b_st.site = &sn_emlrtRSI;
  c_st.site = &ao_emlrtRSI;
  emxInit_real_T(&c_st, &U, 2, &bd_emlrtRTEI, true);
  if (c_X->size[0] == 0) {
    itmp = U->size[0] * U->size[1];
    U->size[0] = 0;
    U->size[1] = 3;
    emxEnsureCapacity_real_T1(&c_st, U, itmp, &rb_emlrtRTEI);
  } else {
    d_st.site = &co_emlrtRSI;
    d_st.site = &bo_emlrtRSI;
    TRANSA = 'N';
    TRANSB = 'N';
    absx11 = 1.0;
    absx21 = 0.0;
    m_t = (ptrdiff_t)c_X->size[0];
    n_t = (ptrdiff_t)3;
    k_t = (ptrdiff_t)3;
    lda_t = (ptrdiff_t)c_X->size[0];
    ldb_t = (ptrdiff_t)3;
    ldc_t = (ptrdiff_t)c_X->size[0];
    itmp = U->size[0] * U->size[1];
    U->size[0] = c_X->size[0];
    U->size[1] = 3;
    emxEnsureCapacity_real_T1(&d_st, U, itmp, &xc_emlrtRTEI);
    dgemm(&TRANSA, &TRANSB, &m_t, &n_t, &k_t, &absx11, &c_X->data[0], &lda_t,
          &xinv[0], &ldb_t, &absx21, &U->data[0], &ldc_t);
  }

  emxFree_real_T(&c_st, &c_X);
  emxInit_real_T(&st, &ptsIn, 2, &ad_emlrtRTEI, true);
  emxInit_real_T(&st, &ptsOut, 2, &sb_emlrtRTEI, true);
  if (U->size[0] == 0) {
    itmp = ptsIn->size[0] * ptsIn->size[1];
    ptsIn->size[0] = 0;
    ptsIn->size[1] = 2;
    emxEnsureCapacity_real_T1(&st, ptsIn, itmp, &rb_emlrtRTEI);
  } else {
    emxInit_int32_T(&st, &r30, 1, &rb_emlrtRTEI, true);
    nm1d2 = U->size[0];
    itmp = r30->size[0];
    r30->size[0] = nm1d2;
    emxEnsureCapacity_int32_T(&st, r30, itmp, &rb_emlrtRTEI);
    for (itmp = 0; itmp < nm1d2; itmp++) {
      r30->data[itmp] = itmp;
    }

    b_st.site = &tn_emlrtRSI;
    itmp = U->size[0];
    p3 = U->size[0];
    if (itmp != p3) {
      y = NULL;
      m5 = emlrtCreateCharArray(2, iv21);
      emlrtInitCharArrayR2013a(&b_st, 15, m5, &cv1[0]);
      emlrtAssign(&y, m5);
      c_st.site = &qs_emlrtRSI;
      f_error(&c_st, y, &d_emlrtMCI);
    }

    p3 = ptsIn->size[0] * ptsIn->size[1];
    ptsIn->size[0] = itmp;
    ptsIn->size[1] = 2;
    emxEnsureCapacity_real_T1(&b_st, ptsIn, p3, &yc_emlrtRTEI);
    itmp = U->size[0];
    overflow = (itmp > 2147483646);
    for (nm1d2 = 0; nm1d2 < 2; nm1d2++) {
      p2 = nm1d2 * itmp;
      c_st.site = &do_emlrtRSI;
      if (overflow) {
        d_st.site = &lb_emlrtRSI;
        check_forloop_overflow_error(&d_st);
      }

      for (p3 = 0; p3 < itmp; p3++) {
        ptsIn->data[p2 + p3] = U->data[p3 + (U->size[0] << 1)];
      }
    }

    b_st.site = &tn_emlrtRSI;
    itmp = U->size[0];
    varargin_1[0] = itmp;
    varargin_1[1] = 2.0;
    for (itmp = 0; itmp < 2; itmp++) {
      varargin_2[itmp] = (uint32_T)ptsIn->size[itmp];
    }

    overflow = false;
    p = true;
    p3 = 0;
    exitg1 = false;
    while ((!exitg1) && (p3 < 2)) {
      if (!((int32_T)(uint32_T)varargin_1[p3] == (int32_T)varargin_2[p3])) {
        p = false;
        exitg1 = true;
      } else {
        p3++;
      }
    }

    if (p) {
      overflow = true;
    }

    if (!overflow) {
      emlrtErrorWithMessageIdR2018a(&b_st, &pf_emlrtRTEI, "MATLAB:dimagree",
        "MATLAB:dimagree", 0);
    }

    nm1d2 = U->size[0];
    itmp = ptsOut->size[0] * ptsOut->size[1];
    ptsOut->size[0] = nm1d2;
    ptsOut->size[1] = 2;
    emxEnsureCapacity_real_T1(&b_st, ptsOut, itmp, &rb_emlrtRTEI);
    for (itmp = 0; itmp < 2; itmp++) {
      for (p3 = 0; p3 < nm1d2; p3++) {
        ptsOut->data[p3 + ptsOut->size[0] * itmp] = U->data[p3 + U->size[0] *
          itmp] / ptsIn->data[p3 + ptsIn->size[0] * itmp];
      }
    }

    outsize[0] = r30->size[0];
    outsize[1] = 2;
    emlrtSubAssignSizeCheckR2012b(&outsize[0], 2, &(*(int32_T (*)[2])
      ptsOut->size)[0], 2, &r_emlrtECI, &st);
    for (itmp = 0; itmp < 2; itmp++) {
      nm1d2 = ptsOut->size[0];
      for (p3 = 0; p3 < nm1d2; p3++) {
        U->data[r30->data[p3] + U->size[0] * itmp] = ptsOut->data[p3 +
          ptsOut->size[0] * itmp];
      }
    }

    emxFree_int32_T(&st, &r30);
    nm1d2 = U->size[0];
    itmp = ptsIn->size[0] * ptsIn->size[1];
    ptsIn->size[0] = nm1d2;
    ptsIn->size[1] = 2;
    emxEnsureCapacity_real_T1(&st, ptsIn, itmp, &rb_emlrtRTEI);
    for (itmp = 0; itmp < 2; itmp++) {
      for (p3 = 0; p3 < nm1d2; p3++) {
        ptsIn->data[p3 + ptsIn->size[0] * itmp] = U->data[p3 + U->size[0] * itmp];
      }
    }
  }

  emxFree_real_T(&st, &U);
  st.site = &ni_emlrtRSI;
  b_distortPoints(&st, ptsIn, intrinsicMatrix, radialDist, tangentialDist,
                  ptsOut);
  y = NULL;
  m5 = emlrtCreateCharArray(2, iv20);
  emlrtInitCharArrayR2013a(sp, 5, m5, &u[0]);
  emlrtAssign(&y, m5);
  st.site = &ps_emlrtRSI;
  clear(&st, y, &c_emlrtMCI);
  absx11 = (this->YBounds[1] - this->YBounds[0]) + 1.0;
  absx21 = (this->XBounds[1] - this->XBounds[0]) + 1.0;
  emxFree_real_T(sp, &ptsIn);
  if (b_strcmp(this->ClassOfImage)) {
    st.site = &oi_emlrtRSI;
    varargin_1[0] = absx11;
    varargin_1[1] = absx21;
    itmp = ptsOut->size[0];
    b_st.site = &ui_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    for (p3 = 0; p3 < 2; p3++) {
      outsize[p3] = (int32_T)varargin_1[p3];
    }

    p2 = ptsOut->size[0];
    p3 = ptsOut->size[0];
    if (1 > p3) {
      p2 = 1;
    }

    nm1d2 = muIntScalarMax_sint32(itmp, p2);
    if (outsize[0] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    if (outsize[1] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    overflow = (outsize[0] >= 0);
    if (overflow && (outsize[1] >= 0)) {
    } else {
      overflow = false;
    }

    if (!overflow) {
      emlrtErrorWithMessageIdR2018a(&st, &ef_emlrtRTEI,
        "MATLAB:checkDimCommon:nonnegativeSize",
        "MATLAB:checkDimCommon:nonnegativeSize", 0);
    }

    itmp = ptsOut->size[0];
    if (outsize[0] * outsize[1] != itmp) {
      emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
        "Coder:MATLAB:getReshapeDims_notSameNumel",
        "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }

    st.site = &pi_emlrtRSI;
    varargin_1[0] = absx11;
    varargin_1[1] = absx21;
    itmp = ptsOut->size[0];
    b_st.site = &ui_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    for (p3 = 0; p3 < 2; p3++) {
      outsize[p3] = (int32_T)varargin_1[p3];
    }

    p2 = ptsOut->size[0];
    p3 = ptsOut->size[0];
    if (1 > p3) {
      p2 = 1;
    }

    nm1d2 = muIntScalarMax_sint32(itmp, p2);
    if (outsize[0] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    if (outsize[1] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    overflow = (outsize[0] >= 0);
    if (overflow && (outsize[1] >= 0)) {
    } else {
      overflow = false;
    }

    if (!overflow) {
      emlrtErrorWithMessageIdR2018a(&st, &ef_emlrtRTEI,
        "MATLAB:checkDimCommon:nonnegativeSize",
        "MATLAB:checkDimCommon:nonnegativeSize", 0);
    }

    itmp = ptsOut->size[0];
    if (outsize[0] * outsize[1] != itmp) {
      emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
        "Coder:MATLAB:getReshapeDims_notSameNumel",
        "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }
  } else {
    st.site = &qi_emlrtRSI;
    varargin_1[0] = absx11;
    varargin_1[1] = absx21;
    itmp = ptsOut->size[0];
    b_st.site = &ui_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    for (p3 = 0; p3 < 2; p3++) {
      outsize[p3] = (int32_T)varargin_1[p3];
    }

    p2 = ptsOut->size[0];
    p3 = ptsOut->size[0];
    if (1 > p3) {
      p2 = 1;
    }

    nm1d2 = muIntScalarMax_sint32(itmp, p2);
    if (outsize[0] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    if (outsize[1] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    overflow = (outsize[0] >= 0);
    if (overflow && (outsize[1] >= 0)) {
    } else {
      overflow = false;
    }

    if (!overflow) {
      emlrtErrorWithMessageIdR2018a(&st, &ef_emlrtRTEI,
        "MATLAB:checkDimCommon:nonnegativeSize",
        "MATLAB:checkDimCommon:nonnegativeSize", 0);
    }

    itmp = ptsOut->size[0];
    if (outsize[0] * outsize[1] != itmp) {
      emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
        "Coder:MATLAB:getReshapeDims_notSameNumel",
        "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }

    emxInit_real_T1(&st, &b_ptsOut, 1, &rb_emlrtRTEI, true);
    nm1d2 = ptsOut->size[0];
    itmp = b_ptsOut->size[0];
    b_ptsOut->size[0] = nm1d2;
    emxEnsureCapacity_real_T(sp, b_ptsOut, itmp, &rb_emlrtRTEI);
    for (itmp = 0; itmp < nm1d2; itmp++) {
      b_ptsOut->data[itmp] = ptsOut->data[itmp];
    }

    p2 = outsize[0];
    itmp = this->XmapSingle->size[0] * this->XmapSingle->size[1];
    this->XmapSingle->size[0] = outsize[0];
    this->XmapSingle->size[1] = outsize[1];
    emxEnsureCapacity_real32_T(sp, this->XmapSingle, itmp, &rb_emlrtRTEI);
    nm1d2 = outsize[1];
    for (itmp = 0; itmp < nm1d2; itmp++) {
      for (p3 = 0; p3 < p2; p3++) {
        this->XmapSingle->data[p3 + this->XmapSingle->size[0] * itmp] =
          (real32_T)b_ptsOut->data[p3 + p2 * itmp];
      }
    }

    st.site = &ri_emlrtRSI;
    varargin_1[0] = absx11;
    varargin_1[1] = absx21;
    itmp = ptsOut->size[0];
    b_st.site = &ui_emlrtRSI;
    assertValidSizeArg(&b_st, varargin_1);
    for (p3 = 0; p3 < 2; p3++) {
      outsize[p3] = (int32_T)varargin_1[p3];
    }

    p2 = ptsOut->size[0];
    p3 = ptsOut->size[0];
    if (1 > p3) {
      p2 = 1;
    }

    nm1d2 = muIntScalarMax_sint32(itmp, p2);
    if (outsize[0] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    if (outsize[1] > nm1d2) {
      b_st.site = &vi_emlrtRSI;
      d_error(&b_st);
    }

    overflow = (outsize[0] >= 0);
    if (overflow && (outsize[1] >= 0)) {
    } else {
      overflow = false;
    }

    if (!overflow) {
      emlrtErrorWithMessageIdR2018a(&st, &ef_emlrtRTEI,
        "MATLAB:checkDimCommon:nonnegativeSize",
        "MATLAB:checkDimCommon:nonnegativeSize", 0);
    }

    itmp = ptsOut->size[0];
    if (outsize[0] * outsize[1] != itmp) {
      emlrtErrorWithMessageIdR2018a(&st, &ff_emlrtRTEI,
        "Coder:MATLAB:getReshapeDims_notSameNumel",
        "Coder:MATLAB:getReshapeDims_notSameNumel", 0);
    }

    nm1d2 = ptsOut->size[0];
    itmp = b_ptsOut->size[0];
    b_ptsOut->size[0] = nm1d2;
    emxEnsureCapacity_real_T(sp, b_ptsOut, itmp, &rb_emlrtRTEI);
    for (itmp = 0; itmp < nm1d2; itmp++) {
      b_ptsOut->data[itmp] = ptsOut->data[itmp + ptsOut->size[0]];
    }

    p2 = outsize[0];
    itmp = this->YmapSingle->size[0] * this->YmapSingle->size[1];
    this->YmapSingle->size[0] = outsize[0];
    this->YmapSingle->size[1] = outsize[1];
    emxEnsureCapacity_real32_T(sp, this->YmapSingle, itmp, &rb_emlrtRTEI);
    nm1d2 = outsize[1];
    for (itmp = 0; itmp < nm1d2; itmp++) {
      for (p3 = 0; p3 < p2; p3++) {
        this->YmapSingle->data[p3 + this->YmapSingle->size[0] * itmp] =
          (real32_T)b_ptsOut->data[p3 + p2 * itmp];
      }
    }

    emxFree_real_T(sp, &b_ptsOut);
  }

  emxFree_real_T(sp, &ptsOut);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

void b_ImageTransformer_transformIma(const emlrtStack *sp, const
  c_vision_internal_calibration_I *this, const uint8_T I[921600],
  emxArray_uint8_T *J)
{
  emxArray_real32_T *X;
  int32_T i39;
  int32_T outputImageSize_idx_0;
  emxArray_real32_T *Y;
  int32_T varargin_1[2];
  boolean_T p;
  int32_T varargin_2[2];
  boolean_T b_p;
  boolean_T exitg1;
  int32_T outputImageSize_idx_1;
  uint8_T fillValues[3];
  real_T x[3];
  real_T b_J[3];
  static const int16_T b_x[3] = { 480, 640, 3 };

  emlrtStack st;
  emlrtStack b_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  emxInit_real32_T(sp, &X, 2, &wb_emlrtRTEI, true);
  st.site = &wi_emlrtRSI;
  i39 = X->size[0] * X->size[1];
  X->size[0] = this->XmapSingle->size[0];
  X->size[1] = this->XmapSingle->size[1];
  emxEnsureCapacity_real32_T(&st, X, i39, &ub_emlrtRTEI);
  outputImageSize_idx_0 = this->XmapSingle->size[0] * this->XmapSingle->size[1];
  for (i39 = 0; i39 < outputImageSize_idx_0; i39++) {
    X->data[i39] = this->XmapSingle->data[i39];
  }

  emxInit_real32_T(&st, &Y, 2, &xb_emlrtRTEI, true);
  i39 = Y->size[0] * Y->size[1];
  Y->size[0] = this->YmapSingle->size[0];
  Y->size[1] = this->YmapSingle->size[1];
  emxEnsureCapacity_real32_T(&st, Y, i39, &ub_emlrtRTEI);
  outputImageSize_idx_0 = this->YmapSingle->size[0] * this->YmapSingle->size[1];
  for (i39 = 0; i39 < outputImageSize_idx_0; i39++) {
    Y->data[i39] = this->YmapSingle->data[i39];
  }

  b_st.site = &xi_emlrtRSI;
  validateattributes(&b_st, X);
  b_st.site = &yi_emlrtRSI;
  b_validateattributes(&b_st, Y);
  for (i39 = 0; i39 < 2; i39++) {
    varargin_1[i39] = X->size[i39];
  }

  for (i39 = 0; i39 < 2; i39++) {
    varargin_2[i39] = Y->size[i39];
  }

  p = false;
  b_p = true;
  outputImageSize_idx_0 = 0;
  exitg1 = false;
  while ((!exitg1) && (outputImageSize_idx_0 < 2)) {
    if (!(varargin_1[outputImageSize_idx_0] == varargin_2[outputImageSize_idx_0]))
    {
      b_p = false;
      exitg1 = true;
    } else {
      outputImageSize_idx_0++;
    }
  }

  if (b_p) {
    p = true;
  }

  if (!p) {
    emlrtErrorWithMessageIdR2018a(&st, &if_emlrtRTEI,
      "images:interp2d:inconsistentXYSize", "images:interp2d:inconsistentXYSize",
      0);
  }

  outputImageSize_idx_0 = X->size[0] * X->size[1] - 1;
  i39 = X->size[0] * X->size[1];
  emxEnsureCapacity_real32_T(&st, X, i39, &ub_emlrtRTEI);
  for (i39 = 0; i39 <= outputImageSize_idx_0; i39++) {
    X->data[i39]--;
  }

  outputImageSize_idx_0 = Y->size[0] * Y->size[1] - 1;
  i39 = Y->size[0] * Y->size[1];
  emxEnsureCapacity_real32_T(&st, Y, i39, &ub_emlrtRTEI);
  for (i39 = 0; i39 <= outputImageSize_idx_0; i39++) {
    Y->data[i39]--;
  }

  b_st.site = &aj_emlrtRSI;
  outputImageSize_idx_0 = X->size[0];
  outputImageSize_idx_1 = X->size[1];
  i39 = J->size[0] * J->size[1] * J->size[2];
  J->size[0] = outputImageSize_idx_0;
  J->size[1] = outputImageSize_idx_1;
  J->size[2] = 3;
  emxEnsureCapacity_uint8_T1(&b_st, J, i39, &vb_emlrtRTEI);
  for (i39 = 0; i39 < 3; i39++) {
    fillValues[i39] = 0U;
  }

  for (i39 = 0; i39 < 3; i39++) {
    x[i39] = b_x[i39];
    b_J[i39] = J->size[i39];
  }

  remaptbb_uint8(I, x, 3.0, &Y->data[0], &X->data[0], 2, fillValues, &J->data[0],
                 b_J, (real_T)(J->size[0] * J->size[1] * 3));
  emxFree_real32_T(sp, &Y);
  emxFree_real32_T(sp, &X);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

c_vision_internal_calibration_I *c_ImageTransformer_ImageTransfo(const
  emlrtStack *sp, c_vision_internal_calibration_I *this)
{
  c_vision_internal_calibration_I *b_this;
  b_this = this;
  d_ImageTransformer_ImageTransfo(sp, &b_this);
  return b_this;
}

/* End of code generation (ImageTransformer.c) */

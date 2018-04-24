/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * rectifyStereoImages.c
 *
 * Code generation for function 'rectifyStereoImages'
 *
 */

/* Include files */
#include <string.h>
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "rectifyStereoImages.h"
#include "depthEstimationFromStereoVideo_kernel_emxutil.h"
#include "ImageTransformer.h"
#include "StereoParametersImpl.h"
#include "error.h"
#include "warning.h"
#include "det.h"
#include "mrdivide.h"
#include "matlabCodegenHandle.h"
#include "depthEstimationFromStereoVideo_kernel_data.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Variable Definitions */
static emlrtRSInfo ee_emlrtRSI = { 121,/* lineNo */
  "rectifyStereoImages",               /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\rectifyStereoImages.m"/* pathName */
};

static emlrtRSInfo dg_emlrtRSI = { 173,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo eg_emlrtRSI = { 177,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo fg_emlrtRSI = { 179,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo gg_emlrtRSI = { 185,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo hg_emlrtRSI = { 188,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo ig_emlrtRSI = { 192,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo jg_emlrtRSI = { 199,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo kg_emlrtRSI = { 206,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo lg_emlrtRSI = { 209,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo pn_emlrtRSI = { 87, /* lineNo */
  "ImageTransformer",                  /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\ImageTransformer.m"/* pathName */
};

static emlrtRTEInfo o_emlrtRTEI = { 102,/* lineNo */
  47,                                  /* colNo */
  "rectifyStereoImages",               /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\rectifyStereoImages.m"/* pName */
};

static emlrtRSInfo ms_emlrtRSI = { 170,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

static emlrtRSInfo ns_emlrtRSI = { 169,/* lineNo */
  "StereoParametersImpl",              /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\+calibration\\StereoParametersImpl.m"/* pathName */
};

/* Function Definitions */
void rectifyStereoImages(e_depthEstimationFromStereoVide *SD, const emlrtStack
  *sp, const uint8_T I1[921600], const uint8_T I2[921600],
  c_vision_internal_calibration_S *stereoParams, emxArray_uint8_T
  *rectifiedImage1, emxArray_uint8_T *rectifiedImage2)
{
  int32_T i3;
  boolean_T success;
  real_T xBounds[2];
  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  emxArray_char_T *b;
  real_T Rl[9];
  real_T Rr[9];
  real_T b_b[3];
  real_T t[3];
  real_T RrowAlign[9];
  c_vision_internal_calibration_C *params;
  int32_T exitg2;
  static const char_T cv6[5] = { 'v', 'a', 'l', 'i', 'd' };

  real_T intrinsicMatrix[9];
  real_T K_new[9];
  real_T b_intrinsicMatrix[9];
  real_T b_K_new[9];
  real_T c_intrinsicMatrix[9];
  real_T b_RrowAlign[9];
  int32_T i4;
  real_T varargin_1;
  projective2d H1;
  real_T yBounds[2];
  real_T Q[16];
  static const char_T a[5] = { 'v', 'a', 'l', 'i', 'd' };

  real_T radialDist[2];
  real_T tangentialDist[2];
  static const int16_T iv3[3] = { 480, 640, 3 };

  static const char_T cv7[5] = { 'u', 'i', 'n', 't', '8' };

  emlrtStack st;
  emlrtStack b_st;
  emlrtStack c_st;
  emlrtStack d_st;
  emlrtStack e_st;
  emlrtStack f_st;
  emlrtStack g_st;
  st.prev = sp;
  st.tls = sp->tls;
  b_st.prev = &st;
  b_st.tls = st.tls;
  c_st.prev = &st;
  c_st.tls = st.tls;
  d_st.prev = &b_st;
  d_st.tls = b_st.tls;
  e_st.prev = &d_st;
  e_st.tls = d_st.tls;
  f_st.prev = &e_st;
  f_st.tls = e_st.tls;
  g_st.prev = &f_st;
  g_st.tls = f_st.tls;
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &ee_emlrtRSI;
  for (i3 = 0; i3 < 2; i3++) {
    xBounds[i3] = stereoParams->RectificationParams.OriginalImageSize[i3];
  }

  success = false;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (!(480.0 + 160.0 * (real_T)k == xBounds[k])) {
      p = false;
      exitg1 = true;
    } else {
      k++;
    }
  }

  if (p) {
    success = true;
  }

  emxInit_char_T(&st, &b, 2, &o_emlrtRTEI, true);
  if (success) {
    i3 = b->size[0] * b->size[1];
    b->size[0] = 1;
    b->size[1] = stereoParams->RectificationParams.OutputView->size[1];
    emxEnsureCapacity_char_T(&st, b, i3, &o_emlrtRTEI);
    k = stereoParams->RectificationParams.OutputView->size[0] *
      stereoParams->RectificationParams.OutputView->size[1];
    for (i3 = 0; i3 < k; i3++) {
      b->data[i3] = stereoParams->RectificationParams.OutputView->data[i3];
    }

    success = false;
    if (5 == b->size[1]) {
      k = 0;
      do {
        exitg2 = 0;
        if (k + 1 < 6) {
          if (cv6[k] != b->data[k]) {
            exitg2 = 1;
          } else {
            k++;
          }
        } else {
          success = true;
          exitg2 = 1;
        }
      } while (exitg2 == 0);
    }

    if (success) {
      success = true;
    } else {
      success = false;
    }
  } else {
    success = false;
  }

  emxFree_char_T(&st, &b);
  b_st.site = &ns_emlrtRSI;
  c_st.site = &ms_emlrtRSI;
  if ((!success) || ImageTransformer_needToUpdate(&b_st,
       &stereoParams->RectifyMap1) || ImageTransformer_needToUpdate(&c_st,
       &stereoParams->RectifyMap2)) {
    b_st.site = &dg_emlrtRSI;
    d_st.site = &mg_emlrtRSI;
    c_StereoParametersImpl_computeH(&d_st, stereoParams, Rl, Rr);
    for (i3 = 0; i3 < 3; i3++) {
      b_b[i3] = stereoParams->TranslationOfCamera2[i3];
    }

    for (i3 = 0; i3 < 3; i3++) {
      t[i3] = 0.0;
      for (k = 0; k < 3; k++) {
        t[i3] += Rr[i3 + 3 * k] * b_b[k];
      }
    }

    d_st.site = &ng_emlrtRSI;
    computeRowAlignmentRotation(&d_st, t, RrowAlign);
    params = stereoParams->CameraParameters1;
    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        intrinsicMatrix[k + 3 * i3] = params->IntrinsicMatrixInternal[i3 + 3 * k];
      }
    }

    params = stereoParams->CameraParameters2;
    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        b_intrinsicMatrix[k + 3 * i3] = params->IntrinsicMatrixInternal[i3 + 3 *
          k];
      }
    }

    c_StereoParametersImpl_computeN(stereoParams, K_new);
    d_st.site = &og_emlrtRSI;
    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        b_RrowAlign[i3 + 3 * k] = 0.0;
        for (i4 = 0; i4 < 3; i4++) {
          b_RrowAlign[i3 + 3 * k] += RrowAlign[i3 + 3 * i4] * Rl[i4 + 3 * k];
        }
      }
    }

    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        b_K_new[i3 + 3 * k] = 0.0;
        for (i4 = 0; i4 < 3; i4++) {
          b_K_new[i3 + 3 * k] += K_new[i3 + 3 * i4] * b_RrowAlign[i4 + 3 * k];
        }

        c_intrinsicMatrix[k + 3 * i3] = intrinsicMatrix[i3 + 3 * k];
      }
    }

    e_st.site = &og_emlrtRSI;
    mrdivide(&e_st, b_K_new, c_intrinsicMatrix, Rl);
    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        intrinsicMatrix[k + 3 * i3] = Rl[i3 + 3 * k];
      }
    }

    e_st.site = &jd_emlrtRSI;
    f_st.site = &kd_emlrtRSI;
    g_st.site = &ic_emlrtRSI;
    success = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if ((!muDoubleScalarIsInf(intrinsicMatrix[k])) && (!muDoubleScalarIsNaN
           (intrinsicMatrix[k]))) {
        k++;
      } else {
        success = false;
        exitg1 = true;
      }
    }

    if (!success) {
      emlrtErrorWithMessageIdR2018a(&g_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:projective2d.set.T:expectedFinite", 3, 4, 1, "T");
    }

    g_st.site = &ic_emlrtRSI;
    success = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if (!muDoubleScalarIsNaN(intrinsicMatrix[k])) {
        k++;
      } else {
        success = false;
        exitg1 = true;
      }
    }

    if (!success) {
      emlrtErrorWithMessageIdR2018a(&g_st, &xe_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedNonNaN",
        "MATLAB:projective2d.set.T:expectedNonNaN", 3, 4, 1, "T");
    }

    f_st.site = &ld_emlrtRSI;
    varargin_1 = det(&f_st, intrinsicMatrix);
    success = false;
    p = true;
    if (!(varargin_1 == 0.0)) {
      p = false;
    }

    if (p) {
      success = true;
    }

    if (success) {
      emlrtErrorWithMessageIdR2018a(&e_st, &we_emlrtRTEI,
        "images:geotrans:singularTransformationMatrix",
        "images:geotrans:singularTransformationMatrix", 0);
    }

    memcpy(&H1.T[0], &intrinsicMatrix[0], 9U * sizeof(real_T));
    d_st.site = &pg_emlrtRSI;
    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        b_RrowAlign[i3 + 3 * k] = 0.0;
        for (i4 = 0; i4 < 3; i4++) {
          b_RrowAlign[i3 + 3 * k] += RrowAlign[i3 + 3 * i4] * Rr[i4 + 3 * k];
        }
      }
    }

    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        b_K_new[i3 + 3 * k] = 0.0;
        for (i4 = 0; i4 < 3; i4++) {
          b_K_new[i3 + 3 * k] += K_new[i3 + 3 * i4] * b_RrowAlign[i4 + 3 * k];
        }

        intrinsicMatrix[k + 3 * i3] = b_intrinsicMatrix[i3 + 3 * k];
      }
    }

    e_st.site = &pg_emlrtRSI;
    mrdivide(&e_st, b_K_new, intrinsicMatrix, Rl);
    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        intrinsicMatrix[k + 3 * i3] = Rl[i3 + 3 * k];
      }
    }

    e_st.site = &jd_emlrtRSI;
    f_st.site = &kd_emlrtRSI;
    g_st.site = &ic_emlrtRSI;
    success = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if ((!muDoubleScalarIsInf(intrinsicMatrix[k])) && (!muDoubleScalarIsNaN
           (intrinsicMatrix[k]))) {
        k++;
      } else {
        success = false;
        exitg1 = true;
      }
    }

    if (!success) {
      emlrtErrorWithMessageIdR2018a(&g_st, &ue_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedFinite",
        "MATLAB:projective2d.set.T:expectedFinite", 3, 4, 1, "T");
    }

    g_st.site = &ic_emlrtRSI;
    success = true;
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 9)) {
      if (!muDoubleScalarIsNaN(intrinsicMatrix[k])) {
        k++;
      } else {
        success = false;
        exitg1 = true;
      }
    }

    if (!success) {
      emlrtErrorWithMessageIdR2018a(&g_st, &xe_emlrtRTEI,
        "Coder:toolbox:ValidateattributesexpectedNonNaN",
        "MATLAB:projective2d.set.T:expectedNonNaN", 3, 4, 1, "T");
    }

    f_st.site = &ld_emlrtRSI;
    varargin_1 = det(&f_st, intrinsicMatrix);
    success = false;
    p = true;
    if (!(varargin_1 == 0.0)) {
      p = false;
    }

    if (p) {
      success = true;
    }

    if (success) {
      emlrtErrorWithMessageIdR2018a(&e_st, &we_emlrtRTEI,
        "images:geotrans:singularTransformationMatrix",
        "images:geotrans:singularTransformationMatrix", 0);
    }

    memcpy(&Rl[0], &intrinsicMatrix[0], 9U * sizeof(real_T));
    for (i3 = 0; i3 < 3; i3++) {
      b_b[i3] = 0.0;
      for (k = 0; k < 3; k++) {
        b_b[i3] += RrowAlign[i3 + 3 * k] * t[k];
      }
    }

    for (i3 = 0; i3 < 3; i3++) {
      t[i3] = b_b[i3];
    }

    d_st.site = &qg_emlrtRSI;
    c_StereoParametersImpl_computeO(SD, &d_st, stereoParams, H1.T, Rl, xBounds,
      yBounds, &success);
    Q[0] = 1.0;
    Q[1] = 0.0;
    Q[2] = 0.0;
    Q[3] = -(K_new[6] - xBounds[0]);
    Q[4] = 0.0;
    Q[5] = 1.0;
    Q[6] = 0.0;
    Q[7] = -(K_new[7] - yBounds[0]);
    Q[8] = 0.0;
    Q[9] = 0.0;
    Q[10] = 0.0;
    Q[11] = K_new[4];
    Q[12] = 0.0;
    Q[13] = 0.0;
    Q[14] = -1.0 / t[0];
    Q[15] = 0.0;
    if (!success) {
      b_st.site = &eg_emlrtRSI;
      b_warning(&b_st);
      b_st.site = &fg_emlrtRSI;
      c_StereoParametersImpl_computeR(SD, &b_st, stereoParams, H1.T, Rl, Q,
        xBounds, yBounds, &success);
    }

    if (!success) {
      b_st.site = &gg_emlrtRSI;
      e_error(&b_st);
    }

    b_st.site = &hg_emlrtRSI;
    stereoParams->RectificationParams.Initialized = true;
    for (i3 = 0; i3 < 2; i3++) {
      stereoParams->RectificationParams.OriginalImageSize[i3] = 480.0 + 160.0 *
        (real_T)i3;
    }

    stereoParams->RectificationParams.H1 = H1;
    for (i3 = 0; i3 < 9; i3++) {
      stereoParams->RectificationParams.H2.T[i3] = Rl[i3];
    }

    for (i3 = 0; i3 < 16; i3++) {
      stereoParams->RectificationParams.Q[i3] = Q[i3];
    }

    i3 = stereoParams->RectificationParams.OutputView->size[0] *
      stereoParams->RectificationParams.OutputView->size[1];
    stereoParams->RectificationParams.OutputView->size[0] = 1;
    stereoParams->RectificationParams.OutputView->size[1] = 5;
    emxEnsureCapacity_char_T(&b_st, stereoParams->RectificationParams.OutputView,
      i3, &o_emlrtRTEI);
    for (i3 = 0; i3 < 5; i3++) {
      stereoParams->RectificationParams.OutputView->data[i3] = a[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      stereoParams->RectificationParams.XBounds[i3] = xBounds[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      stereoParams->RectificationParams.YBounds[i3] = yBounds[i3];
    }

    params = stereoParams->CameraParameters1;
    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        intrinsicMatrix[k + 3 * i3] = params->IntrinsicMatrixInternal[i3 + 3 * k];
      }
    }

    b_st.site = &ig_emlrtRSI;
    for (i3 = 0; i3 < 2; i3++) {
      radialDist[i3] = params->RadialDistortion[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      tangentialDist[i3] = params->TangentialDistortion[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      xBounds[i3] = stereoParams->RectificationParams.XBounds[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      yBounds[i3] = stereoParams->RectificationParams.YBounds[i3];
    }

    H1 = stereoParams->RectificationParams.H1;
    i3 = stereoParams->RectifyMap1.SizeOfImage->size[0] *
      stereoParams->RectifyMap1.SizeOfImage->size[1];
    stereoParams->RectifyMap1.SizeOfImage->size[0] = 1;
    stereoParams->RectifyMap1.SizeOfImage->size[1] = 3;
    emxEnsureCapacity_real_T1(&b_st, stereoParams->RectifyMap1.SizeOfImage, i3,
      &o_emlrtRTEI);
    for (i3 = 0; i3 < 3; i3++) {
      stereoParams->RectifyMap1.SizeOfImage->data[i3] = iv3[i3];
    }

    i3 = stereoParams->RectifyMap1.ClassOfImage->size[0] *
      stereoParams->RectifyMap1.ClassOfImage->size[1];
    stereoParams->RectifyMap1.ClassOfImage->size[0] = 1;
    stereoParams->RectifyMap1.ClassOfImage->size[1] = 5;
    emxEnsureCapacity_char_T(&b_st, stereoParams->RectifyMap1.ClassOfImage, i3,
      &o_emlrtRTEI);
    for (i3 = 0; i3 < 5; i3++) {
      stereoParams->RectifyMap1.ClassOfImage->data[i3] = cv7[i3];
    }

    i3 = stereoParams->RectifyMap1.OutputView->size[0] *
      stereoParams->RectifyMap1.OutputView->size[1];
    stereoParams->RectifyMap1.OutputView->size[0] = 1;
    stereoParams->RectifyMap1.OutputView->size[1] = 5;
    emxEnsureCapacity_char_T(&b_st, stereoParams->RectifyMap1.OutputView, i3,
      &o_emlrtRTEI);
    for (i3 = 0; i3 < 5; i3++) {
      stereoParams->RectifyMap1.OutputView->data[i3] = a[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      stereoParams->RectifyMap1.XBounds[i3] = xBounds[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      stereoParams->RectifyMap1.YBounds[i3] = yBounds[i3];
    }

    d_st.site = &pn_emlrtRSI;
    b_ImageTransformer_computeMap(&d_st, &stereoParams->RectifyMap1,
      intrinsicMatrix, radialDist, tangentialDist, H1.T);
    params = stereoParams->CameraParameters2;
    for (i3 = 0; i3 < 3; i3++) {
      for (k = 0; k < 3; k++) {
        intrinsicMatrix[k + 3 * i3] = params->IntrinsicMatrixInternal[i3 + 3 * k];
      }
    }

    b_st.site = &jg_emlrtRSI;
    for (i3 = 0; i3 < 2; i3++) {
      radialDist[i3] = params->RadialDistortion[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      tangentialDist[i3] = params->TangentialDistortion[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      xBounds[i3] = stereoParams->RectificationParams.XBounds[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      yBounds[i3] = stereoParams->RectificationParams.YBounds[i3];
    }

    H1 = stereoParams->RectificationParams.H2;
    i3 = stereoParams->RectifyMap2.SizeOfImage->size[0] *
      stereoParams->RectifyMap2.SizeOfImage->size[1];
    stereoParams->RectifyMap2.SizeOfImage->size[0] = 1;
    stereoParams->RectifyMap2.SizeOfImage->size[1] = 3;
    emxEnsureCapacity_real_T1(&b_st, stereoParams->RectifyMap2.SizeOfImage, i3,
      &o_emlrtRTEI);
    for (i3 = 0; i3 < 3; i3++) {
      stereoParams->RectifyMap2.SizeOfImage->data[i3] = iv3[i3];
    }

    i3 = stereoParams->RectifyMap2.ClassOfImage->size[0] *
      stereoParams->RectifyMap2.ClassOfImage->size[1];
    stereoParams->RectifyMap2.ClassOfImage->size[0] = 1;
    stereoParams->RectifyMap2.ClassOfImage->size[1] = 5;
    emxEnsureCapacity_char_T(&b_st, stereoParams->RectifyMap2.ClassOfImage, i3,
      &o_emlrtRTEI);
    for (i3 = 0; i3 < 5; i3++) {
      stereoParams->RectifyMap2.ClassOfImage->data[i3] = cv7[i3];
    }

    i3 = stereoParams->RectifyMap2.OutputView->size[0] *
      stereoParams->RectifyMap2.OutputView->size[1];
    stereoParams->RectifyMap2.OutputView->size[0] = 1;
    stereoParams->RectifyMap2.OutputView->size[1] = 5;
    emxEnsureCapacity_char_T(&b_st, stereoParams->RectifyMap2.OutputView, i3,
      &o_emlrtRTEI);
    for (i3 = 0; i3 < 5; i3++) {
      stereoParams->RectifyMap2.OutputView->data[i3] = a[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      stereoParams->RectifyMap2.XBounds[i3] = xBounds[i3];
    }

    for (i3 = 0; i3 < 2; i3++) {
      stereoParams->RectifyMap2.YBounds[i3] = yBounds[i3];
    }

    d_st.site = &pn_emlrtRSI;
    b_ImageTransformer_computeMap(&d_st, &stereoParams->RectifyMap2,
      intrinsicMatrix, radialDist, tangentialDist, H1.T);
  }

  b_st.site = &kg_emlrtRSI;
  b_ImageTransformer_transformIma(&b_st, &stereoParams->RectifyMap1, I1,
    rectifiedImage1);
  b_st.site = &lg_emlrtRSI;
  b_ImageTransformer_transformIma(&b_st, &stereoParams->RectifyMap2, I2,
    rectifiedImage2);
  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (rectifyStereoImages.c) */

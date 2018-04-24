/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * normalizePoints.c
 *
 * Code generation for function 'normalizePoints'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "normalizePoints.h"
#include "visionRecovertformCodeGeneration_kernel_emxutil.h"
#include "mean.h"
#include "sqrt.h"
#include "eml_int_forloop_overflow_check.h"
#include "scalexpAlloc.h"
#include "visionRecovertformCodeGeneration_kernel_data.h"

/* Variable Definitions */
static emlrtRSInfo wg_emlrtRSI = { 25, /* lineNo */
  "normalizePoints",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\normalizePoints.m"/* pathName */
};

static emlrtRSInfo xg_emlrtRSI = { 19, /* lineNo */
  "normalizePoints",                   /* fcnName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\normalizePoints.m"/* pathName */
};

static emlrtRTEInfo tf_emlrtRTEI = { 22,/* lineNo */
  20,                                  /* colNo */
  "normalizePoints",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\normalizePoints.m"/* pName */
};

static emlrtRTEInfo wf_emlrtRTEI = { 25,/* lineNo */
  41,                                  /* colNo */
  "normalizePoints",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\normalizePoints.m"/* pName */
};

static emlrtRTEInfo yf_emlrtRTEI = { 46,/* lineNo */
  5,                                   /* colNo */
  "normalizePoints",                   /* fName */
  "C:\\Program Files\\MATLAB\\R2018a\\toolbox\\vision\\vision\\+vision\\+internal\\normalizePoints.m"/* pName */
};

/* Function Definitions */
void b_normalizePoints(const emlrtStack *sp, const emxArray_real32_T *p,
  emxArray_real32_T *normPoints, real32_T T[9])
{
  int32_T i17;
  boolean_T guard1 = false;
  int32_T firstBlockLength;
  real32_T cent[2];
  int32_T lastBlockLength;
  int32_T nblocks;
  int32_T xj;
  int32_T k;
  int32_T hi;
  emxArray_real32_T *z;
  int32_T xoffset;
  int32_T ia;
  real32_T meanDistanceFromCenter;
  int32_T xblockoffset;
  real32_T bsum[2];
  uint32_T unnamed_idx_1;
  emxArray_real32_T *r17;
  boolean_T overflow;
  real32_T y[3];
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
  emlrtHeapReferenceStackEnterFcnR2012b(sp);
  st.site = &xg_emlrtRSI;
  b_st.site = &yg_emlrtRSI;
  c_st.site = &xc_emlrtRSI;
  i17 = p->size[1];
  guard1 = false;
  if (i17 == 0) {
    guard1 = true;
  } else {
    i17 = p->size[1];
    if (i17 == 0) {
      guard1 = true;
    } else {
      d_st.site = &yc_emlrtRSI;
      i17 = p->size[1];
      if (i17 <= 1024) {
        firstBlockLength = p->size[1];
        lastBlockLength = 0;
        nblocks = 1;
      } else {
        firstBlockLength = 1024;
        i17 = p->size[1];
        nblocks = i17 / 1024;
        i17 = p->size[1];
        lastBlockLength = i17 - (nblocks << 10);
        if (lastBlockLength > 0) {
          nblocks++;
        } else {
          lastBlockLength = 1024;
        }
      }

      for (xj = 0; xj < 2; xj++) {
        cent[xj] = p->data[xj % 2 + p->size[0] * (xj / 2)];
      }

      e_st.site = &bd_emlrtRSI;
      if ((!(2 > firstBlockLength)) && (firstBlockLength > 2147483646)) {
        f_st.site = &mb_emlrtRSI;
        check_forloop_overflow_error(&f_st);
      }

      for (k = 2; k <= firstBlockLength; k++) {
        xoffset = (k - 1) << 1;
        for (xj = 0; xj < 2; xj++) {
          i17 = xoffset + xj;
          meanDistanceFromCenter = cent[xj] + p->data[i17 % 2 + p->size[0] *
            (i17 / 2)];
          cent[xj] = meanDistanceFromCenter;
        }
      }

      e_st.site = &ad_emlrtRSI;
      for (ia = 2; ia <= nblocks; ia++) {
        xblockoffset = (ia - 1) << 11;
        for (xj = 0; xj < 2; xj++) {
          i17 = xblockoffset + xj;
          bsum[xj] = p->data[i17 % 2 + p->size[0] * (i17 / 2)];
        }

        if (ia == nblocks) {
          hi = lastBlockLength;
        } else {
          hi = 1024;
        }

        e_st.site = &ah_emlrtRSI;
        if ((!(2 > hi)) && (hi > 2147483646)) {
          f_st.site = &mb_emlrtRSI;
          check_forloop_overflow_error(&f_st);
        }

        for (k = 2; k <= hi; k++) {
          xoffset = xblockoffset + ((k - 1) << 1);
          for (xj = 0; xj < 2; xj++) {
            i17 = xoffset + xj;
            meanDistanceFromCenter = bsum[xj] + p->data[i17 % 2 + p->size[0] *
              (i17 / 2)];
            bsum[xj] = meanDistanceFromCenter;
          }
        }

        for (xj = 0; xj < 2; xj++) {
          cent[xj] += bsum[xj];
        }
      }
    }
  }

  if (guard1) {
    for (firstBlockLength = 0; firstBlockLength < 2; firstBlockLength++) {
      cent[firstBlockLength] = 0.0F;
    }
  }

  i17 = p->size[1];
  for (firstBlockLength = 0; firstBlockLength < 2; firstBlockLength++) {
    cent[firstBlockLength] /= (real32_T)i17;
  }

  i17 = p->size[1];
  firstBlockLength = normPoints->size[0] * normPoints->size[1];
  normPoints->size[0] = 2;
  normPoints->size[1] = i17;
  emxEnsureCapacity_real32_T(sp, normPoints, firstBlockLength, &tf_emlrtRTEI);
  if (normPoints->size[1] != 0) {
    hi = normPoints->size[1];
    i17 = p->size[1];
    firstBlockLength = (i17 != 1);
    for (k = 0; k < hi; k++) {
      ia = firstBlockLength * k;
      for (xblockoffset = 0; xblockoffset < 2; xblockoffset++) {
        normPoints->data[xblockoffset + normPoints->size[0] * k] = p->
          data[xblockoffset + p->size[0] * ia] - cent[xblockoffset];
      }
    }
  }

  emxInit_real32_T(sp, &z, 2, &uf_emlrtRTEI, true);
  st.site = &wg_emlrtRSI;
  b_st.site = &qc_emlrtRSI;
  c_st.site = &rc_emlrtRSI;
  d_st.site = &sc_emlrtRSI;
  i17 = z->size[0] * z->size[1];
  z->size[0] = 2;
  z->size[1] = normPoints->size[1];
  emxEnsureCapacity_real32_T(&d_st, z, i17, &uf_emlrtRTEI);
  if (!b_dimagree(z, normPoints)) {
    emlrtErrorWithMessageIdR2018a(&d_st, &wi_emlrtRTEI, "MATLAB:dimagree",
      "MATLAB:dimagree", 0);
  }

  i17 = z->size[0] * z->size[1];
  z->size[0] = 2;
  z->size[1] = normPoints->size[1];
  emxEnsureCapacity_real32_T(&c_st, z, i17, &vf_emlrtRTEI);
  d_st.site = &tc_emlrtRSI;
  unnamed_idx_1 = (uint32_T)normPoints->size[1];
  firstBlockLength = (int32_T)unnamed_idx_1 << 1;
  e_st.site = &uc_emlrtRSI;
  if ((!(1 > firstBlockLength)) && (firstBlockLength > 2147483646)) {
    f_st.site = &mb_emlrtRSI;
    check_forloop_overflow_error(&f_st);
  }

  for (k = 0; k < firstBlockLength; k++) {
    z->data[k] = normPoints->data[k] * normPoints->data[k];
  }

  st.site = &wg_emlrtRSI;
  b_st.site = &vc_emlrtRSI;
  c_st.site = &wc_emlrtRSI;
  d_st.site = &xc_emlrtRSI;
  emxInit_real32_T(&d_st, &r17, 2, &wf_emlrtRTEI, true);
  if (z->size[1] == 0) {
    i17 = r17->size[0] * r17->size[1];
    r17->size[0] = 1;
    r17->size[1] = 0;
    emxEnsureCapacity_real32_T(&d_st, r17, i17, &wf_emlrtRTEI);
  } else {
    e_st.site = &yc_emlrtRSI;
    i17 = r17->size[0] * r17->size[1];
    r17->size[0] = 1;
    r17->size[1] = z->size[1];
    emxEnsureCapacity_real32_T(&e_st, r17, i17, &xf_emlrtRTEI);
    f_st.site = &cd_emlrtRSI;
    overflow = (z->size[1] > 2147483646);
    if (overflow) {
      g_st.site = &mb_emlrtRSI;
      check_forloop_overflow_error(&g_st);
    }

    for (firstBlockLength = 0; firstBlockLength < z->size[1]; firstBlockLength++)
    {
      ia = firstBlockLength << 1;
      r17->data[firstBlockLength] = z->data[ia];
      r17->data[firstBlockLength] += z->data[ia + 1];
    }
  }

  emxFree_real32_T(&d_st, &z);
  st.site = &wg_emlrtRSI;
  b_sqrt(&st, r17);
  st.site = &wg_emlrtRSI;
  meanDistanceFromCenter = mean(&st, r17);
  emxFree_real32_T(sp, &r17);
  if (meanDistanceFromCenter > 0.0F) {
    meanDistanceFromCenter = 1.41421354F / meanDistanceFromCenter;
  } else {
    meanDistanceFromCenter = 1.0F;
  }

  for (i17 = 0; i17 < 3; i17++) {
    y[i17] = meanDistanceFromCenter;
  }

  for (i17 = 0; i17 < 9; i17++) {
    T[i17] = 0.0F;
  }

  for (firstBlockLength = 0; firstBlockLength < 3; firstBlockLength++) {
    T[firstBlockLength + 3 * firstBlockLength] = y[firstBlockLength];
  }

  for (i17 = 0; i17 < 2; i17++) {
    T[6 + i17] = -meanDistanceFromCenter * cent[i17];
  }

  T[8] = 1.0F;
  firstBlockLength = normPoints->size[0] * normPoints->size[1] - 1;
  i17 = normPoints->size[0] * normPoints->size[1];
  normPoints->size[0] = 2;
  emxEnsureCapacity_real32_T(sp, normPoints, i17, &yf_emlrtRTEI);
  for (i17 = 0; i17 <= firstBlockLength; i17++) {
    normPoints->data[i17] *= meanDistanceFromCenter;
  }

  emlrtHeapReferenceStackLeaveFcnR2012b(sp);
}

/* End of code generation (normalizePoints.c) */

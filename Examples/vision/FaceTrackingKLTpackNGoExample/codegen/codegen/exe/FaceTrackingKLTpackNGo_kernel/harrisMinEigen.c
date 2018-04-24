/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: harrisMinEigen.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "harrisMinEigen.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "floor.h"
#include "abs.h"
#include "sqrt.h"
#include "power.h"
#include "imfilter.h"
#include "insertMarker.h"
#include "FaceTrackingKLTpackNGo_kernel_rtwutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void subPixelLocationImpl(const emxArray_real32_T *metric, const
  emxArray_real32_T *loc, emxArray_real32_T *subPixelLoc);

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *metric
 *                const emxArray_real32_T *loc
 *                emxArray_real32_T *subPixelLoc
 * Return Type  : void
 */
static void subPixelLocationImpl(const emxArray_real32_T *metric, const
  emxArray_real32_T *loc, emxArray_real32_T *subPixelLoc)
{
  emxArray_real32_T *dy2;
  int unnamed_idx_2;
  int loop_ub;
  int i18;
  emxArray_real32_T *dx2;
  emxArray_real32_T *xm1;
  emxArray_real32_T *xp1;
  emxArray_real32_T *ym1;
  emxArray_real32_T *yp1;
  emxArray_real32_T *xsubs;
  emxArray_real32_T *ysubs;
  emxArray_int32_T *idx;
  short siz[2];
  emxArray_boolean_T *r4;
  emxArray_boolean_T *r5;
  int i;
  emxArray_real32_T *b_dy2;
  emxInit_real32_T2(&dy2, 3);
  unnamed_idx_2 = loc->size[2];
  loop_ub = loc->size[2];
  i18 = dy2->size[0] * dy2->size[1] * dy2->size[2];
  dy2->size[0] = 1;
  dy2->size[1] = 1;
  dy2->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(dy2, i18);
  for (i18 = 0; i18 < loop_ub; i18++) {
    dy2->data[dy2->size[0] * dy2->size[1] * i18] = loc->data[loc->size[0] *
      loc->size[1] * i18];
  }

  emxInit_real32_T2(&dx2, 3);
  loop_ub = loc->size[2];
  i18 = dx2->size[0] * dx2->size[1] * dx2->size[2];
  dx2->size[0] = 1;
  dx2->size[1] = 1;
  dx2->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(dx2, i18);
  for (i18 = 0; i18 < loop_ub; i18++) {
    dx2->data[dx2->size[0] * dx2->size[1] * i18] = loc->data[1 + loc->size[0] *
      loc->size[1] * i18];
  }

  emxInit_real32_T2(&xm1, 3);
  i18 = xm1->size[0] * xm1->size[1] * xm1->size[2];
  xm1->size[0] = 1;
  xm1->size[1] = 1;
  xm1->size[2] = dy2->size[2];
  emxEnsureCapacity_real32_T1(xm1, i18);
  loop_ub = dy2->size[0] * dy2->size[1] * dy2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xm1->data[i18] = dy2->data[i18] - 1.0F;
  }

  emxInit_real32_T2(&xp1, 3);
  i18 = xp1->size[0] * xp1->size[1] * xp1->size[2];
  xp1->size[0] = 1;
  xp1->size[1] = 1;
  xp1->size[2] = dy2->size[2];
  emxEnsureCapacity_real32_T1(xp1, i18);
  loop_ub = dy2->size[0] * dy2->size[1] * dy2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xp1->data[i18] = dy2->data[i18] + 1.0F;
  }

  emxInit_real32_T2(&ym1, 3);
  i18 = ym1->size[0] * ym1->size[1] * ym1->size[2];
  ym1->size[0] = 1;
  ym1->size[1] = 1;
  ym1->size[2] = dx2->size[2];
  emxEnsureCapacity_real32_T1(ym1, i18);
  loop_ub = dx2->size[0] * dx2->size[1] * dx2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ym1->data[i18] = dx2->data[i18] - 1.0F;
  }

  emxInit_real32_T2(&yp1, 3);
  i18 = yp1->size[0] * yp1->size[1] * yp1->size[2];
  yp1->size[0] = 1;
  yp1->size[1] = 1;
  yp1->size[2] = dx2->size[2];
  emxEnsureCapacity_real32_T1(yp1, i18);
  loop_ub = dx2->size[0] * dx2->size[1] * dx2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    yp1->data[i18] = dx2->data[i18] + 1.0F;
  }

  emxInit_real32_T2(&xsubs, 3);
  i18 = xsubs->size[0] * xsubs->size[1] * xsubs->size[2];
  xsubs->size[0] = 3;
  xsubs->size[1] = 3;
  xsubs->size[2] = xm1->size[2];
  emxEnsureCapacity_real32_T1(xsubs, i18);
  loop_ub = xm1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[xsubs->size[0] * xsubs->size[1] * i18] = xm1->data[xm1->size[0] *
      xm1->size[1] * i18];
  }

  loop_ub = dy2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i18] =
      dy2->data[dy2->size[0] * dy2->size[1] * i18];
  }

  loop_ub = xp1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[(xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i18] =
      xp1->data[xp1->size[0] * xp1->size[1] * i18];
  }

  loop_ub = xm1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[1 + xsubs->size[0] * xsubs->size[1] * i18] = xm1->data[xm1->
      size[0] * xm1->size[1] * i18];
  }

  loop_ub = dy2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[(xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i18) + 1] =
      dy2->data[dy2->size[0] * dy2->size[1] * i18];
  }

  loop_ub = xp1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i18)
      + 1] = xp1->data[xp1->size[0] * xp1->size[1] * i18];
  }

  loop_ub = xm1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[2 + xsubs->size[0] * xsubs->size[1] * i18] = xm1->data[xm1->
      size[0] * xm1->size[1] * i18];
  }

  loop_ub = dy2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[(xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i18) + 2] =
      dy2->data[dy2->size[0] * dy2->size[1] * i18];
  }

  loop_ub = xp1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i18)
      + 2] = xp1->data[xp1->size[0] * xp1->size[1] * i18];
  }

  emxInit_real32_T2(&ysubs, 3);
  i18 = ysubs->size[0] * ysubs->size[1] * ysubs->size[2];
  ysubs->size[0] = 3;
  ysubs->size[1] = 3;
  ysubs->size[2] = ym1->size[2];
  emxEnsureCapacity_real32_T1(ysubs, i18);
  loop_ub = ym1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[ysubs->size[0] * ysubs->size[1] * i18] = ym1->data[ym1->size[0] *
      ym1->size[1] * i18];
  }

  loop_ub = ym1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[ysubs->size[0] + ysubs->size[0] * ysubs->size[1] * i18] =
      ym1->data[ym1->size[0] * ym1->size[1] * i18];
  }

  loop_ub = ym1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[(ysubs->size[0] << 1) + ysubs->size[0] * ysubs->size[1] * i18] =
      ym1->data[ym1->size[0] * ym1->size[1] * i18];
  }

  loop_ub = dx2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[1 + ysubs->size[0] * ysubs->size[1] * i18] = dx2->data[dx2->
      size[0] * dx2->size[1] * i18];
  }

  loop_ub = dx2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[(ysubs->size[0] + ysubs->size[0] * ysubs->size[1] * i18) + 1] =
      dx2->data[dx2->size[0] * dx2->size[1] * i18];
  }

  loop_ub = dx2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[((ysubs->size[0] << 1) + ysubs->size[0] * ysubs->size[1] * i18)
      + 1] = dx2->data[dx2->size[0] * dx2->size[1] * i18];
  }

  loop_ub = yp1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[2 + ysubs->size[0] * ysubs->size[1] * i18] = yp1->data[yp1->
      size[0] * yp1->size[1] * i18];
  }

  loop_ub = yp1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[(ysubs->size[0] + ysubs->size[0] * ysubs->size[1] * i18) + 2] =
      yp1->data[yp1->size[0] * yp1->size[1] * i18];
  }

  loop_ub = yp1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    ysubs->data[((ysubs->size[0] << 1) + ysubs->size[0] * ysubs->size[1] * i18)
      + 2] = yp1->data[yp1->size[0] * yp1->size[1] * i18];
  }

  for (i18 = 0; i18 < 2; i18++) {
    siz[i18] = (short)metric->size[i18];
  }

  emxInit_int32_T(&idx, 1);
  i18 = idx->size[0];
  idx->size[0] = 9 * ysubs->size[2];
  emxEnsureCapacity_int32_T(idx, i18);
  loop_ub = 9 * ysubs->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    idx->data[i18] = (int)ysubs->data[i18] + siz[0] * ((int)xsubs->data[i18] - 1);
  }

  emxFree_real32_T(&ysubs);
  i18 = xsubs->size[0] * xsubs->size[1] * xsubs->size[2];
  xsubs->size[0] = 3;
  xsubs->size[1] = 3;
  xsubs->size[2] = unnamed_idx_2;
  emxEnsureCapacity_real32_T1(xsubs, i18);
  loop_ub = 9 * unnamed_idx_2;
  for (i18 = 0; i18 < loop_ub; i18++) {
    xsubs->data[i18] = metric->data[idx->data[i18] - 1];
  }

  emxFree_int32_T(&idx);
  loop_ub = xsubs->size[2];
  i18 = dx2->size[0] * dx2->size[1] * dx2->size[2];
  dx2->size[0] = 1;
  dx2->size[1] = 1;
  dx2->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(dx2, i18);
  for (i18 = 0; i18 < loop_ub; i18++) {
    dx2->data[dx2->size[0] * dx2->size[1] * i18] = ((((((((xsubs->data
      [xsubs->size[0] * xsubs->size[1] * i18] - 2.0F * xsubs->data[xsubs->size[0]
      + xsubs->size[0] * xsubs->size[1] * i18]) + xsubs->data[(xsubs->size[0] <<
      1) + xsubs->size[0] * xsubs->size[1] * i18]) + 2.0F * xsubs->data[1 +
      xsubs->size[0] * xsubs->size[1] * i18]) - 4.0F * xsubs->data[(xsubs->size
      [0] + xsubs->size[0] * xsubs->size[1] * i18) + 1]) + 2.0F * xsubs->data
      [((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i18) + 1]) +
      xsubs->data[2 + xsubs->size[0] * xsubs->size[1] * i18]) - 2.0F *
      xsubs->data[(xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i18) + 2])
      + xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] *
                     i18) + 2]) / 8.0F;
  }

  loop_ub = xsubs->size[2];
  i18 = dy2->size[0] * dy2->size[1] * dy2->size[2];
  dy2->size[0] = 1;
  dy2->size[1] = 1;
  dy2->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(dy2, i18);
  for (i18 = 0; i18 < loop_ub; i18++) {
    dy2->data[dy2->size[0] * dy2->size[1] * i18] = ((((xsubs->data[xsubs->size[0]
      * xsubs->size[1] * i18] + 2.0F * xsubs->data[xsubs->size[0] + xsubs->size
      [0] * xsubs->size[1] * i18]) + xsubs->data[(xsubs->size[0] << 1) +
      xsubs->size[0] * xsubs->size[1] * i18]) - 2.0F * ((xsubs->data[1 +
      xsubs->size[0] * xsubs->size[1] * i18] + 2.0F * xsubs->data[(xsubs->size[0]
      + xsubs->size[0] * xsubs->size[1] * i18) + 1]) + xsubs->data[((xsubs->
      size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i18) + 1])) +
      ((xsubs->data[2 + xsubs->size[0] * xsubs->size[1] * i18] + 2.0F *
        xsubs->data[(xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i18) + 2])
       + xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] *
                      i18) + 2])) / 8.0F;
  }

  loop_ub = xsubs->size[2];
  i18 = xm1->size[0] * xm1->size[1] * xm1->size[2];
  xm1->size[0] = 1;
  xm1->size[1] = 1;
  xm1->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(xm1, i18);
  for (i18 = 0; i18 < loop_ub; i18++) {
    xm1->data[xm1->size[0] * xm1->size[1] * i18] = (((xsubs->data[xsubs->size[0]
      * xsubs->size[1] * i18] - xsubs->data[(xsubs->size[0] << 1) + xsubs->size
      [0] * xsubs->size[1] * i18]) - xsubs->data[2 + xsubs->size[0] *
      xsubs->size[1] * i18]) + xsubs->data[((xsubs->size[0] << 1) + xsubs->size
      [0] * xsubs->size[1] * i18) + 2]) / 4.0F;
  }

  loop_ub = xsubs->size[2];
  i18 = xp1->size[0] * xp1->size[1] * xp1->size[2];
  xp1->size[0] = 1;
  xp1->size[1] = 1;
  xp1->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(xp1, i18);
  for (i18 = 0; i18 < loop_ub; i18++) {
    xp1->data[xp1->size[0] * xp1->size[1] * i18] = (((((-xsubs->data[xsubs->
      size[0] * xsubs->size[1] * i18] - 2.0F * xsubs->data[1 + xsubs->size[0] *
      xsubs->size[1] * i18]) - xsubs->data[2 + xsubs->size[0] * xsubs->size[1] *
      i18]) + xsubs->data[(xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1]
      * i18]) + 2.0F * xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] *
      xsubs->size[1] * i18) + 1]) + xsubs->data[((xsubs->size[0] << 1) +
      xsubs->size[0] * xsubs->size[1] * i18) + 2]) / 8.0F;
  }

  loop_ub = xsubs->size[2];
  i18 = ym1->size[0] * ym1->size[1] * ym1->size[2];
  ym1->size[0] = 1;
  ym1->size[1] = 1;
  ym1->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(ym1, i18);
  for (i18 = 0; i18 < loop_ub; i18++) {
    ym1->data[ym1->size[0] * ym1->size[1] * i18] = (((((-xsubs->data[xsubs->
      size[0] * xsubs->size[1] * i18] - 2.0F * xsubs->data[xsubs->size[0] +
      xsubs->size[0] * xsubs->size[1] * i18]) - xsubs->data[(xsubs->size[0] << 1)
      + xsubs->size[0] * xsubs->size[1] * i18]) + xsubs->data[2 + xsubs->size[0]
      * xsubs->size[1] * i18]) + 2.0F * xsubs->data[(xsubs->size[0] +
      xsubs->size[0] * xsubs->size[1] * i18) + 2]) + xsubs->data[((xsubs->size[0]
      << 1) + xsubs->size[0] * xsubs->size[1] * i18) + 2]) / 8.0F;
  }

  emxFree_real32_T(&xsubs);
  i18 = yp1->size[0] * yp1->size[1] * yp1->size[2];
  yp1->size[0] = 1;
  yp1->size[1] = 1;
  yp1->size[2] = dx2->size[2];
  emxEnsureCapacity_real32_T1(yp1, i18);
  loop_ub = dx2->size[0] * dx2->size[1] * dx2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    yp1->data[i18] = 1.0F / (dx2->data[i18] * dy2->data[i18] - 0.25F * xm1->
      data[i18] * xm1->data[i18]);
  }

  loop_ub = dy2->size[0] * dy2->size[1] * dy2->size[2] - 1;
  i18 = dy2->size[0] * dy2->size[1] * dy2->size[2];
  dy2->size[0] = 1;
  dy2->size[1] = 1;
  emxEnsureCapacity_real32_T1(dy2, i18);
  for (i18 = 0; i18 <= loop_ub; i18++) {
    dy2->data[i18] = -0.5F * (dy2->data[i18] * xp1->data[i18] - 0.5F * xm1->
      data[i18] * ym1->data[i18]) * yp1->data[i18];
  }

  loop_ub = dx2->size[0] * dx2->size[1] * dx2->size[2] - 1;
  i18 = dx2->size[0] * dx2->size[1] * dx2->size[2];
  dx2->size[0] = 1;
  dx2->size[1] = 1;
  emxEnsureCapacity_real32_T1(dx2, i18);
  for (i18 = 0; i18 <= loop_ub; i18++) {
    dx2->data[i18] = -0.5F * (dx2->data[i18] * ym1->data[i18] - 0.5F * xm1->
      data[i18] * xp1->data[i18]) * yp1->data[i18];
  }

  emxFree_real32_T(&yp1);
  emxFree_real32_T(&ym1);
  emxFree_real32_T(&xp1);
  emxInit_boolean_T2(&r4, 3);
  b_abs(dy2, xm1);
  i18 = r4->size[0] * r4->size[1] * r4->size[2];
  r4->size[0] = 1;
  r4->size[1] = 1;
  r4->size[2] = xm1->size[2];
  emxEnsureCapacity_boolean_T1(r4, i18);
  loop_ub = xm1->size[0] * xm1->size[1] * xm1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    r4->data[i18] = (xm1->data[i18] < 1.0F);
  }

  emxInit_boolean_T2(&r5, 3);
  b_abs(dx2, xm1);
  i18 = r5->size[0] * r5->size[1] * r5->size[2];
  r5->size[0] = 1;
  r5->size[1] = 1;
  r5->size[2] = xm1->size[2];
  emxEnsureCapacity_boolean_T1(r5, i18);
  loop_ub = xm1->size[0] * xm1->size[1] * xm1->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    r5->data[i18] = (xm1->data[i18] < 1.0F);
  }

  emxFree_real32_T(&xm1);
  unnamed_idx_2 = r4->size[2];
  for (i = 0; i < unnamed_idx_2; i++) {
    if (!(r4->data[i] && r5->data[i])) {
      dy2->data[i] = 0.0F;
    }
  }

  unnamed_idx_2 = r4->size[2];
  for (i = 0; i < unnamed_idx_2; i++) {
    if (!(r4->data[i] && r5->data[i])) {
      dx2->data[i] = 0.0F;
    }
  }

  emxFree_boolean_T(&r5);
  emxFree_boolean_T(&r4);
  emxInit_real32_T2(&b_dy2, 3);
  i18 = b_dy2->size[0] * b_dy2->size[1] * b_dy2->size[2];
  b_dy2->size[0] = 2;
  b_dy2->size[1] = 1;
  b_dy2->size[2] = dy2->size[2];
  emxEnsureCapacity_real32_T1(b_dy2, i18);
  loop_ub = dy2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    b_dy2->data[b_dy2->size[0] * b_dy2->size[1] * i18] = dy2->data[dy2->size[0] *
      dy2->size[1] * i18];
  }

  emxFree_real32_T(&dy2);
  loop_ub = dx2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    b_dy2->data[1 + b_dy2->size[0] * b_dy2->size[1] * i18] = dx2->data[dx2->
      size[0] * dx2->size[1] * i18];
  }

  emxFree_real32_T(&dx2);
  i18 = subPixelLoc->size[0] * subPixelLoc->size[1] * subPixelLoc->size[2];
  subPixelLoc->size[0] = 2;
  subPixelLoc->size[1] = 1;
  subPixelLoc->size[2] = b_dy2->size[2];
  emxEnsureCapacity_real32_T1(subPixelLoc, i18);
  loop_ub = b_dy2->size[2];
  for (i18 = 0; i18 < loop_ub; i18++) {
    for (i = 0; i < 2; i++) {
      subPixelLoc->data[i + subPixelLoc->size[0] * subPixelLoc->size[1] * i18] =
        b_dy2->data[i + b_dy2->size[0] * b_dy2->size[1] * i18] + loc->data[i +
        loc->size[0] * loc->size[1] * i18];
    }
  }

  emxFree_real32_T(&b_dy2);
}

/*
 * Arguments    : const emxArray_real32_T *metric
 *                const emxArray_real32_T *loc
 *                emxArray_real32_T *values
 * Return Type  : void
 */
void computeMetric(const emxArray_real32_T *metric, const emxArray_real32_T *loc,
                   emxArray_real32_T *values)
{
  emxArray_real32_T *x;
  int loop_ub;
  int i19;
  emxArray_real32_T *y;
  emxArray_real32_T *x1;
  emxArray_real32_T *b_y1;
  emxArray_real32_T *x2;
  emxArray_real32_T *y2;
  emxArray_int32_T *idx;
  short sz;
  short siz[2];
  short b_sz[2];
  emxArray_int32_T *b_idx;
  emxArray_int32_T *c_idx;
  emxArray_int32_T *d_idx;
  emxInit_real32_T1(&x, 1);
  loop_ub = loc->size[0];
  i19 = x->size[0];
  x->size[0] = loop_ub;
  emxEnsureCapacity_real32_T2(x, i19);
  for (i19 = 0; i19 < loop_ub; i19++) {
    x->data[i19] = loc->data[i19];
  }

  emxInit_real32_T1(&y, 1);
  loop_ub = loc->size[0];
  i19 = y->size[0];
  y->size[0] = loop_ub;
  emxEnsureCapacity_real32_T2(y, i19);
  for (i19 = 0; i19 < loop_ub; i19++) {
    y->data[i19] = loc->data[i19 + loc->size[0]];
  }

  emxInit_real32_T1(&x1, 1);
  i19 = x1->size[0];
  x1->size[0] = x->size[0];
  emxEnsureCapacity_real32_T2(x1, i19);
  loop_ub = x->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    x1->data[i19] = x->data[i19];
  }

  emxInit_real32_T1(&b_y1, 1);
  b_floor(x1);
  i19 = b_y1->size[0];
  b_y1->size[0] = y->size[0];
  emxEnsureCapacity_real32_T2(b_y1, i19);
  loop_ub = y->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    b_y1->data[i19] = y->data[i19];
  }

  emxInit_real32_T1(&x2, 1);
  b_floor(b_y1);
  i19 = x2->size[0];
  x2->size[0] = x1->size[0];
  emxEnsureCapacity_real32_T2(x2, i19);
  loop_ub = x1->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    x2->data[i19] = x1->data[i19] + 1.0F;
  }

  emxInit_real32_T1(&y2, 1);
  i19 = y2->size[0];
  y2->size[0] = b_y1->size[0];
  emxEnsureCapacity_real32_T2(y2, i19);
  loop_ub = b_y1->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    y2->data[i19] = b_y1->data[i19] + 1.0F;
  }

  for (i19 = 0; i19 < 2; i19++) {
    sz = (short)metric->size[i19];
    siz[i19] = sz;
    b_sz[i19] = sz;
  }

  emxInit_int32_T(&idx, 1);
  i19 = idx->size[0];
  idx->size[0] = b_y1->size[0];
  emxEnsureCapacity_int32_T(idx, i19);
  loop_ub = b_y1->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    idx->data[i19] = (int)b_y1->data[i19] + siz[0] * ((int)x1->data[i19] - 1);
  }

  for (i19 = 0; i19 < 2; i19++) {
    siz[i19] = b_sz[i19];
  }

  emxInit_int32_T(&b_idx, 1);
  i19 = b_idx->size[0];
  b_idx->size[0] = b_y1->size[0];
  emxEnsureCapacity_int32_T(b_idx, i19);
  loop_ub = b_y1->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    b_idx->data[i19] = (int)b_y1->data[i19] + siz[0] * ((int)x2->data[i19] - 1);
  }

  for (i19 = 0; i19 < 2; i19++) {
    siz[i19] = b_sz[i19];
  }

  emxInit_int32_T(&c_idx, 1);
  i19 = c_idx->size[0];
  c_idx->size[0] = y2->size[0];
  emxEnsureCapacity_int32_T(c_idx, i19);
  loop_ub = y2->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    c_idx->data[i19] = (int)y2->data[i19] + siz[0] * ((int)x1->data[i19] - 1);
  }

  for (i19 = 0; i19 < 2; i19++) {
    siz[i19] = b_sz[i19];
  }

  emxInit_int32_T(&d_idx, 1);
  i19 = d_idx->size[0];
  d_idx->size[0] = y2->size[0];
  emxEnsureCapacity_int32_T(d_idx, i19);
  loop_ub = y2->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    d_idx->data[i19] = (int)y2->data[i19] + siz[0] * ((int)x2->data[i19] - 1);
  }

  i19 = values->size[0];
  values->size[0] = idx->size[0];
  emxEnsureCapacity_real32_T2(values, i19);
  loop_ub = idx->size[0];
  for (i19 = 0; i19 < loop_ub; i19++) {
    values->data[i19] = ((metric->data[idx->data[i19] - 1] * (x2->data[i19] -
      x->data[i19]) * (y2->data[i19] - y->data[i19]) + metric->data[b_idx->
                          data[i19] - 1] * (x->data[i19] - x1->data[i19]) *
                          (y2->data[i19] - y->data[i19])) + metric->data
                         [c_idx->data[i19] - 1] * (x2->data[i19] - x->data[i19])
                         * (y->data[i19] - b_y1->data[i19])) + metric->
      data[d_idx->data[i19] - 1] * (x->data[i19] - x1->data[i19]) * (y->data[i19]
      - b_y1->data[i19]);
  }

  emxFree_int32_T(&d_idx);
  emxFree_int32_T(&c_idx);
  emxFree_int32_T(&b_idx);
  emxFree_int32_T(&idx);
  emxFree_real32_T(&y2);
  emxFree_real32_T(&x2);
  emxFree_real32_T(&b_y1);
  emxFree_real32_T(&x1);
  emxFree_real32_T(&y);
  emxFree_real32_T(&x);
}

/*
 * Arguments    : const emxArray_real32_T *I
 *                emxArray_real32_T *metric
 * Return Type  : void
 */
void cornerMetric(const emxArray_real32_T *I, emxArray_real32_T *metric)
{
  emxArray_real32_T *r3;
  int i9;
  int loop_ub;
  emxArray_real32_T *A;
  emxArray_real32_T *B;
  int b_A;
  int c_A;
  int i10;
  emxArray_real32_T *d_A;
  int i11;
  int b_loop_ub;
  emxArray_real32_T *C;
  emxArray_real32_T *e_A;
  emxArray_real32_T *f_A;
  emxInit_real32_T(&r3, 2);
  i9 = r3->size[0] * r3->size[1];
  r3->size[0] = I->size[0];
  r3->size[1] = I->size[1];
  emxEnsureCapacity_real32_T(r3, i9);
  loop_ub = I->size[0] * I->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    r3->data[i9] = I->data[i9];
  }

  emxInit_real32_T(&A, 2);
  b_imfilter(r3);
  i9 = A->size[0] * A->size[1];
  A->size[0] = r3->size[0];
  A->size[1] = r3->size[1];
  emxEnsureCapacity_real32_T(A, i9);
  loop_ub = r3->size[0] * r3->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    A->data[i9] = r3->data[i9];
  }

  i9 = r3->size[0] * r3->size[1];
  r3->size[0] = I->size[0];
  r3->size[1] = I->size[1];
  emxEnsureCapacity_real32_T(r3, i9);
  loop_ub = I->size[0] * I->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    r3->data[i9] = I->data[i9];
  }

  emxInit_real32_T(&B, 2);
  c_imfilter(r3);
  i9 = B->size[0] * B->size[1];
  B->size[0] = r3->size[0];
  B->size[1] = r3->size[1];
  emxEnsureCapacity_real32_T(B, i9);
  loop_ub = r3->size[0] * r3->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    B->data[i9] = r3->data[i9];
  }

  emxFree_real32_T(&r3);
  if (2 > A->size[0] - 1) {
    i9 = 0;
    b_A = 0;
  } else {
    i9 = 1;
    b_A = A->size[0] - 1;
  }

  if (2 > A->size[1] - 1) {
    c_A = 0;
    i10 = 0;
  } else {
    c_A = 1;
    i10 = A->size[1] - 1;
  }

  emxInit_real32_T(&d_A, 2);
  i11 = d_A->size[0] * d_A->size[1];
  d_A->size[0] = b_A - i9;
  d_A->size[1] = i10 - c_A;
  emxEnsureCapacity_real32_T(d_A, i11);
  loop_ub = i10 - c_A;
  for (i10 = 0; i10 < loop_ub; i10++) {
    b_loop_ub = b_A - i9;
    for (i11 = 0; i11 < b_loop_ub; i11++) {
      d_A->data[i11 + d_A->size[0] * i10] = A->data[(i9 + i11) + A->size[0] *
        (c_A + i10)];
    }
  }

  i9 = A->size[0] * A->size[1];
  A->size[0] = d_A->size[0];
  A->size[1] = d_A->size[1];
  emxEnsureCapacity_real32_T(A, i9);
  loop_ub = d_A->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    b_loop_ub = d_A->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      A->data[b_A + A->size[0] * i9] = d_A->data[b_A + d_A->size[0] * i9];
    }
  }

  if (2 > B->size[0] - 1) {
    i9 = 0;
    b_A = 0;
  } else {
    i9 = 1;
    b_A = B->size[0] - 1;
  }

  if (2 > B->size[1] - 1) {
    c_A = 0;
    i10 = 0;
  } else {
    c_A = 1;
    i10 = B->size[1] - 1;
  }

  i11 = d_A->size[0] * d_A->size[1];
  d_A->size[0] = b_A - i9;
  d_A->size[1] = i10 - c_A;
  emxEnsureCapacity_real32_T(d_A, i11);
  loop_ub = i10 - c_A;
  for (i10 = 0; i10 < loop_ub; i10++) {
    b_loop_ub = b_A - i9;
    for (i11 = 0; i11 < b_loop_ub; i11++) {
      d_A->data[i11 + d_A->size[0] * i10] = B->data[(i9 + i11) + B->size[0] *
        (c_A + i10)];
    }
  }

  i9 = B->size[0] * B->size[1];
  B->size[0] = d_A->size[0];
  B->size[1] = d_A->size[1];
  emxEnsureCapacity_real32_T(B, i9);
  loop_ub = d_A->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    b_loop_ub = d_A->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      B->data[b_A + B->size[0] * i9] = d_A->data[b_A + d_A->size[0] * i9];
    }
  }

  emxInit_real32_T(&C, 2);
  i9 = C->size[0] * C->size[1];
  C->size[0] = A->size[0];
  C->size[1] = A->size[1];
  emxEnsureCapacity_real32_T(C, i9);
  loop_ub = A->size[0] * A->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    C->data[i9] = A->data[i9] * B->data[i9];
  }

  loop_ub = A->size[0] * A->size[1] - 1;
  i9 = A->size[0] * A->size[1];
  emxEnsureCapacity_real32_T(A, i9);
  for (i9 = 0; i9 <= loop_ub; i9++) {
    A->data[i9] *= A->data[i9];
  }

  loop_ub = B->size[0] * B->size[1] - 1;
  i9 = B->size[0] * B->size[1];
  emxEnsureCapacity_real32_T(B, i9);
  for (i9 = 0; i9 <= loop_ub; i9++) {
    B->data[i9] *= B->data[i9];
  }

  emxInit_real32_T(&e_A, 2);
  i9 = e_A->size[0] * e_A->size[1];
  e_A->size[0] = A->size[0];
  e_A->size[1] = A->size[1];
  emxEnsureCapacity_real32_T(e_A, i9);
  loop_ub = A->size[0] * A->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    e_A->data[i9] = A->data[i9];
  }

  imfilter(e_A, A);
  i9 = e_A->size[0] * e_A->size[1];
  e_A->size[0] = B->size[0];
  e_A->size[1] = B->size[1];
  emxEnsureCapacity_real32_T(e_A, i9);
  loop_ub = B->size[0] * B->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    e_A->data[i9] = B->data[i9];
  }

  imfilter(e_A, B);
  i9 = e_A->size[0] * e_A->size[1];
  e_A->size[0] = C->size[0];
  e_A->size[1] = C->size[1];
  emxEnsureCapacity_real32_T(e_A, i9);
  loop_ub = C->size[0] * C->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    e_A->data[i9] = C->data[i9];
  }

  imfilter(e_A, C);
  b_A = A->size[0] - 1;
  loop_ub = b_A - 2;
  c_A = A->size[1] - 1;
  b_loop_ub = c_A - 2;
  i9 = d_A->size[0] * d_A->size[1];
  d_A->size[0] = b_A - 1;
  d_A->size[1] = c_A - 1;
  emxEnsureCapacity_real32_T(d_A, i9);
  emxFree_real32_T(&e_A);
  for (i9 = 0; i9 <= b_loop_ub; i9++) {
    for (b_A = 0; b_A <= loop_ub; b_A++) {
      d_A->data[b_A + d_A->size[0] * i9] = A->data[(b_A + A->size[0] * (1 + i9))
        + 1];
    }
  }

  i9 = A->size[0] * A->size[1];
  A->size[0] = d_A->size[0];
  A->size[1] = d_A->size[1];
  emxEnsureCapacity_real32_T(A, i9);
  loop_ub = d_A->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    b_loop_ub = d_A->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      A->data[b_A + A->size[0] * i9] = d_A->data[b_A + d_A->size[0] * i9];
    }
  }

  b_A = B->size[0] - 1;
  loop_ub = b_A - 2;
  c_A = B->size[1] - 1;
  b_loop_ub = c_A - 2;
  i9 = d_A->size[0] * d_A->size[1];
  d_A->size[0] = b_A - 1;
  d_A->size[1] = c_A - 1;
  emxEnsureCapacity_real32_T(d_A, i9);
  for (i9 = 0; i9 <= b_loop_ub; i9++) {
    for (b_A = 0; b_A <= loop_ub; b_A++) {
      d_A->data[b_A + d_A->size[0] * i9] = B->data[(b_A + B->size[0] * (1 + i9))
        + 1];
    }
  }

  i9 = B->size[0] * B->size[1];
  B->size[0] = d_A->size[0];
  B->size[1] = d_A->size[1];
  emxEnsureCapacity_real32_T(B, i9);
  loop_ub = d_A->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    b_loop_ub = d_A->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      B->data[b_A + B->size[0] * i9] = d_A->data[b_A + d_A->size[0] * i9];
    }
  }

  b_A = C->size[0] - 1;
  loop_ub = b_A - 2;
  c_A = C->size[1] - 1;
  b_loop_ub = c_A - 2;
  i9 = d_A->size[0] * d_A->size[1];
  d_A->size[0] = b_A - 1;
  d_A->size[1] = c_A - 1;
  emxEnsureCapacity_real32_T(d_A, i9);
  for (i9 = 0; i9 <= b_loop_ub; i9++) {
    for (b_A = 0; b_A <= loop_ub; b_A++) {
      d_A->data[b_A + d_A->size[0] * i9] = C->data[(b_A + C->size[0] * (1 + i9))
        + 1];
    }
  }

  i9 = C->size[0] * C->size[1];
  C->size[0] = d_A->size[0];
  C->size[1] = d_A->size[1];
  emxEnsureCapacity_real32_T(C, i9);
  loop_ub = d_A->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    b_loop_ub = d_A->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      C->data[b_A + C->size[0] * i9] = d_A->data[b_A + d_A->size[0] * i9];
    }
  }

  emxFree_real32_T(&d_A);
  emxInit_real32_T(&f_A, 2);
  i9 = f_A->size[0] * f_A->size[1];
  f_A->size[0] = A->size[0];
  f_A->size[1] = A->size[1];
  emxEnsureCapacity_real32_T(f_A, i9);
  loop_ub = A->size[0] * A->size[1];
  for (i9 = 0; i9 < loop_ub; i9++) {
    f_A->data[i9] = A->data[i9] - B->data[i9];
  }

  power(f_A, metric);
  power(C, f_A);
  loop_ub = metric->size[0] * metric->size[1] - 1;
  i9 = metric->size[0] * metric->size[1];
  emxEnsureCapacity_real32_T(metric, i9);
  emxFree_real32_T(&C);
  for (i9 = 0; i9 <= loop_ub; i9++) {
    metric->data[i9] += 4.0F * f_A->data[i9];
  }

  emxFree_real32_T(&f_A);
  b_sqrt(metric);
  loop_ub = A->size[0] * A->size[1] - 1;
  i9 = metric->size[0] * metric->size[1];
  metric->size[0] = A->size[0];
  metric->size[1] = A->size[1];
  emxEnsureCapacity_real32_T(metric, i9);
  for (i9 = 0; i9 <= loop_ub; i9++) {
    metric->data[i9] = ((A->data[i9] + B->data[i9]) - metric->data[i9]) / 2.0F;
  }

  emxFree_real32_T(&B);
  emxFree_real32_T(&A);
}

/*
 * Arguments    : const float varargin_2_data[]
 *                const int varargin_2_size[2]
 *                float *params_MinQuality
 *                double *params_FilterSize
 *                boolean_T *params_usingROI
 *                int params_ROI_data[]
 *                int params_ROI_size[2]
 * Return Type  : void
 */
void parseInputs(const float varargin_2_data[], const int varargin_2_size[2],
                 float *params_MinQuality, double *params_FilterSize, boolean_T *
                 params_usingROI, int params_ROI_data[], int params_ROI_size[2])
{
  int loop_ub;
  int i2;
  float f1;
  int i3;
  *params_MinQuality = 0.01F;
  *params_FilterSize = 5.0;
  *params_usingROI = true;
  params_ROI_size[0] = varargin_2_size[0];
  params_ROI_size[1] = 4;
  loop_ub = varargin_2_size[0] * varargin_2_size[1];
  for (i2 = 0; i2 < loop_ub; i2++) {
    f1 = rt_roundf_snf(varargin_2_data[i2]);
    if (f1 < 2.14748365E+9F) {
      if (f1 >= -2.14748365E+9F) {
        i3 = (int)f1;
      } else {
        i3 = MIN_int32_T;
      }
    } else if (f1 >= 2.14748365E+9F) {
      i3 = MAX_int32_T;
    } else {
      i3 = 0;
    }

    params_ROI_data[i2] = i3;
  }
}

/*
 * Arguments    : const emxArray_real32_T *metric
 *                emxArray_real32_T *loc
 * Return Type  : void
 */
void subPixelLocation(const emxArray_real32_T *metric, emxArray_real32_T *loc)
{
  emxArray_real32_T *x;
  int i38;
  int sqsz_idx_1;
  emxArray_real32_T *b_loc;
  int i39;
  int iv8[3];
  emxArray_real32_T b_x;
  emxInit_real32_T(&x, 2);
  i38 = x->size[0] * x->size[1];
  x->size[0] = 2;
  x->size[1] = loc->size[0];
  emxEnsureCapacity_real32_T(x, i38);
  sqsz_idx_1 = loc->size[0];
  for (i38 = 0; i38 < sqsz_idx_1; i38++) {
    for (i39 = 0; i39 < 2; i39++) {
      x->data[i39 + x->size[0] * i38] = loc->data[i38 + loc->size[0] * i39];
    }
  }

  emxInit_real32_T2(&b_loc, 3);
  iv8[0] = 2;
  iv8[1] = 1;
  iv8[2] = (x->size[1] << 1) / 2;
  b_x = *x;
  b_x.size = (int *)&iv8;
  b_x.numDimensions = 1;
  subPixelLocationImpl(metric, &b_x, b_loc);
  sqsz_idx_1 = 1;
  emxFree_real32_T(&x);
  if (b_loc->size[2] != 1) {
    sqsz_idx_1 = b_loc->size[2];
  }

  i38 = loc->size[0] * loc->size[1];
  loc->size[0] = sqsz_idx_1;
  loc->size[1] = 2;
  emxEnsureCapacity_real32_T(loc, i38);
  for (i38 = 0; i38 < 2; i38++) {
    for (i39 = 0; i39 < sqsz_idx_1; i39++) {
      loc->data[i39 + loc->size[0] * i38] = b_loc->data[i38 + (i39 << 1)];
    }
  }

  emxFree_real32_T(&b_loc);
}

/*
 * File trailer for harrisMinEigen.c
 *
 * [EOF]
 */

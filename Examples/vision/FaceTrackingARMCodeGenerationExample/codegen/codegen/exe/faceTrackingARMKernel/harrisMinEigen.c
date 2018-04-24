/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: harrisMinEigen.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "harrisMinEigen.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "floor.h"
#include "abs.h"
#include "sqrt.h"
#include "power.h"
#include "imfilter.h"
#include "insertShape.h"
#include "faceTrackingARMKernel_rtwutil.h"

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
  unsigned short unnamed_idx_2;
  int loop_ub;
  int i27;
  emxArray_real32_T *dx2;
  emxArray_real32_T *xm1;
  emxArray_real32_T *xp1;
  emxArray_real32_T *ym1;
  emxArray_real32_T *yp1;
  emxArray_real32_T *xsubs;
  emxArray_real32_T *ysubs;
  emxArray_int32_T *idx;
  unsigned char siz[2];
  int tmp_size_idx_2;
  boolean_T tmp_data[34615];
  boolean_T b_tmp_data[34615];
  int i;
  emxArray_real32_T *b_dy2;
  emxInit_real32_T2(&dy2, 3);
  unnamed_idx_2 = (unsigned short)loc->size[2];
  loop_ub = loc->size[2];
  i27 = dy2->size[0] * dy2->size[1] * dy2->size[2];
  dy2->size[0] = 1;
  dy2->size[1] = 1;
  dy2->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(dy2, i27);
  for (i27 = 0; i27 < loop_ub; i27++) {
    dy2->data[dy2->size[0] * dy2->size[1] * i27] = loc->data[loc->size[0] *
      loc->size[1] * i27];
  }

  emxInit_real32_T2(&dx2, 3);
  loop_ub = loc->size[2];
  i27 = dx2->size[0] * dx2->size[1] * dx2->size[2];
  dx2->size[0] = 1;
  dx2->size[1] = 1;
  dx2->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(dx2, i27);
  for (i27 = 0; i27 < loop_ub; i27++) {
    dx2->data[dx2->size[0] * dx2->size[1] * i27] = loc->data[1 + loc->size[0] *
      loc->size[1] * i27];
  }

  emxInit_real32_T2(&xm1, 3);
  i27 = xm1->size[0] * xm1->size[1] * xm1->size[2];
  xm1->size[0] = 1;
  xm1->size[1] = 1;
  xm1->size[2] = dy2->size[2];
  emxEnsureCapacity_real32_T1(xm1, i27);
  loop_ub = dy2->size[0] * dy2->size[1] * dy2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xm1->data[i27] = dy2->data[i27] - 1.0F;
  }

  emxInit_real32_T2(&xp1, 3);
  i27 = xp1->size[0] * xp1->size[1] * xp1->size[2];
  xp1->size[0] = 1;
  xp1->size[1] = 1;
  xp1->size[2] = dy2->size[2];
  emxEnsureCapacity_real32_T1(xp1, i27);
  loop_ub = dy2->size[0] * dy2->size[1] * dy2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xp1->data[i27] = dy2->data[i27] + 1.0F;
  }

  emxInit_real32_T2(&ym1, 3);
  i27 = ym1->size[0] * ym1->size[1] * ym1->size[2];
  ym1->size[0] = 1;
  ym1->size[1] = 1;
  ym1->size[2] = dx2->size[2];
  emxEnsureCapacity_real32_T1(ym1, i27);
  loop_ub = dx2->size[0] * dx2->size[1] * dx2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ym1->data[i27] = dx2->data[i27] - 1.0F;
  }

  emxInit_real32_T2(&yp1, 3);
  i27 = yp1->size[0] * yp1->size[1] * yp1->size[2];
  yp1->size[0] = 1;
  yp1->size[1] = 1;
  yp1->size[2] = dx2->size[2];
  emxEnsureCapacity_real32_T1(yp1, i27);
  loop_ub = dx2->size[0] * dx2->size[1] * dx2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    yp1->data[i27] = dx2->data[i27] + 1.0F;
  }

  emxInit_real32_T2(&xsubs, 3);
  i27 = xsubs->size[0] * xsubs->size[1] * xsubs->size[2];
  xsubs->size[0] = 3;
  xsubs->size[1] = 3;
  xsubs->size[2] = xm1->size[2];
  emxEnsureCapacity_real32_T1(xsubs, i27);
  loop_ub = xm1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[xsubs->size[0] * xsubs->size[1] * i27] = xm1->data[xm1->size[0] *
      xm1->size[1] * i27];
  }

  loop_ub = dy2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i27] =
      dy2->data[dy2->size[0] * dy2->size[1] * i27];
  }

  loop_ub = xp1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[(xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i27] =
      xp1->data[xp1->size[0] * xp1->size[1] * i27];
  }

  loop_ub = xm1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[1 + xsubs->size[0] * xsubs->size[1] * i27] = xm1->data[xm1->
      size[0] * xm1->size[1] * i27];
  }

  loop_ub = dy2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[(xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i27) + 1] =
      dy2->data[dy2->size[0] * dy2->size[1] * i27];
  }

  loop_ub = xp1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i27)
      + 1] = xp1->data[xp1->size[0] * xp1->size[1] * i27];
  }

  loop_ub = xm1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[2 + xsubs->size[0] * xsubs->size[1] * i27] = xm1->data[xm1->
      size[0] * xm1->size[1] * i27];
  }

  loop_ub = dy2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[(xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i27) + 2] =
      dy2->data[dy2->size[0] * dy2->size[1] * i27];
  }

  loop_ub = xp1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i27)
      + 2] = xp1->data[xp1->size[0] * xp1->size[1] * i27];
  }

  emxInit_real32_T2(&ysubs, 3);
  i27 = ysubs->size[0] * ysubs->size[1] * ysubs->size[2];
  ysubs->size[0] = 3;
  ysubs->size[1] = 3;
  ysubs->size[2] = ym1->size[2];
  emxEnsureCapacity_real32_T1(ysubs, i27);
  loop_ub = ym1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[ysubs->size[0] * ysubs->size[1] * i27] = ym1->data[ym1->size[0] *
      ym1->size[1] * i27];
  }

  loop_ub = ym1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[ysubs->size[0] + ysubs->size[0] * ysubs->size[1] * i27] =
      ym1->data[ym1->size[0] * ym1->size[1] * i27];
  }

  loop_ub = ym1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[(ysubs->size[0] << 1) + ysubs->size[0] * ysubs->size[1] * i27] =
      ym1->data[ym1->size[0] * ym1->size[1] * i27];
  }

  loop_ub = dx2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[1 + ysubs->size[0] * ysubs->size[1] * i27] = dx2->data[dx2->
      size[0] * dx2->size[1] * i27];
  }

  loop_ub = dx2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[(ysubs->size[0] + ysubs->size[0] * ysubs->size[1] * i27) + 1] =
      dx2->data[dx2->size[0] * dx2->size[1] * i27];
  }

  loop_ub = dx2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[((ysubs->size[0] << 1) + ysubs->size[0] * ysubs->size[1] * i27)
      + 1] = dx2->data[dx2->size[0] * dx2->size[1] * i27];
  }

  loop_ub = yp1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[2 + ysubs->size[0] * ysubs->size[1] * i27] = yp1->data[yp1->
      size[0] * yp1->size[1] * i27];
  }

  loop_ub = yp1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[(ysubs->size[0] + ysubs->size[0] * ysubs->size[1] * i27) + 2] =
      yp1->data[yp1->size[0] * yp1->size[1] * i27];
  }

  loop_ub = yp1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    ysubs->data[((ysubs->size[0] << 1) + ysubs->size[0] * ysubs->size[1] * i27)
      + 2] = yp1->data[yp1->size[0] * yp1->size[1] * i27];
  }

  for (i27 = 0; i27 < 2; i27++) {
    siz[i27] = (unsigned char)metric->size[i27];
  }

  emxInit_int32_T(&idx, 1);
  i27 = idx->size[0];
  idx->size[0] = 9 * ysubs->size[2];
  emxEnsureCapacity_int32_T(idx, i27);
  loop_ub = 9 * ysubs->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    idx->data[i27] = (int)ysubs->data[i27] + siz[0] * ((int)xsubs->data[i27] - 1);
  }

  emxFree_real32_T(&ysubs);
  i27 = xsubs->size[0] * xsubs->size[1] * xsubs->size[2];
  xsubs->size[0] = 3;
  xsubs->size[1] = 3;
  xsubs->size[2] = unnamed_idx_2;
  emxEnsureCapacity_real32_T1(xsubs, i27);
  loop_ub = 9 * unnamed_idx_2;
  for (i27 = 0; i27 < loop_ub; i27++) {
    xsubs->data[i27] = metric->data[idx->data[i27] - 1];
  }

  emxFree_int32_T(&idx);
  loop_ub = xsubs->size[2];
  i27 = dx2->size[0] * dx2->size[1] * dx2->size[2];
  dx2->size[0] = 1;
  dx2->size[1] = 1;
  dx2->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(dx2, i27);
  for (i27 = 0; i27 < loop_ub; i27++) {
    dx2->data[dx2->size[0] * dx2->size[1] * i27] = ((((((((xsubs->data
      [xsubs->size[0] * xsubs->size[1] * i27] - 2.0F * xsubs->data[xsubs->size[0]
      + xsubs->size[0] * xsubs->size[1] * i27]) + xsubs->data[(xsubs->size[0] <<
      1) + xsubs->size[0] * xsubs->size[1] * i27]) + 2.0F * xsubs->data[1 +
      xsubs->size[0] * xsubs->size[1] * i27]) - 4.0F * xsubs->data[(xsubs->size
      [0] + xsubs->size[0] * xsubs->size[1] * i27) + 1]) + 2.0F * xsubs->data
      [((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i27) + 1]) +
      xsubs->data[2 + xsubs->size[0] * xsubs->size[1] * i27]) - 2.0F *
      xsubs->data[(xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i27) + 2])
      + xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] *
                     i27) + 2]) / 8.0F;
  }

  loop_ub = xsubs->size[2];
  i27 = dy2->size[0] * dy2->size[1] * dy2->size[2];
  dy2->size[0] = 1;
  dy2->size[1] = 1;
  dy2->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(dy2, i27);
  for (i27 = 0; i27 < loop_ub; i27++) {
    dy2->data[dy2->size[0] * dy2->size[1] * i27] = ((((xsubs->data[xsubs->size[0]
      * xsubs->size[1] * i27] + 2.0F * xsubs->data[xsubs->size[0] + xsubs->size
      [0] * xsubs->size[1] * i27]) + xsubs->data[(xsubs->size[0] << 1) +
      xsubs->size[0] * xsubs->size[1] * i27]) - 2.0F * ((xsubs->data[1 +
      xsubs->size[0] * xsubs->size[1] * i27] + 2.0F * xsubs->data[(xsubs->size[0]
      + xsubs->size[0] * xsubs->size[1] * i27) + 1]) + xsubs->data[((xsubs->
      size[0] << 1) + xsubs->size[0] * xsubs->size[1] * i27) + 1])) +
      ((xsubs->data[2 + xsubs->size[0] * xsubs->size[1] * i27] + 2.0F *
        xsubs->data[(xsubs->size[0] + xsubs->size[0] * xsubs->size[1] * i27) + 2])
       + xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1] *
                      i27) + 2])) / 8.0F;
  }

  loop_ub = xsubs->size[2];
  i27 = xm1->size[0] * xm1->size[1] * xm1->size[2];
  xm1->size[0] = 1;
  xm1->size[1] = 1;
  xm1->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(xm1, i27);
  for (i27 = 0; i27 < loop_ub; i27++) {
    xm1->data[xm1->size[0] * xm1->size[1] * i27] = (((xsubs->data[xsubs->size[0]
      * xsubs->size[1] * i27] - xsubs->data[(xsubs->size[0] << 1) + xsubs->size
      [0] * xsubs->size[1] * i27]) - xsubs->data[2 + xsubs->size[0] *
      xsubs->size[1] * i27]) + xsubs->data[((xsubs->size[0] << 1) + xsubs->size
      [0] * xsubs->size[1] * i27) + 2]) / 4.0F;
  }

  loop_ub = xsubs->size[2];
  i27 = xp1->size[0] * xp1->size[1] * xp1->size[2];
  xp1->size[0] = 1;
  xp1->size[1] = 1;
  xp1->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(xp1, i27);
  for (i27 = 0; i27 < loop_ub; i27++) {
    xp1->data[xp1->size[0] * xp1->size[1] * i27] = (((((-xsubs->data[xsubs->
      size[0] * xsubs->size[1] * i27] - 2.0F * xsubs->data[1 + xsubs->size[0] *
      xsubs->size[1] * i27]) - xsubs->data[2 + xsubs->size[0] * xsubs->size[1] *
      i27]) + xsubs->data[(xsubs->size[0] << 1) + xsubs->size[0] * xsubs->size[1]
      * i27]) + 2.0F * xsubs->data[((xsubs->size[0] << 1) + xsubs->size[0] *
      xsubs->size[1] * i27) + 1]) + xsubs->data[((xsubs->size[0] << 1) +
      xsubs->size[0] * xsubs->size[1] * i27) + 2]) / 8.0F;
  }

  loop_ub = xsubs->size[2];
  i27 = ym1->size[0] * ym1->size[1] * ym1->size[2];
  ym1->size[0] = 1;
  ym1->size[1] = 1;
  ym1->size[2] = loop_ub;
  emxEnsureCapacity_real32_T1(ym1, i27);
  for (i27 = 0; i27 < loop_ub; i27++) {
    ym1->data[ym1->size[0] * ym1->size[1] * i27] = (((((-xsubs->data[xsubs->
      size[0] * xsubs->size[1] * i27] - 2.0F * xsubs->data[xsubs->size[0] +
      xsubs->size[0] * xsubs->size[1] * i27]) - xsubs->data[(xsubs->size[0] << 1)
      + xsubs->size[0] * xsubs->size[1] * i27]) + xsubs->data[2 + xsubs->size[0]
      * xsubs->size[1] * i27]) + 2.0F * xsubs->data[(xsubs->size[0] +
      xsubs->size[0] * xsubs->size[1] * i27) + 2]) + xsubs->data[((xsubs->size[0]
      << 1) + xsubs->size[0] * xsubs->size[1] * i27) + 2]) / 8.0F;
  }

  emxFree_real32_T(&xsubs);
  i27 = yp1->size[0] * yp1->size[1] * yp1->size[2];
  yp1->size[0] = 1;
  yp1->size[1] = 1;
  yp1->size[2] = dx2->size[2];
  emxEnsureCapacity_real32_T1(yp1, i27);
  loop_ub = dx2->size[0] * dx2->size[1] * dx2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    yp1->data[i27] = 1.0F / (dx2->data[i27] * dy2->data[i27] - 0.25F * xm1->
      data[i27] * xm1->data[i27]);
  }

  loop_ub = dy2->size[0] * dy2->size[1] * dy2->size[2] - 1;
  i27 = dy2->size[0] * dy2->size[1] * dy2->size[2];
  dy2->size[0] = 1;
  dy2->size[1] = 1;
  emxEnsureCapacity_real32_T1(dy2, i27);
  for (i27 = 0; i27 <= loop_ub; i27++) {
    dy2->data[i27] = -0.5F * (dy2->data[i27] * xp1->data[i27] - 0.5F * xm1->
      data[i27] * ym1->data[i27]) * yp1->data[i27];
  }

  loop_ub = dx2->size[0] * dx2->size[1] * dx2->size[2] - 1;
  i27 = dx2->size[0] * dx2->size[1] * dx2->size[2];
  dx2->size[0] = 1;
  dx2->size[1] = 1;
  emxEnsureCapacity_real32_T1(dx2, i27);
  for (i27 = 0; i27 <= loop_ub; i27++) {
    dx2->data[i27] = -0.5F * (dx2->data[i27] * ym1->data[i27] - 0.5F * xm1->
      data[i27] * xp1->data[i27]) * yp1->data[i27];
  }

  emxFree_real32_T(&yp1);
  emxFree_real32_T(&ym1);
  emxFree_real32_T(&xp1);
  b_abs(dy2, xm1);
  tmp_size_idx_2 = xm1->size[2];
  loop_ub = xm1->size[0] * xm1->size[1] * xm1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    tmp_data[i27] = (xm1->data[i27] < 1.0F);
  }

  b_abs(dx2, xm1);
  loop_ub = xm1->size[0] * xm1->size[1] * xm1->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    b_tmp_data[i27] = (xm1->data[i27] < 1.0F);
  }

  emxFree_real32_T(&xm1);
  for (i = 0; i < tmp_size_idx_2; i++) {
    if (!(tmp_data[i] && b_tmp_data[i])) {
      dy2->data[i] = 0.0F;
    }
  }

  for (i = 0; i < tmp_size_idx_2; i++) {
    if (!(tmp_data[i] && b_tmp_data[i])) {
      dx2->data[i] = 0.0F;
    }
  }

  emxInit_real32_T2(&b_dy2, 3);
  i27 = b_dy2->size[0] * b_dy2->size[1] * b_dy2->size[2];
  b_dy2->size[0] = 2;
  b_dy2->size[1] = 1;
  b_dy2->size[2] = dy2->size[2];
  emxEnsureCapacity_real32_T1(b_dy2, i27);
  loop_ub = dy2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    b_dy2->data[b_dy2->size[0] * b_dy2->size[1] * i27] = dy2->data[dy2->size[0] *
      dy2->size[1] * i27];
  }

  emxFree_real32_T(&dy2);
  loop_ub = dx2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    b_dy2->data[1 + b_dy2->size[0] * b_dy2->size[1] * i27] = dx2->data[dx2->
      size[0] * dx2->size[1] * i27];
  }

  emxFree_real32_T(&dx2);
  i27 = subPixelLoc->size[0] * subPixelLoc->size[1] * subPixelLoc->size[2];
  subPixelLoc->size[0] = 2;
  subPixelLoc->size[1] = 1;
  subPixelLoc->size[2] = b_dy2->size[2];
  emxEnsureCapacity_real32_T1(subPixelLoc, i27);
  loop_ub = b_dy2->size[2];
  for (i27 = 0; i27 < loop_ub; i27++) {
    for (i = 0; i < 2; i++) {
      subPixelLoc->data[i + subPixelLoc->size[0] * subPixelLoc->size[1] * i27] =
        b_dy2->data[i + b_dy2->size[0] * b_dy2->size[1] * i27] + loc->data[i +
        loc->size[0] * loc->size[1] * i27];
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
  int i28;
  emxArray_real32_T *y;
  emxArray_real32_T *x1;
  emxArray_real32_T *b_y1;
  emxArray_real32_T *x2;
  emxArray_real32_T *y2;
  emxArray_int32_T *idx;
  unsigned char sz;
  unsigned char siz[2];
  unsigned char b_sz[2];
  emxArray_int32_T *b_idx;
  emxArray_int32_T *c_idx;
  emxArray_int32_T *d_idx;
  emxInit_real32_T1(&x, 1);
  loop_ub = loc->size[0];
  i28 = x->size[0];
  x->size[0] = loop_ub;
  emxEnsureCapacity_real32_T2(x, i28);
  for (i28 = 0; i28 < loop_ub; i28++) {
    x->data[i28] = loc->data[i28];
  }

  emxInit_real32_T1(&y, 1);
  loop_ub = loc->size[0];
  i28 = y->size[0];
  y->size[0] = loop_ub;
  emxEnsureCapacity_real32_T2(y, i28);
  for (i28 = 0; i28 < loop_ub; i28++) {
    y->data[i28] = loc->data[i28 + loc->size[0]];
  }

  emxInit_real32_T1(&x1, 1);
  i28 = x1->size[0];
  x1->size[0] = x->size[0];
  emxEnsureCapacity_real32_T2(x1, i28);
  loop_ub = x->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    x1->data[i28] = x->data[i28];
  }

  emxInit_real32_T1(&b_y1, 1);
  b_floor(x1);
  i28 = b_y1->size[0];
  b_y1->size[0] = y->size[0];
  emxEnsureCapacity_real32_T2(b_y1, i28);
  loop_ub = y->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    b_y1->data[i28] = y->data[i28];
  }

  emxInit_real32_T1(&x2, 1);
  b_floor(b_y1);
  i28 = x2->size[0];
  x2->size[0] = x1->size[0];
  emxEnsureCapacity_real32_T2(x2, i28);
  loop_ub = x1->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    x2->data[i28] = x1->data[i28] + 1.0F;
  }

  emxInit_real32_T1(&y2, 1);
  i28 = y2->size[0];
  y2->size[0] = b_y1->size[0];
  emxEnsureCapacity_real32_T2(y2, i28);
  loop_ub = b_y1->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    y2->data[i28] = b_y1->data[i28] + 1.0F;
  }

  for (i28 = 0; i28 < 2; i28++) {
    sz = (unsigned char)metric->size[i28];
    siz[i28] = sz;
    b_sz[i28] = sz;
  }

  emxInit_int32_T(&idx, 1);
  i28 = idx->size[0];
  idx->size[0] = b_y1->size[0];
  emxEnsureCapacity_int32_T(idx, i28);
  loop_ub = b_y1->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    idx->data[i28] = (int)b_y1->data[i28] + siz[0] * ((int)x1->data[i28] - 1);
  }

  for (i28 = 0; i28 < 2; i28++) {
    siz[i28] = b_sz[i28];
  }

  emxInit_int32_T(&b_idx, 1);
  i28 = b_idx->size[0];
  b_idx->size[0] = b_y1->size[0];
  emxEnsureCapacity_int32_T(b_idx, i28);
  loop_ub = b_y1->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    b_idx->data[i28] = (int)b_y1->data[i28] + siz[0] * ((int)x2->data[i28] - 1);
  }

  for (i28 = 0; i28 < 2; i28++) {
    siz[i28] = b_sz[i28];
  }

  emxInit_int32_T(&c_idx, 1);
  i28 = c_idx->size[0];
  c_idx->size[0] = y2->size[0];
  emxEnsureCapacity_int32_T(c_idx, i28);
  loop_ub = y2->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    c_idx->data[i28] = (int)y2->data[i28] + siz[0] * ((int)x1->data[i28] - 1);
  }

  for (i28 = 0; i28 < 2; i28++) {
    siz[i28] = b_sz[i28];
  }

  emxInit_int32_T(&d_idx, 1);
  i28 = d_idx->size[0];
  d_idx->size[0] = y2->size[0];
  emxEnsureCapacity_int32_T(d_idx, i28);
  loop_ub = y2->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    d_idx->data[i28] = (int)y2->data[i28] + siz[0] * ((int)x2->data[i28] - 1);
  }

  i28 = values->size[0];
  values->size[0] = idx->size[0];
  emxEnsureCapacity_real32_T2(values, i28);
  loop_ub = idx->size[0];
  for (i28 = 0; i28 < loop_ub; i28++) {
    values->data[i28] = ((metric->data[idx->data[i28] - 1] * (x2->data[i28] -
      x->data[i28]) * (y2->data[i28] - y->data[i28]) + metric->data[b_idx->
                          data[i28] - 1] * (x->data[i28] - x1->data[i28]) *
                          (y2->data[i28] - y->data[i28])) + metric->data
                         [c_idx->data[i28] - 1] * (x2->data[i28] - x->data[i28])
                         * (y->data[i28] - b_y1->data[i28])) + metric->
      data[d_idx->data[i28] - 1] * (x->data[i28] - x1->data[i28]) * (y->data[i28]
      - b_y1->data[i28]);
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
  emxArray_real32_T *A;
  emxArray_real32_T *r2;
  int i11;
  int loop_ub;
  emxArray_real32_T *B;
  emxArray_real32_T *r3;
  int b_A;
  int c_A;
  int i12;
  emxArray_real32_T *d_A;
  int i13;
  int b_loop_ub;
  emxArray_real32_T *b_B;
  emxArray_real32_T *C;
  emxArray_real32_T *r4;
  emxArray_real32_T *e_A;
  emxArray_real32_T *r5;
  emxArray_real32_T *r6;
  emxInit_real32_T(&A, 2);
  emxInit_real32_T(&r2, 2);
  imfilter(I, r2);
  i11 = A->size[0] * A->size[1];
  A->size[0] = r2->size[0];
  A->size[1] = r2->size[1];
  emxEnsureCapacity_real32_T(A, i11);
  loop_ub = r2->size[0] * r2->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    A->data[i11] = r2->data[i11];
  }

  emxFree_real32_T(&r2);
  emxInit_real32_T(&B, 2);
  emxInit_real32_T(&r3, 2);
  b_imfilter(I, r3);
  i11 = B->size[0] * B->size[1];
  B->size[0] = r3->size[0];
  B->size[1] = r3->size[1];
  emxEnsureCapacity_real32_T(B, i11);
  loop_ub = r3->size[0] * r3->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    B->data[i11] = r3->data[i11];
  }

  emxFree_real32_T(&r3);
  if (2 > A->size[0] - 1) {
    i11 = 0;
    b_A = 0;
  } else {
    i11 = 1;
    b_A = A->size[0] - 1;
  }

  if (2 > A->size[1] - 1) {
    c_A = 0;
    i12 = 0;
  } else {
    c_A = 1;
    i12 = A->size[1] - 1;
  }

  emxInit_real32_T(&d_A, 2);
  i13 = d_A->size[0] * d_A->size[1];
  d_A->size[0] = b_A - i11;
  d_A->size[1] = i12 - c_A;
  emxEnsureCapacity_real32_T(d_A, i13);
  loop_ub = i12 - c_A;
  for (i12 = 0; i12 < loop_ub; i12++) {
    b_loop_ub = b_A - i11;
    for (i13 = 0; i13 < b_loop_ub; i13++) {
      d_A->data[i13 + d_A->size[0] * i12] = A->data[(i11 + i13) + A->size[0] *
        (c_A + i12)];
    }
  }

  i11 = A->size[0] * A->size[1];
  A->size[0] = d_A->size[0];
  A->size[1] = d_A->size[1];
  emxEnsureCapacity_real32_T(A, i11);
  loop_ub = d_A->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    b_loop_ub = d_A->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      A->data[b_A + A->size[0] * i11] = d_A->data[b_A + d_A->size[0] * i11];
    }
  }

  if (2 > B->size[0] - 1) {
    i11 = 0;
    b_A = 0;
  } else {
    i11 = 1;
    b_A = B->size[0] - 1;
  }

  if (2 > B->size[1] - 1) {
    c_A = 0;
    i12 = 0;
  } else {
    c_A = 1;
    i12 = B->size[1] - 1;
  }

  emxInit_real32_T(&b_B, 2);
  i13 = b_B->size[0] * b_B->size[1];
  b_B->size[0] = b_A - i11;
  b_B->size[1] = i12 - c_A;
  emxEnsureCapacity_real32_T(b_B, i13);
  loop_ub = i12 - c_A;
  for (i12 = 0; i12 < loop_ub; i12++) {
    b_loop_ub = b_A - i11;
    for (i13 = 0; i13 < b_loop_ub; i13++) {
      b_B->data[i13 + b_B->size[0] * i12] = B->data[(i11 + i13) + B->size[0] *
        (c_A + i12)];
    }
  }

  i11 = B->size[0] * B->size[1];
  B->size[0] = b_B->size[0];
  B->size[1] = b_B->size[1];
  emxEnsureCapacity_real32_T(B, i11);
  loop_ub = b_B->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    b_loop_ub = b_B->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      B->data[b_A + B->size[0] * i11] = b_B->data[b_A + b_B->size[0] * i11];
    }
  }

  emxInit_real32_T(&C, 2);
  i11 = C->size[0] * C->size[1];
  C->size[0] = A->size[0];
  C->size[1] = A->size[1];
  emxEnsureCapacity_real32_T(C, i11);
  loop_ub = A->size[0] * A->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    C->data[i11] = A->data[i11] * B->data[i11];
  }

  loop_ub = A->size[0] * A->size[1] - 1;
  i11 = A->size[0] * A->size[1];
  emxEnsureCapacity_real32_T(A, i11);
  for (i11 = 0; i11 <= loop_ub; i11++) {
    A->data[i11] *= A->data[i11];
  }

  loop_ub = B->size[0] * B->size[1] - 1;
  i11 = B->size[0] * B->size[1];
  emxEnsureCapacity_real32_T(B, i11);
  for (i11 = 0; i11 <= loop_ub; i11++) {
    B->data[i11] *= B->data[i11];
  }

  emxInit_real32_T(&r4, 2);
  c_imfilter(A, r4);
  i11 = A->size[0] * A->size[1];
  A->size[0] = r4->size[0];
  A->size[1] = r4->size[1];
  emxEnsureCapacity_real32_T(A, i11);
  loop_ub = r4->size[0] * r4->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    A->data[i11] = r4->data[i11];
  }

  c_imfilter(B, r4);
  i11 = B->size[0] * B->size[1];
  B->size[0] = r4->size[0];
  B->size[1] = r4->size[1];
  emxEnsureCapacity_real32_T(B, i11);
  loop_ub = r4->size[0] * r4->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    B->data[i11] = r4->data[i11];
  }

  c_imfilter(C, r4);
  i11 = C->size[0] * C->size[1];
  C->size[0] = r4->size[0];
  C->size[1] = r4->size[1];
  emxEnsureCapacity_real32_T(C, i11);
  loop_ub = r4->size[0] * r4->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    C->data[i11] = r4->data[i11];
  }

  emxFree_real32_T(&r4);
  b_A = A->size[0] - 1;
  loop_ub = b_A - 2;
  c_A = A->size[1] - 1;
  b_loop_ub = c_A - 2;
  i11 = d_A->size[0] * d_A->size[1];
  d_A->size[0] = b_A - 1;
  d_A->size[1] = c_A - 1;
  emxEnsureCapacity_real32_T(d_A, i11);
  for (i11 = 0; i11 <= b_loop_ub; i11++) {
    for (b_A = 0; b_A <= loop_ub; b_A++) {
      d_A->data[b_A + d_A->size[0] * i11] = A->data[(b_A + A->size[0] * (1 + i11))
        + 1];
    }
  }

  i11 = A->size[0] * A->size[1];
  A->size[0] = d_A->size[0];
  A->size[1] = d_A->size[1];
  emxEnsureCapacity_real32_T(A, i11);
  loop_ub = d_A->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    b_loop_ub = d_A->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      A->data[b_A + A->size[0] * i11] = d_A->data[b_A + d_A->size[0] * i11];
    }
  }

  emxFree_real32_T(&d_A);
  b_A = B->size[0] - 1;
  loop_ub = b_A - 2;
  c_A = B->size[1] - 1;
  b_loop_ub = c_A - 2;
  i11 = b_B->size[0] * b_B->size[1];
  b_B->size[0] = b_A - 1;
  b_B->size[1] = c_A - 1;
  emxEnsureCapacity_real32_T(b_B, i11);
  for (i11 = 0; i11 <= b_loop_ub; i11++) {
    for (b_A = 0; b_A <= loop_ub; b_A++) {
      b_B->data[b_A + b_B->size[0] * i11] = B->data[(b_A + B->size[0] * (1 + i11))
        + 1];
    }
  }

  i11 = B->size[0] * B->size[1];
  B->size[0] = b_B->size[0];
  B->size[1] = b_B->size[1];
  emxEnsureCapacity_real32_T(B, i11);
  loop_ub = b_B->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    b_loop_ub = b_B->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      B->data[b_A + B->size[0] * i11] = b_B->data[b_A + b_B->size[0] * i11];
    }
  }

  b_A = C->size[0] - 1;
  loop_ub = b_A - 2;
  c_A = C->size[1] - 1;
  b_loop_ub = c_A - 2;
  i11 = b_B->size[0] * b_B->size[1];
  b_B->size[0] = b_A - 1;
  b_B->size[1] = c_A - 1;
  emxEnsureCapacity_real32_T(b_B, i11);
  for (i11 = 0; i11 <= b_loop_ub; i11++) {
    for (b_A = 0; b_A <= loop_ub; b_A++) {
      b_B->data[b_A + b_B->size[0] * i11] = C->data[(b_A + C->size[0] * (1 + i11))
        + 1];
    }
  }

  i11 = C->size[0] * C->size[1];
  C->size[0] = b_B->size[0];
  C->size[1] = b_B->size[1];
  emxEnsureCapacity_real32_T(C, i11);
  loop_ub = b_B->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    b_loop_ub = b_B->size[0];
    for (b_A = 0; b_A < b_loop_ub; b_A++) {
      C->data[b_A + C->size[0] * i11] = b_B->data[b_A + b_B->size[0] * i11];
    }
  }

  emxFree_real32_T(&b_B);
  emxInit_real32_T(&e_A, 2);
  i11 = e_A->size[0] * e_A->size[1];
  e_A->size[0] = A->size[0];
  e_A->size[1] = A->size[1];
  emxEnsureCapacity_real32_T(e_A, i11);
  loop_ub = A->size[0] * A->size[1];
  for (i11 = 0; i11 < loop_ub; i11++) {
    e_A->data[i11] = A->data[i11] - B->data[i11];
  }

  emxInit_real32_T(&r5, 2);
  emxInit_real32_T(&r6, 2);
  power(e_A, r5);
  power(C, r6);
  i11 = metric->size[0] * metric->size[1];
  metric->size[0] = r5->size[0];
  metric->size[1] = r5->size[1];
  emxEnsureCapacity_real32_T(metric, i11);
  loop_ub = r5->size[0] * r5->size[1];
  emxFree_real32_T(&e_A);
  emxFree_real32_T(&C);
  for (i11 = 0; i11 < loop_ub; i11++) {
    metric->data[i11] = r5->data[i11] + 4.0F * r6->data[i11];
  }

  emxFree_real32_T(&r6);
  emxFree_real32_T(&r5);
  b_sqrt(metric);
  loop_ub = A->size[0] * A->size[1] - 1;
  i11 = metric->size[0] * metric->size[1];
  metric->size[0] = A->size[0];
  metric->size[1] = A->size[1];
  emxEnsureCapacity_real32_T(metric, i11);
  for (i11 = 0; i11 <= loop_ub; i11++) {
    metric->data[i11] = ((A->data[i11] + B->data[i11]) - metric->data[i11]) /
      2.0F;
  }

  emxFree_real32_T(&B);
  emxFree_real32_T(&A);
}

/*
 * Arguments    : const double varargin_2_data[]
 *                float *params_MinQuality
 *                double *params_FilterSize
 *                boolean_T *params_usingROI
 *                int params_ROI_data[]
 *                int params_ROI_size[2]
 * Return Type  : void
 */
void parseInputs(const double varargin_2_data[], float *params_MinQuality,
                 double *params_FilterSize, boolean_T *params_usingROI, int
                 params_ROI_data[], int params_ROI_size[2])
{
  int i5;
  double d2;
  int i6;
  *params_MinQuality = 0.01F;
  *params_FilterSize = 5.0;
  *params_usingROI = true;
  params_ROI_size[0] = 1;
  params_ROI_size[1] = 4;
  for (i5 = 0; i5 < 4; i5++) {
    d2 = rt_roundd_snf(varargin_2_data[i5]);
    if (d2 < 2.147483648E+9) {
      if (d2 >= -2.147483648E+9) {
        i6 = (int)d2;
      } else {
        i6 = MIN_int32_T;
      }
    } else if (d2 >= 2.147483648E+9) {
      i6 = MAX_int32_T;
    } else {
      i6 = 0;
    }

    params_ROI_data[i5] = i6;
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
  int i44;
  int loop_ub;
  emxArray_real32_T *b_loc;
  int i45;
  int iv3[3];
  emxArray_real32_T b_x;
  unsigned short sqsz_idx_1;
  emxInit_real32_T(&x, 2);
  i44 = x->size[0] * x->size[1];
  x->size[0] = 2;
  x->size[1] = loc->size[0];
  emxEnsureCapacity_real32_T(x, i44);
  loop_ub = loc->size[0];
  for (i44 = 0; i44 < loop_ub; i44++) {
    for (i45 = 0; i45 < 2; i45++) {
      x->data[i45 + x->size[0] * i44] = loc->data[i44 + loc->size[0] * i45];
    }
  }

  emxInit_real32_T2(&b_loc, 3);
  iv3[0] = 2;
  iv3[1] = 1;
  iv3[2] = (x->size[1] << 1) / 2;
  b_x = *x;
  b_x.size = (int *)&iv3;
  b_x.numDimensions = 1;
  subPixelLocationImpl(metric, &b_x, b_loc);
  sqsz_idx_1 = 1U;
  emxFree_real32_T(&x);
  if (b_loc->size[2] != 1) {
    sqsz_idx_1 = (unsigned short)b_loc->size[2];
  }

  i44 = loc->size[0] * loc->size[1];
  loc->size[0] = sqsz_idx_1;
  loc->size[1] = 2;
  emxEnsureCapacity_real32_T(loc, i44);
  loop_ub = sqsz_idx_1;
  for (i44 = 0; i44 < 2; i44++) {
    for (i45 = 0; i45 < loop_ub; i45++) {
      loc->data[i45 + loc->size[0] * i44] = b_loc->data[i44 + (i45 << 1)];
    }
  }

  emxFree_real32_T(&b_loc);
}

/*
 * File trailer for harrisMinEigen.c
 *
 * [EOF]
 */

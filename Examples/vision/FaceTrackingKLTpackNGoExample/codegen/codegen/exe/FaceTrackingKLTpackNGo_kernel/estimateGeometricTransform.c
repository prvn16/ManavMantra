/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: estimateGeometricTransform.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include <string.h>
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "estimateGeometricTransform.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "any.h"
#include "det.h"
#include "svd1.h"
#include "MarkerInserter.h"
#include "normalizePoints.h"
#include "msac.h"
#include "FaceTrackingKLTpackNGo_kernel_rtwutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Declarations */
static void normalizePoints(const emxArray_real32_T *points, emxArray_real32_T
  *samples1, emxArray_real32_T *samples2, float normMatrix1[9], float
  normMatrix2[9]);
static float rt_hypotf_snf(float u0, float u1);

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *points
 *                emxArray_real32_T *samples1
 *                emxArray_real32_T *samples2
 *                float normMatrix1[9]
 *                float normMatrix2[9]
 * Return Type  : void
 */
static void normalizePoints(const emxArray_real32_T *points, emxArray_real32_T
  *samples1, emxArray_real32_T *samples2, float normMatrix1[9], float
  normMatrix2[9])
{
  emxArray_real32_T *b_points;
  int loop_ub;
  int b_loop_ub;
  int i29;
  emxArray_real32_T *b_samples1;
  int i30;
  emxArray_real32_T *b_samples2;
  emxArray_real32_T *c_samples1;
  emxInit_real32_T(&b_points, 2);
  loop_ub = points->size[0];
  b_loop_ub = points->size[1];
  i29 = b_points->size[0] * b_points->size[1];
  b_points->size[0] = b_loop_ub;
  b_points->size[1] = loop_ub;
  emxEnsureCapacity_real32_T(b_points, i29);
  for (i29 = 0; i29 < loop_ub; i29++) {
    for (i30 = 0; i30 < b_loop_ub; i30++) {
      b_points->data[i30 + b_points->size[0] * i29] = points->data[i29 +
        points->size[0] * i30];
    }
  }

  emxInit_real32_T(&b_samples1, 2);
  b_normalizePoints(b_points, b_samples1, normMatrix1);
  loop_ub = points->size[0];
  b_loop_ub = points->size[1];
  i29 = b_points->size[0] * b_points->size[1];
  b_points->size[0] = b_loop_ub;
  b_points->size[1] = loop_ub;
  emxEnsureCapacity_real32_T(b_points, i29);
  for (i29 = 0; i29 < loop_ub; i29++) {
    for (i30 = 0; i30 < b_loop_ub; i30++) {
      b_points->data[i30 + b_points->size[0] * i29] = points->data[(i29 +
        points->size[0] * i30) + points->size[0] * points->size[1]];
    }
  }

  emxInit_real32_T(&b_samples2, 2);
  emxInit_real32_T(&c_samples1, 2);
  b_normalizePoints(b_points, b_samples2, normMatrix2);
  i29 = c_samples1->size[0] * c_samples1->size[1];
  c_samples1->size[0] = b_samples1->size[1];
  c_samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(c_samples1, i29);
  emxFree_real32_T(&b_points);
  for (i29 = 0; i29 < 2; i29++) {
    loop_ub = b_samples1->size[1];
    for (i30 = 0; i30 < loop_ub; i30++) {
      c_samples1->data[i30 + c_samples1->size[0] * i29] = b_samples1->data[i29 +
        b_samples1->size[0] * i30];
    }
  }

  loop_ub = b_samples1->size[1];
  i29 = samples1->size[0] * samples1->size[1];
  samples1->size[0] = loop_ub;
  samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(samples1, i29);
  emxFree_real32_T(&b_samples1);
  for (i29 = 0; i29 < 2; i29++) {
    for (i30 = 0; i30 < loop_ub; i30++) {
      samples1->data[i30 + samples1->size[0] * i29] = c_samples1->data[i30 +
        loop_ub * i29];
    }
  }

  i29 = c_samples1->size[0] * c_samples1->size[1];
  c_samples1->size[0] = b_samples2->size[1];
  c_samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(c_samples1, i29);
  for (i29 = 0; i29 < 2; i29++) {
    loop_ub = b_samples2->size[1];
    for (i30 = 0; i30 < loop_ub; i30++) {
      c_samples1->data[i30 + c_samples1->size[0] * i29] = b_samples2->data[i29 +
        b_samples2->size[0] * i30];
    }
  }

  loop_ub = b_samples2->size[1];
  i29 = samples2->size[0] * samples2->size[1];
  samples2->size[0] = loop_ub;
  samples2->size[1] = 2;
  emxEnsureCapacity_real32_T(samples2, i29);
  emxFree_real32_T(&b_samples2);
  for (i29 = 0; i29 < 2; i29++) {
    for (i30 = 0; i30 < loop_ub; i30++) {
      samples2->data[i30 + samples2->size[0] * i29] = c_samples1->data[i30 +
        loop_ub * i29];
    }
  }

  emxFree_real32_T(&c_samples1);
}

/*
 * Arguments    : float u0
 *                float u1
 * Return Type  : float
 */
static float rt_hypotf_snf(float u0, float u1)
{
  float y;
  float a;
  float b;
  a = (float)fabs(u0);
  b = (float)fabs(u1);
  if (a < b) {
    a /= b;
    y = b * (float)sqrt(a * a + 1.0F);
  } else if (a > b) {
    b /= a;
    y = a * (float)sqrt(b * b + 1.0F);
  } else if (rtIsNaNF(b)) {
    y = b;
  } else {
    y = a * 1.41421354F;
  }

  return y;
}

/*
 * Arguments    : const float tform_data[]
 *                const int tform_size[2]
 * Return Type  : boolean_T
 */
boolean_T checkTForm(const float tform_data[], const int tform_size[2])
{
  boolean_T tf;
  int b_size_idx_0;
  int loop_ub;
  int i31;
  boolean_T b_data[9];
  boolean_T tmp_data[9];
  boolean_T exitg1;
  b_size_idx_0 = tform_size[0] * tform_size[1];
  loop_ub = tform_size[0] * tform_size[1];
  for (i31 = 0; i31 < loop_ub; i31++) {
    b_data[i31] = rtIsInfF(tform_data[i31]);
  }

  loop_ub = tform_size[0] * tform_size[1];
  for (i31 = 0; i31 < loop_ub; i31++) {
    tmp_data[i31] = rtIsNaNF(tform_data[i31]);
  }

  for (i31 = 0; i31 < b_size_idx_0; i31++) {
    b_data[i31] = ((!b_data[i31]) && (!tmp_data[i31]));
  }

  tf = true;
  loop_ub = 1;
  exitg1 = false;
  while ((!exitg1) && (loop_ub <= b_size_idx_0)) {
    if (!b_data[loop_ub - 1]) {
      tf = false;
      exitg1 = true;
    } else {
      loop_ub++;
    }
  }

  return tf;
}

/*
 * Arguments    : const emxArray_real32_T *points
 *                float T[9]
 * Return Type  : void
 */
void computeSimilarity(const emxArray_real32_T *points, float T[9])
{
  emxArray_real32_T *constraints;
  emxArray_real32_T *points1;
  emxArray_real32_T *points2;
  float normMatrix1[9];
  float normMatrix2[9];
  int i27;
  int r3;
  unsigned int u0;
  int nx;
  int points1_idx_0;
  int r1;
  int r2;
  int i28;
  emxArray_int32_T *r14;
  emxArray_real32_T *varargin_4;
  boolean_T empty_non_axis_sizes;
  emxArray_real32_T *b_points1;
  float s_data[5];
  int s_size[1];
  float V[25];
  static const signed char iv7[3] = { 0, 0, 1 };

  float maxval;
  float B[9];
  float a21;
  emxInit_real32_T(&constraints, 2);
  emxInit_real32_T(&points1, 2);
  emxInit_real32_T(&points2, 2);
  normalizePoints(points, points1, points2, normMatrix1, normMatrix2);
  i27 = constraints->size[0] * constraints->size[1];
  constraints->size[0] = (int)(2.0 * (double)points1->size[0]);
  constraints->size[1] = 5;
  emxEnsureCapacity_real32_T(constraints, i27);
  r3 = (int)(2.0 * (double)points1->size[0]) * 5;
  for (i27 = 0; i27 < r3; i27++) {
    constraints->data[i27] = 0.0F;
  }

  u0 = (unsigned int)points1->size[0] << 1;
  if (1U > u0) {
    i27 = 1;
  } else {
    i27 = 2;
  }

  r3 = points1->size[0] - 1;
  nx = points1->size[0] - 1;
  points1_idx_0 = points1->size[0];
  r1 = points1->size[0];
  r2 = points2->size[0] - 1;
  for (i28 = 0; i28 <= r3; i28++) {
    constraints->data[i27 * i28] = -points1->data[i28 + points1->size[0]];
  }

  for (i28 = 0; i28 <= nx; i28++) {
    constraints->data[i27 * i28 + constraints->size[0]] = points1->data[i28];
  }

  for (i28 = 0; i28 < points1_idx_0; i28++) {
    constraints->data[i27 * i28 + (constraints->size[0] << 1)] = 0.0F;
  }

  for (i28 = 0; i28 < r1; i28++) {
    constraints->data[i27 * i28 + constraints->size[0] * 3] = -1.0F;
  }

  for (i28 = 0; i28 <= r2; i28++) {
    constraints->data[i27 * i28 + (constraints->size[0] << 2)] = points2->
      data[i28 + points2->size[0]];
  }

  u0 = (unsigned int)points1->size[0] << 1;
  if (2U > u0) {
    i27 = 1;
    i28 = 1;
    points1_idx_0 = 0;
  } else {
    i27 = 2;
    i28 = 2;
    points1_idx_0 = (int)u0;
  }

  emxInit_int32_T(&r14, 1);
  nx = r14->size[0];
  r14->size[0] = div_s32_floor(points1_idx_0 - i27, i28) + 1;
  emxEnsureCapacity_int32_T(r14, nx);
  r3 = div_s32_floor(points1_idx_0 - i27, i28);
  for (points1_idx_0 = 0; points1_idx_0 <= r3; points1_idx_0++) {
    r14->data[points1_idx_0] = (i27 + i28 * points1_idx_0) - 1;
  }

  emxInit_real32_T1(&varargin_4, 1);
  r3 = points2->size[0];
  i27 = varargin_4->size[0];
  varargin_4->size[0] = r3;
  emxEnsureCapacity_real32_T2(varargin_4, i27);
  for (i27 = 0; i27 < r3; i27++) {
    varargin_4->data[i27] = -points2->data[i27];
  }

  emxFree_real32_T(&points2);
  if (!((points1->size[0] == 0) || (points1->size[1] == 0))) {
    nx = points1->size[0];
  } else if (!(points1->size[0] == 0)) {
    nx = points1->size[0];
  } else if (!(points1->size[0] == 0)) {
    nx = points1->size[0];
  } else if (!(varargin_4->size[0] == 0)) {
    nx = varargin_4->size[0];
  } else {
    nx = points1->size[0];
    if (!(nx > 0)) {
      nx = 0;
    }

    if (points1->size[0] > nx) {
      nx = points1->size[0];
    }

    if (points1->size[0] > nx) {
      nx = points1->size[0];
    }
  }

  empty_non_axis_sizes = (nx == 0);
  if (empty_non_axis_sizes || (!((points1->size[0] == 0) || (points1->size[1] ==
         0)))) {
    r1 = points1->size[1];
  } else {
    r1 = 0;
  }

  if (empty_non_axis_sizes || (!(points1->size[0] == 0))) {
    r2 = 1;
  } else {
    r2 = 0;
  }

  if (empty_non_axis_sizes || (!(points1->size[0] == 0))) {
    r3 = 1;
  } else {
    r3 = 0;
  }

  if (empty_non_axis_sizes || (!(varargin_4->size[0] == 0))) {
    points1_idx_0 = 1;
  } else {
    points1_idx_0 = 0;
  }

  emxInit_real32_T(&b_points1, 2);
  i27 = b_points1->size[0] * b_points1->size[1];
  b_points1->size[0] = nx;
  b_points1->size[1] = ((r1 + r2) + r3) + points1_idx_0;
  emxEnsureCapacity_real32_T(b_points1, i27);
  for (i27 = 0; i27 < r1; i27++) {
    for (i28 = 0; i28 < nx; i28++) {
      b_points1->data[i28 + b_points1->size[0] * i27] = points1->data[i28 + nx *
        i27];
    }
  }

  emxFree_real32_T(&points1);
  for (i27 = 0; i27 < r2; i27++) {
    for (i28 = 0; i28 < nx; i28++) {
      b_points1->data[i28 + b_points1->size[0] * (i27 + r1)] = 1.0F;
    }
  }

  for (i27 = 0; i27 < r3; i27++) {
    for (i28 = 0; i28 < nx; i28++) {
      b_points1->data[i28 + b_points1->size[0] * ((i27 + r1) + r2)] = 0.0F;
    }
  }

  for (i27 = 0; i27 < points1_idx_0; i27++) {
    for (i28 = 0; i28 < nx; i28++) {
      b_points1->data[i28 + b_points1->size[0] * (((i27 + r1) + r2) + r3)] =
        varargin_4->data[i28 + nx * i27];
    }
  }

  emxFree_real32_T(&varargin_4);
  nx = r14->size[0];
  for (i27 = 0; i27 < 5; i27++) {
    for (i28 = 0; i28 < nx; i28++) {
      constraints->data[r14->data[i28] + constraints->size[0] * i27] =
        b_points1->data[i28 + nx * i27];
    }
  }

  emxFree_int32_T(&r14);
  nx = constraints->size[0] * 5;
  empty_non_axis_sizes = true;
  for (points1_idx_0 = 0; points1_idx_0 < nx; points1_idx_0++) {
    if (empty_non_axis_sizes && ((!rtIsInfF(constraints->data[points1_idx_0])) &&
         (!rtIsNaNF(constraints->data[points1_idx_0])))) {
      empty_non_axis_sizes = true;
    } else {
      empty_non_axis_sizes = false;
    }
  }

  if (empty_non_axis_sizes) {
    svd(constraints, b_points1, s_data, s_size, V);
  } else {
    for (i27 = 0; i27 < 25; i27++) {
      V[i27] = ((real32_T)rtNaN);
    }
  }

  emxFree_real32_T(&b_points1);
  emxFree_real32_T(&constraints);
  T[3] = -V[21] / V[24];
  T[4] = V[20] / V[24];
  T[5] = V[23] / V[24];
  for (i27 = 0; i27 < 3; i27++) {
    T[i27] = V[20 + i27] / V[24];
    T[6 + i27] = iv7[i27];
    for (i28 = 0; i28 < 3; i28++) {
      B[i28 + 3 * i27] = normMatrix2[i27 + 3 * i28];
    }
  }

  r1 = 0;
  r2 = 1;
  r3 = 2;
  maxval = (float)fabs(B[0]);
  a21 = (float)fabs(B[1]);
  if (a21 > maxval) {
    maxval = a21;
    r1 = 1;
    r2 = 0;
  }

  if ((float)fabs(B[2]) > maxval) {
    r1 = 2;
    r2 = 1;
    r3 = 0;
  }

  B[r2] /= B[r1];
  B[r3] /= B[r1];
  B[3 + r2] -= B[r2] * B[3 + r1];
  B[3 + r3] -= B[r3] * B[3 + r1];
  B[6 + r2] -= B[r2] * B[6 + r1];
  B[6 + r3] -= B[r3] * B[6 + r1];
  if ((float)fabs(B[3 + r3]) > (float)fabs(B[3 + r2])) {
    nx = r2;
    r2 = r3;
    r3 = nx;
  }

  B[3 + r3] /= B[3 + r2];
  B[6 + r3] -= B[3 + r3] * B[6 + r2];
  for (points1_idx_0 = 0; points1_idx_0 < 3; points1_idx_0++) {
    normMatrix2[points1_idx_0 + 3 * r1] = T[points1_idx_0] / B[r1];
    normMatrix2[points1_idx_0 + 3 * r2] = T[3 + points1_idx_0] -
      normMatrix2[points1_idx_0 + 3 * r1] * B[3 + r1];
    normMatrix2[points1_idx_0 + 3 * r3] = T[6 + points1_idx_0] -
      normMatrix2[points1_idx_0 + 3 * r1] * B[6 + r1];
    normMatrix2[points1_idx_0 + 3 * r2] /= B[3 + r2];
    normMatrix2[points1_idx_0 + 3 * r3] -= normMatrix2[points1_idx_0 + 3 * r2] *
      B[6 + r2];
    normMatrix2[points1_idx_0 + 3 * r3] /= B[6 + r3];
    normMatrix2[points1_idx_0 + 3 * r2] -= normMatrix2[points1_idx_0 + 3 * r3] *
      B[3 + r3];
    normMatrix2[points1_idx_0 + 3 * r1] -= normMatrix2[points1_idx_0 + 3 * r3] *
      B[r3];
    normMatrix2[points1_idx_0 + 3 * r1] -= normMatrix2[points1_idx_0 + 3 * r2] *
      B[r2];
  }

  for (i27 = 0; i27 < 3; i27++) {
    for (i28 = 0; i28 < 3; i28++) {
      T[i27 + 3 * i28] = 0.0F;
      for (points1_idx_0 = 0; points1_idx_0 < 3; points1_idx_0++) {
        T[i27 + 3 * i28] += normMatrix1[points1_idx_0 + 3 * i27] *
          normMatrix2[points1_idx_0 + 3 * i28];
      }
    }
  }

  maxval = T[8];
  for (i27 = 0; i27 < 9; i27++) {
    T[i27] /= maxval;
  }
}

/*
 * Arguments    : const emxArray_real32_T *matchedPoints1
 *                const emxArray_real32_T *matchedPoints2
 *                float tform_T_data[]
 *                int tform_T_size[2]
 *                emxArray_real32_T *inlierPoints1
 *                emxArray_real32_T *inlierPoints2
 * Return Type  : void
 */
void estimateGeometricTransform(const emxArray_real32_T *matchedPoints1, const
  emxArray_real32_T *matchedPoints2, float tform_T_data[], int tform_T_size[2],
  emxArray_real32_T *inlierPoints1, emxArray_real32_T *inlierPoints2)
{
  int status;
  int i24;
  int iy;
  signed char failedMatrix[9];
  emxArray_boolean_T *inliers;
  emxArray_real32_T *points;
  unsigned int ysize_idx_0;
  unsigned int ysize_idx_1;
  int loop_ub;
  int tmatrix_size[2];
  float tmatrix_data[9];
  int j;
  emxArray_int32_T *r11;
  emxArray_boolean_T *b_inliers;
  boolean_T isFound;
  signed char varargin_1[2];
  float A_data[6];
  boolean_T p;
  boolean_T exitg1;
  emxArray_int32_T *r12;
  boolean_T guard1 = false;
  boolean_T tmp_data[9];
  int tmp_size[1];
  boolean_T b_tmp_data[9];
  static const signed char iv5[3] = { 0, 0, 1 };

  emxArray_boolean_T c_tmp_data;
  boolean_T d_tmp_data[9];
  status = (matchedPoints1->size[0] < 2);
  for (i24 = 0; i24 < 9; i24++) {
    failedMatrix[i24] = 0;
  }

  for (iy = 0; iy < 3; iy++) {
    failedMatrix[iy + 3 * iy] = 1;
  }

  emxInit_boolean_T1(&inliers, 2);
  if (status == 0) {
    emxInit_real32_T2(&points, 3);
    ysize_idx_0 = (unsigned int)matchedPoints1->size[0];
    ysize_idx_1 = (unsigned int)matchedPoints1->size[1];
    i24 = points->size[0] * points->size[1] * points->size[2];
    points->size[0] = (int)ysize_idx_0;
    points->size[1] = (int)ysize_idx_1;
    points->size[2] = 2;
    emxEnsureCapacity_real32_T1(points, i24);
    iy = -1;
    i24 = matchedPoints1->size[0] * matchedPoints1->size[1];
    for (j = 1; j <= i24; j++) {
      iy++;
      points->data[iy] = matchedPoints1->data[j - 1];
    }

    i24 = matchedPoints2->size[0] << 1;
    for (j = 1; j <= i24; j++) {
      iy++;
      points->data[iy] = matchedPoints2->data[j - 1];
    }

    emxInit_boolean_T(&b_inliers, 1);
    msac(points, &isFound, tmatrix_data, tmatrix_size, b_inliers);
    i24 = inliers->size[0] * inliers->size[1];
    inliers->size[0] = b_inliers->size[0];
    inliers->size[1] = 1;
    emxEnsureCapacity_boolean_T(inliers, i24);
    loop_ub = b_inliers->size[0];
    emxFree_real32_T(&points);
    for (i24 = 0; i24 < loop_ub; i24++) {
      inliers->data[i24] = b_inliers->data[i24];
    }

    emxFree_boolean_T(&b_inliers);
    if (!isFound) {
      status = 2;
    }

    isFound = false;
    p = true;
    if (!(det(tmatrix_data, tmatrix_size) == 0.0F)) {
      p = false;
    }

    if (p) {
      isFound = true;
    }

    guard1 = false;
    if (isFound) {
      guard1 = true;
    } else {
      iy = tmatrix_size[0] * tmatrix_size[1];
      loop_ub = tmatrix_size[0] * tmatrix_size[1];
      for (i24 = 0; i24 < loop_ub; i24++) {
        tmp_data[i24] = rtIsInfF(tmatrix_data[i24]);
      }

      loop_ub = tmatrix_size[0] * tmatrix_size[1];
      for (i24 = 0; i24 < loop_ub; i24++) {
        b_tmp_data[i24] = rtIsNaNF(tmatrix_data[i24]);
      }

      tmp_size[0] = iy;
      for (i24 = 0; i24 < iy; i24++) {
        d_tmp_data[i24] = !((!tmp_data[i24]) && (!b_tmp_data[i24]));
      }

      c_tmp_data.data = (boolean_T *)&d_tmp_data;
      c_tmp_data.size = (int *)&tmp_size;
      c_tmp_data.allocatedSize = 9;
      c_tmp_data.numDimensions = 1;
      c_tmp_data.canFreeData = false;
      if (any(&c_tmp_data)) {
        guard1 = true;
      }
    }

    if (guard1) {
      status = 2;
      tmatrix_size[0] = 3;
      for (i24 = 0; i24 < 9; i24++) {
        tmatrix_data[i24] = failedMatrix[i24];
      }
    }
  } else {
    i24 = inliers->size[0] * inliers->size[1];
    inliers->size[0] = matchedPoints1->size[0];
    inliers->size[1] = matchedPoints1->size[0];
    emxEnsureCapacity_boolean_T(inliers, i24);
    loop_ub = matchedPoints1->size[0] * matchedPoints1->size[0];
    for (i24 = 0; i24 < loop_ub; i24++) {
      inliers->data[i24] = false;
    }

    tmatrix_size[0] = 3;
    for (i24 = 0; i24 < 9; i24++) {
      tmatrix_data[i24] = failedMatrix[i24];
    }
  }

  if (status == 0) {
    status = inliers->size[0] * inliers->size[1] - 1;
    iy = 0;
    for (j = 0; j <= status; j++) {
      if (inliers->data[j]) {
        iy++;
      }
    }

    emxInit_int32_T(&r11, 1);
    i24 = r11->size[0];
    r11->size[0] = iy;
    emxEnsureCapacity_int32_T(r11, i24);
    iy = 0;
    for (j = 0; j <= status; j++) {
      if (inliers->data[j]) {
        r11->data[iy] = j + 1;
        iy++;
      }
    }

    loop_ub = matchedPoints1->size[1];
    i24 = inlierPoints1->size[0] * inlierPoints1->size[1];
    inlierPoints1->size[0] = r11->size[0];
    inlierPoints1->size[1] = loop_ub;
    emxEnsureCapacity_real32_T(inlierPoints1, i24);
    for (i24 = 0; i24 < loop_ub; i24++) {
      iy = r11->size[0];
      for (j = 0; j < iy; j++) {
        inlierPoints1->data[j + inlierPoints1->size[0] * i24] =
          matchedPoints1->data[(r11->data[j] + matchedPoints1->size[0] * i24) -
          1];
      }
    }

    emxFree_int32_T(&r11);
    status = inliers->size[0] * inliers->size[1] - 1;
    iy = 0;
    for (j = 0; j <= status; j++) {
      if (inliers->data[j]) {
        iy++;
      }
    }

    emxInit_int32_T(&r12, 1);
    i24 = r12->size[0];
    r12->size[0] = iy;
    emxEnsureCapacity_int32_T(r12, i24);
    iy = 0;
    for (j = 0; j <= status; j++) {
      if (inliers->data[j]) {
        r12->data[iy] = j + 1;
        iy++;
      }
    }

    i24 = inlierPoints2->size[0] * inlierPoints2->size[1];
    inlierPoints2->size[0] = r12->size[0];
    inlierPoints2->size[1] = 2;
    emxEnsureCapacity_real32_T(inlierPoints2, i24);
    for (i24 = 0; i24 < 2; i24++) {
      loop_ub = r12->size[0];
      for (j = 0; j < loop_ub; j++) {
        inlierPoints2->data[j + inlierPoints2->size[0] * i24] =
          matchedPoints2->data[(r12->data[j] + matchedPoints2->size[0] * i24) -
          1];
      }
    }

    emxFree_int32_T(&r12);
  } else {
    i24 = inlierPoints1->size[0] * inlierPoints1->size[1];
    inlierPoints1->size[0] = 0;
    inlierPoints1->size[1] = 0;
    emxEnsureCapacity_real32_T(inlierPoints1, i24);
    i24 = inlierPoints2->size[0] * inlierPoints2->size[1];
    inlierPoints2->size[0] = 0;
    inlierPoints2->size[1] = 0;
    emxEnsureCapacity_real32_T(inlierPoints2, i24);
    tmatrix_size[0] = 3;
    for (i24 = 0; i24 < 9; i24++) {
      tmatrix_data[i24] = failedMatrix[i24];
    }
  }

  emxFree_boolean_T(&inliers);
  loop_ub = tmatrix_size[0];
  for (i24 = 0; i24 < 2; i24++) {
    for (j = 0; j < loop_ub; j++) {
      A_data[j + loop_ub * i24] = tmatrix_data[j + tmatrix_size[0] * i24];
    }
  }

  varargin_1[0] = (signed char)tmatrix_size[0];
  varargin_1[1] = 2;
  isFound = false;
  p = true;
  iy = 0;
  exitg1 = false;
  while ((!exitg1) && (iy < 2)) {
    if (!(varargin_1[iy] == 3 - iy)) {
      p = false;
      exitg1 = true;
    } else {
      iy++;
    }
  }

  if (p) {
    isFound = true;
  }

  if (isFound) {
    if (!(tmatrix_size[0] == 0)) {
      iy = 2;
    } else {
      iy = 0;
    }

    tmatrix_size[0] = 3;
    tmatrix_size[1] = iy + 1;
    for (i24 = 0; i24 < iy; i24++) {
      for (j = 0; j < 3; j++) {
        tmatrix_data[j + 3 * i24] = A_data[j + 3 * i24];
      }
    }

    for (i24 = 0; i24 < 3; i24++) {
      tmatrix_data[i24 + 3 * iy] = iv5[i24];
    }
  } else {
    tmatrix_size[1] = 2;
    loop_ub <<= 1;
    if (0 <= loop_ub - 1) {
      memcpy(&tmatrix_data[0], &A_data[0], (unsigned int)(loop_ub * (int)sizeof
              (float)));
    }
  }

  tform_T_size[0] = tmatrix_size[0];
  tform_T_size[1] = tmatrix_size[1];
  loop_ub = tmatrix_size[0] * tmatrix_size[1];
  for (i24 = 0; i24 < loop_ub; i24++) {
    tform_T_data[i24] = tmatrix_data[i24];
  }
}

/*
 * Arguments    : const float tform[9]
 *                const emxArray_real32_T *points
 *                emxArray_real32_T *dis
 * Return Type  : void
 */
void evaluateTForm(const float tform[9], const emxArray_real32_T *points,
                   emxArray_real32_T *dis)
{
  int i;
  int coffset;
  int boffset;
  boolean_T empty_non_axis_sizes;
  int aoffset;
  int result;
  cell_wrap_59 reshapes[2];
  int m;
  emxArray_real32_T *b_points;
  int inner;
  emxArray_real32_T *pt1h;
  emxArray_real32_T *b_pt1h;
  emxArray_real32_T *w;
  int k;
  emxArray_real32_T *b_w;
  emxArray_real32_T *delta;
  int exitg1;
  emxArray_boolean_T *r15;
  emxArray_int32_T *r16;
  i = points->size[0];
  coffset = points->size[1];
  if (!((i == 0) || (coffset == 0))) {
    boffset = points->size[0];
  } else {
    i = points->size[0];
    if (!(i == 0)) {
      boffset = points->size[0];
    } else {
      i = points->size[0];
      if (i > 0) {
        boffset = points->size[0];
      } else {
        boffset = 0;
      }

      i = points->size[0];
      if (i > boffset) {
        boffset = points->size[0];
      }
    }
  }

  empty_non_axis_sizes = (boffset == 0);
  if (empty_non_axis_sizes) {
    aoffset = points->size[1];
  } else {
    i = points->size[0];
    coffset = points->size[1];
    if (!((i == 0) || (coffset == 0))) {
      aoffset = points->size[1];
    } else {
      aoffset = 0;
    }
  }

  if (empty_non_axis_sizes) {
    result = 1;
  } else {
    i = points->size[0];
    if (!(i == 0)) {
      result = 1;
    } else {
      result = 0;
    }
  }

  emxInitMatrix_cell_wrap_59(reshapes);
  i = reshapes[1].f1->size[0] * reshapes[1].f1->size[1];
  reshapes[1].f1->size[0] = boffset;
  reshapes[1].f1->size[1] = result;
  emxEnsureCapacity_real32_T(reshapes[1].f1, i);
  m = boffset * result;
  for (i = 0; i < m; i++) {
    reshapes[1].f1->data[i] = 1.0F;
  }

  emxInit_real32_T(&b_points, 2);
  m = points->size[0];
  inner = points->size[1];
  i = b_points->size[0] * b_points->size[1];
  b_points->size[0] = m;
  b_points->size[1] = inner;
  emxEnsureCapacity_real32_T(b_points, i);
  for (i = 0; i < inner; i++) {
    for (coffset = 0; coffset < m; coffset++) {
      b_points->data[coffset + b_points->size[0] * i] = points->data[coffset +
        points->size[0] * i];
    }
  }

  emxInit_real32_T(&pt1h, 2);
  i = pt1h->size[0] * pt1h->size[1];
  pt1h->size[0] = boffset;
  pt1h->size[1] = aoffset + reshapes[1].f1->size[1];
  emxEnsureCapacity_real32_T(pt1h, i);
  for (i = 0; i < aoffset; i++) {
    for (coffset = 0; coffset < boffset; coffset++) {
      pt1h->data[coffset + pt1h->size[0] * i] = b_points->data[coffset + boffset
        * i];
    }
  }

  emxFree_real32_T(&b_points);
  m = reshapes[1].f1->size[1];
  for (i = 0; i < m; i++) {
    inner = reshapes[1].f1->size[0];
    for (coffset = 0; coffset < inner; coffset++) {
      pt1h->data[coffset + pt1h->size[0] * (i + aoffset)] = reshapes[1].f1->
        data[coffset + reshapes[1].f1->size[0] * i];
    }
  }

  emxFreeMatrix_cell_wrap_59(reshapes);
  emxInit_real32_T(&b_pt1h, 2);
  if (pt1h->size[1] == 1) {
    i = b_pt1h->size[0] * b_pt1h->size[1];
    b_pt1h->size[0] = pt1h->size[0];
    b_pt1h->size[1] = 3;
    emxEnsureCapacity_real32_T(b_pt1h, i);
    m = pt1h->size[0];
    for (i = 0; i < m; i++) {
      for (coffset = 0; coffset < 3; coffset++) {
        b_pt1h->data[i + b_pt1h->size[0] * coffset] = 0.0F;
        inner = pt1h->size[1];
        for (result = 0; result < inner; result++) {
          b_pt1h->data[i + b_pt1h->size[0] * coffset] += pt1h->data[i +
            pt1h->size[0] * result] * tform[result + 3 * coffset];
        }
      }
    }
  } else {
    m = pt1h->size[0];
    inner = pt1h->size[1];
    i = b_pt1h->size[0] * b_pt1h->size[1];
    b_pt1h->size[0] = pt1h->size[0];
    b_pt1h->size[1] = 3;
    emxEnsureCapacity_real32_T(b_pt1h, i);
    for (result = 0; result < 3; result++) {
      coffset = result * m - 1;
      boffset = result * inner - 1;
      for (i = 1; i <= m; i++) {
        b_pt1h->data[coffset + i] = 0.0F;
      }

      for (k = 1; k <= inner; k++) {
        if (tform[boffset + k] != 0.0F) {
          aoffset = (k - 1) * m;
          for (i = 1; i <= m; i++) {
            b_pt1h->data[coffset + i] += tform[boffset + k] * pt1h->data
              [(aoffset + i) - 1];
          }
        }
      }
    }
  }

  emxFree_real32_T(&pt1h);
  emxInit_real32_T1(&w, 1);
  m = b_pt1h->size[0];
  i = w->size[0];
  w->size[0] = m;
  emxEnsureCapacity_real32_T2(w, i);
  for (i = 0; i < m; i++) {
    w->data[i] = b_pt1h->data[i + (b_pt1h->size[0] << 1)];
  }

  emxInit_real32_T(&b_w, 2);
  m = b_pt1h->size[0];
  i = b_w->size[0] * b_w->size[1];
  b_w->size[0] = w->size[0];
  b_w->size[1] = 2;
  emxEnsureCapacity_real32_T(b_w, i);
  inner = w->size[0];
  for (i = 0; i < inner; i++) {
    b_w->data[i] = w->data[i];
  }

  inner = w->size[0];
  for (i = 0; i < inner; i++) {
    b_w->data[i + b_w->size[0]] = w->data[i];
  }

  emxInit_real32_T(&delta, 2);
  i = delta->size[0] * delta->size[1];
  delta->size[0] = m;
  delta->size[1] = 2;
  emxEnsureCapacity_real32_T(delta, i);
  for (i = 0; i < 2; i++) {
    for (coffset = 0; coffset < m; coffset++) {
      delta->data[coffset + delta->size[0] * i] = b_pt1h->data[coffset +
        b_pt1h->size[0] * i] / b_w->data[coffset + b_w->size[0] * i] -
        points->data[(coffset + points->size[0] * i) + points->size[0] *
        points->size[1]];
    }
  }

  emxFree_real32_T(&b_w);
  result = delta->size[0];
  i = dis->size[0];
  dis->size[0] = result;
  emxEnsureCapacity_real32_T2(dis, i);
  for (k = 0; k < result; k++) {
    dis->data[k] = rt_hypotf_snf(delta->data[k], delta->data[k + delta->size[0]]);
  }

  emxFree_real32_T(&delta);
  i = b_pt1h->size[0];
  coffset = w->size[0];
  w->size[0] = i;
  emxEnsureCapacity_real32_T2(w, coffset);
  k = 0;
  do {
    exitg1 = 0;
    i = b_pt1h->size[0];
    if (k + 1 <= i) {
      w->data[k] = (float)fabs(b_pt1h->data[k + (b_pt1h->size[0] << 1)]);
      k++;
    } else {
      exitg1 = 1;
    }
  } while (exitg1 == 0);

  emxFree_real32_T(&b_pt1h);
  emxInit_boolean_T(&r15, 1);
  i = r15->size[0];
  r15->size[0] = w->size[0];
  emxEnsureCapacity_boolean_T2(r15, i);
  m = w->size[0];
  for (i = 0; i < m; i++) {
    r15->data[i] = (w->data[i] < 1.1920929E-7F);
  }

  emxFree_real32_T(&w);
  coffset = r15->size[0] - 1;
  result = 0;
  for (i = 0; i <= coffset; i++) {
    if (r15->data[i]) {
      result++;
    }
  }

  emxInit_int32_T(&r16, 1);
  i = r16->size[0];
  r16->size[0] = result;
  emxEnsureCapacity_int32_T(r16, i);
  result = 0;
  for (i = 0; i <= coffset; i++) {
    if (r15->data[i]) {
      r16->data[result] = i + 1;
      result++;
    }
  }

  emxFree_boolean_T(&r15);
  m = r16->size[0];
  for (i = 0; i < m; i++) {
    dis->data[r16->data[i] - 1] = ((real32_T)rtInf);
  }

  emxFree_int32_T(&r16);
}

/*
 * File trailer for estimateGeometricTransform.c
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: estimateGeometricTransform.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include <string.h>
#include "faceTrackingARMKernel.h"
#include "estimateGeometricTransform.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "any.h"
#include "det.h"
#include "svd1.h"
#include "MarkerInserter.h"
#include "normalizePoints.h"
#include "msac.h"
#include "faceTrackingARMKernel_rtwutil.h"

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
  int i38;
  emxArray_real32_T *b_samples1;
  int i39;
  emxArray_real32_T *b_samples2;
  emxArray_real32_T *c_samples1;
  emxInit_real32_T(&b_points, 2);
  loop_ub = points->size[0];
  b_loop_ub = points->size[1];
  i38 = b_points->size[0] * b_points->size[1];
  b_points->size[0] = b_loop_ub;
  b_points->size[1] = loop_ub;
  emxEnsureCapacity_real32_T(b_points, i38);
  for (i38 = 0; i38 < loop_ub; i38++) {
    for (i39 = 0; i39 < b_loop_ub; i39++) {
      b_points->data[i39 + b_points->size[0] * i38] = points->data[i38 +
        points->size[0] * i39];
    }
  }

  emxInit_real32_T(&b_samples1, 2);
  b_normalizePoints(b_points, b_samples1, normMatrix1);
  loop_ub = points->size[0];
  b_loop_ub = points->size[1];
  i38 = b_points->size[0] * b_points->size[1];
  b_points->size[0] = b_loop_ub;
  b_points->size[1] = loop_ub;
  emxEnsureCapacity_real32_T(b_points, i38);
  for (i38 = 0; i38 < loop_ub; i38++) {
    for (i39 = 0; i39 < b_loop_ub; i39++) {
      b_points->data[i39 + b_points->size[0] * i38] = points->data[(i38 +
        points->size[0] * i39) + points->size[0] * points->size[1]];
    }
  }

  emxInit_real32_T(&b_samples2, 2);
  emxInit_real32_T(&c_samples1, 2);
  b_normalizePoints(b_points, b_samples2, normMatrix2);
  i38 = c_samples1->size[0] * c_samples1->size[1];
  c_samples1->size[0] = b_samples1->size[1];
  c_samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(c_samples1, i38);
  emxFree_real32_T(&b_points);
  for (i38 = 0; i38 < 2; i38++) {
    loop_ub = b_samples1->size[1];
    for (i39 = 0; i39 < loop_ub; i39++) {
      c_samples1->data[i39 + c_samples1->size[0] * i38] = b_samples1->data[i38 +
        b_samples1->size[0] * i39];
    }
  }

  loop_ub = b_samples1->size[1];
  i38 = samples1->size[0] * samples1->size[1];
  samples1->size[0] = loop_ub;
  samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(samples1, i38);
  emxFree_real32_T(&b_samples1);
  for (i38 = 0; i38 < 2; i38++) {
    for (i39 = 0; i39 < loop_ub; i39++) {
      samples1->data[i39 + samples1->size[0] * i38] = c_samples1->data[i39 +
        loop_ub * i38];
    }
  }

  i38 = c_samples1->size[0] * c_samples1->size[1];
  c_samples1->size[0] = b_samples2->size[1];
  c_samples1->size[1] = 2;
  emxEnsureCapacity_real32_T(c_samples1, i38);
  for (i38 = 0; i38 < 2; i38++) {
    loop_ub = b_samples2->size[1];
    for (i39 = 0; i39 < loop_ub; i39++) {
      c_samples1->data[i39 + c_samples1->size[0] * i38] = b_samples2->data[i38 +
        b_samples2->size[0] * i39];
    }
  }

  loop_ub = b_samples2->size[1];
  i38 = samples2->size[0] * samples2->size[1];
  samples2->size[0] = loop_ub;
  samples2->size[1] = 2;
  emxEnsureCapacity_real32_T(samples2, i38);
  emxFree_real32_T(&b_samples2);
  for (i38 = 0; i38 < 2; i38++) {
    for (i39 = 0; i39 < loop_ub; i39++) {
      samples2->data[i39 + samples2->size[0] * i38] = c_samples1->data[i39 +
        loop_ub * i38];
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
  int i40;
  boolean_T b_data[9];
  boolean_T tmp_data[9];
  boolean_T exitg1;
  b_size_idx_0 = tform_size[0] * tform_size[1];
  loop_ub = tform_size[0] * tform_size[1];
  for (i40 = 0; i40 < loop_ub; i40++) {
    b_data[i40] = rtIsInfF(tform_data[i40]);
  }

  loop_ub = tform_size[0] * tform_size[1];
  for (i40 = 0; i40 < loop_ub; i40++) {
    tmp_data[i40] = rtIsNaNF(tform_data[i40]);
  }

  for (i40 = 0; i40 < b_size_idx_0; i40++) {
    b_data[i40] = ((!b_data[i40]) && (!tmp_data[i40]));
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
  int i36;
  int r3;
  unsigned int u1;
  int nx;
  int points1_idx_0;
  int r1;
  int r2;
  int i37;
  emxArray_int32_T *r14;
  emxArray_real32_T *varargin_4;
  boolean_T empty_non_axis_sizes;
  emxArray_real32_T *b_points1;
  float s_data[5];
  int s_size[1];
  float V[25];
  static const signed char iv2[3] = { 0, 0, 1 };

  float maxval;
  float B[9];
  float a21;
  emxInit_real32_T(&constraints, 2);
  emxInit_real32_T(&points1, 2);
  emxInit_real32_T(&points2, 2);
  normalizePoints(points, points1, points2, normMatrix1, normMatrix2);
  i36 = constraints->size[0] * constraints->size[1];
  constraints->size[0] = (int)(2.0 * (double)points1->size[0]);
  constraints->size[1] = 5;
  emxEnsureCapacity_real32_T(constraints, i36);
  r3 = (int)(2.0 * (double)points1->size[0]) * 5;
  for (i36 = 0; i36 < r3; i36++) {
    constraints->data[i36] = 0.0F;
  }

  u1 = (unsigned int)points1->size[0] << 1;
  if (1U > u1) {
    i36 = 1;
  } else {
    i36 = 2;
  }

  r3 = points1->size[0] - 1;
  nx = points1->size[0] - 1;
  points1_idx_0 = points1->size[0];
  r1 = points1->size[0];
  r2 = points2->size[0] - 1;
  for (i37 = 0; i37 <= r3; i37++) {
    constraints->data[i36 * i37] = -points1->data[i37 + points1->size[0]];
  }

  for (i37 = 0; i37 <= nx; i37++) {
    constraints->data[i36 * i37 + constraints->size[0]] = points1->data[i37];
  }

  for (i37 = 0; i37 < points1_idx_0; i37++) {
    constraints->data[i36 * i37 + (constraints->size[0] << 1)] = 0.0F;
  }

  for (i37 = 0; i37 < r1; i37++) {
    constraints->data[i36 * i37 + constraints->size[0] * 3] = -1.0F;
  }

  for (i37 = 0; i37 <= r2; i37++) {
    constraints->data[i36 * i37 + (constraints->size[0] << 2)] = points2->
      data[i37 + points2->size[0]];
  }

  u1 = (unsigned int)points1->size[0] << 1;
  if (2U > u1) {
    i36 = 1;
    i37 = 1;
    points1_idx_0 = 0;
  } else {
    i36 = 2;
    i37 = 2;
    points1_idx_0 = (int)u1;
  }

  emxInit_int32_T(&r14, 1);
  nx = r14->size[0];
  r14->size[0] = div_s32_floor(points1_idx_0 - i36, i37) + 1;
  emxEnsureCapacity_int32_T(r14, nx);
  r3 = div_s32_floor(points1_idx_0 - i36, i37);
  for (points1_idx_0 = 0; points1_idx_0 <= r3; points1_idx_0++) {
    r14->data[points1_idx_0] = (i36 + i37 * points1_idx_0) - 1;
  }

  emxInit_real32_T1(&varargin_4, 1);
  r3 = points2->size[0];
  i36 = varargin_4->size[0];
  varargin_4->size[0] = r3;
  emxEnsureCapacity_real32_T2(varargin_4, i36);
  for (i36 = 0; i36 < r3; i36++) {
    varargin_4->data[i36] = -points2->data[i36];
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
  i36 = b_points1->size[0] * b_points1->size[1];
  b_points1->size[0] = nx;
  b_points1->size[1] = ((r1 + r2) + r3) + points1_idx_0;
  emxEnsureCapacity_real32_T(b_points1, i36);
  for (i36 = 0; i36 < r1; i36++) {
    for (i37 = 0; i37 < nx; i37++) {
      b_points1->data[i37 + b_points1->size[0] * i36] = points1->data[i37 + nx *
        i36];
    }
  }

  emxFree_real32_T(&points1);
  for (i36 = 0; i36 < r2; i36++) {
    for (i37 = 0; i37 < nx; i37++) {
      b_points1->data[i37 + b_points1->size[0] * (i36 + r1)] = 1.0F;
    }
  }

  for (i36 = 0; i36 < r3; i36++) {
    for (i37 = 0; i37 < nx; i37++) {
      b_points1->data[i37 + b_points1->size[0] * ((i36 + r1) + r2)] = 0.0F;
    }
  }

  for (i36 = 0; i36 < points1_idx_0; i36++) {
    for (i37 = 0; i37 < nx; i37++) {
      b_points1->data[i37 + b_points1->size[0] * (((i36 + r1) + r2) + r3)] =
        varargin_4->data[i37 + nx * i36];
    }
  }

  emxFree_real32_T(&varargin_4);
  nx = r14->size[0];
  for (i36 = 0; i36 < 5; i36++) {
    for (i37 = 0; i37 < nx; i37++) {
      constraints->data[r14->data[i37] + constraints->size[0] * i36] =
        b_points1->data[i37 + nx * i36];
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
    for (i36 = 0; i36 < 25; i36++) {
      V[i36] = ((real32_T)rtNaN);
    }
  }

  emxFree_real32_T(&b_points1);
  emxFree_real32_T(&constraints);
  T[3] = -V[21] / V[24];
  T[4] = V[20] / V[24];
  T[5] = V[23] / V[24];
  for (i36 = 0; i36 < 3; i36++) {
    T[i36] = V[20 + i36] / V[24];
    T[6 + i36] = iv2[i36];
    for (i37 = 0; i37 < 3; i37++) {
      B[i37 + 3 * i36] = normMatrix2[i36 + 3 * i37];
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

  for (i36 = 0; i36 < 3; i36++) {
    for (i37 = 0; i37 < 3; i37++) {
      T[i36 + 3 * i37] = 0.0F;
      for (points1_idx_0 = 0; points1_idx_0 < 3; points1_idx_0++) {
        T[i36 + 3 * i37] += normMatrix1[points1_idx_0 + 3 * i36] *
          normMatrix2[points1_idx_0 + 3 * i37];
      }
    }
  }

  maxval = T[8];
  for (i36 = 0; i36 < 9; i36++) {
    T[i36] /= maxval;
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
  int i33;
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
  static const signed char iv0[3] = { 0, 0, 1 };

  emxArray_boolean_T c_tmp_data;
  boolean_T d_tmp_data[9];
  status = (matchedPoints1->size[0] < 2);
  for (i33 = 0; i33 < 9; i33++) {
    failedMatrix[i33] = 0;
  }

  for (iy = 0; iy < 3; iy++) {
    failedMatrix[iy + 3 * iy] = 1;
  }

  emxInit_boolean_T1(&inliers, 2);
  if (status == 0) {
    emxInit_real32_T2(&points, 3);
    ysize_idx_0 = (unsigned int)matchedPoints1->size[0];
    ysize_idx_1 = (unsigned int)matchedPoints1->size[1];
    i33 = points->size[0] * points->size[1] * points->size[2];
    points->size[0] = (int)ysize_idx_0;
    points->size[1] = (int)ysize_idx_1;
    points->size[2] = 2;
    emxEnsureCapacity_real32_T1(points, i33);
    iy = -1;
    i33 = matchedPoints1->size[0] * matchedPoints1->size[1];
    for (j = 1; j <= i33; j++) {
      iy++;
      points->data[iy] = matchedPoints1->data[j - 1];
    }

    i33 = matchedPoints2->size[0] << 1;
    for (j = 1; j <= i33; j++) {
      iy++;
      points->data[iy] = matchedPoints2->data[j - 1];
    }

    emxInit_boolean_T(&b_inliers, 1);
    msac(points, &isFound, tmatrix_data, tmatrix_size, b_inliers);
    i33 = inliers->size[0] * inliers->size[1];
    inliers->size[0] = b_inliers->size[0];
    inliers->size[1] = 1;
    emxEnsureCapacity_boolean_T1(inliers, i33);
    loop_ub = b_inliers->size[0];
    emxFree_real32_T(&points);
    for (i33 = 0; i33 < loop_ub; i33++) {
      inliers->data[i33] = b_inliers->data[i33];
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
      for (i33 = 0; i33 < loop_ub; i33++) {
        tmp_data[i33] = rtIsInfF(tmatrix_data[i33]);
      }

      loop_ub = tmatrix_size[0] * tmatrix_size[1];
      for (i33 = 0; i33 < loop_ub; i33++) {
        b_tmp_data[i33] = rtIsNaNF(tmatrix_data[i33]);
      }

      tmp_size[0] = iy;
      for (i33 = 0; i33 < iy; i33++) {
        d_tmp_data[i33] = !((!tmp_data[i33]) && (!b_tmp_data[i33]));
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
      for (i33 = 0; i33 < 9; i33++) {
        tmatrix_data[i33] = failedMatrix[i33];
      }
    }
  } else {
    i33 = inliers->size[0] * inliers->size[1];
    inliers->size[0] = matchedPoints1->size[0];
    inliers->size[1] = matchedPoints1->size[0];
    emxEnsureCapacity_boolean_T1(inliers, i33);
    loop_ub = matchedPoints1->size[0] * matchedPoints1->size[0];
    for (i33 = 0; i33 < loop_ub; i33++) {
      inliers->data[i33] = false;
    }

    tmatrix_size[0] = 3;
    for (i33 = 0; i33 < 9; i33++) {
      tmatrix_data[i33] = failedMatrix[i33];
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
    i33 = r11->size[0];
    r11->size[0] = iy;
    emxEnsureCapacity_int32_T(r11, i33);
    iy = 0;
    for (j = 0; j <= status; j++) {
      if (inliers->data[j]) {
        r11->data[iy] = j + 1;
        iy++;
      }
    }

    loop_ub = matchedPoints1->size[1];
    i33 = inlierPoints1->size[0] * inlierPoints1->size[1];
    inlierPoints1->size[0] = r11->size[0];
    inlierPoints1->size[1] = loop_ub;
    emxEnsureCapacity_real32_T(inlierPoints1, i33);
    for (i33 = 0; i33 < loop_ub; i33++) {
      iy = r11->size[0];
      for (j = 0; j < iy; j++) {
        inlierPoints1->data[j + inlierPoints1->size[0] * i33] =
          matchedPoints1->data[(r11->data[j] + matchedPoints1->size[0] * i33) -
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
    i33 = r12->size[0];
    r12->size[0] = iy;
    emxEnsureCapacity_int32_T(r12, i33);
    iy = 0;
    for (j = 0; j <= status; j++) {
      if (inliers->data[j]) {
        r12->data[iy] = j + 1;
        iy++;
      }
    }

    i33 = inlierPoints2->size[0] * inlierPoints2->size[1];
    inlierPoints2->size[0] = r12->size[0];
    inlierPoints2->size[1] = 2;
    emxEnsureCapacity_real32_T(inlierPoints2, i33);
    for (i33 = 0; i33 < 2; i33++) {
      loop_ub = r12->size[0];
      for (j = 0; j < loop_ub; j++) {
        inlierPoints2->data[j + inlierPoints2->size[0] * i33] =
          matchedPoints2->data[(r12->data[j] + matchedPoints2->size[0] * i33) -
          1];
      }
    }

    emxFree_int32_T(&r12);
  } else {
    i33 = inlierPoints1->size[0] * inlierPoints1->size[1];
    inlierPoints1->size[0] = 0;
    inlierPoints1->size[1] = 0;
    emxEnsureCapacity_real32_T(inlierPoints1, i33);
    i33 = inlierPoints2->size[0] * inlierPoints2->size[1];
    inlierPoints2->size[0] = 0;
    inlierPoints2->size[1] = 0;
    emxEnsureCapacity_real32_T(inlierPoints2, i33);
    tmatrix_size[0] = 3;
    for (i33 = 0; i33 < 9; i33++) {
      tmatrix_data[i33] = failedMatrix[i33];
    }
  }

  emxFree_boolean_T(&inliers);
  loop_ub = tmatrix_size[0];
  for (i33 = 0; i33 < 2; i33++) {
    for (j = 0; j < loop_ub; j++) {
      A_data[j + loop_ub * i33] = tmatrix_data[j + tmatrix_size[0] * i33];
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
    for (i33 = 0; i33 < iy; i33++) {
      for (j = 0; j < 3; j++) {
        tmatrix_data[j + 3 * i33] = A_data[j + 3 * i33];
      }
    }

    for (i33 = 0; i33 < 3; i33++) {
      tmatrix_data[i33 + 3 * iy] = iv0[i33];
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
  for (i33 = 0; i33 < loop_ub; i33++) {
    tform_T_data[i33] = tmatrix_data[i33];
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
  cell_wrap_62 reshapes[2];
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

  emxInitMatrix_cell_wrap_62(reshapes);
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

  emxFreeMatrix_cell_wrap_62(reshapes);
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
  emxEnsureCapacity_boolean_T(r15, i);
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

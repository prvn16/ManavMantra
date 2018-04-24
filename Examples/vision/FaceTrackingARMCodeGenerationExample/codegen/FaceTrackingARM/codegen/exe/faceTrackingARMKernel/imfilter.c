/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: imfilter.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "imfilter.h"
#include "faceTrackingARMKernel_emxutil.h"
#include "convn.h"
#include "repmat.h"

/* Function Declarations */
static void padImage(const emxArray_real32_T *a_tmp, const double pad[2],
                     emxArray_real32_T *a);

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *a_tmp
 *                const double pad[2]
 *                emxArray_real32_T *a
 * Return Type  : void
 */
static void padImage(const emxArray_real32_T *a_tmp, const double pad[2],
                     emxArray_real32_T *a)
{
  int i17;
  double sizeA[2];
  double b_sizeA[2];
  unsigned char c_sizeA[2];
  double varargin_1[2];
  double maxval;
  int onesVector_size_idx_1;
  int loop_ub;
  signed char onesVector_data[4];
  int idxDir_size_idx_1;
  unsigned char y_data[214];
  unsigned char idxDir_data[222];
  unsigned char tmp_data[168];
  unsigned char b_idxDir_data[222];
  unsigned char idxA_data[444];
  unsigned char b_tmp_data[222];
  if ((a_tmp->size[0] == 0) || (a_tmp->size[1] == 0)) {
    for (i17 = 0; i17 < 2; i17++) {
      b_sizeA[i17] = (double)a_tmp->size[i17] + 2.0 * pad[i17];
    }

    sizeA[0] = b_sizeA[0];
    sizeA[1] = b_sizeA[1];
    repmat(sizeA, a);
  } else {
    for (i17 = 0; i17 < 2; i17++) {
      b_sizeA[i17] = a_tmp->size[i17];
    }

    sizeA[0] = 2.0 * pad[0];
    sizeA[1] = 2.0 * pad[1];
    c_sizeA[0] = (unsigned char)b_sizeA[0];
    c_sizeA[1] = (unsigned char)b_sizeA[1];
    for (i17 = 0; i17 < 2; i17++) {
      varargin_1[i17] = sizeA[i17] + (double)c_sizeA[i17];
    }

    if ((varargin_1[0] < varargin_1[1]) || (rtIsNaN(varargin_1[0]) && (!rtIsNaN
          (varargin_1[1])))) {
      maxval = varargin_1[1];
    } else {
      maxval = varargin_1[0];
    }

    onesVector_size_idx_1 = (int)pad[0];
    loop_ub = (int)pad[0];
    if (0 <= loop_ub - 1) {
      memset(&onesVector_data[0], 1, (unsigned int)(loop_ub * (int)sizeof(signed
               char)));
    }

    loop_ub = (unsigned char)b_sizeA[0] - 1;
    for (i17 = 0; i17 <= loop_ub; i17++) {
      y_data[i17] = (unsigned char)(1U + (unsigned char)i17);
    }

    idxDir_size_idx_1 = ((int)pad[0] + (unsigned char)b_sizeA[0]) + (int)pad[0];
    loop_ub = (int)pad[0];
    for (i17 = 0; i17 < loop_ub; i17++) {
      idxDir_data[i17] = (unsigned char)onesVector_data[i17];
    }

    loop_ub = (unsigned char)b_sizeA[0];
    for (i17 = 0; i17 < loop_ub; i17++) {
      idxDir_data[i17 + onesVector_size_idx_1] = y_data[i17];
    }

    loop_ub = (int)pad[0];
    for (i17 = 0; i17 < loop_ub; i17++) {
      idxDir_data[(i17 + onesVector_size_idx_1) + (unsigned char)b_sizeA[0]] =
        (unsigned char)((unsigned int)(unsigned char)b_sizeA[0] * (unsigned char)
                        onesVector_data[i17]);
    }

    loop_ub = (unsigned char)idxDir_size_idx_1 - 1;
    for (i17 = 0; i17 <= loop_ub; i17++) {
      tmp_data[i17] = (unsigned char)i17;
    }

    for (i17 = 0; i17 < idxDir_size_idx_1; i17++) {
      b_idxDir_data[i17] = idxDir_data[i17];
    }

    loop_ub = (unsigned char)idxDir_size_idx_1;
    for (i17 = 0; i17 < loop_ub; i17++) {
      idxA_data[tmp_data[i17]] = b_idxDir_data[i17];
    }

    onesVector_size_idx_1 = (int)pad[1];
    loop_ub = (int)pad[1];
    if (0 <= loop_ub - 1) {
      memset(&onesVector_data[0], 1, (unsigned int)(loop_ub * (int)sizeof(signed
               char)));
    }

    loop_ub = (unsigned char)b_sizeA[1] - 1;
    for (i17 = 0; i17 <= loop_ub; i17++) {
      y_data[i17] = (unsigned char)(1U + (unsigned char)i17);
    }

    idxDir_size_idx_1 = ((int)pad[1] + (unsigned char)b_sizeA[1]) + (int)pad[1];
    loop_ub = (int)pad[1];
    for (i17 = 0; i17 < loop_ub; i17++) {
      idxDir_data[i17] = (unsigned char)onesVector_data[i17];
    }

    loop_ub = (unsigned char)b_sizeA[1];
    for (i17 = 0; i17 < loop_ub; i17++) {
      idxDir_data[i17 + onesVector_size_idx_1] = y_data[i17];
    }

    loop_ub = (int)pad[1];
    for (i17 = 0; i17 < loop_ub; i17++) {
      idxDir_data[(i17 + onesVector_size_idx_1) + (unsigned char)b_sizeA[1]] =
        (unsigned char)((unsigned int)(unsigned char)b_sizeA[1] * (unsigned char)
                        onesVector_data[i17]);
    }

    loop_ub = (unsigned char)idxDir_size_idx_1 - 1;
    for (i17 = 0; i17 <= loop_ub; i17++) {
      b_tmp_data[i17] = (unsigned char)i17;
    }

    for (i17 = 0; i17 < idxDir_size_idx_1; i17++) {
      b_idxDir_data[i17] = idxDir_data[i17];
    }

    loop_ub = (unsigned char)idxDir_size_idx_1;
    for (i17 = 0; i17 < loop_ub; i17++) {
      idxA_data[b_tmp_data[i17] + (int)maxval] = b_idxDir_data[i17];
    }

    for (i17 = 0; i17 < 2; i17++) {
      b_sizeA[i17] = (double)a_tmp->size[i17] + 2.0 * pad[i17];
    }

    i17 = a->size[0] * a->size[1];
    a->size[0] = (int)b_sizeA[0];
    a->size[1] = (int)b_sizeA[1];
    emxEnsureCapacity_real32_T(a, i17);
    i17 = a->size[1];
    for (onesVector_size_idx_1 = 0; onesVector_size_idx_1 < i17;
         onesVector_size_idx_1++) {
      loop_ub = a->size[0];
      for (idxDir_size_idx_1 = 0; idxDir_size_idx_1 < loop_ub; idxDir_size_idx_1
           ++) {
        a->data[idxDir_size_idx_1 + a->size[0] * onesVector_size_idx_1] =
          a_tmp->data[(idxA_data[idxDir_size_idx_1] + a_tmp->size[0] *
                       (idxA_data[onesVector_size_idx_1 + (int)maxval] - 1)) - 1];
      }
    }
  }
}

/*
 * Arguments    : const emxArray_real32_T *varargin_1
 *                emxArray_real32_T *b
 * Return Type  : void
 */
void b_imfilter(const emxArray_real32_T *varargin_1, emxArray_real32_T *b)
{
  unsigned char finalSize_idx_0;
  double pad[2];
  unsigned char finalSize_idx_1;
  emxArray_real32_T *a;
  int i19;
  emxArray_real32_T *r8;
  int loop_ub;
  emxArray_real_T *b_a;
  emxArray_real_T *result;
  int i20;
  int i21;
  int b_loop_ub;
  int i22;
  finalSize_idx_0 = (unsigned char)varargin_1->size[0];
  pad[0] = 1.0;
  finalSize_idx_1 = (unsigned char)varargin_1->size[1];
  pad[1] = 0.0;
  if ((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0)) {
    i19 = b->size[0] * b->size[1];
    b->size[0] = varargin_1->size[0];
    b->size[1] = varargin_1->size[1];
    emxEnsureCapacity_real32_T(b, i19);
    loop_ub = varargin_1->size[0] * varargin_1->size[1];
    for (i19 = 0; i19 < loop_ub; i19++) {
      b->data[i19] = varargin_1->data[i19];
    }
  } else {
    emxInit_real32_T(&a, 2);
    emxInit_real32_T(&r8, 2);
    padImage(varargin_1, pad, r8);
    i19 = a->size[0] * a->size[1];
    a->size[0] = r8->size[0];
    a->size[1] = r8->size[1];
    emxEnsureCapacity_real32_T(a, i19);
    loop_ub = r8->size[0] * r8->size[1];
    for (i19 = 0; i19 < loop_ub; i19++) {
      a->data[i19] = r8->data[i19];
    }

    emxFree_real32_T(&r8);
    emxInit_real_T(&b_a, 2);
    i19 = b_a->size[0] * b_a->size[1];
    b_a->size[0] = a->size[0];
    b_a->size[1] = a->size[1];
    emxEnsureCapacity_real_T1(b_a, i19);
    loop_ub = a->size[0] * a->size[1];
    for (i19 = 0; i19 < loop_ub; i19++) {
      b_a->data[i19] = a->data[i19];
    }

    emxFree_real32_T(&a);
    emxInit_real_T(&result, 2);
    b_convn(b_a, result);
    emxFree_real_T(&b_a);
    if (2 > finalSize_idx_0 + 1) {
      i19 = 0;
      i20 = 0;
    } else {
      i19 = 1;
      i20 = finalSize_idx_0 + 1;
    }

    if (1 > finalSize_idx_1) {
      loop_ub = 0;
    } else {
      loop_ub = finalSize_idx_1;
    }

    i21 = b->size[0] * b->size[1];
    b->size[0] = i20 - i19;
    b->size[1] = loop_ub;
    emxEnsureCapacity_real32_T(b, i21);
    for (i21 = 0; i21 < loop_ub; i21++) {
      b_loop_ub = i20 - i19;
      for (i22 = 0; i22 < b_loop_ub; i22++) {
        b->data[i22 + b->size[0] * i21] = (float)result->data[(i19 + i22) +
          result->size[0] * i21];
      }
    }

    emxFree_real_T(&result);
  }
}

/*
 * Arguments    : const emxArray_real32_T *varargin_1
 *                emxArray_real32_T *b
 * Return Type  : void
 */
void c_imfilter(const emxArray_real32_T *varargin_1, emxArray_real32_T *b)
{
  unsigned char finalSize_idx_0;
  double pad[2];
  unsigned char finalSize_idx_1;
  emxArray_real32_T *a;
  int i23;
  emxArray_real_T *b_a;
  int loop_ub;
  emxArray_real_T *result;
  int b_loop_ub;
  int i24;
  finalSize_idx_0 = (unsigned char)(varargin_1->size[0] + 4);
  pad[0] = 4.0;
  finalSize_idx_1 = (unsigned char)(varargin_1->size[1] + 4);
  pad[1] = 4.0;
  if ((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0)) {
    i23 = b->size[0] * b->size[1];
    b->size[0] = finalSize_idx_0;
    b->size[1] = finalSize_idx_1;
    emxEnsureCapacity_real32_T(b, i23);
    loop_ub = finalSize_idx_0 * finalSize_idx_1;
    for (i23 = 0; i23 < loop_ub; i23++) {
      b->data[i23] = 0.0F;
    }
  } else {
    emxInit_real32_T(&a, 2);
    emxInit_real_T(&b_a, 2);
    padImage(varargin_1, pad, a);
    i23 = b_a->size[0] * b_a->size[1];
    b_a->size[0] = a->size[0];
    b_a->size[1] = a->size[1];
    emxEnsureCapacity_real_T1(b_a, i23);
    loop_ub = a->size[0] * a->size[1];
    for (i23 = 0; i23 < loop_ub; i23++) {
      b_a->data[i23] = a->data[i23];
    }

    emxFree_real32_T(&a);
    emxInit_real_T(&result, 2);
    c_convn(b_a, result);
    loop_ub = finalSize_idx_0;
    b_loop_ub = finalSize_idx_1;
    i23 = b->size[0] * b->size[1];
    b->size[0] = finalSize_idx_0;
    b->size[1] = finalSize_idx_1;
    emxEnsureCapacity_real32_T(b, i23);
    emxFree_real_T(&b_a);
    for (i23 = 0; i23 < b_loop_ub; i23++) {
      for (i24 = 0; i24 < loop_ub; i24++) {
        b->data[i24 + b->size[0] * i23] = (float)result->data[(i24 +
          result->size[0] * (4 + i23)) + 4];
      }
    }

    emxFree_real_T(&result);
  }
}

/*
 * Arguments    : const emxArray_real32_T *varargin_1
 *                emxArray_real32_T *b
 * Return Type  : void
 */
void imfilter(const emxArray_real32_T *varargin_1, emxArray_real32_T *b)
{
  unsigned char finalSize_idx_0;
  double pad[2];
  unsigned char finalSize_idx_1;
  emxArray_real32_T *a;
  int i14;
  emxArray_real32_T *r7;
  int loop_ub;
  emxArray_real_T *b_a;
  emxArray_real_T *result;
  int i15;
  int i16;
  int b_loop_ub;
  finalSize_idx_0 = (unsigned char)varargin_1->size[0];
  pad[0] = 0.0;
  finalSize_idx_1 = (unsigned char)varargin_1->size[1];
  pad[1] = 1.0;
  if ((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0)) {
    i14 = b->size[0] * b->size[1];
    b->size[0] = varargin_1->size[0];
    b->size[1] = varargin_1->size[1];
    emxEnsureCapacity_real32_T(b, i14);
    loop_ub = varargin_1->size[0] * varargin_1->size[1];
    for (i14 = 0; i14 < loop_ub; i14++) {
      b->data[i14] = varargin_1->data[i14];
    }
  } else {
    emxInit_real32_T(&a, 2);
    emxInit_real32_T(&r7, 2);
    padImage(varargin_1, pad, r7);
    i14 = a->size[0] * a->size[1];
    a->size[0] = r7->size[0];
    a->size[1] = r7->size[1];
    emxEnsureCapacity_real32_T(a, i14);
    loop_ub = r7->size[0] * r7->size[1];
    for (i14 = 0; i14 < loop_ub; i14++) {
      a->data[i14] = r7->data[i14];
    }

    emxFree_real32_T(&r7);
    emxInit_real_T(&b_a, 2);
    i14 = b_a->size[0] * b_a->size[1];
    b_a->size[0] = a->size[0];
    b_a->size[1] = a->size[1];
    emxEnsureCapacity_real_T1(b_a, i14);
    loop_ub = a->size[0] * a->size[1];
    for (i14 = 0; i14 < loop_ub; i14++) {
      b_a->data[i14] = a->data[i14];
    }

    emxFree_real32_T(&a);
    emxInit_real_T(&result, 2);
    convn(b_a, result);
    emxFree_real_T(&b_a);
    if (1 > finalSize_idx_0) {
      loop_ub = 0;
    } else {
      loop_ub = finalSize_idx_0;
    }

    if (2 > finalSize_idx_1 + 1) {
      i14 = 0;
      i15 = 0;
    } else {
      i14 = 1;
      i15 = finalSize_idx_1 + 1;
    }

    i16 = b->size[0] * b->size[1];
    b->size[0] = loop_ub;
    b->size[1] = i15 - i14;
    emxEnsureCapacity_real32_T(b, i16);
    b_loop_ub = i15 - i14;
    for (i15 = 0; i15 < b_loop_ub; i15++) {
      for (i16 = 0; i16 < loop_ub; i16++) {
        b->data[i16 + b->size[0] * i15] = (float)result->data[i16 + result->
          size[0] * (i14 + i15)];
      }
    }

    emxFree_real_T(&result);
  }
}

/*
 * File trailer for imfilter.c
 *
 * [EOF]
 */

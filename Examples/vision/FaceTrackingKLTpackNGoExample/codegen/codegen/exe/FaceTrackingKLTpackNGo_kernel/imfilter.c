/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: imfilter.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include <string.h>
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "imfilter.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "repmat.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "libmwippfilter.h"

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
  int i12;
  double sizeA[2];
  double b_sizeA[2];
  short c_sizeA[2];
  double varargin_1[2];
  double maxval;
  int onesVector_size_idx_1;
  int loop_ub;
  signed char onesVector_data[4];
  int idxDir_size_idx_1;
  short y_data[640];
  short idxDir_data[648];
  short tmp_data[488];
  short b_idxDir_data[648];
  short idxA_data[1296];
  short b_tmp_data[648];
  if ((a_tmp->size[0] == 0) || (a_tmp->size[1] == 0)) {
    for (i12 = 0; i12 < 2; i12++) {
      b_sizeA[i12] = (double)a_tmp->size[i12] + 2.0 * pad[i12];
    }

    sizeA[0] = b_sizeA[0];
    sizeA[1] = b_sizeA[1];
    repmat(sizeA, a);
  } else {
    for (i12 = 0; i12 < 2; i12++) {
      b_sizeA[i12] = a_tmp->size[i12];
    }

    sizeA[0] = 2.0 * pad[0];
    sizeA[1] = 2.0 * pad[1];
    c_sizeA[0] = (short)b_sizeA[0];
    c_sizeA[1] = (short)b_sizeA[1];
    for (i12 = 0; i12 < 2; i12++) {
      varargin_1[i12] = sizeA[i12] + (double)c_sizeA[i12];
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

    loop_ub = (short)b_sizeA[0] - 1;
    for (i12 = 0; i12 <= loop_ub; i12++) {
      y_data[i12] = (short)(1 + (short)i12);
    }

    idxDir_size_idx_1 = ((int)pad[0] + (short)b_sizeA[0]) + (int)pad[0];
    loop_ub = (int)pad[0];
    for (i12 = 0; i12 < loop_ub; i12++) {
      idxDir_data[i12] = onesVector_data[i12];
    }

    loop_ub = (short)b_sizeA[0];
    for (i12 = 0; i12 < loop_ub; i12++) {
      idxDir_data[i12 + onesVector_size_idx_1] = y_data[i12];
    }

    loop_ub = (int)pad[0];
    for (i12 = 0; i12 < loop_ub; i12++) {
      idxDir_data[(i12 + onesVector_size_idx_1) + (short)b_sizeA[0]] = (short)
        ((short)b_sizeA[0] * onesVector_data[i12]);
    }

    loop_ub = (short)idxDir_size_idx_1 - 1;
    for (i12 = 0; i12 <= loop_ub; i12++) {
      tmp_data[i12] = (short)i12;
    }

    for (i12 = 0; i12 < idxDir_size_idx_1; i12++) {
      b_idxDir_data[i12] = idxDir_data[i12];
    }

    loop_ub = (short)idxDir_size_idx_1;
    for (i12 = 0; i12 < loop_ub; i12++) {
      idxA_data[tmp_data[i12]] = b_idxDir_data[i12];
    }

    onesVector_size_idx_1 = (int)pad[1];
    loop_ub = (int)pad[1];
    if (0 <= loop_ub - 1) {
      memset(&onesVector_data[0], 1, (unsigned int)(loop_ub * (int)sizeof(signed
               char)));
    }

    loop_ub = (short)b_sizeA[1] - 1;
    for (i12 = 0; i12 <= loop_ub; i12++) {
      y_data[i12] = (short)(1 + (short)i12);
    }

    idxDir_size_idx_1 = ((int)pad[1] + (short)b_sizeA[1]) + (int)pad[1];
    loop_ub = (int)pad[1];
    for (i12 = 0; i12 < loop_ub; i12++) {
      idxDir_data[i12] = onesVector_data[i12];
    }

    loop_ub = (short)b_sizeA[1];
    for (i12 = 0; i12 < loop_ub; i12++) {
      idxDir_data[i12 + onesVector_size_idx_1] = y_data[i12];
    }

    loop_ub = (int)pad[1];
    for (i12 = 0; i12 < loop_ub; i12++) {
      idxDir_data[(i12 + onesVector_size_idx_1) + (short)b_sizeA[1]] = (short)
        ((short)b_sizeA[1] * onesVector_data[i12]);
    }

    loop_ub = (short)idxDir_size_idx_1 - 1;
    for (i12 = 0; i12 <= loop_ub; i12++) {
      b_tmp_data[i12] = (short)i12;
    }

    for (i12 = 0; i12 < idxDir_size_idx_1; i12++) {
      b_idxDir_data[i12] = idxDir_data[i12];
    }

    loop_ub = (short)idxDir_size_idx_1;
    for (i12 = 0; i12 < loop_ub; i12++) {
      idxA_data[b_tmp_data[i12] + (int)maxval] = b_idxDir_data[i12];
    }

    for (i12 = 0; i12 < 2; i12++) {
      b_sizeA[i12] = (double)a_tmp->size[i12] + 2.0 * pad[i12];
    }

    i12 = a->size[0] * a->size[1];
    a->size[0] = (int)b_sizeA[0];
    a->size[1] = (int)b_sizeA[1];
    emxEnsureCapacity_real32_T(a, i12);
    i12 = a->size[1];
    for (onesVector_size_idx_1 = 0; onesVector_size_idx_1 < i12;
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
 * Arguments    : emxArray_real32_T *varargin_1
 * Return Type  : void
 */
void b_imfilter(emxArray_real32_T *varargin_1)
{
  double outSizeT[2];
  double startT[2];
  emxArray_real32_T *a;
  emxArray_real32_T *r17;
  int i33;
  int loop_ub;
  double padSizeT[2];
  double kernel[3];
  outSizeT[0] = varargin_1->size[0];
  startT[0] = 0.0;
  outSizeT[1] = varargin_1->size[1];
  startT[1] = 1.0;
  if (!((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0))) {
    emxInit_real32_T(&a, 2);
    emxInit_real32_T(&r17, 2);
    padImage(varargin_1, startT, r17);
    i33 = a->size[0] * a->size[1];
    a->size[0] = r17->size[0];
    a->size[1] = r17->size[1];
    emxEnsureCapacity_real32_T(a, i33);
    loop_ub = r17->size[0] * r17->size[1];
    for (i33 = 0; i33 < loop_ub; i33++) {
      a->data[i33] = r17->data[i33];
    }

    emxFree_real32_T(&r17);
    i33 = varargin_1->size[0] * varargin_1->size[1];
    varargin_1->size[0] = (int)outSizeT[0];
    varargin_1->size[1] = (int)outSizeT[1];
    emxEnsureCapacity_real32_T(varargin_1, i33);
    for (i33 = 0; i33 < 2; i33++) {
      padSizeT[i33] = a->size[i33];
    }

    for (i33 = 0; i33 < 3; i33++) {
      kernel[i33] = -1.0 + (double)i33;
    }

    for (i33 = 0; i33 < 2; i33++) {
      startT[i33] = 1.0 + 2.0 * (double)i33;
    }

    ippfilter_real32(&a->data[0], &varargin_1->data[0], outSizeT, 2.0, padSizeT,
                     kernel, startT, true);
    emxFree_real32_T(&a);
  }
}

/*
 * Arguments    : emxArray_real32_T *varargin_1
 * Return Type  : void
 */
void c_imfilter(emxArray_real32_T *varargin_1)
{
  double outSizeT[2];
  double startT[2];
  emxArray_real32_T *a;
  emxArray_real32_T *r18;
  int i34;
  int loop_ub;
  double padSizeT[2];
  double kernel[3];
  outSizeT[0] = varargin_1->size[0];
  startT[0] = 1.0;
  outSizeT[1] = varargin_1->size[1];
  startT[1] = 0.0;
  if (!((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0))) {
    emxInit_real32_T(&a, 2);
    emxInit_real32_T(&r18, 2);
    padImage(varargin_1, startT, r18);
    i34 = a->size[0] * a->size[1];
    a->size[0] = r18->size[0];
    a->size[1] = r18->size[1];
    emxEnsureCapacity_real32_T(a, i34);
    loop_ub = r18->size[0] * r18->size[1];
    for (i34 = 0; i34 < loop_ub; i34++) {
      a->data[i34] = r18->data[i34];
    }

    emxFree_real32_T(&r18);
    i34 = varargin_1->size[0] * varargin_1->size[1];
    varargin_1->size[0] = (int)outSizeT[0];
    varargin_1->size[1] = (int)outSizeT[1];
    emxEnsureCapacity_real32_T(varargin_1, i34);
    for (i34 = 0; i34 < 2; i34++) {
      padSizeT[i34] = a->size[i34];
    }

    for (i34 = 0; i34 < 3; i34++) {
      kernel[i34] = -1.0 + (double)i34;
    }

    for (i34 = 0; i34 < 2; i34++) {
      startT[i34] = 3.0 + -2.0 * (double)i34;
    }

    ippfilter_real32(&a->data[0], &varargin_1->data[0], outSizeT, 2.0, padSizeT,
                     kernel, startT, true);
    emxFree_real32_T(&a);
  }
}

/*
 * Arguments    : const emxArray_real32_T *varargin_1
 *                emxArray_real32_T *b
 * Return Type  : void
 */
void imfilter(const emxArray_real32_T *varargin_1, emxArray_real32_T *b)
{
  double outSizeT[2];
  double startT[2];
  emxArray_real32_T *a;
  int i14;
  int loop_ub;
  double padSizeT[2];
  static const double kernel[25] = { 0.017842203926833885, 0.03061734437494857,
    0.036655616298368318, 0.03061734437494857, 0.017842203926833885,
    0.03061734437494857, 0.052539573049288711, 0.062901289105615155,
    0.052539573049288711, 0.03061734437494857, 0.036655616298368318,
    0.062901289105615155, 0.075306515479987221, 0.062901289105615155,
    0.036655616298368318, 0.03061734437494857, 0.052539573049288711,
    0.062901289105615155, 0.052539573049288711, 0.03061734437494857,
    0.017842203926833885, 0.03061734437494857, 0.036655616298368318,
    0.03061734437494857, 0.017842203926833885 };

  outSizeT[0] = ((double)varargin_1->size[0] + 5.0) - 1.0;
  startT[0] = 4.0;
  outSizeT[1] = ((double)varargin_1->size[1] + 5.0) - 1.0;
  startT[1] = 4.0;
  if ((varargin_1->size[0] == 0) || (varargin_1->size[1] == 0)) {
    i14 = b->size[0] * b->size[1];
    b->size[0] = (int)outSizeT[0];
    emxEnsureCapacity_real32_T(b, i14);
    i14 = b->size[0] * b->size[1];
    b->size[1] = (int)outSizeT[1];
    emxEnsureCapacity_real32_T(b, i14);
    loop_ub = (int)outSizeT[0] * (int)outSizeT[1];
    for (i14 = 0; i14 < loop_ub; i14++) {
      b->data[i14] = 0.0F;
    }
  } else {
    emxInit_real32_T(&a, 2);
    padImage(varargin_1, startT, a);
    i14 = b->size[0] * b->size[1];
    b->size[0] = (int)outSizeT[0];
    b->size[1] = (int)outSizeT[1];
    emxEnsureCapacity_real32_T(b, i14);
    for (i14 = 0; i14 < 2; i14++) {
      padSizeT[i14] = a->size[i14];
    }

    for (i14 = 0; i14 < 2; i14++) {
      startT[i14] = 5.0;
    }

    ippfilter_real32(&a->data[0], &b->data[0], outSizeT, 2.0, padSizeT, kernel,
                     startT, true);
    emxFree_real32_T(&a);
  }
}

/*
 * File trailer for imfilter.c
 *
 * [EOF]
 */

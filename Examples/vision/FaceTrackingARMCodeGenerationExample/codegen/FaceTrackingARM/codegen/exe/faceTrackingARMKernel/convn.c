/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: convn.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "convn.h"
#include "faceTrackingARMKernel_emxutil.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real_T *A
 *                emxArray_real_T *C
 * Return Type  : void
 */
void b_convn(const emxArray_real_T *A, emxArray_real_T *C)
{
  unsigned char szC_idx_0;
  unsigned char szC_idx_1;
  int aidx;
  int firstRowA;
  int ma;
  int na;
  int lastColB;
  int lastColA;
  int k;
  int iC;
  int iA;
  int iB;
  int i;
  int b_i;
  int a_length;
  int r;
  szC_idx_0 = (unsigned char)A->size[0];
  szC_idx_1 = (unsigned char)A->size[1];
  aidx = C->size[0] * C->size[1];
  C->size[0] = szC_idx_0;
  C->size[1] = szC_idx_1;
  emxEnsureCapacity_real_T1(C, aidx);
  firstRowA = szC_idx_0 * szC_idx_1;
  for (aidx = 0; aidx < firstRowA; aidx++) {
    C->data[aidx] = 0.0;
  }

  if ((A->size[1] == 0) || (szC_idx_1 == 0)) {
  } else {
    ma = A->size[0];
    na = A->size[1];
    if (1 <= szC_idx_1 - 1) {
      lastColB = 1;
    } else {
      lastColB = szC_idx_1;
    }

    aidx = 0;
    while (aidx <= lastColB - 1) {
      if (na - 1 < szC_idx_1 - 1) {
        lastColA = na;
      } else {
        lastColA = szC_idx_1;
      }

      for (k = 0; k < lastColA; k++) {
        if (k > 0) {
          firstRowA = k;
        } else {
          firstRowA = 0;
        }

        iC = firstRowA * szC_idx_0;
        iA = k * ma;
        iB = 0;
        for (i = 0; i < 3; i++) {
          firstRowA = (i < 1);
          if (i + ma <= szC_idx_0) {
            b_i = ma;
          } else {
            b_i = (szC_idx_0 - i) + 1;
          }

          a_length = b_i - firstRowA;
          aidx = iA + firstRowA;
          firstRowA = iC;
          for (r = 1; r <= a_length; r++) {
            C->data[firstRowA] += (-1.0 + (double)iB) * A->data[aidx];
            aidx++;
            firstRowA++;
          }

          iB++;
          if (i >= 1) {
            iC++;
          }
        }
      }

      aidx = 1;
    }
  }
}

/*
 * Arguments    : const emxArray_real_T *A
 *                emxArray_real_T *C
 * Return Type  : void
 */
void c_convn(const emxArray_real_T *A, emxArray_real_T *C)
{
  unsigned char szC_idx_0;
  unsigned char szC_idx_1;
  int iA;
  int iC;
  boolean_T b0;
  int ma;
  int na;
  int j;
  int lastColA;
  int k;
  int iB;
  int i;
  int lastRowA;
  int aidx;
  int cidx;
  int r;
  static const double dv0[25] = { 0.017842203926833885, 0.03061734437494857,
    0.036655616298368318, 0.03061734437494857, 0.017842203926833885,
    0.03061734437494857, 0.052539573049288711, 0.062901289105615155,
    0.052539573049288711, 0.03061734437494857, 0.036655616298368318,
    0.062901289105615155, 0.075306515479987221, 0.062901289105615155,
    0.036655616298368318, 0.03061734437494857, 0.052539573049288711,
    0.062901289105615155, 0.052539573049288711, 0.03061734437494857,
    0.017842203926833885, 0.03061734437494857, 0.036655616298368318,
    0.03061734437494857, 0.017842203926833885 };

  if (A->size[0] > 0) {
    szC_idx_0 = (unsigned char)(A->size[0] + 4);
  } else {
    szC_idx_0 = 5U;
  }

  if (A->size[1] > 0) {
    szC_idx_1 = (unsigned char)(A->size[1] + 4);
  } else {
    szC_idx_1 = 5U;
  }

  iA = C->size[0] * C->size[1];
  C->size[0] = szC_idx_0;
  C->size[1] = szC_idx_1;
  emxEnsureCapacity_real_T1(C, iA);
  iC = szC_idx_0 * szC_idx_1;
  for (iA = 0; iA < iC; iA++) {
    C->data[iA] = 0.0;
  }

  b0 = ((A->size[0] == 0) || (A->size[1] == 0));
  if (!b0) {
    ma = A->size[0];
    na = A->size[1];
    for (j = 0; j < 5; j++) {
      if ((j + na) - 1 < szC_idx_1 - 1) {
        lastColA = na;
      } else {
        lastColA = szC_idx_1 - j;
      }

      for (k = 0; k < lastColA; k++) {
        iA = j + k;
        if (!(iA > 0)) {
          iA = 0;
        }

        iC = iA * szC_idx_0;
        iA = k * ma;
        iB = j * 5;
        for (i = 0; i < 5; i++) {
          if (i + ma <= szC_idx_0 - 1) {
            lastRowA = ma;
          } else {
            lastRowA = szC_idx_0 - i;
          }

          aidx = iA;
          cidx = iC;
          for (r = 1; r <= lastRowA; r++) {
            C->data[cidx] += dv0[iB] * A->data[aidx];
            aidx++;
            cidx++;
          }

          iB++;
          iC++;
        }
      }
    }
  }
}

/*
 * Arguments    : const emxArray_real_T *A
 *                emxArray_real_T *C
 * Return Type  : void
 */
void convn(const emxArray_real_T *A, emxArray_real_T *C)
{
  unsigned char szC_idx_0;
  unsigned char szC_idx_1;
  int aidx;
  int lastRowA;
  int ma;
  int na;
  int lastRowB;
  int j;
  int lastColA;
  int k;
  int b_j;
  int iC;
  int iA;
  int iB;
  int cidx;
  int r;
  szC_idx_0 = (unsigned char)A->size[0];
  szC_idx_1 = (unsigned char)A->size[1];
  aidx = C->size[0] * C->size[1];
  C->size[0] = szC_idx_0;
  C->size[1] = szC_idx_1;
  emxEnsureCapacity_real_T1(C, aidx);
  lastRowA = szC_idx_0 * szC_idx_1;
  for (aidx = 0; aidx < lastRowA; aidx++) {
    C->data[aidx] = 0.0;
  }

  if ((A->size[0] == 0) || (szC_idx_0 == 0)) {
  } else {
    ma = A->size[0];
    na = A->size[1] - 1;
    if (1 <= szC_idx_0 - 1) {
      lastRowB = 1;
    } else {
      lastRowB = szC_idx_0;
    }

    for (j = 0; j < 3; j++) {
      if (j + na < szC_idx_1) {
        lastColA = na;
      } else {
        lastColA = szC_idx_1 - j;
      }

      for (k = (j < 1); k <= lastColA; k++) {
        if (j + k > 1) {
          b_j = (j + k) - 1;
        } else {
          b_j = 0;
        }

        iC = b_j * szC_idx_0;
        iA = k * ma;
        iB = j;
        aidx = 0;
        while (aidx <= lastRowB - 1) {
          if (ma <= szC_idx_0 - 1) {
            lastRowA = ma;
          } else {
            lastRowA = szC_idx_0;
          }

          aidx = iA;
          cidx = iC;
          for (r = 1; r <= lastRowA; r++) {
            C->data[cidx] += (-1.0 + (double)iB) * A->data[aidx];
            aidx++;
            cidx++;
          }

          iB++;
          iC++;
          aidx = 1;
        }
      }
    }
  }
}

/*
 * File trailer for convn.c
 *
 * [EOF]
 */

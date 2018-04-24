/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: bsxfun.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "bsxfun.h"
#include "faceTrackingARMKernel_emxutil.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *a
 *                const float b[2]
 *                emxArray_real32_T *c
 * Return Type  : void
 */
void bsxfun(const emxArray_real32_T *a, const float b[2], emxArray_real32_T *c)
{
  unsigned short csz_idx_0;
  int k;
  int szc;
  int acoef;
  int b_k;
  csz_idx_0 = (unsigned short)a->size[0];
  k = c->size[0] * c->size[1];
  c->size[0] = csz_idx_0;
  c->size[1] = 2;
  emxEnsureCapacity_real32_T(c, k);
  if (c->size[0] != 0) {
    for (k = 0; k < 2; k++) {
      szc = c->size[0];
      acoef = (a->size[0] != 1);
      for (b_k = 0; b_k < szc; b_k++) {
        c->data[b_k + c->size[0] * k] = a->data[acoef * b_k + a->size[0] * k] +
          b[k];
      }
    }
  }
}

/*
 * File trailer for bsxfun.c
 *
 * [EOF]
 */

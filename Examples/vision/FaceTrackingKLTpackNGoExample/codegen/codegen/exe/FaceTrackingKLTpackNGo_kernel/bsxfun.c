/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: bsxfun.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "bsxfun.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *a
 *                const float b[2]
 *                emxArray_real32_T *c
 * Return Type  : void
 */
void bsxfun(const emxArray_real32_T *a, const float b[2], emxArray_real32_T *c)
{
  int csz_idx_0;
  int szc;
  int acoef;
  int k;
  csz_idx_0 = a->size[0];
  szc = c->size[0] * c->size[1];
  c->size[0] = csz_idx_0;
  c->size[1] = 2;
  emxEnsureCapacity_real32_T(c, szc);
  if (c->size[0] != 0) {
    for (csz_idx_0 = 0; csz_idx_0 < 2; csz_idx_0++) {
      szc = c->size[0];
      acoef = (a->size[0] != 1);
      for (k = 0; k < szc; k++) {
        c->data[k + c->size[0] * csz_idx_0] = a->data[acoef * k + a->size[0] *
          csz_idx_0] + b[csz_idx_0];
      }
    }
  }
}

/*
 * File trailer for bsxfun.c
 *
 * [EOF]
 */

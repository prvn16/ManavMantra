/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: power.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "power.h"
#include "faceTrackingARMKernel_emxutil.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *a
 *                emxArray_real32_T *y
 * Return Type  : void
 */
void power(const emxArray_real32_T *a, emxArray_real32_T *y)
{
  int nx;
  emxArray_real32_T *ztemp;
  unsigned char uv3[2];
  int k;
  for (nx = 0; nx < 2; nx++) {
    uv3[nx] = (unsigned char)a->size[nx];
  }

  emxInit_real32_T(&ztemp, 2);
  nx = ztemp->size[0] * ztemp->size[1];
  ztemp->size[0] = uv3[0];
  ztemp->size[1] = uv3[1];
  emxEnsureCapacity_real32_T(ztemp, nx);
  nx = y->size[0] * y->size[1];
  y->size[0] = uv3[0];
  y->size[1] = uv3[1];
  emxEnsureCapacity_real32_T(y, nx);
  nx = ztemp->size[0] * ztemp->size[1];
  k = 0;
  emxFree_real32_T(&ztemp);
  while (k + 1 <= nx) {
    y->data[k] = a->data[k] * a->data[k];
    k++;
  }
}

/*
 * File trailer for power.c
 *
 * [EOF]
 */

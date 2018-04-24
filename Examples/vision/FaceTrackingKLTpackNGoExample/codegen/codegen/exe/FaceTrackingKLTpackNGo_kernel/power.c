/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: power.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "power.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

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
  short iv3[2];
  int k;
  for (nx = 0; nx < 2; nx++) {
    iv3[nx] = (short)a->size[nx];
  }

  emxInit_real32_T(&ztemp, 2);
  nx = ztemp->size[0] * ztemp->size[1];
  ztemp->size[0] = iv3[0];
  ztemp->size[1] = iv3[1];
  emxEnsureCapacity_real32_T(ztemp, nx);
  nx = y->size[0] * y->size[1];
  y->size[0] = iv3[0];
  y->size[1] = iv3[1];
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

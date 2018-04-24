/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xaxpy.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "xaxpy.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : int n
 *                float a
 *                const emxArray_real32_T *x
 *                int ix0
 *                emxArray_real32_T *y
 *                int iy0
 * Return Type  : void
 */
void b_xaxpy(int n, float a, const emxArray_real32_T *x, int ix0,
             emxArray_real32_T *y, int iy0)
{
  int ix;
  int iy;
  int k;
  if ((n < 1) || (a == 0.0F)) {
  } else {
    ix = ix0 - 1;
    iy = iy0 - 1;
    for (k = 0; k < n; k++) {
      y->data[iy] += a * x->data[ix];
      ix++;
      iy++;
    }
  }
}

/*
 * Arguments    : int n
 *                float a
 *                const emxArray_real32_T *x
 *                int ix0
 *                emxArray_real32_T *y
 *                int iy0
 * Return Type  : void
 */
void c_xaxpy(int n, float a, const emxArray_real32_T *x, int ix0,
             emxArray_real32_T *y, int iy0)
{
  int ix;
  int iy;
  int k;
  if ((n < 1) || (a == 0.0F)) {
  } else {
    ix = ix0 - 1;
    iy = iy0 - 1;
    for (k = 0; k < n; k++) {
      y->data[iy] += a * x->data[ix];
      ix++;
      iy++;
    }
  }
}

/*
 * Arguments    : int n
 *                float a
 *                int ix0
 *                emxArray_real32_T *y
 *                int iy0
 * Return Type  : void
 */
void d_xaxpy(int n, float a, int ix0, emxArray_real32_T *y, int iy0)
{
  int ix;
  int iy;
  int k;
  if ((n < 1) || (a == 0.0F)) {
  } else {
    ix = ix0 - 1;
    iy = iy0 - 1;
    for (k = 0; k < n; k++) {
      y->data[iy] += a * y->data[ix];
      ix++;
      iy++;
    }
  }
}

/*
 * Arguments    : int n
 *                float a
 *                int ix0
 *                float y[25]
 *                int iy0
 * Return Type  : void
 */
void e_xaxpy(int n, float a, int ix0, float y[25], int iy0)
{
  int ix;
  int iy;
  int k;
  if ((n < 1) || (a == 0.0F)) {
  } else {
    ix = ix0 - 1;
    iy = iy0 - 1;
    for (k = 0; k < n; k++) {
      y[iy] += a * y[ix];
      ix++;
      iy++;
    }
  }
}

/*
 * Arguments    : int n
 *                float a
 *                int ix0
 *                emxArray_real32_T *y
 *                int iy0
 * Return Type  : void
 */
void xaxpy(int n, float a, int ix0, emxArray_real32_T *y, int iy0)
{
  int ix;
  int iy;
  int k;
  if ((n < 1) || (a == 0.0F)) {
  } else {
    ix = ix0 - 1;
    iy = iy0 - 1;
    for (k = 0; k < n; k++) {
      y->data[iy] += a * y->data[ix];
      ix++;
      iy++;
    }
  }
}

/*
 * File trailer for xaxpy.c
 *
 * [EOF]
 */

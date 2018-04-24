/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xdotc.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "xdotc.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : int n
 *                const emxArray_real32_T *x
 *                int ix0
 *                const emxArray_real32_T *y
 *                int iy0
 * Return Type  : float
 */
float b_xdotc(int n, const emxArray_real32_T *x, int ix0, const
              emxArray_real32_T *y, int iy0)
{
  float d;
  int ix;
  int iy;
  int k;
  d = 0.0F;
  if (!(n < 1)) {
    ix = ix0;
    iy = iy0;
    for (k = 1; k <= n; k++) {
      d += x->data[ix - 1] * y->data[iy - 1];
      ix++;
      iy++;
    }
  }

  return d;
}

/*
 * Arguments    : int n
 *                const float x[25]
 *                int ix0
 *                const float y[25]
 *                int iy0
 * Return Type  : float
 */
float c_xdotc(int n, const float x[25], int ix0, const float y[25], int iy0)
{
  float d;
  int ix;
  int iy;
  int k;
  d = 0.0F;
  if (!(n < 1)) {
    ix = ix0;
    iy = iy0;
    for (k = 1; k <= n; k++) {
      d += x[ix - 1] * y[iy - 1];
      ix++;
      iy++;
    }
  }

  return d;
}

/*
 * Arguments    : int n
 *                const emxArray_real32_T *x
 *                int ix0
 *                const emxArray_real32_T *y
 *                int iy0
 * Return Type  : float
 */
float xdotc(int n, const emxArray_real32_T *x, int ix0, const emxArray_real32_T *
            y, int iy0)
{
  float d;
  int ix;
  int iy;
  int k;
  d = 0.0F;
  if (!(n < 1)) {
    ix = ix0;
    iy = iy0;
    for (k = 1; k <= n; k++) {
      d += x->data[ix - 1] * y->data[iy - 1];
      ix++;
      iy++;
    }
  }

  return d;
}

/*
 * File trailer for xdotc.c
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xrot.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "xrot.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : int n
 *                emxArray_real32_T *x
 *                int ix0
 *                int iy0
 *                float c
 *                float s
 * Return Type  : void
 */
void b_xrot(int n, emxArray_real32_T *x, int ix0, int iy0, float c, float s)
{
  int ix;
  int iy;
  int k;
  float temp;
  if (!(n < 1)) {
    ix = ix0 - 1;
    iy = iy0 - 1;
    for (k = 1; k <= n; k++) {
      temp = c * x->data[ix] + s * x->data[iy];
      x->data[iy] = c * x->data[iy] - s * x->data[ix];
      x->data[ix] = temp;
      iy++;
      ix++;
    }
  }
}

/*
 * Arguments    : float x[25]
 *                int ix0
 *                int iy0
 *                float c
 *                float s
 * Return Type  : void
 */
void xrot(float x[25], int ix0, int iy0, float c, float s)
{
  int ix;
  int iy;
  int k;
  float temp;
  ix = ix0 - 1;
  iy = iy0 - 1;
  for (k = 0; k < 5; k++) {
    temp = c * x[ix] + s * x[iy];
    x[iy] = c * x[iy] - s * x[ix];
    x[ix] = temp;
    iy++;
    ix++;
  }
}

/*
 * File trailer for xrot.c
 *
 * [EOF]
 */

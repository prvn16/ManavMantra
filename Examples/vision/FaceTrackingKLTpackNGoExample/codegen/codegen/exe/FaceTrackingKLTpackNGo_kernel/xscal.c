/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: xscal.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "xscal.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : float a
 *                float x[25]
 *                int ix0
 * Return Type  : void
 */
void b_xscal(float a, float x[25], int ix0)
{
  int k;
  for (k = ix0; k <= ix0 + 4; k++) {
    x[k - 1] *= a;
  }
}

/*
 * Arguments    : int n
 *                float a
 *                emxArray_real32_T *x
 *                int ix0
 * Return Type  : void
 */
void xscal(int n, float a, emxArray_real32_T *x, int ix0)
{
  int i42;
  int k;
  i42 = (ix0 + n) - 1;
  for (k = ix0; k <= i42; k++) {
    x->data[k - 1] *= a;
  }
}

/*
 * File trailer for xscal.c
 *
 * [EOF]
 */

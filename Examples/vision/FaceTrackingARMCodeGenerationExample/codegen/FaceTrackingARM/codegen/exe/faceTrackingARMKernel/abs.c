/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: abs.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "abs.h"
#include "faceTrackingARMKernel_emxutil.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *x
 *                emxArray_real32_T *y
 * Return Type  : void
 */
void b_abs(const emxArray_real32_T *x, emxArray_real32_T *y)
{
  int k;
  k = y->size[0] * y->size[1] * y->size[2];
  y->size[0] = 1;
  y->size[1] = 1;
  y->size[2] = (unsigned short)x->size[2];
  emxEnsureCapacity_real32_T1(y, k);
  for (k = 0; k < x->size[2]; k++) {
    y->data[k] = (float)fabs(x->data[k]);
  }
}

/*
 * File trailer for abs.c
 *
 * [EOF]
 */

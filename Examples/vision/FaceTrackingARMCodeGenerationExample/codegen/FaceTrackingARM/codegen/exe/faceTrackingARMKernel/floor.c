/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: floor.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include <math.h>
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "floor.h"

/* Function Definitions */

/*
 * Arguments    : emxArray_real32_T *x
 * Return Type  : void
 */
void b_floor(emxArray_real32_T *x)
{
  int nx;
  int k;
  nx = x->size[0];
  for (k = 0; k < nx; k++) {
    x->data[k] = (float)floor(x->data[k]);
  }
}

/*
 * File trailer for floor.c
 *
 * [EOF]
 */

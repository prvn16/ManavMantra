/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: cropImage.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "cropImage.h"
#include "faceTrackingARMKernel_emxutil.h"

/* Function Definitions */

/*
 * Arguments    : const float I[34240]
 *                const int roi_data[]
 *                emxArray_real32_T *Iroi
 * Return Type  : void
 */
void cropImage(const float I[34240], const int roi_data[], emxArray_real32_T
               *Iroi)
{
  int c2;
  int q1;
  int r2;
  int i7;
  int i8;
  int i9;
  int i10;
  c2 = roi_data[3];
  q1 = roi_data[1];
  if ((c2 < 0) && (q1 < MIN_int32_T - c2)) {
    c2 = MIN_int32_T;
  } else if ((c2 > 0) && (q1 > MAX_int32_T - c2)) {
    c2 = MAX_int32_T;
  } else {
    c2 += q1;
  }

  if (c2 < -2147483647) {
    r2 = MIN_int32_T;
  } else {
    r2 = c2 - 1;
  }

  c2 = roi_data[2];
  q1 = roi_data[0];
  if ((c2 < 0) && (q1 < MIN_int32_T - c2)) {
    c2 = MIN_int32_T;
  } else if ((c2 > 0) && (q1 > MAX_int32_T - c2)) {
    c2 = MAX_int32_T;
  } else {
    c2 += q1;
  }

  if (c2 < -2147483647) {
    c2 = MIN_int32_T;
  } else {
    c2--;
  }

  if (roi_data[1] > r2) {
    i7 = 0;
    r2 = 0;
  } else {
    i7 = roi_data[1] - 1;
  }

  if (roi_data[0] > c2) {
    i8 = 0;
    c2 = 0;
  } else {
    i8 = roi_data[0] - 1;
  }

  i9 = Iroi->size[0] * Iroi->size[1];
  Iroi->size[0] = r2 - i7;
  Iroi->size[1] = c2 - i8;
  emxEnsureCapacity_real32_T(Iroi, i9);
  q1 = c2 - i8;
  for (i9 = 0; i9 < q1; i9++) {
    c2 = r2 - i7;
    for (i10 = 0; i10 < c2; i10++) {
      Iroi->data[i10 + Iroi->size[0] * i9] = I[(i7 + i10) + 160 * (i8 + i9)];
    }
  }
}

/*
 * File trailer for cropImage.c
 *
 * [EOF]
 */

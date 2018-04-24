/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: cropImage.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "cropImage.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const float I[307200]
 *                const int roi_data[]
 *                const int roi_size[2]
 *                emxArray_real32_T *Iroi
 * Return Type  : void
 */
void cropImage(const float I[307200], const int roi_data[], const int roi_size[2],
               emxArray_real32_T *Iroi)
{
  int c2;
  int i5;
  int q1;
  int r2;
  int i6;
  int i7;
  int i8;
  if (roi_size[0] == 0) {
    i5 = Iroi->size[0] * Iroi->size[1];
    Iroi->size[0] = 0;
    Iroi->size[1] = 0;
    emxEnsureCapacity_real32_T(Iroi, i5);
  } else {
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
      i5 = 0;
      r2 = 0;
    } else {
      i5 = roi_data[1] - 1;
    }

    if (roi_data[0] > c2) {
      i6 = 0;
      c2 = 0;
    } else {
      i6 = roi_data[0] - 1;
    }

    i7 = Iroi->size[0] * Iroi->size[1];
    Iroi->size[0] = r2 - i5;
    Iroi->size[1] = c2 - i6;
    emxEnsureCapacity_real32_T(Iroi, i7);
    q1 = c2 - i6;
    for (i7 = 0; i7 < q1; i7++) {
      c2 = r2 - i5;
      for (i8 = 0; i8 < c2; i8++) {
        Iroi->data[i8 + Iroi->size[0] * i7] = I[(i5 + i8) + 480 * (i6 + i7)];
      }
    }
  }
}

/*
 * File trailer for cropImage.c
 *
 * [EOF]
 */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: bwlookup.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "bwlookup.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "libmwbwlookup_tbb.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_boolean_T *bwin
 *                emxArray_boolean_T *B
 * Return Type  : void
 */
void bwlookup(const emxArray_boolean_T *bwin, emxArray_boolean_T *B)
{
  int i17;
  short iv4[2];
  double b_bwin[2];
  static const boolean_T lut[512] = { false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    true, true, true, true, false, true, true, true, true, true, true, false,
    false, true, true, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, true, false, true,
    true, true, false, true, true, false, false, true, true, false, false, true,
    true, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, true, false, false, false, false,
    false, false, false, true, true, true, true, false, false, true, true, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, true, false, false, true, true, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, true, false, false, false, false, false, false, false,
    true, true, true, true, false, false, true, true, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, true, false, true, true, true, false, true, true, true, true, false,
    false, true, true, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, true,
    false, false, false, false, false, false, false, true, true, true, true,
    false, false, true, true, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, true, false,
    true, true, true, false, true, true, true, true, false, false, true, true,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, true, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, true, false, true, true, true,
    false, true, true, false, false, true, true, false, false, true, true, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, true, true, false, false, true, true, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, false, true, false, false, false, false, false, false, false, true,
    true, true, true, false, false, true, true, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, false,
    false, true, false, true, true, true, false, true, true, true, true, false,
    false, true, true, false, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, false, true,
    false, false, false, false, false, false, false, true, true, true, true,
    false, false, true, true, false, false, false, false, false, false, false,
    false, false, false, false, false, false, false, false, false, true, false,
    true, true, true, false, true, true, true, true, false, false, true, true,
    false, false };

  for (i17 = 0; i17 < 2; i17++) {
    iv4[i17] = (short)bwin->size[i17];
  }

  i17 = B->size[0] * B->size[1];
  B->size[0] = iv4[0];
  B->size[1] = iv4[1];
  emxEnsureCapacity_boolean_T(B, i17);
  for (i17 = 0; i17 < 2; i17++) {
    b_bwin[i17] = bwin->size[i17];
  }

  bwlookup_tbb_boolean(&bwin->data[0], b_bwin, 2.0, lut, 512.0, &B->data[0]);
}

/*
 * File trailer for bwlookup.c
 *
 * [EOF]
 */

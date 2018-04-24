/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: imregionalmax.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "imregionalmax.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"
#include "libmwimregionalmax.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_real32_T *varargin_1
 *                emxArray_boolean_T *BW
 * Return Type  : void
 */
void imregionalmax(const emxArray_real32_T *varargin_1, emxArray_boolean_T *BW)
{
  int i16;
  double imSizeT[2];
  boolean_T conn[9];
  double connSizeT[2];
  i16 = BW->size[0] * BW->size[1];
  BW->size[0] = varargin_1->size[0];
  BW->size[1] = varargin_1->size[1];
  emxEnsureCapacity_boolean_T(BW, i16);
  for (i16 = 0; i16 < 2; i16++) {
    imSizeT[i16] = varargin_1->size[i16];
  }

  for (i16 = 0; i16 < 9; i16++) {
    conn[i16] = true;
  }

  for (i16 = 0; i16 < 2; i16++) {
    connSizeT[i16] = 3.0;
  }

  imregionalmax_real32(&varargin_1->data[0], &BW->data[0], 2.0, imSizeT, conn,
                       2.0, connSizeT);
}

/*
 * File trailer for imregionalmax.c
 *
 * [EOF]
 */

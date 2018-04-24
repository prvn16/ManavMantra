/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: repmat.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "repmat.h"
#include "FaceTrackingKLTpackNGo_kernel_emxutil.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const float a_data[]
 *                double varargin_1
 *                emxArray_real32_T *b
 * Return Type  : void
 */
void b_repmat(const float a_data[], double varargin_1, emxArray_real32_T *b)
{
  int itilerow;
  itilerow = b->size[0];
  b->size[0] = (int)varargin_1;
  emxEnsureCapacity_real32_T2(b, itilerow);
  for (itilerow = 1; itilerow <= (int)varargin_1; itilerow++) {
    b->data[itilerow - 1] = a_data[0];
  }
}

/*
 * Arguments    : const double varargin_1[2]
 *                emxArray_real32_T *b
 * Return Type  : void
 */
void repmat(const double varargin_1[2], emxArray_real32_T *b)
{
  int i13;
  int loop_ub;
  i13 = b->size[0] * b->size[1];
  b->size[0] = (short)(int)varargin_1[0];
  b->size[1] = (short)(int)varargin_1[1];
  emxEnsureCapacity_real32_T(b, i13);
  loop_ub = (short)(int)varargin_1[0] * (short)(int)varargin_1[1];
  for (i13 = 0; i13 < loop_ub; i13++) {
    b->data[i13] = 0.0F;
  }
}

/*
 * File trailer for repmat.c
 *
 * [EOF]
 */

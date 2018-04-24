/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: repmat.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "repmat.h"
#include "faceTrackingARMKernel_emxutil.h"

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
  b->size[0] = (unsigned short)(int)varargin_1;
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
  int i18;
  int loop_ub;
  i18 = b->size[0] * b->size[1];
  b->size[0] = (unsigned char)(int)varargin_1[0];
  b->size[1] = (unsigned char)(int)varargin_1[1];
  emxEnsureCapacity_real32_T(b, i18);
  loop_ub = (unsigned char)(int)varargin_1[0] * (unsigned char)(int)varargin_1[1];
  for (i18 = 0; i18 < loop_ub; i18++) {
    b->data[i18] = 0.0F;
  }
}

/*
 * File trailer for repmat.c
 *
 * [EOF]
 */

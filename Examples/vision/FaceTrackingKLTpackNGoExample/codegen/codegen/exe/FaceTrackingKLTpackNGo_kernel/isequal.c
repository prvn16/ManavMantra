/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: isequal.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 10:56:07
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "FaceTrackingKLTpackNGo_kernel.h"
#include "isequal.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */

/*
 * Arguments    : const emxArray_boolean_T *varargin_1
 *                const emxArray_boolean_T *varargin_2
 * Return Type  : boolean_T
 */
boolean_T isequal(const emxArray_boolean_T *varargin_1, const emxArray_boolean_T
                  *varargin_2)
{
  boolean_T p;
  boolean_T b_p;
  int k;
  boolean_T exitg1;
  p = false;
  b_p = false;
  if ((varargin_1->size[0] != varargin_2->size[0]) || (varargin_1->size[1] !=
       varargin_2->size[1])) {
  } else {
    b_p = true;
  }

  if (b_p) {
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k <= varargin_2->size[0] * varargin_2->size[1] - 1)) {
      if (varargin_1->data[k] != varargin_2->data[k]) {
        b_p = false;
        exitg1 = true;
      } else {
        k++;
      }
    }
  }

  if (b_p) {
    p = true;
  }

  return p;
}

/*
 * File trailer for isequal.c
 *
 * [EOF]
 */

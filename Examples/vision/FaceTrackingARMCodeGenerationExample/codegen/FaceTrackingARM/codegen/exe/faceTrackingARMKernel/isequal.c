/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 * File: isequal.c
 *
 * MATLAB Coder version            : 4.0
 * C/C++ source code generated on  : 18-Apr-2018 06:23:17
 */

/* Include Files */
#include "rt_nonfinite.h"
#include "faceTrackingARMKernel.h"
#include "isequal.h"

/* Function Definitions */

/*
 * Arguments    : const boolean_T varargin_1_data[]
 *                const int varargin_1_size[2]
 *                const boolean_T varargin_2_data[]
 *                const int varargin_2_size[2]
 * Return Type  : boolean_T
 */
boolean_T isequal(const boolean_T varargin_1_data[], const int varargin_1_size[2],
                  const boolean_T varargin_2_data[], const int varargin_2_size[2])
{
  boolean_T p;
  boolean_T b_p;
  int k;
  boolean_T exitg1;
  p = false;
  b_p = false;
  if ((varargin_1_size[0] != varargin_2_size[0]) || (varargin_1_size[1] !=
       varargin_2_size[1])) {
  } else {
    b_p = true;
  }

  if (b_p) {
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k <= varargin_2_size[0] * varargin_2_size[1] - 1)) {
      if (varargin_1_data[k] != varargin_2_data[k]) {
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

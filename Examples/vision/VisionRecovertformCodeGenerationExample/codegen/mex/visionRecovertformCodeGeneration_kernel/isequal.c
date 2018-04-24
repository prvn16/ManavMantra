/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * isequal.c
 *
 * Code generation for function 'isequal'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "isequal.h"

/* Function Definitions */
boolean_T isequal(const real32_T varargin_1_data[], const int32_T
                  varargin_1_size[1], const real_T varargin_2[3])
{
  boolean_T p;
  boolean_T b_p;
  int32_T k;
  boolean_T exitg1;
  p = false;
  b_p = false;
  if (varargin_1_size[0] == 3) {
    b_p = true;
  }

  if (b_p && (!(varargin_1_size[0] == 0))) {
    k = 0;
    exitg1 = false;
    while ((!exitg1) && (k < 3)) {
      if (!(varargin_1_data[k] == varargin_2[k])) {
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

/* End of code generation (isequal.c) */

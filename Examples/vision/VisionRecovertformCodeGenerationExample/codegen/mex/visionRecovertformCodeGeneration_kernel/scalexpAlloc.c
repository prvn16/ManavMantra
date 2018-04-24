/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * scalexpAlloc.c
 *
 * Code generation for function 'scalexpAlloc'
 *
 */

/* Include files */
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "scalexpAlloc.h"

/* Function Definitions */
boolean_T b_dimagree(const emxArray_real32_T *z, const emxArray_real32_T
                     *varargin_1)
{
  boolean_T p;
  boolean_T b_p;
  int32_T k;
  boolean_T exitg1;
  p = true;
  b_p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k + 1 < 3)) {
    if (z->size[k] != varargin_1->size[k]) {
      b_p = false;
      exitg1 = true;
    } else {
      k++;
    }
  }

  if (!b_p) {
    p = false;
  }

  return p;
}

boolean_T c_dimagree(const emxArray_real32_T *z, const emxArray_real32_T
                     *varargin_1, const emxArray_real32_T *varargin_2)
{
  boolean_T p;
  boolean_T b_p;
  int32_T k;
  boolean_T exitg1;
  int32_T i21;
  int32_T i22;
  p = true;
  b_p = true;
  k = 1;
  exitg1 = false;
  while ((!exitg1) && (k < 3)) {
    if (k <= 1) {
      i21 = z->size[0];
      i22 = varargin_1->size[0];
    } else {
      i21 = 1;
      i22 = 1;
    }

    if (i21 != i22) {
      b_p = false;
      exitg1 = true;
    } else {
      k++;
    }
  }

  if (b_p) {
    b_p = true;
    k = 1;
    exitg1 = false;
    while ((!exitg1) && (k < 3)) {
      if (k <= 1) {
        i21 = z->size[0];
        i22 = varargin_2->size[0];
      } else {
        i21 = 1;
        i22 = 1;
      }

      if (i21 != i22) {
        b_p = false;
        exitg1 = true;
      } else {
        k++;
      }
    }

    if (b_p) {
    } else {
      p = false;
    }
  } else {
    p = false;
  }

  return p;
}

boolean_T dimagree(const emxArray_real32_T *z, const emxArray_real32_T
                   *varargin_1)
{
  boolean_T p;
  boolean_T b_p;
  int32_T k;
  boolean_T exitg1;
  p = true;
  b_p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k + 1 < 3)) {
    if (z->size[k] != varargin_1->size[k]) {
      b_p = false;
      exitg1 = true;
    } else {
      k++;
    }
  }

  if (!b_p) {
    p = false;
  }

  return p;
}

/* End of code generation (scalexpAlloc.c) */

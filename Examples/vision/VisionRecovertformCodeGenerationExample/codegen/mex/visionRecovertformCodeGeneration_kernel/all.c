/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * all.c
 *
 * Code generation for function 'all'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "all.h"

/* Function Definitions */
boolean_T all(const emxArray_real32_T *a)
{
  boolean_T p;
  int32_T i6;
  int32_T k;
  boolean_T exitg1;
  p = true;
  i6 = a->size[0] * a->size[1];
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= i6 - 1)) {
    if ((!muSingleScalarIsInf(a->data[k])) && (!muSingleScalarIsNaN(a->data[k])))
    {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  return p;
}

boolean_T b_all(const emxArray_real32_T *a)
{
  boolean_T p;
  int32_T k;
  boolean_T exitg1;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k <= a->size[0] - 1)) {
    if ((!muSingleScalarIsInf(a->data[k])) && (!muSingleScalarIsNaN(a->data[k])))
    {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  return p;
}

/* End of code generation (all.c) */

/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * validatesize.c
 *
 * Code generation for function 'validatesize'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "validatesize.h"

/* Function Definitions */
boolean_T size_check(const emxArray_real32_T *a)
{
  boolean_T p;
  static real_T dv1[2] = { 0.0, 2.0 };

  int32_T k;
  boolean_T exitg1;
  dv1[0U] = rtNaN;
  p = true;
  k = 0;
  exitg1 = false;
  while ((!exitg1) && (k < 2)) {
    if (muDoubleScalarIsNaN(dv1[k]) || (dv1[k] == a->size[k])) {
      k++;
    } else {
      p = false;
      exitg1 = true;
    }
  }

  return p;
}

/* End of code generation (validatesize.c) */

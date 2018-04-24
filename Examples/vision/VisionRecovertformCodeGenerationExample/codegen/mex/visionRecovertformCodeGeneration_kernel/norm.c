/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * norm.c
 *
 * Code generation for function 'norm'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "norm.h"

/* Function Definitions */
real32_T b_norm(const real32_T x[9])
{
  real32_T y;
  int32_T j;
  boolean_T exitg1;
  real32_T s;
  int32_T i;
  y = 0.0F;
  j = 0;
  exitg1 = false;
  while ((!exitg1) && (j < 3)) {
    s = 0.0F;
    for (i = 0; i < 3; i++) {
      s += muSingleScalarAbs(x[i + 3 * j]);
    }

    if (muSingleScalarIsNaN(s)) {
      y = ((real32_T)rtNaN);
      exitg1 = true;
    } else {
      if (s > y) {
        y = s;
      }

      j++;
    }
  }

  return y;
}

real32_T norm(const real32_T x_data[], const int32_T x_size[2])
{
  real32_T y;
  int32_T j;
  boolean_T exitg1;
  int32_T i;
  real32_T s;
  if (x_size[0] == 0) {
    y = 0.0F;
  } else if ((x_size[0] == 1) || (x_size[1] == 1)) {
    y = 0.0F;
    j = x_size[0] * x_size[1];
    for (i = 0; i < j; i++) {
      y += muSingleScalarAbs(x_data[i]);
    }
  } else {
    y = 0.0F;
    j = 0;
    exitg1 = false;
    while ((!exitg1) && (j <= x_size[1] - 1)) {
      s = 0.0F;
      for (i = 0; i < x_size[0]; i++) {
        s += muSingleScalarAbs(x_data[i + x_size[0] * j]);
      }

      if (muSingleScalarIsNaN(s)) {
        y = ((real32_T)rtNaN);
        exitg1 = true;
      } else {
        if (s > y) {
          y = s;
        }

        j++;
      }
    }
  }

  return y;
}

/* End of code generation (norm.c) */

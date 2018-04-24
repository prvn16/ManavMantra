/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * mod.c
 *
 * Code generation for function 'mod'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "visionRecovertformCodeGeneration_kernel.h"
#include "mod.h"

/* Function Definitions */
real_T b_mod(real_T x)
{
  real_T r;
  if ((!muDoubleScalarIsInf(x)) && (!muDoubleScalarIsNaN(x))) {
    if (x == 0.0) {
      r = 0.0;
    } else {
      r = muDoubleScalarRem(x, 2.0);
      if (r == 0.0) {
        r = 0.0;
      } else {
        if (x < 0.0) {
          r += 2.0;
        }
      }
    }
  } else {
    r = rtNaN;
  }

  return r;
}

/* End of code generation (mod.c) */

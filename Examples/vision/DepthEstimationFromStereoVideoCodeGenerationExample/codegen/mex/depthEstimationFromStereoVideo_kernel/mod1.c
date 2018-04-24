/*
 * Academic License - for use in teaching, academic research, and meeting
 * course requirements at degree granting institutions only.  Not for
 * government, commercial, or other organizational use.
 *
 * mod1.c
 *
 * Code generation for function 'mod1'
 *
 */

/* Include files */
#include "mwmathutil.h"
#include "rt_nonfinite.h"
#include "depthEstimationFromStereoVideo_kernel.h"
#include "mod1.h"
#include "matlabCodegenHandle.h"
#include "DAHostLib_rtw.h"
#include "HostLib_MMFile.h"
#include "HostLib_Multimedia.h"
#include "HostLib_Video.h"

/* Function Definitions */
real_T c_mod(real_T x, real_T y)
{
  real_T r;
  if ((!muDoubleScalarIsInf(x)) && (!muDoubleScalarIsNaN(x)) &&
      ((!muDoubleScalarIsInf(y)) && (!muDoubleScalarIsNaN(y)))) {
    if (x == 0.0) {
      r = 0.0;
    } else {
      r = muDoubleScalarRem(x, y);
      if (r == 0.0) {
        r = 0.0;
      } else {
        if (x < 0.0) {
          r += y;
        }
      }
    }
  } else {
    r = rtNaN;
  }

  return r;
}

/* End of code generation (mod1.c) */
